#!/bin/bash
#
# mbcheck — a pre-purchase inspection for second-hand Apple-silicon MacBooks.
#
#   Run it at the shop, on the machine you are thinking of buying:
#
#     bash <(curl -fsSL https://raw.githubusercontent.com/mingrath/mbcheck/main/check.sh)
#
#   NOT `curl ... | bash` — that steals stdin and the prompts stop working.
#
# It reads every software fact for free, runs a load test behind the physical
# checks, prompts you for the things no script can do, and prints one report.
#
# It takes no sudo, installs nothing, writes nothing except the report in your
# home directory, and makes no network call unless you pass --stolen-check.
#
# Scope: MacBook Air and MacBook Pro, M1-M5. Not Intel, not desktops.
#
# ---------------------------------------------------------------------------
# Why every tool below is called by absolute path
# ---------------------------------------------------------------------------
# Demonstrated on a MacBook Air (Mac16,13, macOS 26.5.2) on 2026-08-04: a
# three-line shell script placed earlier on PATH, or an exported shell
# function, will fake the ENTIRE hardware sheet — model, chip, RAM, serial,
# and "Activation Lock Status: Disabled". It needs no privileges at all.
#
# Calling the same tools by absolute path defeats both, because the real
# binaries live on the sealed system volume: an unprivileged overwrite of
# /usr/sbin/system_profiler is refused ("Operation not permitted"), and
# DYLD_INSERT_LIBRARIES is stripped from platform binaries. So the readings
# below are only as good as (a) these absolute paths and (b) SIP being on —
# which is why SIP is checked first and reported as a precondition.
# ---------------------------------------------------------------------------

set -u

PATH=/usr/bin:/bin:/usr/sbin:/sbin
export PATH
for _f in system_profiler ioreg csrutil profiles sysctl pmset sw_vers \
          notifyutil shasum fdesetup diskutil defaults curl open date; do
    unset -f "$_f" 2>/dev/null
done
unset _f

SP=/usr/sbin/system_profiler
IOREG=/usr/sbin/ioreg
CSRUTIL=/usr/bin/csrutil
PROFILES=/usr/bin/profiles
NOTIFYUTIL=/usr/bin/notifyutil
SYSCTL=/usr/sbin/sysctl
PMSET=/usr/bin/pmset
SWVERS=/usr/bin/sw_vers
SHASUM=/usr/bin/shasum
FDESETUP=/usr/bin/fdesetup
DEFAULTS=/usr/bin/defaults
OPEN=/usr/bin/open
DATE=/bin/date
CURL=/usr/bin/curl

VERSION="1.0"
PRICES_AS_OF="2026-08-04"

# Testing hooks. Neither is needed at a shop.
LOAD_SECONDS="${MBCHECK_LOAD_SECONDS:-180}"
LOAD_CAP=300
STOLEN_CHECK=no
BATTERY_FLOOR=20

for arg in "$@"; do
    case "$arg" in
        --stolen-check) STOLEN_CHECK=yes ;;
        --version) echo "mbcheck $VERSION"; exit 0 ;;
        -h|--help)
            /bin/cat <<'USAGE'
mbcheck — pre-purchase inspection for second-hand Apple-silicon MacBooks

  bash <(curl -fsSL https://raw.githubusercontent.com/mingrath/mbcheck/main/check.sh)

  --stolen-check   Also query stolenregister.com with this machine's serial.
                   OFF by default: it sends a stranger's serial to a third
                   party from the stranger's own machine. Prefer running the
                   printed URL on your own phone instead.
  --version        Print version and exit.
USAGE
            exit 0 ;;
    esac
done

# ---------------------------------------------------------------------------
# Findings
#
# Grades come from the severity model: no check aborts the visit, the script
# always finishes, and the buyer decides at the end from the report.
#
#   STOP   unfixable at any price, or a fault that spreads
#   BAHT   renegotiate, with a named Thai repair price
#   NOTE   free to live with
#   OK     checked, nothing found
#   UNSET  could not look — deliberately NOT the same as "nothing found"
# ---------------------------------------------------------------------------

# Parallel arrays, not delimited records: findings carry multi-line detail and
# any field-splitting tool would tear them apart.
F_GRADE=()
F_TITLE=()
F_DETAIL=()
F_PRICE=()
N_FINDINGS=0
TALLY=0
REPAIR_SEEN=no

finding() {  # grade  title  detail  [baht_low]  [baht_text]
    F_GRADE[$N_FINDINGS]="$1"
    F_TITLE[$N_FINDINGS]="$2"
    F_DETAIL[$N_FINDINGS]="$3"
    F_PRICE[$N_FINDINGS]="${5:-}"
    N_FINDINGS=$(( N_FINDINGS + 1 ))
    case "${4:-0}" in
        ''|*[!0-9]*) : ;;
        *) [ "${4:-0}" -gt 0 ] && TALLY=$(( TALLY + ${4} )) ;;
    esac
}

count_grade() {
    local g="$1" n=0 i=0
    while [ "$i" -lt "$N_FINDINGS" ]; do
        [ "${F_GRADE[$i]}" = "$g" ] && n=$(( n + 1 ))
        i=$(( i + 1 ))
    done
    echo "$n"
}

icon() {
    case "$1" in
        STOP)  printf '\xf0\x9f\x9b\x91' ;;
        BAHT)  printf '\xf0\x9f\x92\xb0' ;;
        NOTE)  printf '\xf0\x9f\x93\x9d' ;;
        OK)    printf 'OK' ;;
        UNSET) printf '??' ;;
    esac
}

baht() {  # 9490 -> 9,490 (BSD sed has no \B, so do it by hand)
    printf '%s' "$1" | /usr/bin/rev | /usr/bin/sed 's/[0-9]\{3\}/&,/g' \
        | /usr/bin/rev | /usr/bin/sed 's/^,//'
}

say()  { printf '%s\n' "$*"; }
rule() { printf '%s\n' "------------------------------------------------------------"; }
head2(){ printf '\n%s\n' "$*"; rule; }

# ---------------------------------------------------------------------------
# Load test workers — tracked by PID and killed by PID.
#
# `pkill -x shasum` cannot work: shasum is a Perl script, so the process name
# is /usr/bin/perl. And `killall yes` was observed reaping an unrelated
# session's processes. On a stranger's machine, neither is acceptable.
# ---------------------------------------------------------------------------

WORKER_PIDS=()
SAMPLER_PID=""
SLEEP_PID=""
TMPDIR_MB=""

stop_workers() {
    local p
    for p in "${WORKER_PIDS[@]:-}"; do
        [ -n "$p" ] && kill "$p" 2>/dev/null
    done
    WORKER_PIDS=()
    if [ -n "$SAMPLER_PID" ]; then
        # The sampler is a subshell whose own `sleep` child would outlive it.
        /usr/bin/pgrep -P "$SAMPLER_PID" 2>/dev/null | while read -r c; do
            kill "$c" 2>/dev/null
        done
        kill "$SAMPLER_PID" 2>/dev/null
        SAMPLER_PID=""
    fi
}

cleanup() {
    stop_workers
    [ -n "$SLEEP_PID" ] && kill "$SLEEP_PID" 2>/dev/null
    [ -n "$TMPDIR_MB" ] && [ -d "$TMPDIR_MB" ] && /bin/rm -rf "$TMPDIR_MB"
}

on_signal() {
    printf '\n\n  Interrupted. Stopping the load and leaving the machine as found.\n'
    cleanup
    exit 130
}

# HUP matters as much as INT here: closing the Terminal window is exactly how
# a buyer walks away mid-run, and N pinned cores must not be what they leave
# behind on a stranger's Mac.
trap cleanup EXIT
trap on_signal INT TERM HUP

# Long waits are backgrounded and `wait`ed on. A foreground `sleep` would make
# bash defer the signal handler until the sleep finished, which is the whole
# window in which an interrupt needs to work.
nap() {
    sleep "$1" &
    SLEEP_PID=$!
    wait "$SLEEP_PID" 2>/dev/null
    SLEEP_PID=""
}

TMPDIR_MB="$(/usr/bin/mktemp -d /tmp/mbcheck.XXXXXX)"
SAMPLE_FILE="$TMPDIR_MB/thermal"
: > "$SAMPLE_FILE"

thermal_level() {
    local v
    v="$($NOTIFYUTIL -g com.apple.system.thermalpressurelevel 2>/dev/null | /usr/bin/awk '{print $2}')"
    case "$v" in ''|*[!0-9]*) echo "-1" ;; *) echo "$v" ;; esac
}

