# Shop-readable storage, memory and thermal health facts on Apple silicon

Research for [#6](https://github.com/mingrath/mbcheck/issues/6). Dated **2026-08-04**.

**Constraint this research is answering against** (from the map, [#1](https://github.com/mingrath/mbcheck/issues/1)):
one unprivileged `check.sh`, **no sudo ever**, no third-party install, no network assumed,
must work on M1–M5, Air **and** Pro, must not hardcode a core count or assume a fan exists.

## How the primary evidence was obtained

Everything marked **[measured]** was run by the researcher on the dev's own machine:

```
$ sysctl -n machdep.cpu.brand_string   →  Apple M4
$ sysctl -n hw.model                   →  Mac16,13   (MacBook Air, 10-core, 16 GB)
$ sw_vers                              →  macOS 26.5.2 (25F84)
```

This is a **fanless MacBook Air**, which is the awkward case in area 4, so the fanless
observations below are first-hand rather than inferred. Every command below was run as a
**normal admin user with no `sudo`**.

Two caveats on the measurements, stated up front:

- The machine was **not idle** during the load work — concurrent research subagents held
  `loadavg` between 9 and 34. Per-process CPU percentages from the load test are therefore
  **not representative of a shop machine**, and are reported only for what they still prove.
- The 5-minute load test was **not** run on this machine. A 25-second version was, and is
  labelled as such.

---

# 1. SSD wear

## 1.1 `system_profiler SPNVMeDataType` — no wear counters at all **[measured]**

| | |
|---|---|
| Command | `system_profiler SPNVMeDataType` |
| Runtime | ~0.2 s |
| Install / network | none |
| Sudo | no |
| Verdict | **Gives no wear data.** |

Full real output on the M4 Air:

```
NVMExpress:
    Apple SSD Controller:
        APPLE SSD AP0256Z:
          Capacity: 251 GB (251,000,193,024 bytes)
          TRIM Support: Yes
          Model: APPLE SSD AP0256Z
          Revision: 2,973.120
          Serial Number: 0ba0291184ac7631
          Detachable Drive: No
          BSD Name: disk0
          Partition Map Type: GPT (GUID Partition Table)
          Removable Media: No
          S.M.A.R.T. status: Verified
          Volumes: …
```

There is **no** Percentage Used, no Data Units Written, no Power On Hours, no Available Spare,
no Unsafe Shutdowns. The only health field is `S.M.A.R.T. status: Verified` — a **binary**
pass/fail, not a wear figure.

`system_profiler SPStorageDataType` adds nothing beyond `S.M.A.R.T. Status: Verified` and
`Protocol: Apple Fabric` — note **Apple Fabric**, not PCIe/NVMe; the internal SSD is not on a
standard NVMe transport.

**Threshold:** `S.M.A.R.T. status` anything other than `Verified` → 🛑 walk away (soldered,
unfixable). `Verified` is worth **nothing** as reassurance — see 1.5.

## 1.2 `ioreg` — geometry, but still no wear counters **[measured]**

The internal SSD controller is exposed, and `ioreg` reads it **without sudo**. The live class on
the M4 is `AppleANS3CGv2Controller` (Apple NAND Storage v3). Note that the class name varies by
generation — `ioreg -c` matches subclasses, so any of `IONVMeController`, `AppleNVMeController`,
`AppleANS2NVMeController`, `AppleANS2CGv2Controller`, `AppleANS3NVMeController`,
`AppleANS3CGv2Controller` returned the same single node here. **`ioreg -rd1 -c IONVMeController`
is the generation-portable form** — it matched on M4 despite the concrete class being ANS3CGv2.

```
$ ioreg -rd1 -c IONVMeController -w0
+-o AppleANS3CGv2Controller  <class AppleANS3CGv2Controller, …>
      "Physical Interconnect" = "Apple Fabric"
      "Model Number" = "APPLE SSD AP0256Z"
      "Firmware Revision" = "2973.120"
      "NVMe Revision Supported" = "1.10"
      "AppleNANDStatus" = "Ready"
      "Controller Characteristics" = {"default-bits-per-cell"=3, "cell-type"=3,
        "capacity"=256000000000, "nand-marketing-name"="tlc_3d_g5_2p_512",
        "package_blocks_at_EOL"=12560, "blocks-per-cau"=1662, "cau-per-die"=2,
        "num-bus"=4, "dies-per-bus"=(1,1,1,1), "page-size"=16384,
        "vendor-name"="Toshiba", "chip-id"="S5E", "msp-version"="4.12.2.0.0.0", …}
```

This is **static geometry and configuration**, not wear. `package_blocks_at_EOL` = 12560 looks
tempting but it is a **fixed manufacturing parameter** (the block budget at end of life), not a
live remaining-spare count — it does not move.

I grepped the **entire** 34,311-line IORegistry for every plausible wear key:

```
$ ioreg -l -w0 | grep -o -i '"[^"]*\(wear\|erase\|Percentage Used\|TBW\|Data Units\
    \|power_on\|lifetime\|spare\|endurance\|erase_count\|units_written\)[^"]*"' | sort -u
"ForceLifetimeExpired"
"ForceLifetimeExpired Completions"
"LifetimeData"            ← this is AppleSmartBattery, not the SSD
"block-erase-supported"
… (remainder are ANE / HID / PCI power-on keys, unrelated)
```

**There is no SSD wear counter anywhere in the IORegistry.** `LifetimeData` belongs to
`AppleSmartBattery` (it sits next to `CycleCount`, `Qmax`, `DesignCapacity`), not to storage.

**Verdict: no unprivileged `ioreg` route to TBW / percentage-used / power-on-hours.**

## 1.3 The data **does** exist, and root is **not** what is blocking it **[measured]**

This is the finding that overturned the obvious conclusion, so it is worth stating precisely.

The received wisdom — including the first draft of this document — is that Apple's ANS is a
closed, non-standard controller that simply does not expose SMART. **That is wrong.** The
namespace node advertises it:

```
$ ioreg -l -w0 | grep -o -i '"[^"]*SMART[^"]*"' | sort -u
"AppleNVMeSMARTUserClient"
"AppleNVMeTranslationSMARTUserClient"
"AppleSATLSMARTUserClient"
"NVMe SMART Capable"
"NVMeSMARTLib.plugin"
```

and on the namespace node:

```
+-o NS_01@1  <class IOEmbeddedNVMeBlockDevice, …>
      "NVMe SMART Capable" = Yes
      "ThermalThrottlingSupported" = Yes
      "IOCFPlugInTypes" = {"AA0FA6F9-C2D6-457F-B10B-59A13253292F"="NVMeSMARTLib.plugin"}
```

That UUID is `kIONVMeSMARTUserClientTypeID`, and `/System/Library/Extensions/NVMeSMARTLib.plugin`
**ships with macOS**. To settle whether root is required, ~60 lines of C were written against the
plug-in's `IOCreatePlugInInterfaceForService` / `SMARTReadData` vtable and run **as uid 501 with
no sudo** on this M4:

```
IOCreatePlugInInterfaceForService -> 0x0
QueryInterface(SMART)             -> 0x0
--- SMARTReadData -> 0x0 ---
  Critical Warning      : 0x00
  Available Spare       : 100 %
  Available Spare Thresh: 99 %
  PERCENTAGE USED       : 4 %
  Data Units Read       : 257109193  (= 131.64 TB)
  DATA UNITS WRITTEN    : 88433716  (= 45.28 TB)
  Power Cycles          : 468
  POWER ON HOURS        : 853
  Unsafe Shutdowns      : 10
  Media Errors          : 0
```

**The complete, standard NVMe SMART/Health log page — TBW, Percentage Used, Power On Hours and
all — is readable without root on Apple silicon.** The counters are live and increment between
runs.

The same plug-in also exposes **Apple-proprietary** health keys (`CopyAppleCareNANDInfo`),
likewise unprivileged:

```
com.apple.NANDInfo.Health.MaxPercentageNANDUsed = 11
com.apple.NANDInfo.Health.SpareAvailablePercent = 100
com.apple.NANDInfo.Health.NumGrownBad           = 0
com.apple.NANDInfo.Health.NumDieFailures        = 0
com.apple.NANDInfo.Health.IsNANDRetirable       = 1
```

⚠️ **Lead, not a finding:** Apple's own `MaxPercentageNANDUsed` reads **11** where the
NVMe-standard `Percentage Used` reads **4** on the *same* drive — nearly 3×. The standard field
looks like a rolled-up average and Apple's like the worst-case block. This is **one machine** and
is not documented anywhere; do not build a threshold on it.

**So the blocker is not privilege — it is that macOS ships no binary that opens this interface.**
Confirmed on this machine and by grepping `/usr/bin`, `/usr/sbin`, `/usr/libexec` and
`/System/Library/CoreServices` for both the user-client UUID and the string `NVMeSMART`:

```
$ command -v smartctl nvme    →  (nothing)
```

No `nvme` CLI, no `smartctl`, and `SPNVMeReporter.spreporter` contains no wear-related strings.
Whether the buyer could compile the 60 lines on the spot is answered **no** in §1.4 — and that,
not root, is what makes this unshippable.

⚠️ Caveat: the C probe and the grep were done on **M4 / macOS 26.5.2 only**. M1–M3 behaviour is
inferred from the class hierarchy and from matching third-party output in forums.

## 1.3a `smartctl` reads it all — and does **not** need sudo **[measured]**

smartmontools 7.5 was installed via Homebrew, run, and removed again. **As uid 501, no sudo:**

```
$ smartctl -a /dev/disk0
Model Number:      APPLE SSD AP0256Z
NVMe Version:      <1.2
SMART overall-health self-assessment test result: PASSED
Critical Warning:                   0x00
Available Spare:                    100%
Available Spare Threshold:          99%
Percentage Used:                    4%
Data Units Read:                    257,214,745 [131 TB]
Data Units Written:                 88,491,342 [45.3 TB]
Power Cycles:                       468
Power On Hours:                     853
Unsafe Shutdowns:                   10
Media and Data Integrity Errors:    0
```

Identical to the C probe. **Every tutorial that writes `sudo smartctl` is cargo-culting** — it
goes through the same unprivileged IOKit path. Minor wrinkle: `smartctl` exits non-zero (4)
because the ANS rejects the *error-log* page (`GetLogPage failed … code=745`); the **health page
is fully standard**. Apple's ANS is a partial NVMe implementation (`NVMe Version: <1.2`, one
power state) but the part that matters works.

| | |
|---|---|
| Command | `smartctl -a /dev/disk0` |
| Runtime | <1 s |
| Sudo | **no** |
| Install / network | **yes — Homebrew, and this is the disqualifier** |

Reported stable **M1 → M4, Big Sur → Tahoe 26**, corroborated on M2 Pro
(forum.blackmagicdesign.com/viewtopic.php?t=222009, 2025-05-22) and in general how-tos
(osxdaily.com/2024/04/10/how-to-check-disk-health-on-mac-with-smartctl/, 2024-04-10).

### The exception the map invited someone to argue — and why it still fails

The map allows arguing for a third-party install. **This is the strongest candidate in the whole
project**, and it should be recorded that it was considered seriously and rejected:

- it is the **only** route to the single most valuable used-machine number;
- it needs **no sudo**, which was the usual killer.

It still fails, on three counts, and the third is fatal:

1. **Network at the shop** is not assumed by the map.
2. **Installing Homebrew on a stranger's Mac** to inspect it is not something a seller will
   agree to, and it leaves the machine changed. (Note the real-world cost: the agent's Homebrew
   uninstall also removed an unrelated pre-existing package, which had to be reinstalled.)
3. **Time.** A cold Homebrew install is many minutes of download against the map's ~10-minute
   hand budget, and the buyer is standing over someone else's laptop while it runs.

**Recommendation: do not ship it in `check.sh`.** But the README explainer *should* say the
number exists and is free to read at home, so a buyer who gets the machine cheaply can check
after the fact — and so anyone re-litigating this knows it was a judgement call, not an
oversight.

## 1.4 Compiling a helper on the spot is **not** available **[measured]**

A tempting escape hatch — write 30 lines of Swift/C that opens the SMART user client — dies on a
stock Mac:

```
$ ls -la /usr/bin/swift /usr/bin/cc /usr/bin/python3
-rwxr-xr-x  78 root  wheel  118928 Jun 25 09:29 /usr/bin/cc
-rwxr-xr-x  78 root  wheel  118928 Jun 25 09:29 /usr/bin/python3
-rwxr-xr-x  78 root  wheel  118928 Jun 25 09:29 /usr/bin/swift
```

All three are **the same binary**: identical size (118,928 bytes) and a link count of **78** —
they are hardlinks to the single `xcode-select` shim. On a machine with Command Line Tools
installed (this one) they work; on a **stock** Mac they pop the *"The 'swift' command requires
the command line developer tools. Would you like to install them now?"* dialog, which needs
network, an admin password, and several minutes.

**Consequence for `check.sh`: it may not invoke `swift`, `cc`, `clang`, `gcc`, `python3`,
`perl`-with-XS, or anything else behind that shim.** This is a general constraint, not just an
SSD one, and it should be recorded on the map — it bounds every future check, not only this one.

(`perl` itself is a real binary and is safe; `shasum` is a perl script and worked fine.)

## 1.5 The headline answer for area 1

It is a **pass/fail threshold flag**, not a wear reading, and it flips only when the drive is
already failing. It does **not** tell you a drive is at 80% of its endurance. Treat it as a
smoke alarm, not a fuel gauge.

**Precise answer to the ticket:**

- SMART **is** exposed on Apple-silicon internal NVMe, and **is** readable **without root**.
- `system_profiler SPNVMeDataType` gives **a binary status and nothing else**.
- The counters are reachable **only** through the `NVMeSMARTLib` IOKit user client, and **macOS
  ships no binary that opens it**, and the compiler that would let you write one is behind a
  network install (§1.4).
- Therefore, under the map's constraints — stock macOS, no install, no network —
  **SSD wear is NOT READABLE.** Not because it is privileged, and not because Apple hides it,
  but because there is no tool.

That distinction matters for the guide's honesty: the right line is *"this number exists and we
cannot get at it here"*, not *"Apple doesn't expose it."*

## 1.5a Thresholds — for the README explainer, and for a buyer checking at home

These apply to `smartctl` output, in the order that actually matters. **The field everyone
fixates on is fourth.**

| rank | field | threshold | grade |
|---|---|---|---|
| 1 | `Critical Warning` | anything other than `0x00` — spec-defined failure bits | 🛑 |
| 2 | `Available Spare` vs `Available Spare Threshold` | Apple sets the threshold at **99%**, so **any** drop below 100% is meaningful | 🛑 at/below threshold · 💰 below 100% |
| 3 | `Media and Data Integrity Errors` | `> 0` | 🛑 |
| 4 | `Percentage Used` | informational only — see below | 📝 |
| 5 | `Power On Hours` | **ignore on a Mac** — see below | — |

**Why `Percentage Used` is only informational.** NVMe Base Spec 2.1 (2024-08-05, and identically
1.2a §5.10.1.2) defines it as *"a **vendor specific estimate**… A value of 100 indicates that the
estimated endurance… has been consumed, **but may not indicate an NVM subsystem failure. The
value is allowed to exceed 100.**"* Independently corroborated by Rossmann Group (2026-04-08):
healthy drives routinely report 96–100%.

**Why `Power On Hours` is noise.** The spec says it *"may not include time that the controller
was powered and in a non-operational power state."* This machine reports **853 hours against
45.3 TB written** — impossible as wall-clock. Do not compute a drive's age from it.

**Why the guide must not print a TBW rating.** *Apple publishes no TBW, P/E or endurance figure
for any Mac SSD, anywhere* — verified against Apple's tech-specs and warranty pages. Every
circulating number is a substitution:

- Samsung's published consumer **warranty** TBW is a flat **600 TB per TB** of capacity
  (150/300/600/1,200 TB for 250GB/500GB/1TB/2TB), unchanged 2018→2025.
- Back-solving `Data Units Written ÷ Percentage Used` across real Apple machines implies
  **~1,800 to ~6,700 P/E cycles — a 3.7× spread.** This M4 lands at ~4,400.
- The original 2021 panic ran on **150 TBW ≈ 600 cycles**, a generic consumer warranty number
  applied by analogy. It was never Apple's, and it looks **4–10× too low.**

**Rough calibration, explicitly weak:** typical write rates are **~10–35 TB/year**
(~30–100 GB/day), so a 3-year-old machine in normal use should show roughly **30–100 TB written
and 1–5% used on 512GB+, or 3–10% on 256GB.** ⚠️ **This range is built entirely from individual
anecdotes. There is no dataset, survey or telemetry study of Mac SSD writes — none exists — and
the population that posts SMART dumps is self-selected toward worriers.** Print it as a rule of
thumb or not at all.

**And the strongest single fact for the explainer: after extensive searching, there is no
documented case of an Apple-silicon SSD failing from write exhaustion in normal use.** One
destructive datapoint on record — a 256GB M1 mini hit 0% remaining life at ~700 TB and kept
working to 2.3 PB and 4.5 PB on two units ⚠️ *(single source, commercially interested party,
forum post, n=2)*.

## 1.6 The one storage number that *is* readable, and what it is good for **[measured]**

```
$ ioreg -rd1 -c IOBlockStorageDriver -w0 | grep '"Statistics"'
"Statistics" = {"Operations (Write)"=3032817, "Bytes (Write)"=92307652608,
                "Operations (Read)"=14800553, "Bytes (Read)"=252440379392,
                "Errors (Write)"=0, "Errors (Read)"=0,
                "Retries (Write)"=0, "Retries (Read)"=0, …}
```

| | |
|---|---|
| Command | `ioreg -rd1 -c IOBlockStorageDriver -w0` |
| Runtime | ~28 ms (measured, in a bundle with several sysctls) |
| Install / network | none |
| Sudo | no |

**These are since-boot counters, not lifetime.** Proof from this machine, without needing a
reboot to demonstrate it:

- uptime at the time of reading was **6 h 09 m** (`kern.boottime` = Tue Aug 4 12:33:22 2026);
- `Bytes (Write)` = 92.3 GB;
- over the *same* window `vm_stat` reported **2,987,168 Swapouts × 16384 B = 45.6 GB** of swap
  writes alone.

If `Bytes (Write)` were a lifetime figure it would have to be smaller than six hours of this
machine's swap traffic, on a system volume installed 2026-06-25. It is not a lifetime counter.
Both counters are since-boot, which is also what `IOBlockStorageDriver` documents itself as.

**So it cannot substitute for TBW.** What it *is* useful for:

- `Errors (Write)` / `Errors (Read)` / `Retries (*)` — **any non-zero value is a real signal**
  and costs nothing to read.
- A **write-rate** reading when combined with uptime, which matters for area 2 below.

**Threshold:** `Errors (Read)` or `Errors (Write)` > 0 → 🛑 (soldered storage throwing I/O
errors is unfixable). Retries > 0 with Errors = 0 → 📝 note. Because the counters reset at
boot, a **zero here proves almost nothing** if the machine was booted minutes ago — the script
must print uptime alongside them or the number is misleading.

## 1.7 Age proxies that *do* survive, and why they are weak

There is no power-on-hours counter. The closest unprivileged age proxies are:

- **Battery cycle count** (already in the guide) — the best available age proxy, but it tracks
  charge cycles, not drive writes.
- **`pmset -g log`** covers only a rolling ~7-day window (measured: earliest entry
  2026-07-28 for a read taken 2026-08-04) — useless as a lifetime record.
- **Filesystem/OS install date** — trivially reset by an erase, so a seller who reinstalled
  shows a fresh date. Not evidence.

**None of these is a drive-wear figure.** Report the absence honestly rather than substituting a
proxy that looks like wear and is not.

---

# 2. Swap wear

## 2.1 Current swap is readable; historic swap is not **[measured]**

```
$ sysctl vm.swapusage
vm.swapusage: total = 14336.00M  used = 13263.56M  free = 1072.44M  (encrypted)

$ vm_stat
Mach Virtual Memory Statistics: (page size of 16384 bytes)
Pages free:                    3659.
Pages stored in compressor:  3037310.
Pages occupied by compressor: 500086.
Compressions:               99690351.
Decompressions:             89004950.
Pageouts:                     127332.
Swapins:                     2017628.
Swapouts:                    2943660.

$ ls -la /System/Volumes/VM
drwxr-xr-x  16 root  wheel  512 …
-rw-------   1 root  wheel  1073741824 Aug  4 16:02 swapfile0
… swapfile1 … swapfile13     (14 × 1 GiB)
```

| | |
|---|---|
| Commands | `sysctl vm.swapusage` · `vm_stat` · `ls -la /System/Volumes/VM` |
| Runtime | <30 ms combined |
| Install / network | none |
| Sudo | **no** — the directory is `drwxr-xr-x`, so the listing works; the swapfiles themselves are `-rw-------` root and cannot be read, but their **names, sizes and mtimes** are all the script needs |

**All of it is since-boot.** The swapfiles are created on demand *after* boot and destroyed at
shutdown — on this machine boot was 12:33 and `swapfile0` is stamped 16:02, three and a half
hours later. `vm_stat`'s Mach counters likewise reset at boot.

**Answer to the ticket's sub-question: historic swap volume is NOT observable after a reboot.
There is no cumulative, boot-surviving swap or pageout counter on macOS.** A seller who
restarts the Mac before you arrive — which is what anyone does before selling — erases the entire
record. Any check built on swap history is defeated by a reboot, for free, without the seller
even intending to defeat it.

## 2.2 Does swap actually dominate SSD writes? Yes, measurably **[measured]**

This is the one place where the dev's own machine produced a genuinely new number rather than
confirming a known one. Over a single 6 h 09 m boot on a **16 GB** M4 Air under sustained
memory pressure:

| quantity | value |
|---|---|
| `Bytes (Write)` to disk0, since boot | 92.3 GB |
| Swapouts × page size (2,987,168 × 16384) | **45.6 GB** |
| Pageouts × page size (127,368 × 16384) | 1.9 GB |
| **swap share of all SSD writes** | **≈ 51 %** |

Memory pressure was real, not synthetic: `memory_pressure` reported *Pages free: 4604* out of
1,048,576, with 489,185 pages held by the compressor and 13.2 GB of 14 GB of swap in use.

So: **on a memory-pressured Apple-silicon Mac, swap is roughly half of all bytes written to the
soldered SSD.** That is the mechanism the 8 GB worry is built on, and it is real.

**But it does not license the check the ticket was hoping for**, for two independent reasons:

1. **The wear it causes is unreadable** (area 1) — you can prove swap is happening now, and you
   cannot see what it did to the drive.
2. **The history is unreadable** (2.1) — you cannot even prove it happened before you arrived.

Independently reproduced later the same day on the same machine over a **10-minute** window:
Swapouts +1,661,157 pages (**+27.2 GB**) against `Bytes (Write)` +34.1 GB — **≈80% of all disk
writes in that window were swap.** Both measurements agree on the mechanism; the share varies
with how hard the machine is being pushed.

⚠️ **Caveat both figures heavily.** This is a **16 GB** machine, not 8 GB, under an atypical
load (concurrent AI agents), n=1. It demonstrates that **swap can dominate SSD writes on Apple
silicon** — it is not a representative usage figure and says nothing about whether a drive dies.

## 2.2a The one memory signal that **does** survive a reboot **[measured]**

Everything in 2.1 is erased by a restart. There is exactly one exception, and it is worth
having:

```bash
ls /Library/Logs/DiagnosticReports/ | grep -c JetsamEvent
```

`JetsamEvent-*.ips` files are crash-report artefacts written when macOS kills processes under
memory pressure (`"bug_type":"298"`). **They persist across reboots for weeks to months** —
on this machine they span 2026-07-28 → 2026-08-04 on a volume set up 2026-06-25.

| | |
|---|---|
| Runtime | <50 ms · no install · no network · **no sudo** (but see the `_analyticsusers` caveat in §3.2) |
| Threshold | **a pile of JetsamEvent files on an 8 GB machine = it has repeatedly run out of memory** → 💰, reinforcing the RAM-size finding |

**This is the best persistent proxy available, and it is a proxy for under-provisioning, not for
a RAM *fault* and not for drive wear.** Do not overstate it. It also survives only as long as
the seller has not erased the machine.

## 2.3 What this justifies: a RAM-size finding, not a wear finding

The defensible move is to stop trying to measure swap damage and instead treat **RAM size as the
finding**, because RAM is soldered and is the thing the buyer cannot fix:

```
sysctl -n hw.memsize        # bytes
```

| | |
|---|---|
| Runtime | <5 ms · no sudo · no install |
| Threshold | **8 GB → 💰 renegotiate**, as a *capability* limitation, priced as such — not as evidence of drive damage |

Framing it as 💰 rather than 🛑 matters: an 8 GB machine is not broken, it is less machine. The
guide should say plainly that an 8 GB Apple-silicon Mac will swap heavily under modern
workloads, that this writes tens of GB per day to a drive that cannot be replaced, **and that
the resulting wear cannot be measured — which is a reason to discount the price, not a reason to
claim the drive is worn.**

**The best argument for the 8 GB → 💰 threshold is Apple's own reversal, not any forum thread.**
On **2024-10-30** (apple.com/newsroom/2024/10/…) Apple *"double[d] the starting memory to 16GB"*
on M2 and M3 MacBook Air *"while keeping the starting price at just $999"*, and moved the M4
MacBook Pro, iMac and Mac mini to 16 GB base at unchanged prices in the same week — **retiring
8 GB from the entire current Mac line**, five months after an Apple executive argued at WWDC 2024
that 8 GB *"is analogous to 16GB on other systems."* That is a far stronger signal than anything
on a forum, and it is citable.

⚠️ **Do not let the "2–3× more SSD wear on base models" figure into the guide.** It circulates
widely and **traces to nothing** — no credible measured 8 GB vs 16 GB swap-volume comparison
exists from anyone. Oakley asked for one in 2022 and never got it. His own clearly-labelled
*estimate* is that 8 GB with 6–12 GB of swap might mean *"5–6 years instead of 10+."*

**Evidence status: the mechanism is measured first-hand and solid; the "8 GB Macs are dying of
swap wear" claim is NOT verified and should not be repeated as fact. The real 2026 argument
against a second-hand 8 GB machine is usability and remaining supported life, not SSD death.**
See §5 for what the follow-up literature actually found.

---

# 3. Memory faults

## 3.1 There is no unprivileged, install-free RAM test **[measured]**

Nothing on a stock macOS tests DRAM from userspace. `memtest86` is x86/UEFI and does not boot on
Apple silicon at all. `memtester` and `rember` need installation. And per §1.4 the buyer cannot
compile a test on the spot, because `cc`/`swift`/`python3` are the xcode-select shim.

`/usr/bin/memory_pressure` exists and is unprivileged, but it **reports** VM statistics — it does
not test memory integrity:

```
$ memory_pressure
The system has 17179869184 (1048576 pages with a page size of 16384).
Stats:  Pages free: 4604   Pages purgeable: 5   Pages purged: 6502396
Swap I/O:  Swapins: 2053709   Swapouts: 2987168
…
```

## 3.2 Historic evidence of memory faults: panic logs, with a permissions catch **[measured]**

```
$ ls -ld /Library/Logs/DiagnosticReports
drwxrwx---  63 root  _analyticsusers  2016 Aug  4 16:39 /Library/Logs/DiagnosticReports
```

The directory is **`drwxrwx---` root:_analyticsusers** — group-readable only.

```
$ id -Gn | grep -E 'analytics|admin'
staff admin _lpadmin _analyticsusers
```

Admin users are in `_analyticsusers`, so an admin can read it **without sudo**. A **standard
(non-admin) user cannot.** At a shop the buyer is typically handed an admin session, so this
usually works — but the script must **handle the failure gracefully and say which case it hit**,
rather than reporting "no panics found" when it actually means "could not look".

On this machine, 61 reports, none of them kernel panics:

```
54 .diag   4 .shutdownStall   1 .ips   1 .Retired   1 .DiagnosticLogs
```

| | |
|---|---|
| Command | `ls /Library/Logs/DiagnosticReports/ 2>/dev/null \| grep -icE '\.panic\|\.ips'` |
| Runtime | <50 ms |
| Install / network | none |
| Sudo | no, **but** requires membership of `_analyticsusers` (= admin) |
| Threshold | repeated kernel panics → 🛑 · isolated panic → 📝 · **unreadable → say so, do not report a pass** |

**Panic logs are mostly gone anyway.** Howard Oakley
(eclecticlight.co/2025/04/15/save-and-read-the-panic-log/, 2025-04-15): panic logs *"used to be
saved in /Library/Logs/DiagnosticReports … more recently were found somewhere closer to
/var/db/PanicReporter, but **now seem to vanish into thin air.**"* Confirmed here: zero `.panic`
files, zero panic-type `.ips`, and `/var/db/PanicReporter` **exists, is world-readable (0777),
and is completely empty**. **A buyer cannot rely on finding historic panic logs on a modern
macOS machine.**

**And if one *is* present, it will not name a RAM fault.** Apple-silicon panic logs contain no
DRAM/ECC/memory-fault fields. The field most often misread as bad RAM is
`zalloc: zone map exhausted … likely due to memory leak` — that is a **software** leak.
Genuinely useful fields: `secure boot?: YES` (no third-party kexts → software cause less
likely), and third-party kexts at the top of `loaded kexts:` (→ suspect software first).

## 3.2a Apple silicon reports no corrected memory errors, at all **[measured]**

```
$ sysctl -a | grep -icE "machine_check|mcheck|memory_error|ecc"
0
```

**Zero.** No machine-check, ECC, or corrected-error sysctl exists on macOS 26.5.2 / M4. There is
no `mcelog` equivalent.

The reason is architectural: LPDDR5 has **on-die ECC**, which is internal to the DRAM die and —
unlike server sideband/registered ECC — **does not report corrected errors to the host OS.**

**Guide line: an Apple-silicon Mac cannot tell you it has been having corrected memory errors.
The information does not exist above the DRAM die.** ⚠️ Contested detail, immaterial to the
buyer: whether Apple additionally implements *link* ECC is unconfirmed — nothing is exposed to
software either way.

⚠️ **Trap for anyone implementing this:** grepping the unified log for `ECC` returns pages of
**Bluetooth/AirPods** records (`… ECC 3, MCCp 1 …`), not memory. A buyer grepping for ECC will
get confident-looking false hits.

## 3.3 Apple Diagnostics — the only real RAM test, and macOS 26 changed it

**Invocation on Apple silicon**, verified against Apple's own page
(support.apple.com/en-us/102550, *"Use Apple Diagnostics to test your Mac"*, published
2025-12-19): shut down → **press and hold the power button** (Touch ID on laptops that have it)
→ **release when "Options" appears** (do not click Options) → **hold Command-D until the Mac
restarts**. Prep: disconnect externals except keyboard/mouse/display/Ethernet/power.

**⚠️ The change nobody's buying guide has caught up with.** Apple's page, updated 2025-12-19:
*"In macOS Tahoe 26 and later, **you're asked to choose a specific diagnostic to run**, such as
a diagnostic for your built-in display, keyboard, or trackpad. In earlier versions of macOS,
this is automatic."* **On a 2026 second-hand Mac running macOS 26, the buyer must actively
select the memory test — the full automatic sweep is no longer the default.** Any instruction
that says "run it and read the code" is now wrong.

**Memory reference codes — the ticket's assumed codes were wrong.** Per Apple's current list
(support.apple.com/en-us/102334, published 2025-12-15):

| code | meaning |
|---|---|
| **PPM002 – PPM016** | *"There may be an issue with the **onboard memory**"* — **this is the Apple-silicon walk-away code** |
| PPM001 | *"issue with a **memory module**"* — a socketed DIMM, **cannot occur on a soldered Apple-silicon laptop** |
| ADP000 | *"No issues found."* |
| NDR001 / NDR003 / NDR004 | **trackpad**, not memory |
| NDM001 / NDM002 | **do not exist** on Apple's current list |

**Threshold: any PPM002–PPM016 → 🛑 walk away** (RAM is soldered; unfixable at any sane price).

**Runtime:** Apple says "a few minutes"; real reports cluster at **<2 min (M1 Air, Reddit,
2020-12)** to **3–5 min**. But **budget 10–15 minutes of wall clock** — shutdown, boot to
Options, language, T&Cs, the macOS 26 diagnostic picker, reboot, and the seller logging back in.
**In a 20-minute visit that is most of your time.**

**It does not need the seller's password** (Diagnostics runs from a volume not protected by
FileVault) — but the seller must log back into macOS afterwards. **It changes nothing and wipes
nothing**; it is read-only. Do not confuse it with **DFU Restore**, which *does* wipe everything.

**⚠️ Network is genuinely contested.** Apple (2025-12-19): *"you might be given the option to run
diagnostics offline. In that case, click Run Offline."* Oakley (2025-08-22): it *"may require
download of the disk image from Apple's servers … so a good Wi-Fi connection is important."*
**Do not promise a no-network buyer it will work — bring a phone hotspot.**

**⚠️ Its main limitation is exactly the fault class that matters here.** Oakley
(eclecticlight.co, 2019-09-23): ***"Memory faults are commonly intermittent, and can persist
even though diagnostics claims that they're fine."*** And: *"a zero code or ADP000 … **does not
prove absolutely that your Mac doesn't have a hardware fault.** Some faults are intermittent,
others **only manifest when your Mac is warm or cold**."* Restated for Apple silicon
(2025-08-22): the tests *"don't always catch problems, particularly in their early stages."*

**Actionable consequence, and it interacts with area 4:** a shop machine has usually been sitting
cold and idle — the **worst** condition for catching a thermally-triggered marginal fault. If
Diagnostics is going to be run at all, **run it after the load test, not before.** That ordering
is free and roughly doubles its value.

⚠️ Two thin threads, flagged: a **hidden extended test via Command-E** is documented by **exactly
one source** (Oakley, 2025-08-22) and by Apple nowhere — worth trying, not worth relying on. And
I found **no documented case of "ADP000 then confirmed bad RAM"**; the intermittent-miss
limitation is well attested in general terms, but that specific link is inferential.

**❌ The NVRAM shortcut is dead on Apple silicon [measured].** The widely-repeated Intel-era
trick of reading the last Diagnostics result without rebooting does not work:

```
$ nvram -p | grep -iE "aht|diag"
prev-lang-diags:kbd    en          ← only this; no aht-results
$ system_profiler SPDiagnosticsDataType
(empty)
```

`nvram -p` reads fine with no sudo, but there is **no `aht-results` variable** and
`SPDiagnosticsDataType` is **empty** on M4 / macOS 26.5.2. ⚠️ This machine may never have
completed a Diagnostics run, so absence is not conclusive — but treat the shortcut as dead until
someone verifies it on a machine that has.

**Verdict for the deliverable: Apple Diagnostics cannot be run *by* `check.sh` — it needs a
shutdown, so the script that is running would have to end.** It can only be *recommended by*
it. The honest design is for the script to state that RAM integrity is one of the things it
cannot test, and to leave Diagnostics as an explicit, optional, buyer-initiated step **at the
end** of the visit, after the load test, if the price justifies the minutes.

## 3.4 Nothing else tests RAM — vendor-confirmed

**MemTest86 cannot run on Apple silicon**, from PassMark's own admin on PassMark's own forum
(forums.passmark.com/memtest86/56523, 2024-01-16): *"**Memtest86 cannot boot from these
machines.** … **So no hardware testing for Apple users at the moment.**"* It is UEFI-boot; Apple
silicon provides no such path.

| tool | Apple silicon? | install | sudo |
|---|---|---|---|
| MemTest86 | ❌ **no** (vendor-confirmed) | USB boot | — |
| Rember | ❌ abandoned, PowerPC/Intel-era | — | — |
| memtester | compiles, but **userspace only** — tests only what it can `malloc`, never the kernel-resident or in-use pages where faults hide | Homebrew | yes, to lock pages |
| Techtool Pro / ATOMIC | ✅ the only real option | paid | yes |

MacRumors, 2026-03-07: *"**I am not aware of any memory testing tools for Apple Silicon Macs.**"*

**Bottom line: under the map's constraints there is NO way to actively test RAM other than Apple
Diagnostics. The guide should say so plainly rather than implying coverage it does not have.**

---

# 4. Thermal behaviour

## 4.1 `pmset -g therm` is dead on Apple silicon **[measured]**

```
$ pmset -g therm
Note: No thermal warning level has been recorded
Note: No performance warning level has been recorded
Note: No CPU power status has been recorded
```

All three lines, on a machine that was under heavy sustained load at the time. This is the
Intel-era CPU-speed-limit interface and it reports **nothing** on Apple silicon.

Likewise the Intel throttle sysctls are simply absent:

```
$ sysctl -a | grep -iE 'thermal|xcpm'
(no output)
$ sysctl hw.cpufrequency hw.cpufrequency_max
(both missing; only hw.tbfrequency: 24000000 exists)
```

**So: CPU clock speed is not readable on Apple silicon, privileged or not, and `pmset -g therm`
must not be shipped.** Anything in the guide that suggests reading a speed limit is wrong.

## 4.2 The shippable throttling signal: `notifyutil` thermal pressure **[measured]**

This is the answer to "is throttling observable **without** third-party tools and **without**
sudo?" — **yes, and it is nearly free.**

```
$ notifyutil -g com.apple.system.thermalpressurelevel
com.apple.system.thermalpressurelevel 1
```

| | |
|---|---|
| Command | `notifyutil -g com.apple.system.thermalpressurelevel` |
| Runtime | **8 ms** (measured) |
| Install / network | none |
| Sudo | **no** |

`/usr/bin/notifyutil` is part of the base OS, not Command Line Tools: it is a real 120,688-byte
binary with a link count of 1 (contrast the 78-link xcode-select shim in §1.4), living on the
SIP-sealed system volume with the OS install mtime.

**The value scale, from Apple's own SDK header on this machine** —
`/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk/usr/include/libkern/OSThermalNotification.h`:

```c
typedef enum {
#if TARGET_OS_OSX || TARGET_OS_MACCATALYST
        kOSThermalPressureLevelNominal = 0,
        kOSThermalPressureLevelModerate,
        kOSThermalPressureLevelHeavy,
        kOSThermalPressureLevelTrapping,
        kOSThermalPressureLevelSleeping
#else
        … iOS uses 0/10/20/30/40/50 …
#endif
} OSThermalPressureLevel;
```

**On macOS the scale is 0 = Nominal, 1 = Moderate, 2 = Heavy, 3 = Trapping, 4 = Sleeping.**
(The header must be read on a machine that has CLT; the *runtime* command needs nothing.)

**It moves, and I watched it move through three levels on a fanless M4 Air:**

| when | `loadavg` | level |
|---|---|---|
| near idle, early in session | ~1 | **0** Nominal |
| sustained multi-core load | ~10 | **1** Moderate |
| heavy sustained all-core load | 20–33 | **2** Heavy |

**This is the single most valuable finding in area 4** and it is what should replace the
unreadable fan RPM.

### ⚠️ The correction that matters: level 2 is NORMAL on a fanless Air

An earlier draft of this document proposed *"thermal pressure ≥ 2 → 💰"*. **That threshold is
wrong and would have flagged every healthy MacBook Air.** Measured on this machine — a
perfectly healthy M4 Air — under sustained all-core load:

```
t=10s load={20.34 …}  thermal=2
t=20s load={23.29 …}  thermal=2
t=30s load={26.88 …}  thermal=2
t=40s load={29.17 …}  thermal=2
t=50s load={30.76 …}  thermal=2
t=60s load={31.96 …}  thermal=2
t=70s load={31.33 …}  thermal=2
t=80s load={32.49 …}  thermal=2
```

**Level 2 (Heavy) held steady for 80+ seconds and never progressed to 3.** The machine stayed
responsive throughout and returned to lower levels when the load stopped. A fanless chassis
reaching Heavy under an all-core load is **the design working**, not a fault.

**The corrected reading of the scale for buying purposes:**

| level | meaning under sustained load |
|---|---|
| **0–1** | comfortably within envelope |
| **2** Heavy | **normal for a fanless Air under all-core load** · on a **Pro** it is worth pairing with "are the fans actually spinning?" |
| **3** Trapping | the system is taking emergency measures — **abnormal**, 💰 at minimum |
| **4** Sleeping | thermal shutdown imminent — 🛑 |

⚠️ **Levels 3 and 4 were never observed.** Their severity is taken from Apple's header semantics
and from what the names mean, **not** from an observed failure. That is the main residual
uncertainty in area 4, and the guide should not pretend otherwise.

**What this also demonstrates: the plateau is the signal.** A healthy machine climbs to a level
and *stays there*. A machine whose cooling has degraded should keep climbing. That is a shape,
not a number, and it is why the script should **sample repeatedly and report the trajectory**
rather than take a single reading.

## 4.3 What the README's `yes`-loop actually proves **[measured, 25 s version]**

The current `README.md` §"Step 3 — Stress test the fans (6 min)" ships:

```bash
for i in {1..8}; do yes > /dev/null & done; sleep 300; killall yes
```

with the surrounding text *"This is the whole reason you're buying a Pro instead of an Air"*,
*"It pins all 8 performance cores for 5 minutes"*, *"open **Activity Monitor** → **CPU** tab"*,
and under **Walk away if**: *"**Total silence.** Dead or unplugged fans."*

**Defect 0 — it is scoped to a Pro by construction.** *"the whole reason you're buying a Pro
instead of an Air"* was fine when the README targeted one 16" M1 Pro. Under the redrawn map
(M1–M5, **Air and Pro**) this entire step has no Air branch at all, and its walk-away rule is
actively wrong there (§4.5).

**Defect 1 — the hardcoded 8, and the claim about it is false.** *"It pins all 8 performance
cores"* is not what happens. This M4 Air has **4** performance cores and 6 efficiency cores;
the M1 Pro the README was written for has 8 P + 2 E; an M4 Max has more. Eight `yes` processes
pin *eight schedulable threads*, which is not the same as eight P-cores, and the number is wrong
on nearly every machine in the supported range. The portable replacement is measured and free:

```
$ sysctl -n hw.logicalcpu hw.nperflevels
10
2
$ sysctl -n hw.perflevel0.name hw.perflevel0.physicalcpu \
              hw.perflevel1.name hw.perflevel1.physicalcpu
Performance  4
Efficiency   6
```

`hw.logicalcpu` is the count to spawn; `hw.perflevel*` additionally tells you the P/E split,
which is worth printing.

**Defect 2 — `yes > /dev/null` is a weak thermal load.** Measured composition on this machine:

```
$ /usr/bin/time -p sh -c 'yes | head -n 50000000 > /dev/null'
real 2.96   user 2.57   sys 0.11
```

It is a tight integer/`memcpy` loop with no vector, FP or memory-subsystem work. It occupies
cores without exercising the parts of the SoC that produce peak power draw. It is the *cheapest*
way to make a core busy, which is not the same as the *hottest*.

**Defect 3 — 300 seconds is asserted, not derived.** My own 25-second run is too short and too
contaminated to settle it.

**⚠️ The P-core / E-core question is NOT resolved, and I want to be explicit about that.** A
reasonable worry is that shell-launched background jobs inherit a low QoS and get parked on
efficiency cores, in which case the load test would barely heat the P-cores and prove little.
I could not settle it:

- **Per-core residency needs `powermetrics`, which is root-only** — so the direct observation is
  unavailable under this project's constraints, permanently.
- `/usr/sbin/taskpolicy` **is** a real base-OS binary (link count 1, not the shim) and **runs
  unprivileged** — but its `-c <clamp>` / `-b` / `-t` options **lower** QoS. There is no
  unprivileged way to *raise* a process above the shell's default.

What can be said: a Terminal-launched job inherits the shell's default QoS, not a background
one, so it should be eligible for P-cores — but **"should be" is inference, not measurement.**
This is the weakest link in area 4 and it argues for using a load that is unambiguously heavy
(§4.4) rather than relying on `yes` being scheduled well.

**What the 25-second run does prove** (10 × `yes`, `hw.logicalcpu` = 10, on the fanless M4 Air,
machine already at `loadavg` 9.98 from concurrent agents):

```
cores=10  baseline_thermal=1  load={ 9.98 9.98 7.64 }
t=5s   thermal=1  yes[0]_cpu=41.4%  cputime=0:02.16  loadavg={10.38 10.06 7.68}
t=10s  thermal=1  yes[0]_cpu=28.0%  cputime=0:03.63  loadavg={10.75 10.14 7.72}
t=15s  thermal=1  yes[0]_cpu=33.9%  cputime=0:05.30  loadavg={14.05 10.84 7.98}
t=20s  thermal=1  yes[0]_cpu=33.4%  cputime=0:07.18  loadavg={14.77 11.04 8.07}
t=25s  thermal=1  yes[0]_cpu=39.5%  cputime=0:09.11  loadavg={16.79 11.52 8.26}
after_kill thermal=1
```

Honest reading: the per-process CPU figures are **worthless** here because the machine was
already oversubscribed. What it does establish is that the **sampling harness works** — thermal
pressure can be polled cheaply at intervals during a load test from plain shell, with no sudo,
and correlated against elapsed time. **The 25 s run did not move thermal pressure**, which is
consistent with 25 s being too short, but on a contaminated machine it is not proof either way.

## 4.4 A better load, and a way to *measure* the throttle rather than infer it

Stock, no-install CPU load candidates, all measured on this machine:

```
$ time (dd if=/dev/zero bs=1m count=2000 2>/dev/null | shasum -a 256 >/dev/null)
6.39s user  1.75s system  96% cpu   8.461 total
$ time (dd if=/dev/zero bs=1m count=2000 2>/dev/null | md5 >/dev/null)
3.55s user  0.81s system  94% cpu   4.617 total
$ time (yes | head -n 50000000 >/dev/null)
2.64s user  0.12s system  81% cpu   3.406 total
$ time openssl speed -evp aes-256-gcm     # LibreSSL 3.3.6
10.72s user 0.17s system  72% cpu  15.031 total
```

Two useful conclusions:

- **`openssl speed` is a poor stress test on Apple silicon.** It reported 150.9 GB/s at the
  8 KB block size, because `hw.optional.arm.FEAT_AES = 1` — it runs in the dedicated crypto
  units at low power and barely heats the general-purpose pipeline. It is also 15 s per run and
  Apple ships **LibreSSL 3.3.6**, whose `speed` subcommand **does not support `-seconds`**, so
  the runtime cannot be shortened. Do not use it.
- **`dd | shasum -a 256` is the best stock heavy load**: real ALU work, 96% CPU, no disk writes
  (`/dev/zero` in, `/dev/null` out — important, because the script must not wear the seller's
  drive while testing it), and available everywhere.

**The stronger idea, which the current guide does not have at all: measure throttling as a
throughput drop instead of guessing at it.** Run one fixed unit of work at t=0 and the same unit
at the end of the load, and compare wall times. This is chip-agnostic, needs no clock readout
(which §4.1 shows does not exist), no sudo, no install, and works identically on Air and Pro:

```
# repeatable ~3 s single-threaded probe, measured above
/usr/bin/time -p sh -c 'yes | head -n 50000000 > /dev/null'
```

A machine that is thermally healthy shows a modest, *plateauing* slowdown. A machine with
degraded cooling shows a large and *continuing* slide.

### Grade on `user` CPU time, not wall time **[measured]**

The obvious implementation — compare wall-clock times — is the wrong one, and I have a
measurement that shows why. The same probe, run three times while the machine was at
`loadavg` 34 from unrelated work:

```
2.35s user 0.05s system 54% cpu  4.411 total
2.36s user 0.05s system 56% cpu  4.284 total
2.32s user 0.05s system 64% cpu  3.683 total
```

against an earlier baseline of `2.64s user … 3.406 total`.

**Wall time moved by 8–29%. User CPU time did not move at all** (it was in fact slightly lower).
Wall time absorbed the scheduling contention; user time did not, because time spent waiting for
a runnable core is not charged to the process.

This is exactly the discrimination the check needs:

- **contention** (background apps, Spotlight indexing, the seller's Dropbox syncing) inflates
  **wall** time and is *noise*;
- **clock throttling** inflates **user** time, because the same work occupies the core for more
  seconds — and that is the *signal*.

**So: `/usr/bin/time -p`, compare the `user` field.** It makes the probe robust on a seller's
machine that you do not control and cannot quiesce — which is the realistic shop condition.

⚠️ **Flagged honestly: I proved the noise-rejection half, not the signal half.** These runs show
user time is insensitive to contention. I did **not** produce a throttled machine and watch user
time rise, because that needs a sustained load on a quiet machine. The mechanism is sound and
the metric is strictly better than wall time, but **the threshold is uncalibrated.**

**Threshold — proposed, explicitly NOT calibrated:** grade on end-probe ÷ start-probe **user**
time. I do not have clean enough data to set the boundary, because this machine was contaminated
throughout by concurrent work. **This needs one clean run on an idle Air and an idle Pro before
`check.sh` ships a number, and it is the main open item this research did not close.**

## 4.5 The fanless Air — what replaces "fans audible"

Every MacBook Air M1–M5 is fanless (already established on the map by
[#13](https://github.com/mingrath/mbcheck/issues/13)). **Confirmed here from the other
direction: there is no fan anywhere in the IORegistry on this M4 Air.**

```
$ ioreg -l -w0 | grep -o -i '"[^"]*fan[^"]*"' | sort -u
(no output)
```

**So the README's rule — verbatim, *"**Total silence.** Dead or unplugged fans — the single most
expensive failure mode"* — is not merely imprecise for Airs. On an Air, silence under load is
the only correct outcome.** A buyer applying that rule to any Air M1–M5 walks away from a
perfectly good machine, every time. The final checklist repeats it (*"Fans audible under load,
no shutdown"*). **This is a live defect in the shipped README, not a theoretical one**, and it is
the highest-value single correction this research produced.

**Detecting whether the machine has a fan at all.** The obvious `hw.model` prefix test is
**broken on modern Macs** — measured:

```
$ sysctl -n hw.model
Mac16,13
```

M4-era identifiers are `MacNN,N`, *not* `MacBookAir10,1`. A script doing
`hw.model | grep '^MacBookAir'` silently fails on every M4 and M5 Air and treats it as a Pro.
The working route is the human-readable name:

```
$ system_profiler SPHardwareDataType | awk -F': ' '/Model Name/{print $2}'
MacBook Air          # elapsed 192 ms
```

| | |
|---|---|
| Command | `system_profiler SPHardwareDataType \| awk -F': ' '/Model Name/{print $2}'` |
| Runtime | 192 ms · no sudo · no install |

**What the script should tell the buyer, branching on that one string:**

| | **MacBook Air (fanless)** | **MacBook Pro (has fans)** |
|---|---|---|
| Correct behaviour under load | **Silent.** Chassis becomes hot, especially above the keyboard and on the underside. Sustained performance drops and then **plateaus**. | Fans **audibly spin up** and stay up; chassis warm but not painful. |
| 📝 note | Warm to the touch — expected, say so explicitly so the buyer does not misread it as a fault | Fans already audible **at idle**, before the load starts |
| 💰 renegotiate | — | Fan noise that is rattling, grinding or scraping rather than rushing air (fan/bearing is a serviceable part) |
| 🛑 walk away | **Machine shuts down, hard-freezes, or kernel-panics under load** · or thermal pressure reaches **4 (Sleeping)** | Fans **never** spin up at all *and* pressure keeps climbing · or shutdown/freeze/panic |

**The replacement signal for "fans audible" on an Air is the pair (thermal pressure trajectory,
did it survive).** Silence carries no information on an Air; *completing the load run without
shutting down, freezing or panicking* is the actual pass condition, and
`notifyutil -g com.apple.system.thermalpressurelevel` is the readable half.

**Threshold on the readable half — corrected against measurement (§4.2):** on an Air, reaching
**0, 1 or 2** under sustained load is **normal and must be reported as OK**; this healthy M4 Air
sat at **2 (Heavy)** for 80+ seconds without degrading. Only **3 (Trapping)** → 💰 and
**4 (Sleeping)** → 🛑, and a level that **keeps climbing rather than plateauing** is the shape to
watch.

**⚠️ The single most dangerous thing the guide could ship here is a threshold set at level 2.**
It looks alarming, it is the obvious place to draw the line, and it would tell buyers to walk
away from healthy Airs.

## 4.6 Thermal and shutdown history is effectively unreadable **[measured]**

I tried hard to find a boot-surviving record of past thermal shutdowns. It is not there.

**`log show` is disqualified on runtime alone:**

```
$ log show --predicate 'eventMessage CONTAINS "Previous shutdown cause"' --last 7d --style compact
elapsed: 336s        ← and returned nothing
```

```
$ log show --start <boot-60s> --end <boot+240s> \
      --predicate 'eventMessage CONTAINS[c] "shutdown cause"' --style compact
elapsed: 93s         ← and returned nothing
```

Two separate problems: **336 seconds for a 7-day window, and 93 seconds even for a 5-minute
window** — the cost is scanning the archive, not the window size. That alone exceeds the entire
budget of a shop visit. And on macOS 26.5.2 the query **returned no "Previous shutdown cause"
line at all** at default log level. `log show` should not appear in `check.sh`.

**`pmset -g log` is fast but carries no thermal data:**

```
$ pmset -g log     # 7 s, 65,447 lines, no sudo
$ grep -ic thermal <that output>
0
```

Its content is Assertions (61,736 lines), Kernel, Wake/Sleep/DarkWake, HibernateStats — a
**sleep/wake reliability** record, not a thermal one. Its window is also only ~7 days (earliest
entry 2026-07-28 for a read on 2026-08-04).

It is still worth one cheap grep for sleep/wake **failures**, which is a genuine fault signal —
just not the one this section was looking for.

**Also present and free:** 4 × `.shutdownStall` reports in `/Library/Logs/DiagnosticReports`
(subject to the `_analyticsusers` caveat in §3.2). A stall is a hang at shutdown, not a thermal
event; treat repeated ones as 📝.

**Conclusion for area 4's history question: there is no unprivileged, fast, boot-surviving
record of prior thermal shutdowns. The load test is the only way to learn how the machine
behaves hot, which is precisely why it has to earn its minutes.**

---

# 5. Source review — claims this research did *not* settle first-hand

Everything above marked **[measured]** is first-hand from an M4 Air on macOS 26.5.2. The items
below depend on external sources and are recorded separately so the map does not mistake them
for measured facts.

## 5.1 The 2021 SSD-swap-wear controversy — what actually happened

The ticket dated this to 2022–2023. **It began 2021-02-16**, weeks after the first M1 Macs
shipped. Timeline: 2021-02-16 first report → 2021-02-23 mainstream pickup → 2021-03-11 first
rebuttal → macOS 11.4 "fix" (2021-05-24) → Oakley's measurement series Nov–Dec 2022 → the
1.45 PB datapoint Feb 2023. The "2023 wave" was the same MacRumors mega-thread rolling on,
entangled with a **separate** M2 story (256 GB M2 Airs using a single NAND die = *slower*, a
performance issue, not wear).

**Origin** — MacRumors user "Forti", 2021-02-16 (thread now 3,550+ posts): M1 Mac mini,
256 GB/16 GB, **8 days old → 0.9 TB written** (~115 GB/day). His dump also showed
`Percentage Used: 0%`, `Media and Data Integrity Errors: 0`, and `Power On Hours: 22` after
8 days — an obviously broken value that became the backbone of the "the tool is misreading the
drive" counter-argument. **The load-bearing assumption was never sourced**; Forti himself:
*"From what I found on the web this ssd should last for ~150 TBW… but once again — no one
knows it."*

**Four rebuttals, routinely conflated:**

1. **The TBW assumption was far too low** — Macworld/9to5Mac, 2021-03-11: *"the 256GB SSD will
   reach **300TBW with ease**, and quite likely more."* Explicitly industry scuttlebutt, no
   measurements — and per §1.5a even this was a ~5× underestimate.
2. **The SMART data was broken** — AppleInsider, 2021-02-23 and 2021-06-04, citing **an unnamed
   Apple employee "not authorized to speak on behalf of the company"**: *"a data reporting error
   within the tools… not believed to be an actual hardware issue."*
3. **⚠️ THE CONTESTED CORE, NEVER RESOLVED.** (2) and Hector Martin's account are
   **incompatible** and both were reported as fact. Martin declared it fixed in 11.4 *before*
   identifying it (*"It's going to be interesting diffing the XNU kernel source… and seeing what
   the bug was"*). **No XNU diff or post-mortem was ever published.** Cutting the other way, a
   MacRumors user found **Apple's own Mac Analytics Data contained a life-percentage agreeing
   with DriveDx**, undercutting "third-party tools are wrong." **Apple has never said anything
   publicly.** Safest phrasing for the guide: *macOS 11.4 materially reduced reported swap/write
   volumes; nobody outside Apple has established whether the fix was in the VM subsystem, in
   SMART reporting, or both.*
4. **A real units error, but not the one people think** — Oakley corrected himself
   (eclecticlight.co, 2022-12-05 and 2022-12-13) after checking NVMe Base Spec 2.0: Data Units
   Written is reported *"in thousands"*, a 1000× factor. **But `smartctl` already applies this
   correctly** — the bracketed `[1.03 TB]` in the forum dumps was right. **Claims that "the whole
   panic was a units misread" are overstated.**

**⚠️ Hector Martin's primary sources are now unretrievable.** A targeted search returned zero
results — he has left/purged X. **Every Martin quote in circulation is second-hand**, including
the ones above. Note he was **not** alarmed by his own machine (*"I'm at <600GBW on my MBP"*) and
**walked back** his own 30%-wear estimate: *"later analysis indicated that endurance ratings
aren't necessarily proportionate to drive size."* Do not cite him as if the thread is readable.

## 5.2 Did any drive actually die? No confirmed case — but the absence is weaker than it looks

- r/macbook, 2024-01-07, *"How many base m1 models did die from the SSD wear issue?"* —
  **19 comments, zero confirmed cases**: *"It's been almost 3 years and I have heard absolutely
  nothing about actual users experiencing actual widespread SSD failure."*
- **No Apple repair programme exists.** Strong signal: SSD replacement requires a **logic-board
  swap** — expensive and highly visible. Apple could not have hidden it.
- Oakley (2026-02-26) describes the cohort in the past tense with no deaths — *"some were
  getting worryingly **close to** the end of their expected working life."* Close to, not
  reached. He also revised his endurance estimate up to ***"at least 3,000 erase-write
  cycles."***

⚠️ **Why this is weaker than it looks:** a worn soldered SSD presents as *"my Mac won't boot /
logic board failure"*, so such failures would be **systematically misattributed and invisible**.
There is **no Backblaze-equivalent for Mac internal SSDs, no Apple service data, and nobody has
resurveyed the 2020–21 M1 cohort in 2025–26.**

**Recommended phrasing for the README explainer:** *"Five years on, no confirmed pattern of
M1/M2 Macs failing from write exhaustion has surfaced, no Apple repair programme exists, and
endurance estimates have been revised upward roughly fivefold. But nobody has run the study that
would settle it and Apple publishes no service data — this is 'no evidence of harm', not
'demonstrated safe'."*

## 5.3 Unified-log retention — why history questions mostly fail **[measured]**

`/usr/bin/log stats` on this machine (⚠️ takes ~10 minutes — never run it in a shop):

```
start: Sat Jul 25 23:52:08 2026     end: Tue Aug  4 18:43:05 2026    ← ~10 days
size: 2,627,855,664 bytes (11.9 GB uncompressed), 58,887,278 events
ttl:  1day 3days 7days 14days 30days
```

**~10 days of history, not months.** A fault from six months ago is simply not in there. This
compounds the runtime problem in §4.6 — the unified log is both too slow to query and too short
to answer the questions a buyer has.

⚠️ **Two traps for anyone implementing a log query:** zsh has a **`log` builtin**, so a script
must call `/usr/bin/log` explicitly or get `too many arguments`. And
`log show --start "2026-07-01" --end "2026-07-02"` **silently returned events dated 2026-08-04** —
out-of-range requests do not error, they return current data.

## 5.4 Permissions on the diagnostic directories — the common claim is wrong **[measured]**

`/Library/Logs/DiagnosticReports` is **not** world-readable. It is mode **0770**, group
`_analyticsusers`. Traced why a normal admin can still read it:

```
$ dscl . -read /Groups/_analyticsusers NestedGroups
NestedGroups: ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050
$ dscl . -read /Groups/admin GeneratedUID
GeneratedUID: ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050      ← identical
```

**`_analyticsusers` nests the entire `admin` group.** So: **any admin user reads it with no
sudo; a standard (non-admin) user cannot.** Same for `/var/db/diagnostics` (root:admin) — which
is why `log show` works without sudo **only for admin accounts**. Say *"admin, no sudo"*, not
*"world-readable"*.

---

# 6. The shippable set

**Free, script-read, no sudo, no install, no network — total cost well under one second:**

| what | command | grade on |
|---|---|---|
| SSD pass/fail | `system_profiler SPNVMeDataType \| grep 'S.M.A.R.T'` | ≠ `Verified` → 🛑 |
| I/O errors since boot | `ioreg -rd1 -c IOBlockStorageDriver -w0` → `Errors (*)`, `Retries (*)` | Errors > 0 → 🛑 · Retries > 0 → 📝 |
| uptime (context for the above) | `sysctl -n kern.boottime` | print always; a short uptime voids the zero |
| RAM size | `sysctl -n hw.memsize` | 8 GB → 💰 |
| current memory pressure | `sysctl vm.swapusage` · `vm_stat` | context only, not a grade |
| **past memory exhaustion (survives reboot)** | `ls /Library/Logs/DiagnosticReports/ \| grep -c JetsamEvent` | many, on an 8 GB machine → 💰 |
| core topology (drives the load test) | `sysctl -n hw.logicalcpu hw.nperflevels hw.perflevel*.name` | never hardcode 8 |
| Air or Pro | `system_profiler SPHardwareDataType \| awk -F': ' '/Model Name/{print $2}'` | selects the fanless branch |
| thermal pressure (sample repeatedly) | `notifyutil -g com.apple.system.thermalpressurelevel` | 0–2 normal · **3 → 💰** · 4 → 🛑 · not plateauing → 💰 |
| panic history | `ls /Library/Logs/DiagnosticReports/` | repeated panics → 🛑 · unreadable → say so |
| sleep/wake failures | `pmset -g log \| grep -i failure` | 7 s; failures → 📝 |

**Load test — the only part that costs the buyer minutes:**

- spawn `$(sysctl -n hw.logicalcpu)` × `dd if=/dev/zero bs=1m count=… | shasum -a 256`,
  **never** a hardcoded 8, and **never** anything that writes to the seller's disk;
- poll `notifyutil -g com.apple.system.thermalpressurelevel` every 15 s (8 ms each, free);
- run the fixed probe `/usr/bin/time -p sh -c 'yes | head -n 50000000 > /dev/null'` **before and
  after** and compare the **`user`** field, not wall time (§4.4);
- **on an Air, tell the buyer silence is correct and the chassis will get hot**; the pass
  condition is finishing without shutdown, freeze or panic.

**Explicitly recommended *against* shipping, with reasons, so it is not re-litigated:**

- `pmset -g therm` — records nothing on Apple silicon (§4.1)
- `log show` — 336 s for 7 days, 93 s for a 5-minute window, ~10-day retention, and returned
  nothing anyway (§4.6, §5.3)
- `openssl speed` — hardware-accelerated, barely heats the SoC, 15 s fixed runtime, and Apple's
  LibreSSL has no `-seconds` (§4.4)
- `swift` / `cc` / `python3` — the xcode-select shim; prompts for a network install (§1.4)
- `smartctl` — the one genuinely tempting exception; needs Homebrew + network + the seller's
  consent to modify their machine (§1.3a)
- `log stats` — ~10 minutes (§5.3)
- `hw.model` prefix matching for Air/Pro — **broken on M4+** (§4.5)

**What is NOT readable, and must be stated as such rather than papered over:**

1. **SSD wear — TBW, percentage used, power-on hours.** The data exists and is readable
   *without root*, but **only** through an IOKit user client that no stock binary opens, and the
   compiler that would let you write one is behind the xcode-select shim. Not a privilege
   problem — a tooling problem.
2. **Historic swap volume.** Reset by every reboot; a seller restarting the Mac erases it
   without trying.
3. **RAM integrity.** No stock userspace test; Apple Diagnostics needs a reboot and so cannot
   be part of `check.sh`.
4. **CPU clock / speed limit.** `hw.cpufrequency` and the `xcpm` sysctls do not exist on Apple
   silicon; `pmset -g therm` records nothing.
5. **Fan RPM** — already established on the map; this research adds that on an Air **there is
   no fan node in the IORegistry at all**, so it is not merely privileged, it is absent.
6. **Prior thermal shutdowns.** `log show` is both too slow (336 s) and empty; `pmset -g log`
   has no thermal entries and only a ~7-day window.
7. **Corrected memory errors.** Zero machine-check/ECC sysctls exist; LPDDR5 on-die ECC does not
   report to the host. The information does not exist above the DRAM die.
8. **Prior kernel panics, reliably.** Panic logs *"vanish into thin air"* on modern macOS;
   `/var/db/PanicReporter` was empty here. And a panic log would not name a RAM fault anyway.