# ---------------------------------------------------------------------------
# Prompts. Every hand prompt takes y / n / ?.
#
# `?` is not a forced binary on purpose. A buyer who is not sure whether a
# trackpad corner rocked will guess if forced, and a guess manufactures a
# finding. `?` records "not established" and prints as such, so the buyer can
# see what they did not settle rather than believing they settled it.
# ---------------------------------------------------------------------------

INTERACTIVE=yes
[ -t 0 ] || INTERACTIVE=no

ask() {  # question -> sets REPLY_YN to y/n/?
    local q="$1" a=""
    REPLY_YN="?"
    if [ "$INTERACTIVE" = no ] && [ ! -p /dev/stdin ] && [ ! -f /dev/stdin ]; then
        return 0
    fi
    while :; do
        printf '%s [y/n/? = not sure] ' "$q"
        if ! read -r a; then echo; REPLY_YN="?"; return 0; fi
        a="$(printf '%s' "$a" | /usr/bin/tr '[:upper:]' '[:lower:]')"
        case "$a" in
            y|yes) REPLY_YN=y; return 0 ;;
            n|no)  REPLY_YN=n; return 0 ;;
            ''|\?|not|"not sure") REPLY_YN="?"; return 0 ;;
            *) say "  Please answer y, n, or ? if you are not sure." ;;
        esac
    done
}

pause_for() {  # message
    local a
    printf '%s [press return when done] ' "$1"
    read -r a 2>/dev/null || echo
}

# ===========================================================================
# 0. Preconditions — is anything below trustworthy at all?
# ===========================================================================

say ""
say "  mbcheck $VERSION — pre-purchase inspection"
say "  Read-only. No sudo. Nothing is installed. Nothing is changed."
say ""
say "  This run will take roughly 12-15 minutes. Nothing you find stops the"
say "  run: it grades everything and you decide at the end."
say ""

head2 "Checking that the machine can be trusted to tell the truth"

SIP_RAW="$($CSRUTIL status 2>/dev/null)"
BOOT_POLICY="$($SP SPiBridgeDataType 2>/dev/null)"
SECURE_BOOT="$(printf '%s' "$BOOT_POLICY" | /usr/bin/awk -F': ' '/Secure Boot:/{print $2; exit}')"
SIP_STATE="$(printf '%s' "$BOOT_POLICY" | /usr/bin/awk -F': ' '/System Integrity Protection:/{print $2; exit}')"
SSV_STATE="$(printf '%s' "$BOOT_POLICY" | /usr/bin/awk -F': ' '/Signed System Volume:/{print $2; exit}')"
KEXT_ALL="$(printf '%s' "$BOOT_POLICY" | /usr/bin/awk -F': ' '/Allow All Kernel Extensions:/{print $2; exit}')"

TRUSTWORTHY=yes
case "$SIP_RAW" in
    *enabled*) say "  System Integrity Protection ........ enabled" ;;
    *)         say "  System Integrity Protection ........ NOT ENABLED"; TRUSTWORTHY=no ;;
esac
say "  Secure Boot ........................ ${SECURE_BOOT:-unreadable}"
say "  Signed System Volume ............... ${SSV_STATE:-unreadable}"

if [ "$TRUSTWORTHY" = yes ] && [ -z "${SECURE_BOOT:-}" ]; then
    # SPiBridgeDataType is missing or empty. SIP itself reads enabled, so do
    # NOT treat this as a downgrade — an unreadable field is not a bad field.
    finding UNSET "Boot policy could not be read" \
"csrutil reports SIP enabled, but SPiBridgeDataType returned nothing, so Secure
Boot and Signed System Volume could not be confirmed independently. Not a
finding — just a gap in what this run could establish."
elif [ "$TRUSTWORTHY" = no ] || [ "${SECURE_BOOT:-}" != "Full Security" ]; then
    finding STOP "Boot security has been deliberately downgraded" \
"Secure Boot reads '${SECURE_BOOT:-unreadable}' and SIP reads '$(printf '%s' "$SIP_RAW" | /usr/bin/sed 's/.*status: //')'.
Turning SIP off on Apple silicon REQUIRES dropping to Permissive Security, which
cannot be done by accident and cannot be reached from Startup Security Utility -
only from the command line, deliberately, by someone with the admin password.

Three things follow, and they compound:
  1. Activation Lock stops applying below Full Security, so a 'Disabled'
     reading downstream may mean the protection was removed, not signed out of.
  2. The Parts & Service pane is hidden entirely when SIP is off, so the
     repair-history check below cannot run - and that may be the point.
  3. Every other software reading in this report is now only as good as the
     word of whoever turned it off.
A buyer cannot tell a hobbyist's kext machine from a cover-up, and does not
have to: the fix is free (an erase resets it to Full Security), so ask the
seller to erase and re-run this script."
fi
if [ "${KEXT_ALL:-No}" = "Yes" ]; then
    finding NOTE "Third-party kernel extensions are permitted" \
"'Allow All Kernel Extensions: Yes'. Someone configured this machine to load
unsigned kernel code. Free to reverse with an erase; worth asking why."
fi

# ===========================================================================
# 1. Identity — what is this machine, actually?
# ===========================================================================

HW="$($SP -detailLevel basic SPHardwareDataType 2>/dev/null)"
PW="$($SP -detailLevel basic SPPowerDataType 2>/dev/null)"

# Literal substring match, never a regex: the key "Serial Number (system):"
# contains parentheses, and as a dynamic awk regex those silently match
# nothing — which would print an empty serial rather than an error.
field() {  # haystack  literal-key
    printf '%s' "$1" | /usr/bin/awk -v k="$2" \
        'index($0, k) { print substr($0, index($0, k) + length(k)); exit }' \
        | /usr/bin/sed -e 's/^ *//' -e 's/ *$//'
}
hwf() { field "$HW" "$1"; }

MODEL_NAME="$(hwf 'Model Name:')"
MODEL_ID="$(hwf 'Model Identifier:')"
MODEL_NUMBER="$(hwf 'Model Number:')"
CHIP="$(hwf 'Chip:')"
CORES="$(hwf 'Total Number of Cores:')"
MEMORY="$(hwf 'Memory:')"
SERIAL="$(hwf 'Serial Number (system):')"
ACTIVATION="$(hwf 'Activation Lock Status:')"

PRODUCT_NAME="$($IOREG -l -p IODeviceTree -n / 2>/dev/null \
    | /usr/bin/awk -F'"' '/"product-name"/{print $4; exit}')"
[ -z "$PRODUCT_NAME" ] && PRODUCT_NAME="$MODEL_NAME"

REGION_INFO="$($IOREG -l -p IODeviceTree -n / 2>/dev/null \
    | /usr/bin/awk '/"region-info"/{print}' \
    | /usr/bin/sed -e 's/.*<//' -e 's/>.*//' \
    | /usr/bin/xxd -r -p 2>/dev/null | /usr/bin/tr -d '\000')"
REG_MODEL="$($IOREG -l -p IODeviceTree -n / 2>/dev/null \
    | /usr/bin/awk '/"regulatory-model-number"/{print}' \
    | /usr/bin/sed -e 's/.*<//' -e 's/>.*//' \
    | /usr/bin/xxd -r -p 2>/dev/null | /usr/bin/tr -d '\000')"
KBD_LANG="$($IOREG -l 2>/dev/null | /usr/bin/awk -F'"' '/"KeyboardLanguage"/{print $4; exit}')"

OS_VER="$($SWVERS -productVersion 2>/dev/null)"
OS_MAJOR="${OS_VER%%.*}"
case "$OS_MAJOR" in ''|*[!0-9]*) OS_MAJOR=0 ;; esac

IS_PRO=no
case "$MODEL_NAME" in *Pro*) IS_PRO=yes ;; esac

head2 "This machine"
say "  $PRODUCT_NAME"
say "  $CHIP · $CORES · $MEMORY"
say "  Serial ............ ${SERIAL:-unreadable}"
say "  Model number ...... ${MODEL_NUMBER:-unreadable}   Regulatory ... ${REG_MODEL:-unreadable}"
say "  Sold in region .... ${REGION_INFO:-unreadable}"
say "  macOS ............. ${OS_VER:-unreadable}"
say ""
say "  Check these against the listing yourself. RAM and storage are soldered"
say "  on M1-M5, so a '16GB' machine cannot have been quietly downgraded -"
say "  but the listing can still be describing a different machine."

# Region cross-check: the Model Number suffix carries the sales region, and
# the top case carries its own keyboard language. A mismatch is on-device
# evidence of a cross-region top-case swap.
MN_SUFFIX=""
case "$MODEL_NUMBER" in
    *TH/A) MN_SUFFIX=TH ;; *LL/A) MN_SUFFIX=US ;; *ZP/A) MN_SUFFIX=HK ;;
    *X/A)  MN_SUFFIX=AU ;; *B/A)  MN_SUFFIX=GB ;; *J/A) MN_SUFFIX=JP ;;
esac
if [ -n "$REGION_INFO" ] && [ -n "$MN_SUFFIX" ]; then
    case "$REGION_INFO" in
        "${MN_SUFFIX}"*) : ;;
        *) finding NOTE "Sales region and model number disagree" \
"Device tree region-info reads '$REGION_INFO' but the model number is
'$MODEL_NUMBER'. Worth asking about; not on its own a fault." ;;
    esac
fi
if [ -n "$KBD_LANG" ] && [ "$MN_SUFFIX" = TH ] && [ "$KBD_LANG" != "Thai" ]; then
    finding BAHT "Keyboard region does not match the machine's sales region" \
"The top case reports KeyboardLanguage '$KBD_LANG' on a Thai-market machine
($MODEL_NUMBER). The top case is not tracked by Parts & Service, so this is one
of the few on-device tells that it was replaced - possibly with a donor part
from another region." 6190 "top case from ฿6,190 + ฿1,605 fitting (as of $PRICES_AS_OF)"
fi

if [ -n "$REGION_INFO" ] && [ "${REGION_INFO#TH}" = "$REGION_INFO" ]; then
    finding NOTE "Not a Thai-market machine (เครื่องหิ้ว)" \
"region-info reads '$REGION_INFO'. Apple's contract reserves the right to
restrict Mac service to the country of sale, and AppleCare+ bought in Thailand
is Thailand-only. This is free to live with, but it is the fact Thai listings
advertise as ศูนย์ไทย - and its absence is the signal, because nobody labels
their own machine a grey import."
fi

# ===========================================================================
# 2. Software locks — the checks that protect the whole purchase price
# ===========================================================================

head2 "Software locks"

ENROLL="$($PROFILES status -type enrollment 2>/dev/null)"
DEP_LINE="$(printf '%s' "$ENROLL" | /usr/bin/awk -F': ' '/Enrolled via DEP/{print $2; exit}')"
MDM_LINE="$(printf '%s' "$ENROLL" | /usr/bin/awk -F': ' '/MDM enrollment/{print $2; exit}')"
CONFIG_PROFILES="$($SP SPConfigurationProfileDataType 2>/dev/null)"

say "  Enrolled via DEP .................. ${DEP_LINE:-unreadable}"
say "  MDM enrollment .................... ${MDM_LINE:-unreadable}"
say "  Activation Lock Status ............ ${ACTIVATION:-unreadable}"

case "${DEP_LINE:-}${MDM_LINE:-}" in
    *Yes*)
        finding STOP "This Mac is enrolled in device management" \
"profiles reports: Enrolled via DEP: ${DEP_LINE:-?} / MDM enrollment: ${MDM_LINE:-?}.
Only the enrolling organisation can lift this. Apple runs no proof-of-purchase
escalation for it - Apple Support is not on Apple's own list of who can release
a device. Erasing does not help: the record is server-side against the serial,
so the Mac re-enrols at the next setup. In Thailand this is as often an
instalment or pawn-shop lock (ติดผ่อน) as a corporate one."
        ;;
esac
if [ -n "$CONFIG_PROFILES" ]; then
    finding STOP "Configuration profiles are installed" \
"SPConfigurationProfileDataType is not empty. On a machine being sold as
personal property, an installed management profile needs explaining."
fi

say ""
say "  IMPORTANT — what these two readings do NOT prove:"
say ""
say "  'Enrolled via DEP: No' means only that this Mac is not enrolled right"
say "  now, on this OS install. No command at any privilege level can ask"
say "  whether the serial sits in someone's Apple Business Manager. A serial"
say "  can be in ABM but unassigned today and assigned tomorrow, with one"
say "  click by an IT admin who never touches the machine. It detonates on"
say "  your first erase."
say ""
say "  'Activation Lock: Enabled' is the NORMAL reading on an honest machine."
say "  It reports whether Find My is on right now - which, before the seller"
say "  signs out, it should be. What matters is that it reads Disabled AFTER"
say "  they sign out in front of you. That is the last prompt in this run."

FDE="$($FDESETUP status 2>/dev/null)"
case "$FDE" in
    *"FileVault is On"*)
        finding NOTE "FileVault is on" \
"The seller must unlock or erase the machine for you. The data is theirs and
unrecoverable to you; the machine is fine. But a seller who cannot unlock their
own machine cannot demonstrate anything else either." ;;
esac

# ===========================================================================
# 3. Battery
# ===========================================================================

head2 "Battery"

pwf() { field "$PW" "$1"; }
CYCLES="$(pwf 'Cycle Count:')"
CONDITION="$(pwf 'Condition:')"
MAXCAP="$(pwf 'Maximum Capacity:')"
MAXCAP_N="$(printf '%s' "$MAXCAP" | /usr/bin/tr -dc '0-9')"
[ -z "$MAXCAP_N" ] && MAXCAP_N=-1

say "  Cycle count ....................... ${CYCLES:-unreadable}"
say "  Maximum capacity .................. ${MAXCAP:-unreadable}"
say "  Condition ......................... ${CONDITION:-unreadable}"

# Apple rates EVERY Apple-silicon MacBook at 1000 cycles. The widely repeated
# "over 300 cycles = renegotiate" is an Intel-era number with no Apple basis.
BATT_PRICE=8690
BATT_LABEL="MacBook Pro battery, Apple TH ฿8,690"
case "$PRODUCT_NAME" in
    *"MacBook Air"*13*|*"MacBook Air"*"13-inch"*)
        case "$CHIP" in
            *M4*|*M5*) BATT_PRICE=6290; BATT_LABEL="MacBook Air 13-inch M4/M5 battery, Apple TH ฿6,290" ;;
            *) BATT_PRICE=5590; BATT_LABEL="MacBook Air 13-inch M1-M3 battery, Apple TH ฿5,590" ;;
        esac ;;
    *"MacBook Air"*15*)
        BATT_PRICE=6990; BATT_LABEL="MacBook Air 15-inch battery, Apple TH ฿6,990" ;;
    *"MacBook Air"*)
        BATT_PRICE=5590; BATT_LABEL="MacBook Air battery, Apple TH from ฿5,590" ;;
    *"MacBook Pro"*14*)
        case "$CHIP" in
            *M5*) BATT_PRICE=7990; BATT_LABEL="MacBook Pro 14-inch M5 battery, Apple TH ฿7,990" ;;
            *) BATT_PRICE=8690; BATT_LABEL="MacBook Pro 14-inch battery, Apple TH ฿8,690" ;;
        esac ;;
esac

case "$CONDITION" in
    "Service Recommended")
        finding BAHT "Battery condition reads Service Recommended" \
"macOS has decided this battery needs replacing. Apple rates every
Apple-silicon MacBook at 1000 cycles and this one has ${CYCLES:-?}.
Note: in the Thai listing market a DISCLOSED battery replacement is an
advertised selling point that prices a machine up, not down - so this is a
price lever, not a reason to walk." "$BATT_PRICE" "$BATT_LABEL (as of $PRICES_AS_OF)" ;;
    "Normal")
        if [ "$MAXCAP_N" -ge 0 ] && [ "$MAXCAP_N" -lt 80 ]; then
            finding BAHT "Battery below 80% of original capacity" \
"Maximum capacity ${MAXCAP}, condition still reads Normal. Apple's design
target is 80% at 1000 cycles; this one is at ${CYCLES:-?} cycles." \
"$BATT_PRICE" "$BATT_LABEL (as of $PRICES_AS_OF)"
        elif [ "$MAXCAP_N" -ge 0 ] && [ "$MAXCAP_N" -lt 90 ]; then
            finding NOTE "Battery between 80% and 90% of original capacity" \
"Maximum capacity ${MAXCAP} at ${CYCLES:-?} cycles, condition Normal. Free to
live with. Worth knowing: AppleCare+ only replaces a battery once it falls
BELOW 80%, so coverage is worth nothing to a merely mediocre battery."
        fi ;;
    "") finding UNSET "Battery condition could not be read" \
"SPPowerDataType returned no Condition line." ;;
esac

# A cycle count wildly out of step with the machine's age is the one on-device
# hint that the battery was swapped - the part is invisible to Parts & Service.
if [ -n "$CYCLES" ] && [ "$CYCLES" -lt 30 ] 2>/dev/null; then
    finding NOTE "Very low cycle count — ask when the battery was replaced" \
"${CYCLES} cycles. On a second-hand machine that usually means a replaced
battery, which sets no flag anywhere: the battery is not a Parts & Service
tracked part on any MacBook. Not a fault, and in the Thai market a disclosed
replacement prices up - but get it said out loud."
fi

# ===========================================================================
# 4. History the machine still carries
# ===========================================================================

head2 "What the machine still remembers"

PANIC_DIR=/var/db/PanicReporter
PANIC_N="$(/bin/ls -1 "$PANIC_DIR" 2>/dev/null | /usr/bin/grep -c '\.panic$')"
case "$PANIC_N" in ''|*[!0-9]*) PANIC_N=0 ;; esac
if [ "$PANIC_N" -gt 0 ]; then
    finding STOP "The machine has kernel-panicked recently" \
"$PANIC_N panic report(s) in $PANIC_DIR. This directory lives on the data
volume, so an erase wipes it - which means these panics happened SINCE the last
erase, i.e. recently, on the machine as it stands."
else
    say "  Kernel panics since last erase .... none"
fi

ERASE_DATE="$(/usr/bin/grep -i 'obliterat' /var/log/install.log 2>/dev/null \
    | /usr/bin/tail -1 | /usr/bin/awk '{print $1, $2, $3}')"
if [ -n "$ERASE_DATE" ]; then
    say "  Last erase-all-content receipt .... $ERASE_DATE"
    say "    (/var/log/install.log is world-readable. You cannot read this"
    say "     machine's history, but you can read how far back any history"
    say "     could possibly reach. A recent erase before a sale is normal;"
    say "     one that contradicts the seller's story is a finding.)"
fi

# Name only what was actually matched. Listing every third-party install would
# flag ordinary software as if it were a finding.
INSTALL_HISTORY="$($SP SPInstallHistoryDataType 2>/dev/null)"
REMOTE_FOUND=""
for _app in TeamViewer AnyDesk RealVNC Splashtop LogMeIn "Chrome Remote Desktop" \
            GoToAssist ConnectWise "Zoho Assist" Supremo NoMachine Parsec; do
    case "$INSTALL_HISTORY" in
        *"$_app"*) REMOTE_FOUND="${REMOTE_FOUND}${REMOTE_FOUND:+, }$_app" ;;
    esac
done
unset _app
if [ -n "$REMOTE_FOUND" ]; then
    finding NOTE "Remote-access software has been installed" \
"Install history names: ${REMOTE_FOUND}.

Not a fault, and an erase removes it. But remote-access tooling on a machine
you are about to buy is worth one question, and it raises the value of watching
the erase actually happen at the end of this run."
fi

# ===========================================================================
# 5. Screen reads — the panes the script cannot read for you
#
# These cost your eyes for ~10-30 seconds each, not your hands, so they are
# budgeted by time (~2 min total) rather than counted against the 8 hand
# prompts. The ORDER below is forced, not chosen.
# ===========================================================================

head2 "Three panes to read (about 2 minutes)"

say "  Ask the seller these two questions BEFORE anything opens. Without a"
say "  claim on record there is nothing for the pane to contradict, and a"
say "  clean pane produces no finding at all."
say ""
say "    มี AppleCare+ เหลืออยู่ไหมครับ แล้วโอนให้ผมได้ไหมครับ"
say "      (Is there AppleCare+ left, and can it transfer to me?)"
say ""
say "    เครื่องเคยซ่อมหรือเปลี่ยนอะไหล่อะไรบ้างไหมครับ"
say "      (Has it ever been repaired, or had any part replaced?)"
say ""

CLAIMED_COVERAGE="?"
CLAIMED_REPAIR="?"
ask "  Did the seller claim this machine still has AppleCare+ or warranty?"
CLAIMED_COVERAGE="$REPLY_YN"
ask "  Did the seller say it has NEVER been repaired or had a part replaced?"
CLAIMED_REPAIR="$REPLY_YN"

# --- Pane 1: coverage. MUST be read before the iCloud sign-out, because the
# --- pane goes blank the moment the seller signs out.
if [ "$CLAIMED_COVERAGE" = y ]; then
    say ""
    say "  Opening System Settings > AppleCare & Warranty."
    say "  Read the row for THIS device. Do this now, while the seller is"
    say "  still signed in — the pane goes blank the moment they sign out."
    $OPEN "x-apple.systempreferences:com.apple.Coverage-Settings.extension" 2>/dev/null
    ask "  Does the pane confirm active coverage on this device?"
    case "$REPLY_YN" in
        n) finding NOTE "Seller claimed coverage; the machine does not show it" \
"This is a claim about the SELLER, not about the Mac, and it is often innocent:
the plan lapsed unnoticed, coverage sits on a different Apple Account because
they bought it used themselves, it was bought on a business account, macOS is
older than the pane (macOS 14+), or the shop has no network.

So on its own this is a note. It becomes a walk-away only if a SECOND
independent claim also turns out to be untrue - because the worst risk on this
whole list (an ABM/DEP registration) is undetectable by any command at any
privilege level, and there the seller's word is your only defence. A seller
caught out twice has spent that word.

Coverage itself is worth ฿0 to you unless they produce the original
ใบกำกับภาษี: a Thai AppleCare+ plan is Thailand-only, transfers exactly once,
needs that invoice plus written notice to Apple South Asia - and any prior
independent repair voids it outright." ;;
        y) finding NOTE "Coverage is live, and here is what it is actually worth" \
"Live coverage is not valid coverage. A prior independent repair voids
AppleCare+ outright, and Parts & Service is blind to battery, display and top
case swaps - so the machine can show coverage in the pane and have none in
fact, with nothing on the machine able to tell you which.

Worth ฿0 unless they hand you the original ใบกำกับภาษี. Transfers once,
Thailand only, needs written notice to Apple South Asia.

And it does not reduce the repair total below. Battery service is ฿0 under
AppleCare+ ONLY once the battery is already below 80% of original capacity -
verified against Apple's AppleCare+ terms, which set the threshold at 'less
than eighty percent (80%)'. Above that Apple declines the job.

One practical rule that follows: do NOT let the seller 'fix it first'. Their
independent repair voids the coverage you are paying for." ;;
    esac
fi

# --- Pane 2: Parts & Service.
say ""
if [ "$OS_MAJOR" -ge 26 ]; then
    say "  Opening System Settings > General > About."
    say "  Scroll to Parts & Service History and read EVERY row."
    $OPEN "x-apple.systempreferences:com.apple.SystemSettings.extension?About" 2>/dev/null
    say ""
    say "    Genuine        clean — but only for the parts it tracks"
    say "    Used           genuine part from a donor Mac; fine, mention it"
    say "    Unverified     usually a replaced logic board — walk-away grade"
    say "    Unknown        non-genuine or unpaired part — walk-away grade"
    say "    Finish Repair  a repair is sitting uncalibrated RIGHT NOW"
    say "    (no section)   proves nothing on its own"
    say ""
    ask "  Does any row read Unknown or Unverified?"
    case "$REPLY_YN" in
        y) REPAIR_SEEN=yes
           finding STOP "Parts & Service reports an Unknown or Unverified part" \
"Apple tracks only four things here: logic board, Touch ID board, lid angle
sensor (M5 only), and display (MacBook Neo only). So this row is almost
certainly the logic board or the Touch ID board.

It grades as a walk-away not because the flag is permanent - Apple never says
it is - but because no Thai shop publishes an Apple-silicon logic-board swap
price, and 14-inch Pro boards are not in Thai stock at all. A finding with no
nameable price cannot be a renegotiation; there is nothing to renegotiate
against. Apple's own note on Unverified: it 'may impact your ability to use
certain features on your Mac, such as Apple Pay.'" ;;
        n)
            ask "  Does any row read Finish Repair?"
            case "$REPLY_YN" in
                y) finding STOP "A repair on this machine is unfinished" \
"'Finish Repair' means a part is sitting uncalibrated right now and the pane is
not in a final state - so its true state is unknowable. Either the seller
finishes the repair in front of you and you re-read the pane, or the fact
cannot be established by any method, which is itself a walk-away." ;;
                *) say "  Parts & Service: no Unknown, Unverified or Finish Repair row." ;;
            esac
            if [ "$CLAIMED_REPAIR" = y ]; then
                ask "  Does the pane show ANY repair at all (Genuine or Used)?"
                if [ "$REPLY_YN" = y ]; then
                    REPAIR_SEEN=yes
                    finding NOTE "Seller said never repaired; the pane shows a repair" \
"A Genuine or Used row is harmless in itself - it is the contradiction that
matters. This is the second-claim trigger: combined with any other contradicted
claim, treat the seller's unverifiable statements as worthless, and the biggest
of those (whether the serial sits in someone's Apple Business Manager) is one
you cannot check at all."
                fi
            fi ;;
    esac
    say ""
    say "  What that pane does NOT cover, so you do not over-read it:"
    say "    battery · display (on any Air or Pro) · top case · speaker ·"
    say "    camera · microphone · fan · trackpad · Thunderbolt board."
    say "  Any of those can have been replaced with the pane still clean."
else
    finding UNSET "Repair history could not be read — macOS is older than Tahoe 26" \
"This machine runs macOS ${OS_VER}. The Parts & Service History pane requires
macOS Tahoe 26, and there is no command-line equivalent: a sweep of all 50
system_profiler domains found no surface that exposes it.

This is deliberately NOT graded as a fault, and the distinction matters. The
walk-away grade elsewhere in this guide fires when a seller refuses every
method of establishing a fact. Here the seller is refusing nothing - the guide
has no method to offer, because asking a stranger to spend forty minutes
updating a machine you do not own is not a check that fits in a shop visit, and
it would destroy the very 'Finish Repair' state a fresh repair would show.

So this reads as 'could not look', never as 'nothing found'. What you can still
do: ask, in writing in chat, for ไม่เคยแกะ ไม่เคยซ่อม (never opened, never
repaired). Only 2.7% of Thai listings claim it - so it is worth something."
fi

# The one case where a missing pane IS damning, and the script can tell.
if [ "$OS_MAJOR" -ge 26 ] && [ -n "${SECURE_BOOT:-}" ] && [ "$SECURE_BOOT" != "Full Security" ]; then
    finding STOP "The repair-history pane is hidden by the boot policy" \
"macOS ${OS_VER} would show Parts & Service, but SIP is off - and macOS hides
that pane entirely when SIP is off. The downgrade to Permissive Security is
always deliberate. This is the one configuration where a missing pane is
evidence rather than an absence of it."
fi

# --- Pane 3: Device Management.
say ""
say "  Opening System Settings > General > Device Management."
$OPEN "x-apple.systempreferences:com.apple.Profiles-Settings.extension" 2>/dev/null
ask "  Does it name an organisation ('managed by ...')?"
case "$REPLY_YN" in
    y) finding STOP "The machine names a managing organisation" \
"An organisation name here is conclusive. Absence is not - which is why this
pane is read but not relied on." ;;
esac
/usr/bin/osascript -e 'tell application "System Settings" to quit' 2>/dev/null

# ===========================================================================
# 6. Load test — started here, runs behind the physical checks
# ===========================================================================

head2 "Starting the load test"

POWER_SRC="$($PMSET -g ps 2>/dev/null | /usr/bin/head -1)"
BATT_PCT="$($PMSET -g ps 2>/dev/null | /usr/bin/grep -o '[0-9]\{1,3\}%' | /usr/bin/head -1 | /usr/bin/tr -d '%')"
case "$BATT_PCT" in ''|*[!0-9]*) BATT_PCT=-1 ;; esac

say "  The load test runs ON BATTERY, not on the charger."
say ""
say "  On the charger the battery is not asked to supply any current, so a"
say "  cell that collapses under load is invisible. On battery the same run"
say "  tests cooling AND the battery's ability to source peak current. It is"
say "  also the only state guaranteed to exist: the seller's charger is a"
say "  ฿1,190-3,190 accessory that may not be in the room."
say ""

case "$POWER_SRC" in
    *"AC Power"*)
        say "  This machine is currently on AC power."
        pause_for "  Unplug the charger, then"
        POWER_SRC="$($PMSET -g ps 2>/dev/null | /usr/bin/head -1)"
        ;;
esac

ON_BATTERY=no
case "$POWER_SRC" in *"Battery Power"*) ON_BATTERY=yes ;; esac
BATT_PCT="$($PMSET -g ps 2>/dev/null | /usr/bin/grep -o '[0-9]\{1,3\}%' | /usr/bin/head -1 | /usr/bin/tr -d '%')"
case "$BATT_PCT" in ''|*[!0-9]*) BATT_PCT=-1 ;; esac

RUN_LOAD=yes
if [ "$BATT_PCT" -ge 0 ] && [ "$BATT_PCT" -lt "$BATTERY_FLOOR" ]; then
    RUN_LOAD=no
    finding UNSET "Load test not run — battery too low to be meaningful" \
"Charge was ${BATT_PCT}%, below the ${BATTERY_FLOOR}% floor. Saturating every
performance core on a nearly-flat battery will shut the machine down for
entirely innocent reasons, and that would manufacture the single most severe
finding this script can produce. Charge it and re-run."
fi

if [ "$RUN_LOAD" = yes ]; then
    say ""
    say "  READ THIS BEFORE IT STARTS:"
    say ""
    say "    If the machine SHUTS DOWN, REBOOTS or FREEZES during the next"
    say "    few minutes, that is the most serious thing this whole run can"
    say "    find, and this script will not be alive to tell you. It is a"
    say "    walk-away: a fault that spreads is a walk-away however cheap the"
    say "    quote, and this one has two possible causes, both bad."
    say ""
    say "    Your report file already exists at:"
    say "      ~/mbcheck-${SERIAL:-unknown}-$($DATE +%Y-%m-%d).md"
    say ""

    N_WORKERS="$($SYSCTL -n hw.perflevel0.physicalcpu 2>/dev/null)"
    case "$N_WORKERS" in ''|*[!0-9]*) N_WORKERS="$($SYSCTL -n hw.physicalcpu 2>/dev/null)" ;; esac
    case "$N_WORKERS" in ''|*[!0-9]*) N_WORKERS=4 ;; esac

    BASELINE="$(thermal_level)"
    say "  Thermal pressure before load ...... $BASELINE"
    say "  Starting $N_WORKERS workers on the performance cores."
    say "  (Efficiency cores are left free so the machine stays usable while"
    say "   you work through the checks below.)"

    i=1
    while [ "$i" -le "$N_WORKERS" ]; do
        $SHASUM -a 256 /dev/zero >/dev/null 2>&1 &
        WORKER_PIDS+=($!)
        i=$(( i + 1 ))
    done

    (
        trap 'exit 0' TERM INT HUP
        end=$(( $($DATE +%s) + LOAD_SECONDS ))
        while [ "$($DATE +%s)" -lt "$end" ]; do
            printf '%s\n' "$($NOTIFYUTIL -g com.apple.system.thermalpressurelevel 2>/dev/null | /usr/bin/awk '{print $2}')" >> "$SAMPLE_FILE"
            sleep 10
        done
    ) &
    SAMPLER_PID=$!
    LOAD_START="$($DATE +%s)"
    say "  Load running. Work through the checks below while it does."
fi

# ===========================================================================
# 7. Hand prompts — the checks no script can perform
#
# Capped at 8 steps / about 10 minutes, because the real limit is not the
# clock, it is how likely you are to abandon the procedure while a seller
# watches you fiddle. Air spends 7 of them, Pro spends 8.
# ===========================================================================

head2 "Physical checks"

if [ "$IS_PRO" = yes ]; then
    say "  8 checks, about 10 minutes. Take them in order."
else
    say "  7 checks, about 10 minutes. Take them in order."
fi
say ""

# --- Pro-only, part 1 of 2: fans at idle, BEFORE the load has spun them up.
if [ "$IS_PRO" = yes ] && [ "$RUN_LOAD" = yes ]; then
    say "  [Pro only] Listen to the machine right now, before the fans spin up."
    ask "  Is it silent, or near-silent, at idle?"
    case "$REPLY_YN" in
        n) finding NOTE "Audible at idle" \
"A Pro should be quiet with nothing running. Worth noting; the load-test half
of this check below is the one that matters." ;;
    esac
    say ""
fi

# --- 1. Trackpad.
say "  1. TRACKPAD — press each of the four corners, one at a time."
say "     You are feeling for a corner that sits raised, rocks, or clicks"
say "     differently from the others."
ask "     Did any corner sit raised, rock, or click unevenly?"
case "$REPLY_YN" in
    y) finding STOP "Trackpad is lifting — the battery underneath is swelling" \
"A swelling cell lifts the trackpad from below. The repair is cheap and the
grade is still a walk-away, because this is a fault that SPREADS: it will get
worse, it can crack the display from the inside, and a quote prices today's
damage rather than what it takes with it." ;;
    '?') finding UNSET "Trackpad evenness not established" "Answered 'not sure'." ;;
    *) say "     OK." ;;
esac
say ""

# --- 2. Ports.
PORT_HINT="both USB-C ports"
case "$PRODUCT_NAME" in
    *"MacBook Pro"*) PORT_HINT="every USB-C port (2 or 3 — count them)" ;;
esac
MAGSAFE_HINT=""
case "$PRODUCT_NAME" in
    *"MacBook Air"*2020*|*"MacBook Pro"*2020*|*"MacBook Pro (13-inch, M2"*)
        MAGSAFE_HINT="This model has no MagSafe port." ;;
    *) MAGSAFE_HINT="If it has a MagSafe port, test that too." ;;
esac
say "  2. PORTS — plug the charger into $PORT_HINT,"
say "     ONE AT A TIME, and confirm each one starts charging."
say "     $MAGSAFE_HINT"
say "     Plugging into several at once proves nothing: a Mac charges over"
say "     only one port at a time, using whichever supplies the most power."
ask "     Did every port charge?"
case "$REPLY_YN" in
    n) finding BAHT "A port will not charge" \
"On Apple silicon the ports are modular sub-boards, not soldered to the logic
board, which caps what this costs to fix." 1500 "charge-port board ฿1,500-3,500 independent (as of $PRICES_AS_OF)" ;;
    '?') finding UNSET "Ports not established" "Answered 'not sure'." ;;
    *) say "     OK." ;;
esac
say ""

# --- 3. Screen.
DISPLAY_PRICE=10300
DISPLAY_LABEL="display assembly ฿10,300-17,900 independent"
case "$PRODUCT_NAME" in
    *"MacBook Pro"*14*|*"MacBook Pro"*16*)
        DISPLAY_PRICE=17990; DISPLAY_LABEL="mini-LED XDR display ฿17,990-18,990 independent" ;;
esac
say "  3. SCREEN — full-screen white, then full-screen black, then move the"
say "     lid slowly through its whole arc twice while watching the screen."
say "     White finds dead pixels and yellow patches. Black finds stuck"
say "     pixels. The lid movement finds internal display wiring, which is"
say "     the failure that only shows at one particular angle."
say "     On a 14/16-inch Pro, uneven glow around bright objects on black is"
say "     NORMAL mini-LED blooming. A dead patch is not."
ask "     Any dead/stuck pixels, patches, lines, or flicker at any angle?"
case "$REPLY_YN" in
    y) finding BAHT "Display fault" \
"Note that a replaced screen sets NO flag on any MacBook Air or Pro - the
display is only a tracked part on the MacBook Neo. So the pane being clean
tells you nothing about this." "$DISPLAY_PRICE" "$DISPLAY_LABEL (as of $PRICES_AS_OF)" ;;
    '?') finding UNSET "Display not established" "Answered 'not sure'." ;;
    *) say "     OK." ;;
esac
say ""

# --- 4. Keyboard.
TOPCASE_PRICE=6190
case "$PRODUCT_NAME" in
    *"MacBook Air"*15*) TOPCASE_PRICE=7490 ;;
    *"MacBook Pro"*) TOPCASE_PRICE=9490 ;;
esac
say "  4. KEYBOARD — open TextEdit and type every key, including the"
say "     function row and the arrows."
say "     Apple silicon never shipped the butterfly keyboard, so there is no"
say "     known model-specific keyboard defect to hunt. This is just a test."
ask "     Did every key register?"
case "$REPLY_YN" in
    n) finding BAHT "A key does not register" \
"The keyboard is not separately orderable on any M1-M5 MacBook: the repair is
a whole top-case assembly." "$TOPCASE_PRICE" "top case ฿$(baht "$TOPCASE_PRICE") + ฿1,605 fitting (Apple TH list, effective 2023-11-01)" ;;
    '?') finding UNSET "Keyboard not established" "Answered 'not sure'." ;;
    *) say "     OK." ;;
esac
say ""

# --- 5. Speakers, camera, microphone.
say "  5. SOUND AND CAMERA — play something bass-heavy, loud. Then open"
say "     Photo Booth, record five seconds, and play it back."
say "     Listen for rattle or buzz, not for quality."
ask "     Any rattle, buzz, or a dead camera or microphone?"
case "$REPLY_YN" in
    y) finding BAHT "Speaker, camera or microphone fault" \
"Speaker rattle on 2021 14/16-inch Pros is widely reported but was never
acknowledged by Apple, and is sometimes just debris in the grille - so it is
capped at a renegotiation rather than a walk-away. The camera rides inside the
display assembly; the microphone rides in the top case, and has no on-device
tell at all." 4000 "speaker pair ฿4,000-4,500 independent (as of $PRICES_AS_OF)" ;;
    '?') finding UNSET "Sound and camera not established" "Answered 'not sure'." ;;
    *) say "     OK." ;;
esac
say ""

# --- Pro-only, part 2 of 2: fans under load, late in the window.
if [ "$IS_PRO" = yes ] && [ "$RUN_LOAD" = yes ]; then
    say "  6. [Pro only] FANS — the load has been running for a few minutes"
    say "     now, so the fans should be working."
    say "     A fan can cool perfectly while its bearing grinds, which is why"
    say "     this is a listening check and not a reading. Fan speed needs"
    say "     sudo, and this script does not ask for a password."
    ask "     Any grinding, rattling or ticking from the fans?"
    case "$REPLY_YN" in
        y) finding BAHT "Fan bearing noise under load" \
"Cooling may still be fine - the thermal reading below answers that
separately. This is the bearing." 1000 "fan clean and re-paste ฿1,000-2,000; replacement price unpinned in Thailand" ;;
        '?') finding UNSET "Fan noise not established" "Answered 'not sure'." ;;
        *) say "     OK." ;;
    esac
    say ""
fi

# ===========================================================================
# 8. Finish the load, grade the trajectory
# ===========================================================================

if [ "$RUN_LOAD" = yes ]; then
    head2 "Finishing the load test"
    ELAPSED=$(( $($DATE +%s) - LOAD_START ))
    if [ "$ELAPSED" -lt "$LOAD_SECONDS" ]; then
        REMAIN=$(( LOAD_SECONDS - ELAPSED ))
        say "  You were quicker than the load test. ${REMAIN}s left — hold on."
        nap "$REMAIN"
    fi

    stop_workers

    SAMPLES="$(/usr/bin/grep -E '^[0-9]+$' "$SAMPLE_FILE" 2>/dev/null | /usr/bin/tr '\n' ' ')"
    NSAMP="$(printf '%s' "$SAMPLES" | /usr/bin/wc -w | /usr/bin/tr -d ' ')"
    PEAK=0
    for s in $SAMPLES; do [ "$s" -gt "$PEAK" ] && PEAK="$s"; done

    say "  Thermal pressure trajectory ....... ${SAMPLES:-none captured}"
    say "  (0 nominal · 1 moderate · 2 heavy · 3 trapping · 4 sleeping)"
    say "  Peak .............................. $PEAK"

    # Still climbing? Compare the last third against the middle third.
    CLIMBING=no
    if [ "$NSAMP" -ge 6 ]; then
        third=$(( NSAMP / 3 ))
        mid_max=0; last_max=0; idx=0
        for s in $SAMPLES; do
            idx=$(( idx + 1 ))
            if [ "$idx" -gt "$third" ] && [ "$idx" -le $(( third * 2 )) ]; then
                [ "$s" -gt "$mid_max" ] && mid_max="$s"
            elif [ "$idx" -gt $(( third * 2 )) ]; then
                [ "$s" -gt "$last_max" ] && last_max="$s"
            fi
        done
        [ "$last_max" -gt "$mid_max" ] && CLIMBING=yes
    fi

    if [ "$NSAMP" -eq 0 ]; then
        finding UNSET "Thermal trajectory not captured" \
"The load ran but no thermal samples were recorded."
    elif [ "$PEAK" -ge 4 ]; then
        finding STOP "Thermal pressure reached level 4 (Sleeping)" \
"macOS was forced to its most severe thermal response. On a machine under a
routine CPU load that is a cooling failure, not a hot day."
    elif [ "$PEAK" -eq 3 ]; then
        finding BAHT "Thermal pressure reached level 3 (Trapping)" \
"Sustained load pushed macOS past its normal throttling into Trapping. On a
Pro this usually means the fans, the paste, or both." 1000 "fan clean and re-paste ฿1,000-2,000 (as of $PRICES_AS_OF)"
    elif [ "$CLIMBING" = yes ]; then
        if [ "$IS_PRO" = yes ]; then
            # The 180s window and the plateau shape were measured ONCE, on a
            # fanless Air. A fan-cooled Pro may simply saturate more slowly.
            # Grading a still-climbing Pro would be a false renegotiation on a
            # healthy machine, derived from a threshold nobody has measured on
            # this class. So: report it, do not grade it.
            finding UNSET "Thermal pressure was still climbing at ${LOAD_SECONDS}s — not graded on a Pro" \
"Trajectory: ${SAMPLES}
On a MacBook Air this shape would be a renegotiation. It is NOT graded here,
because the ${LOAD_SECONDS}s window and the plateau shape behind it were measured once,
on a fanless MacBook Air - the thermally weakest configuration there is. A
fan-cooled Pro may simply take longer to saturate, and grading this would mean
telling you to renegotiate on a healthy machine using a threshold nobody has
measured on this class of machine.

Treat it as information: peak $PEAK, never reached 3 or 4, machine survived."
        else
            finding BAHT "Thermal pressure never flattened out" \
"Trajectory: ${SAMPLES}
A healthy machine climbs and then plateaus. One that keeps climbing through a
${LOAD_SECONDS}-second load is still losing the argument with its own heat when the
test ends." 1000 "fan clean and re-paste ฿1,000-2,000 (as of $PRICES_AS_OF); on a fanless Air this points at the thermal interface"
        fi
    else
        say "  Verdict ........................... plateaued at $PEAK — normal"
        if [ "$IS_PRO" = no ]; then
            say ""
            say "  On a fanless Air, silence is the correct result and a hot"
            say "  chassis is by design. Reaching level 2 and staying there is"
            say "  normal: a healthy M4 Air sat at 2 for over 80 seconds."
        fi
    fi

    if [ "$ON_BATTERY" = no ]; then
        finding UNSET "Load test ran on the charger, not on battery" \
"The machine was still on AC power. The thermal half of the test is valid and is
graded above. The battery half is not: plugged in, the cell is never asked to
supply current, so one that collapses under load stays invisible. If you can,
unplug and re-run."
    fi
fi

# ===========================================================================
# 9. The two checks that need a restart — last, because they end the visit
# ===========================================================================

head2 "The last two checks"
say "  Both of these restart the machine, so they come after everything else."
say ""

# --- 7. Recovery Lock.
say "  7. RECOVERY LOCK — shut the machine down fully, then press and hold"
say "     the power / Touch ID button until something appears."
say ""
say "     You want: the startup options screen — your startup disk, plus"
say "     Options with a gear icon."
say "     You do not want: a password prompt saying recoveryOS is locked."
say ""
say "     This is the ONLY way to find this. No command at any privilege"
say "     level exposes it, and only an MDM can set it — so a machine with"
say "     one was, at some point, a managed machine."
ask "     Did the startup options screen appear normally?"
case "$REPLY_YN" in
    n) finding STOP "Recovery Lock — recoveryOS is password-protected" \
"The machine boots macOS perfectly and cannot enter recovery. Only an MDM can
set this and only an MDM can clear it; Apple runs no proof-of-purchase route
for it, unlike Activation Lock. A DFU restore from a second Mac does clear it -
a revive does not - so it is survivable if you own another Mac and fatal if you
do not. Combined with any Activation Lock or ABM problem, it is not survivable
at all." ;;
    '?') finding UNSET "Recovery Lock not established" "Answered 'not sure'." ;;
    *) say "     OK." ;;
esac
say ""

# --- 8. Erase All Content and Settings, watched, on Wi-Fi.
say "  8. THE ERASE — this is the most valuable check in the whole run."
say ""
say "     Ask the seller to run Erase All Content and Settings in front of"
say "     you, and to complete setup ON WI-FI. Then watch the machine reach"
say "     the Hello screen with no Remote Management pane and no request"
say "     for someone else's Apple Account."
say ""
say "     WI-FI, NOT ETHERNET. Over Ethernet a managed Mac can re-enrol"
say "     silently, with no pane shown at all. Wi-Fi forces the pane."
say ""
say "     Why it is worth the minutes: it is the only test that exercises"
say "     Apple's activation-time checks, which is where the locks actually"
say "     bite. Nothing readable from a running system does that. It also"
say "     forces the seller to prove they hold the Apple Account password,"
say "     because the erase cannot complete without it."
say ""
ask "     Did the seller run the erase in front of you, on Wi-Fi?"
ERASE_RUN="$REPLY_YN"
if [ "$ERASE_RUN" != y ]; then
    ask "     Ask once more — will they run it? Answer y if they now agree."
    ERASE_RUN="$REPLY_YN"
fi

case "$ERASE_RUN" in
    y)
        ask "     Did a Remote Management pane appear, or a request for"$'\n'"     someone else's Apple Account?"
        case "$REPLY_YN" in
            y) finding STOP "The machine is locked to someone else" \
"A Remote Management pane names an organisation that owns this serial
server-side, or an Apple Account prompt means Activation Lock is live against
an account that is not the seller's. Neither can be cleared by erasing again -
the record is not on the machine." ;;
            '?') finding UNSET "Erase outcome not established" "Answered 'not sure'." ;;
            *)
                say "     Clean. That is the best result available."
                say ""
                say "     One honest caveat: this proves the serial is not"
                say "     ASSIGNED to a management server today. It cannot"
                say "     prove the serial is not sitting in an organisation's"
                say "     Apple Business Manager, unassigned. Nothing available"
                say "     to a buyer can prove that. It is the one risk you"
                say "     cannot check, only price." ;;
        esac ;;
    *)
        finding STOP "The seller would not erase the machine in front of you" \
"There is no substitute for this check and no second method to try. Refusing
one method of establishing a fact is free; refusing every method for a fact
this important is itself the finding.

It is also the one refusal with an obvious innocent explanation - the erase is
irreversible for the seller, and they lose the machine's setup if you then walk
away. Which is exactly why it is the test a seller with something to hide
refuses." ;;
esac

# ===========================================================================
# 10. Your legal position — not a property of the machine
# ===========================================================================

head2 "Who you are buying from"
say "  This is not a grade and it is not in the repair total. It is a"
say "  property of the transaction, not of the Mac."
say ""
ask "  Does this seller deal in Macs as a trade (a shop or a regular"$'\n'"  reseller), rather than selling their own personal machine?"
SELLER_KIND="$REPLY_YN"

# ===========================================================================
# 11. Optional: reported-stolen lookup, off by default
# ===========================================================================

STOLEN_RESULT=""
if [ "$STOLEN_CHECK" = yes ] && [ -n "$SERIAL" ]; then
    head2 "Reported-stolen lookup"
    STOLEN_RESULT="$($CURL -fsS --max-time 12 "https://www.stolenregister.com/check?sn=${SERIAL}" 2>/dev/null)"
    if [ -z "$STOLEN_RESULT" ]; then
        finding UNSET "Reported-stolen lookup did not return" \
"No response from stolenregister.com. Try it yourself at
https://www.stolenregister.com/check?sn=${SERIAL}"
    else
        case "$(printf '%s' "$STOLEN_RESULT" | /usr/bin/tr '[:upper:]' '[:lower:]')" in
            *"has been reported"*|*"reported stolen"*|*"reported lost"*|*"is stolen"*)
                finding STOP "This serial is on a public stolen/lost register" \
"stolenregister.com returned a hit for ${SERIAL}. Verify it yourself at
https://www.stolenregister.com/check?sn=${SERIAL} before acting - but a hit is
as serious as this list gets." ;;
            *) say "  No hit for ${SERIAL}."
               say "  A miss proves nothing: the register is voluntary and"
               say "  crowd-sourced, and no Thai state channel lets a buyer"
               say "  check whether a device is stolen at all." ;;
        esac
    fi
fi

# ===========================================================================
# 12. The report
# ===========================================================================

REPORT="$HOME/mbcheck-${SERIAL:-unknown}-$($DATE +%Y-%m-%d).md"

# Grade ceiling: every criterion the script can read is disqualifying, and the
# one it cannot (cosmetics) can only push the grade DOWN. So "not Grade A" is
# conclusive and "is Grade A" is unreachable.
CEIL="A"
CEIL_WHY=""
if [ "$MAXCAP_N" -ge 0 ]; then
    if [ "$MAXCAP_N" -lt 80 ]; then CEIL="C"; CEIL_WHY="battery ${MAXCAP}"
    elif [ "$MAXCAP_N" -lt 90 ]; then CEIL="B"; CEIL_WHY="battery ${MAXCAP}"
    else CEIL_WHY="battery ${MAXCAP}"; fi
else
    CEIL_WHY="battery capacity unreadable"
fi
if [ "$REPAIR_SEEN" = yes ]; then
    # Grade A explicitly requires "never opened, no part replaced", and a
    # genuine battery-or-screen replacement is Grade C — below the published
    # table, with no floor under it at all.
    CEIL="C"
    CEIL_WHY="${CEIL_WHY}; a repair is on record"
elif [ "$OS_MAJOR" -lt 26 ]; then
    CEIL_WHY="${CEIL_WHY}; 'never opened' not evaluable on macOS ${OS_VER}"
fi

n_stop="$(count_grade STOP)"; n_baht="$(count_grade BAHT)"
n_note="$(count_grade NOTE)"; n_unset="$(count_grade UNSET)"

{
printf '# mbcheck report\n\n'
printf '**%s**  \n' "$PRODUCT_NAME"
printf '%s · %s · %s  \n' "$CHIP" "$CORES" "$MEMORY"
printf 'Serial `%s` · model number `%s` · region `%s`  \n' \
       "${SERIAL:-unknown}" "${MODEL_NUMBER:-unknown}" "${REGION_INFO:-unknown}"
printf 'macOS %s · inspected %s · mbcheck %s\n\n' "${OS_VER:-unknown}" "$($DATE +%Y-%m-%d)" "$VERSION"
printf 'Grade %s at best (BKK APPLE rubric, TH) — %s; cosmetic condition, which you can see and I can not, can only lower this.\n\n' "$CEIL" "$CEIL_WHY"
printf -- '---\n\n'
printf '## Summary\n\n'
printf '| 🛑 High risk | 💰 Renegotiate | 📝 Note | ?? Not established |\n'
printf '|---|---|---|---|\n'
printf '| %s | %s | %s | %s |\n\n' "$n_stop" "$n_baht" "$n_note" "$n_unset"

if [ "$N_FINDINGS" -gt 0 ]; then
    printf '| Finding | Grade | Impact |\n|---|---|---|\n'
    for g in STOP BAHT NOTE UNSET; do
        i=0
        while [ "$i" -lt "$N_FINDINGS" ]; do
            if [ "${F_GRADE[$i]}" = "$g" ]; then
                printf '| %s | %s | %s |\n' \
                    "${F_TITLE[$i]}" "$(icon "$g")" "${F_PRICE[$i]:-—}"
            fi
            i=$(( i + 1 ))
        done
    done
    if [ "$TALLY" -gt 0 ]; then
        printf '| **Repair total, at least** | | **฿%s** |\n' "$(baht "$TALLY")"
    fi
    printf '\n'
    if [ "$TALLY" -gt 0 ]; then
        printf 'That total is the low end of every named range, and it counts repair costs only.\n'
        printf 'Resale impact is deliberately not in it: it is not a repair cost, and adding it\n'
        printf 'would double-count against the prices already here. This report takes no position\n'
        printf 'on when a total is too much — that depends on what you are buying it for.\n\n'
    fi
else
    printf 'No findings.\n\n'
fi

printf -- '---\n\n## Detail\n\n'
for g in STOP BAHT NOTE UNSET; do
    i=0
    while [ "$i" -lt "$N_FINDINGS" ]; do
        if [ "${F_GRADE[$i]}" = "$g" ]; then
            printf '### %s %s\n\n' "$(icon "$g")" "${F_TITLE[$i]}"
            printf '%s\n\n' "${F_DETAIL[$i]}"
            [ -n "${F_PRICE[$i]}" ] && printf '**Price:** %s\n\n' "${F_PRICE[$i]}"
        fi
        i=$(( i + 1 ))
    done
done

printf -- '---\n\n## Your legal position\n\n'
case "$SELLER_KIND" in
    y) printf 'You answered that this seller deals in Macs as a trade.\n\n'
       printf 'Under Thai Civil and Commercial Code s.1332, a buyer who buys in good faith\n'
       printf 'from a **dealer in that kind of goods** keeps the machine even if it turns out\n'
       printf 'to be stolen, unless the true owner refunds what you paid. That limb needs no\n'
       printf 'registration of any kind — it is about what the seller actually trades in.\n\n'
       printf '**Do this before you pay:** ask to see the ใบอนุญาตซื้อของเก่า (second-hand\n'
       printf 'dealer licence). In the one documented Thai MacBook case, the outcome turned on\n'
       printf 'exactly that licence plus the shop holding a signed ID copy of its own seller.\n' ;;
    n) printf 'You answered that this is a private individual selling their own machine.\n\n'
       printf 'Under Thai Civil and Commercial Code s.1332 you are in the **unprotected**\n'
       printf 'branch: if the machine turns out to be stolen, you hand it back and get nothing.\n\n'
       printf '**Do this before you pay:** get the seller\x27s ID and a written statement in chat.\n'
       printf 'Your only remedy is รอนสิทธิ under ss.475/479, and it runs against the seller\n'
       printf 'personally — which means it needs a name you can actually find.\n' ;;
    *) printf 'You were not sure what kind of seller this is.\n\n'
       printf 'Assume the **unprotected** branch — that is the honest default for the Facebook\n'
       printf 'flipper moving three Macs a month, who is neither a shop nor selling their own\n'
       printf 'daily driver. Under Thai CCC s.1332, if the machine is stolen you hand it back\n'
       printf 'and get nothing.\n\n'
       printf '**Do this before you pay:** get the seller\x27s ID and a written statement in chat.\n' ;;
esac
printf '\nThe portable part of this is not the Thai rule — it is **name your seller**. A\n'
printf 'remedy against the seller exists in every jurisdiction; s.1332 is unusually\n'
printf 'buyer-friendly and may invert where you are. Do not assume this holds outside\n'
printf 'Thailand.\n\n'

printf -- '---\n\n## What this inspection could not see\n\n'
printf -- '- **Whether this serial sits in an organisation'\''s Apple Business Manager.** No\n'
printf '  command at any privilege level can ask. A serial can be registered but unassigned\n'
printf '  today and assigned tomorrow, and macOS 14+ then walls the machine off. The watched\n'
printf '  erase above is the best test that exists and it still cannot prove this.\n'
printf -- '- **SSD wear.** `S.M.A.R.T. status: Verified` is a pass/fail bit, not a health\n'
printf '  figure. The wear counter exists on the drive and is readable without privileges,\n'
printf '  but macOS ships no tool that opens it, and this script installs nothing.\n'
printf -- '- **Whether the screen or the top case were ever replaced.** Neither is a tracked\n'
printf '  part on any MacBook Air or Pro.\n'
printf -- '- **RAM.** Only Apple Diagnostics really tests it, and that needs a full shutdown.\n'
printf -- '- **Anything before the last erase.** Panic and diagnostic history live on the data\n'
printf '  volume and do not survive it.\n\n'

printf -- '---\n\n'
printf 'Written on the seller'\''s machine. **AirDrop this to yourself, then delete it here.**\n'
printf 'A report you cannot take home is not a negotiation document.\n'
} > "$REPORT" 2>/dev/null

head2 "Report"
say ""
say "   $(icon STOP) $n_stop high risk    $(icon BAHT) $n_baht renegotiate    $(icon NOTE) $n_note note    ?? $n_unset not established"
say ""
if [ "$N_FINDINGS" -gt 0 ]; then
    for g in STOP BAHT NOTE UNSET; do
        i=0
        while [ "$i" -lt "$N_FINDINGS" ]; do
            if [ "${F_GRADE[$i]}" = "$g" ]; then
                printf '   %s  %s\n' "$(icon "$g")" "${F_TITLE[$i]}"
                [ -n "${F_PRICE[$i]}" ] && printf '        %s\n' "${F_PRICE[$i]}"
            fi
            i=$(( i + 1 ))
        done
    done
    [ "$TALLY" -gt 0 ] && { say ""; say "   Repair total, at least: ฿$(baht "$TALLY")"; }
else
    say "   Nothing found."
fi
say ""
say "  Grade $CEIL at best (BKK APPLE rubric, TH) — $CEIL_WHY."
say "  Cosmetic condition, which you can see and this script cannot, can only"
say "  lower that."
say ""
rule
say "  Full report written to:"
say "    $REPORT"
say ""
say "  AirDrop it to yourself, then delete it from this machine."
say ""
say "  This report takes no position on whether to buy. It grades, it prices,"
say "  and the decision is yours."
say ""

exit 0
