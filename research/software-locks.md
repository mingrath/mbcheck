# Every software lock that can make a second-hand Apple-silicon MacBook unusable

Research note resolving [issue #2](https://github.com/mingrath/mbcheck/issues/2).
Feeds the 🛑 **High risk** grade defined in [issue #10](https://github.com/mingrath/mbcheck/issues/10) — every
lock below is either unfixable at any price (🛑) or fixable only by a cooperative seller before payment.
Also feeds the script-read fact list fixed by [issue #11](https://github.com/mingrath/mbcheck/issues/11):
every command in this note was run **unprivileged**, because the script takes no sudo.

**Research date: 2026-08-04.** Every claim carries its source URL. Where an Apple page carries no publication
date in its body, that is stated rather than glossed — this is systematically true of the **Apple Platform
Deployment** guide and the **Apple Business / School Manager** user guides, whose pages carry no date at all.
Standalone `support.apple.com/en-us/NNNNNN` articles do carry a Published Date and it is quoted.

**Commands were verified first-hand** on the dev's own machine: MacBook Air, `Mac16,13`, Apple M4, 16 GB,
macOS **26.5.2 (25F84)**, `profiles` tool version 8.51, standard admin account, no sudo.

---

## ⚠️ Corrections this research forces on the current README

| # | README says | Reality | Where |
|---|---|---|---|
| 1 | Step 1b is titled "Is it locked or stolen?" and consists of **iCloud sign-out + Activation Lock only** | The README is missing **the lock that actually bricks machines**. ADE/MDM is a separate lock, survives Erase All Content and Settings *and* a DFU restore, and only the enrolling organisation can lift it. | [ADE](#2-automated-device-enrollment-ade--the-one-that-actually-bricks-machines) |
| 2 | "restart the machine and confirm it boots to **Setup Assistant**… not a login screen asking for someone else's Apple ID" — presented as the decisive test | **Necessary, nowhere near sufficient.** Activation Lock and ADE are checked at different points against different records. A Mac can reach a clean Hello screen and still be ADE-enrolled. Worse, with **Auto Advance over Ethernet** it re-enrols with *no pane at all*. | [§2](#2-automated-device-enrollment-ade--the-one-that-actually-bricks-machines), [Detection](#the-detection-procedure) |
| 3 | Implies a clean erase is the buyer's safety net | **Erasing is the trigger, not the cure.** EACS and DFU restore both leave the ABM record intact; the Mac re-enrols at the next Setup Assistant. Deleting `/private/var/db/.AppleSetupDone` no longer relaunches Setup Assistant on macOS 14+. | [§2](#2-automated-device-enrollment-ade--the-one-that-actually-bricks-machines) |
| 4 | "**Walk away if:** an Activation Lock screen appears" — treats the *screen* as the signal | The screen only appears at activation. The **machine-readable** signal is `system_profiler SPHardwareDataType` → `Activation Lock Status`, readable in 200 ms with no sudo, before you touch anything. | [§1](#1-activation-lock) |
| 5 | Nothing about **Recovery Lock** | A Mac can boot macOS perfectly and be permanently unable to enter recoveryOS. **Invisible from a running system** — no command, no Settings pane, no `system_profiler` field exposes it. Only a power-button-hold reboot finds it. | [§3](#3-recovery-lock-recoveryos-password) |
| 6 | Nothing about **Activation-Locked parts** | On macOS Tahoe 26+, a *replaced part* carries its own Activation Lock tied to the donor machine's Apple Account. Apple: "**Apple can't help remove Activation Lock for previously used parts.**" Proof of purchase does not save you. | [§9](#9-activation-locked-parts-the-lock-nobody-expects) |
| 7 | Ends "get a genuine Apple battery for ฿6,990" and a Docker tip — no post-purchase lock hygiene | Two silent post-purchase traps: the **90-day Apple Account association lock**, and **App Store licences that do not transfer at all**. | [§10](#10-things-that-are-not-locks-but-cost-the-buyer-anyway) |
| 8 | Uses "Apple ID" throughout | Apple's current term is **Apple Account**. Also: **Apple Business Manager, Business Essentials and Business Connect are being consolidated into "Apple Business"** — Apple states the three "will no longer be available once Apple Business launches". | [Naming](#naming-apple-business-not-apple-business-manager) |

---

## Summary table — every lock, one row

**Severity** uses [#10](https://github.com/mingrath/mbcheck/issues/10)'s grades. **"Survives EACS"** means Erase
All Content and Settings. **"Survives DFU"** means a full Apple Configurator **restore** (not a revive).

| Lock | Detectable unprivileged, before payment? | Survives EACS | Survives DFU restore | Liftable by anyone but the enrolling party? | Severity |
|---|---|---|---|---|---|
| **[Activation Lock](#1-activation-lock)** (personal) | **Yes** — `system_profiler SPHardwareDataType` | No¹ | **Yes** | Apple, with proof of purchase | 🛑 if seller won't sign out |
| **[Activation Lock](#1-activation-lock)** (organisation) | Partly — same field, no owner shown | No¹ | **Yes** | **No** — org only; Apple refers you to "your IT department" | 🛑 |
| **[ADE / DEP](#2-automated-device-enrollment-ade--the-one-that-actually-bricks-machines)** (ABM/ASM) | **No — this is the core finding.** `profiles status` gives false negatives | **Yes** | **Yes** | **No.** Apple Support is not on Apple's list of who can release a device | 🛑 |
| **[MDM enrollment](#2-automated-device-enrollment-ade--the-one-that-actually-bricks-machines)** (non-ADE) | **Yes** — `profiles status -type enrollment` | Yes² | No | Yes — seller/org removes profile | 🛑 |
| **[Recovery Lock](#3-recovery-lock-recoveryos-password)** | **No** — reboot test only | **Unpinned** | **No** | MDM only. **No Apple proof-of-purchase path exists** | 🛑 unless DFU-capable |
| **[Firmware password](#4-firmware-password--does-not-exist-on-apple-silicon)** | N/A | N/A | N/A | N/A | **Does not exist on Apple silicon** |
| **[Reduced / Permissive Security](#5-startup-security--localpolicy)** | **Yes** — `csrutil status`, `csrutil authenticated-root status` | No — resets to Full | No | Buyer-fixable | 💰 / 🛑 if SIP off |
| **[FileVault](#6-filevault-with-an-unknown-password), unknown password** | **Yes** — `fdesetup status` | N/A (EACS unusable) | No | Data gone; machine recoverable | 📝 if seller cooperates |
| **[Screen Time](#7-screen-time--much-weaker-on-macos-than-the-ticket-assumed)** | **Yes** — Settings pane | No | No | Yes — login password or Touch ID clears it | 📝 |
| **[Non-admin / seller-retained admin](#8-local-account-and-admin-locks)** | **Yes** — `dscl`, `sysadminctl` | No | No | Yes | 💰 |
| **[Activation-Locked parts](#9-activation-locked-parts-the-lock-nobody-expects)** | **Yes** — Parts & Service / Repair Assistant (Tahoe 26+) | **Yes** | **Yes** | **No. Apple explicitly refuses** | 🛑 |
| **[MDM remote lock](#2-automated-device-enrollment-ade--the-one-that-actually-bricks-machines)** (6-digit PIN) | Only once triggered | — | Yes (org still owns it) | Org only | 🛑 |
| **[Carrier lock](#11-carrier-and-financing-locks--mostly-a-myth-on-a-mac)** | N/A | N/A | N/A | N/A | **Cannot exist — no MacBook has cellular** |
| **[Financing lock](#11-carrier-and-financing-locks--mostly-a-myth-on-a-mac)** | Same as ADE — it *is* ADE | Yes | Yes | No | 🛑 |
| **[90-day account association](#10-things-that-are-not-locks-but-cost-the-buyer-anyway)** | No | — | — | Seller can pre-clear | 📝 |
| **[App Store licences](#10-things-that-are-not-locks-but-cost-the-buyer-anyway)** | N/A | — | — | **Non-transferable** | 💰 (re-buy) |

¹ EACS clears Activation Lock *only because it makes the signed-in account sign out*, which requires the Apple
Account password. Without that password EACS does not complete. See [§1](#1-activation-lock).
² An MDM profile is removed by an erase, but if the serial is still in ABM the Mac simply re-enrols. The
distinction only matters for a manually-enrolled Mac whose serial was never in ABM.

---

## The short version

Rank the locks by **who holds the key**, because that is what decides whether money can fix it:

1. **The seller holds the key** — Activation Lock (personal), FileVault, Screen Time, admin account, security
   policy. All fixable *before payment* by a cooperative seller, in front of you. If the seller won't, the
   answer is no-sale, not negotiation.
2. **An organisation holds the key** — ADE/ABM, org Activation Lock, Recovery Lock, MDM remote lock. Apple
   documents **no remedy** for a private buyer against an uncooperative or dissolved organisation. 🛑, always.
3. **Nobody holds the key** — an Activation-Locked *part* from a donor machine whose owner you will never
   find. Apple states outright that it cannot help. 🛑, permanently.

And the one structural fact that reorganises the whole guide: **the lock that matters most is the one you
cannot detect.** Activation Lock is a one-line read. ADE is not readable at all from the device — no command,
privileged or not, can ask "is this serial in someone's Apple Business Manager?" The best available test is
watching the seller erase the machine and complete Setup Assistant over **Wi-Fi** in front of you.

---

## 1. Activation Lock

### What turns it on

&gt; "your Apple Account password or device passcode is required before anyone can turn off Find My, erase your
&gt; Mac, or **reactivate and use your Mac**. Even if you erase your Mac remotely, Activation Lock can continue to
&gt; deter others from reactivating your Mac without your permission."
&gt; — <https://support.apple.com/en-us/102541> (Published 2026-06-05)

System requirements from the same page, and the third one is load-bearing: Apple silicon (or T2), **macOS
10.15+**, **"Security policy set to Full Security, which is the default setting"**, and two-factor auth on the
Apple Account.

**Consequence the guide must state:** a Mac downgraded to Reduced or Permissive Security has **silently lost
Activation Lock**. So a machine reading `Activation Lock Status: Disabled` is not necessarily a machine whose
owner signed out — it may be a machine whose security policy was downgraded. Cross-read with
[§5](#5-startup-security--localpolicy).

### Detection — one line, no sudo

Verified on the M4 Air, 2026-08-04:

```
$ system_profiler SPHardwareDataType | grep -i "Activation Lock"
      Activation Lock Status: Enabled
```

JSON form, for the script:

```
$ system_profiler -json SPHardwareDataType | grep -i activation
      "activation_lock_status" : "activation_lock_enabled",
```

**Trap for the script author, verified:** `system_profiler -detailLevel mini SPHardwareDataType` **omits both
the Activation Lock Status line and the serial number.** Do not use `mini`.

A second, independent unprivileged read of the underlying Find My state:

```
$ defaults read /Library/Preferences/com.apple.FindMyMac
{
    FMMEnabled = 1;
}
```

### ⚠️ The crux: `Enabled` is the *normal* reading on a machine you are about to buy

The dev's own, entirely healthy, personally-owned M4 Air reads **`Activation Lock Status: Enabled`**. That is
what a working Mac with Find My on looks like. It reflects **the current owner's** Find My, and the current
owner at inspection time is the seller.

So the field answers "is Find My on right now?", **not** "will this machine be locked against me?" The
buyer-relevant question is whether it reads `Disabled` *after the seller signs out in front of you*. The
guide must not print "Activation Lock: Enabled → walk away" — that would fail nearly every honest machine on
the market.

The correct framing:

| Reading | Before seller signs out | After seller signs out |
|---|---|---|
| `Enabled` | **Normal.** Expected. No signal. | **🛑 Sign-out did not take.** |
| `Disabled` | Unusual — ask why. Either already signed out (fine) or security policy downgraded (check `csrutil`). | **Correct.** This is the state you pay for. |

⚠️ **Confidence note, stated plainly.** Only the top-left cell of that table was observed first-hand: the test
machine has Find My on and reads `Enabled`. The other three cells are **inference from Apple's documented
mechanism**, not observation — the dedicated Activation Lock investigation for this ticket did not report back,
so this section was assembled from the other three investigations plus first-hand command output. The
inference is strong (Apple states Activation Lock is turned on by Find My, and the field is named for it), but
**nobody has watched this field flip on a real machine as part of this research.** The transition is cheap to
verify and should be, before the guide leans on it: sign out of iCloud on any Mac and re-read the field. See
[Unpinned #20](#unpinned--could-not-establish).

### Two flavours, and the organisation one is worse

<https://support.apple.com/guide/deployment/activation-lock-depf4ab94ef1/web> (no date in body):

- **User-linked** — the previous owner's personal Apple Account. Cleared by them: System Settings → Apple
  Account → iCloud → Find My Mac → off; or remotely at `icloud.com/find` → **Remove This Device**
  (<https://support.apple.com/en-us/108934>, Published 2026-05-27).
- **Organisation-linked** — cleared server-side in ABM/ASM. Apple flags a real trap for ex-corporate Macs:

  &gt; "For a Mac with macOS 11 or later, if it's supervised using Device Enrollment, you can't manage Activation
  &gt; Lock until you enroll the device in a device management service. That means it may be possible for
  &gt; Activation Lock to already be turned on when the Mac enrolls… In that case, **you can't turn it off using a
  &gt; device management service** and macOS can't disallow it by default until the user turns it off."

  And once a device is released from ABM: "**Managing Activation Lock using Apple Business isn't possible after
  a device is released.**" (<https://support.apple.com/guide/business/release-devices-axmec4d28461/web>)

### Does Erase All Content and Settings clear it?

Yes — but only because EACS makes the account sign out, which needs the Apple Account password. Apple's EACS
description includes "Turns off Find My and Activation Lock"
(<https://support.apple.com/guide/mac-help/erase-your-mac-mchl7676b710/mac>), and the flow asks for the Apple
Account password to sign out (<https://support.apple.com/en-us/102664>, Published 2026-05-13). **EACS is
therefore not a bypass** — a seller who cannot remember their password cannot complete it.

### Does a DFU restore clear it? **No.**

This is the ceiling of what a buyer can fix alone. Apple's own restore procedure, step 6.1:

&gt; "**If asked, sign in to the Apple Account previously used with this restored Mac.**"
&gt; — <https://support.apple.com/en-us/108900> (Published 2026-06-16)

### Can anyone but the Apple Account holder lift it?

Only Apple, and only with documentation:

&gt; "If you need help removing Activation Lock, and have proof of purchase documentation, you can start an
&gt; Activation Lock support request." — <https://support.apple.com/en-us/108934>, form at
&gt; <https://al-support.apple.com/#/kbase>

Apple's documented bar for that receipt — all six elements, from an **Apple Authorized Reseller**:

&gt; "A legible sales receipt. The sales receipt must provide: **A clear description of your device. The device's
&gt; date of purchase. An invoice or receipt number. The device's price. The reseller's contact information**
&gt; (we prefer the reseller's seal or logo too). **The device's serial number** if the reseller normally lists
&gt; serial numbers on their receipts." — <https://support.apple.com/en-us/102264> (Published 2025-03-20)

**But not for organisation-owned machines:** "If your device is owned by a business or educational institution,
please contact your IT department or manager." (<https://support.apple.com/en-us/108934>) Apple will not
release an org device to a private buyer.

**Guide consequence:** the receipt is not paperwork theatre. It is the *only* fallback that exists, and Apple
publishes exactly what it must contain. A machine with no compliant receipt is a machine with no fallback.

---

## 2. Automated Device Enrollment (ADE) — the one that actually bricks machines

### The four enrollment concepts, in Apple's vocabulary

<https://support.apple.com/guide/deployment/enrollment-methods-for-apple-devices-dep08f54fcf6/web>

| Apple's term | What it is | Supervised on Mac? |
|---|---|---|
| Account-driven **User** Enrollment | Managed Apple Account sign-in, max data separation | No |
| Account-driven **Device** Enrollment | Managed Apple Account sign-in in System Settings | **Yes (Mac)** |
| Profile-based **Device** Enrollment | User installs an enrollment profile manually | **Yes (Mac)** |
| **Automated Device Enrollment (ADE)** | Serial in ABM/ASM, assigned to an MDM server, enrols at Setup Assistant | **Yes** |

"For a Mac with macOS 11 or later, Device Enrollment also enforces supervision."
(<https://support.apple.com/guide/deployment/device-enrollment-and-device-management-depd1c27dfe6/web>)

**So on a Mac, "supervised" does not imply ADE.** Only ADE is enforced by Apple's servers against the serial
number, and only ADE therefore survives a wipe.

**What ADE uniquely grants the organisation** (same enrollment-methods table): restrictions = "All" rather
than "Unsupervised only", Always-On VPN, global HTTP proxy, Managed Lost Mode — on top of the Device-Enrollment
set of remote erase-all-content-and-settings, enforced software updates, **FileVault control**, and
**Activation Lock management**. Never available under any method: device location on a Mac, personal
mail/messages/calendars, Safari history.

### It survives everything on the device

The decisive Apple sentence:

&gt; "*The Mac is owned by an organization and appears in Apple School Manager or Apple Business:* The first time
&gt; a Mac with macOS 13 or later is set up and connected to a network, it's acknowledged as owned by an
&gt; organization… **As long as the device remains registered to the organization, when the device is erased,
&gt; Setup Assistant requires a network connection to proceed with future activations.**"
&gt; — <https://support.apple.com/guide/deployment/manage-setup-assistant-depdeff4a547/web>

Erasing destroys the OS and the data. The registration is **server-side, against the serial number**, and the
Mac is forced online at every subsequent activation precisely so it can be re-checked.

The mechanism, assembled from Apple sources:

1. Device **added** to ABM against its serial — via Apple Customer Number, Apple Authorized Reseller,
   authorised carrier, AppleCare replacement, or **Apple Configurator**
   (<https://support.apple.com/guide/business/view-device-information-axm02774ff54/web>).
2. Device **assigned** to an MDM server: "**You need to assign a device to a device management service so that
   Setup Assistant displays the pane to enroll the device in that service.**"
   (<https://support.apple.com/guide/business/assign-reassign-or-unassign-devices-axmf500c0851/web>)
3. At Setup Assistant the Mac fetches an **activation record** — Apple's `Profile` object, carrying the MDM
   `url`, `is_supervised`, `is_mandatory`, `is_mdm_removable`, `skip_setup_items`, `await_device_configured`
   (<https://developer.apple.com/documentation/devicemanagement/profile>).

Apple keeps **added**, **assigned** and **enrolled** as three distinct states
(<https://support.apple.com/guide/business/device-workflow-axm6a88f692e/web>). That three-state model is the
whole reason the device-side check fails — see below.

Also dead: on macOS 14+, "**removing the `/private/var/db/.AppleSetupDone` file no longer relaunches Setup
Assistant** if a local user already exists."

### A Mac can be Activation-Lock-clear and still ADE-enrolled — confirmed

Separate mechanisms, separate records, separate lifecycles:

- ABM membership is a *prerequisite* for Activation Lock management, not a consequence: "You need to add the
  device to Apple School Manager or Apple Business **before** enabling Activation Lock… but **you don't need to
  assign it to a device management service**."
  (<https://support.apple.com/guide/deployment/activation-lock-depf4ab94ef1/web>)
- The MDM `SecurityInfo` response carries `IsActivationLockManageable` as a **sibling** of `EnrolledViaDEP` —
  orthogonal fields
  (<https://developer.apple.com/documentation/devicemanagement/securityinforesponse/securityinfo-data.dictionary/managementstatus-data.dictionary>).

**So reaching a clean Hello screen with no Activation Lock prompt proves nothing about ADE.** The README's
Step 1b test is necessary and insufficient.

### Detection — and why the obvious command is a weak test

Verified unprivileged, exit 0:

```
$ profiles status -type enrollment
Enrolled via DEP: No
MDM enrollment: No
```

`man profiles` (page dated 2022-03-24, still shipping on macOS 26.5.2) documents the `status` verb and one
output nuance: "When displaying the enrollment type status, if the MDM enrollment was user approved, the
status output will show **\"(User Approved)\"**." It never documents the literal strings `Enrolled via DEP:` or
`MDM enrollment:` — a real documentation gap. Their meaning is inferred, with high confidence, from Apple's
MDM `ManagementStatus` dictionary, whose keys are character-for-character these lines and share the same
macOS 10.13.2 availability:

- `EnrolledViaDEP` — "If `true`, the device enrolled in MDM through Automated Device Enrollment (ADE)."
- `UserApprovedEnrollment` — "If `true`, the enrollment was user-approved."

Buyer's truth table:

| DEP | MDM | Meaning |
|---|---|---|
| No | No | Clean **on this OS install, right now**. Says nothing about ABM. |
| No | Yes | Manually enrolled; removable — but on macOS 11+ also supervised. |
| Yes | Yes | ADE-enrolled and managed. **Walk away.** |
| Yes | No | *Was* ADE-enrolled, profile since removed. Serial almost certainly still in ABM. **Walk away.** |

#### ⚠️ The false negatives — the single most important finding in this note

`profiles status` reports **completed enrollment on this OS install**. It does not, and cannot, query ABM.
**No command — privileged or not — asks "is this serial in someone's Apple Business Manager?"** That requires
the owning organisation's ABM credentials.

`Enrolled via DEP: No` is returned in all of these dangerous states:

1. **In ABM but never assigned to an MDM server.** No assignment → no Setup Assistant pane → no DEP enrollment
   → `No`. The organisation can assign **at any time afterwards**, and macOS 14+ enforcement then walls the
   machine off. This is the worst case and it is fully supported by Apple's own documentation.
2. **In ABM, assigned, but not activated since assignment.**
3. **Seller removed the profile locally but never released the serial.** Re-arms at the next erase.
4. **Seller wiped and set up offline**, or on a network blocking Apple's ADE endpoint.
5. **Reinstalled from an older or modified image** where the check never ran.

Cases 2–5 all detonate on the buyer's **first erase-and-reinstall** — day one.

Jamf's own support documentation presumes exactly the assigned-but-not-enrolled state that `status` renders as
`No`: `profiles show -type enrollment` "shows the current Automated Device Enrollment configuration **to which
the device is assigned**", used "to confirm the device is registering as being **assigned**… **prior to running
the renew command**" (<https://support.jamf.com/en/articles/11022103-using-profiles-type-enrollment-commands-with-jamf-school>,
2025-05-29 — MDM vendor, secondary). Apple describes the pending state too: "if the Mac isn't connected to the
internet during the initial configuration, users receive notifications every two hours that the Mac **has
available device enrollment settings**"
(<https://support.apple.com/guide/deployment/about-device-supervision-dep1d89f0bff/web>).

**Verdict — this is a one-directional test.** `Yes` on either line is conclusive bad news. `No`/`No` is weak
evidence only. **No source publishes a false-negative rate and this note will not invent one.** The defensible
statement for the guide: *`Enrolled via DEP: No` establishes only that this Mac is not currently DEP-enrolled
on this OS install. The transition from "not enrolled" to "permanently walled off" requires a single click by
the seller's IT admin — no physical access to the machine.*

#### What `sudo` would add, and why the script cannot have it

```
$ profiles show -type enrollment
Must be running as root
$ echo $?
1
```

`sudo profiles show -type enrollment` returns the **activation record** — organisation name, MDM
`ConfigurationURL`, `IsMandatory`, `IsMDMUnremovable`, `IsSupervised`, `SkipSetup`. Per Jamf it reveals
**assignment** where `status` reveals only **enrollment** — i.e. it is the check that closes the hole above.
**The map fixes that the script takes no sudo, so this check is out of reach of `check.sh`.** It is available
to a buyer who asks the seller to type their admin password, and that is worth prompting for.

**A documented Apple-vs-Apple contradiction on its rate limit:**

- `man profiles` on macOS 26.5.2: rate limited "**10 times every 23 hours**", covering `show`/`renew`/`validate`.
- Apple Platform Deployment: "macOS also limits the `profiles` command-line tool to **10 of the following
  requests per 24 hours** **for devices owned by an organization that appear in Apple School Manager or Apple
  Business**" (<https://support.apple.com/guide/deployment/about-device-supervision-dep1d89f0bff/web>).

23 vs 24 hours, and the guide adds a scope condition the man page lacks. Both are Apple. Both are reported here.

#### Other unprivileged signals, all verified on the M4 Air

| Check | Clean-Mac result |
|---|---|
| `profiles status -type enrollment` | `Enrolled via DEP: No` / `MDM enrollment: No` |
| `profiles list` | `There are no configuration profiles installed for user 'x'` (user scope only) |
| `system_profiler SPConfigurationProfileDataType` | **empty output**, exit 0 |
| `system_profiler SPManagedClientDataType` | **empty output** |
| `ls /Library/Managed\ Preferences/` | `No such file or directory` |

**Script-author trap:** empty output *is* the clean answer for both `system_profiler` datatypes. It is easy to
misread as "the command failed".

The one unambiguous positive string, from Apple: "*Mac:* You can go to System Settings > General > Device
Management and look for this line at the top of the window: '**This Mac is supervised and managed by
[Organization name].**'" (<https://support.apple.com/guide/deployment/about-device-supervision-dep1d89f0bff/web>)
Treat **presence** of an organisation name as damning; treat **absence** as inconclusive.

**There is no menu-bar MDM indicator on macOS.** No Apple documentation describes one. Do not put one in the guide.

### Can enrollment be silent on a machine already past Setup Assistant?

**Not without a click — with one devastating exception.**

Apple's only primary statement on user-approved enrollment is **archived**: "Using automation or attempting to
enroll a device remotely via screen sharing will not result in User Approved enrollment"
(<https://support.apple.com/en-us/101332>, Published 2023-11-17, carrying Apple's "This article has been
archived and is no longer updated by Apple" banner). The `support.apple.com/guide/deployment/…user-approved-mdm…`
URLs cited by vendor glossaries **404**.

A manually installed profile still requires clicks — "**double-click the profile**… **click Continue, Install,
or Enroll**… **You may be asked to supply your password**"
(<https://support.apple.com/guide/mac-help/configuration-profiles-standardize-settings-mh35561/mac>). And there
has been no CLI install path since macOS 11 — `man profiles`: "Starting with macOS 11.0… **this tool cannot be
used to install configuration profiles.**"

**The exception, and it is exactly the buyer's scenario — Auto Advance:**

&gt; "A supervised Mac using macOS 11 or later… [is] automatically configured **without any user intervention**,
&gt; provided no other Setup Assistant panes are enabled" — requires the serial in ASM/ABM, an MDM applying the
&gt; Auto Advance key, and an **active Ethernet connection**.
&gt; — <https://support.apple.com/guide/deployment/automated-device-enrollment-management-dep73069dd57/web>

Take a "clean-looking" used Mac home, erase it, plug in Ethernet — and it **silently re-enrols with no prompt
at all**. This is why the guide's erase test must be run over **Wi-Fi**, which forces the pane to render.

### The Remote Management pane, and macOS 14+ enforcement

Apple's Setup Assistant pane table: "**Remote Management** — iPhone, iPad, Mac, Apple TV. *Note:* **You can't
skip this pane if you add the device to Apple School Manager or Apple Business when using a device management
service.**" (<https://support.apple.com/guide/deployment/manage-setup-assistant-depdeff4a547/web>)

Whether the user can click past it is governed by `is_mandatory`, which Apple's spec forces true only for **iOS
13 and later** — on macOS it still defaults to `false`
(<https://developer.apple.com/documentation/devicemanagement/profile>). But macOS 14+ bolts on enforcement
regardless:

&gt; "**Enforce Automated Device Enrollment** — If a Mac with macOS 14 or later that's registered to Apple School
&gt; Manager or Apple Business doesn't enroll into device management during the first setup, **a full-screen setup
&gt; experience is displayed**. The user can choose 'Not now' **once**, which causes the screen to be dismissed for
&gt; **eight hours**… **After the time expires, a user with the proper permissions in Apple School Manager or Apple
&gt; Business needs to enroll the device.** This… **ensures that the device needs to be enrolled into device
&gt; management in order to be used**."
&gt; — <https://support.apple.com/guide/deployment/automated-device-enrollment-management-dep73069dd57/web>

The supervision page adds the terminal condition: "**the user needs to perform the enrollment or erase their
Mac**".

**Every M1–M5 MacBook runs macOS 14 or later today. So an ADE-registered Mac cannot be skipped past durably:
worst case unskippable, best case eight hours.**

**Independently corroborated in Apple's Thai-language documentation.** Sibling research on
[#7](https://github.com/mingrath/mbcheck/issues/7) surfaced Apple's Thai macOS Sonoma enterprise notes stating
that ADE **"สามารถบังคับใช้ได้หลังจากผู้ช่วยตั้งค่า"** — *enrollment can be enforced after Setup Assistant*.
That is the same claim as the English "Enforce Automated Device Enrollment" text above, reached from a
different Apple page in a different language, and it settles the question #7 left open: **enrollment is not a
one-shot gate at first boot. A Mac that got past Setup Assistant clean can still be walled off afterwards.**
This is the mechanism behind false-negative state 1 below — the organisation assigns the serial at any time
after the sale, and enforcement does the rest.

Apple never publishes the pane's on-screen wording. Anything quoting it verbatim is vendor or forum material.

### Who can release the device — and Apple is not on the list

&gt; "Devices can be removed from Apple Business… This is called *releasing a device*." Steps: Devices > Inventory
&gt; → select → **Release from Organization** → "**select the I understand that this cannot be undone box**" →
&gt; Release. "**After a device is released, it needs to be erased and restored.**"
&gt;
&gt; "The following entities can release a device: **A user who has permissions to manage devices**; **A linked
&gt; device management service** that can release devices; **An Apple Authorized Reseller**."
&gt; — <https://support.apple.com/guide/business/release-devices-axmec4d28461/web>

**Apple Support is absent from that list.** The contrast with Activation Lock is the citable finding: Apple
runs a formal proof-of-purchase escalation for Activation Lock, and for organisation-owned devices says only
"contact your IT department or manager" (<https://support.apple.com/en-us/108934>). **There is no equivalent
ADE removal request form and no equivalent Apple Support article.**

**Unassigning ≠ releasing.** "Unassign Device Management" drops the MDM-server assignment but keeps the device
in ABM. **A seller who only unassigns has not freed the Mac** — the organisation can reassign at will.

**Defunct organisation, or a reseller who won't help: Apple documents no remedy.** That is the finding. No
defensible primary source exists for a private buyer obtaining release against an uncooperative or dissolved
organisation.

### Apple Configurator additions and the 30-day provisional window

&gt; "You can manually add the following devices to Apple Business using **Apple Configurator**, **even if the
&gt; devices weren't purchased directly from Apple, an Apple Authorized Reseller, or an authorized cellular
&gt; carrier**… After you set up the devices, they behave like any other device already in Apple Business **with
&gt; mandatory supervision and device management service enrollment**… When you give the device to a user, **they
&gt; have a 30-day provisional period to release the device**… This 30-day provisional period begins after
&gt; successfully assigning and enrolling the device in a device management service."
&gt; — <https://support.apple.com/guide/business/add-devices-using-apple-configurator-axm200a54d59/web>

This is the mechanism by which **any consumer Mac** — including one bought at retail by a private person — can
be pulled into an organisation's inventory. Requirements: Apple silicon or T2, macOS 12.0.1+, added via **Apple
Configurator for iPhone** (the Mac app adds only iPhone/iPad/Apple TV), paired at the "Select Your Country or
Region" pane; an already-configured Mac must be erased first.

**Critical gap:** Apple documents the 30-day release *right* for Macs but **not the on-Mac mechanism**. The one
auto-release mechanism it spells out is explicitly iOS-only. And **the buyer has no way to tell whether a
machine is inside the window** — nothing in `profiles status` or anywhere buyer-visible exposes the provisional
flag or the enrollment date. Do not plan a purchase around it.

Note also: a Mac put into ABM through the reseller/carrier/Apple channel has **never** had a provisional window.
Only Configurator-added devices do.

### What actually happens to a buyer who bought an ADE-enrolled Mac

1. EACS appears to succeed. Data destroyed, reboot to Setup Assistant.
2. Setup Assistant **refuses to proceed offline** — the org registration forces a network connection.
3. Online → **Remote Management pane appears**, naming the organisation. Unskippable if `is_mandatory`.
4. If skippable, macOS 14+ throws a full-screen enrollment experience; "Not now" works **once**, buying **eight
   hours**. Then the machine needs the organisation to enrol it, or another erase.
5. **Or nothing visible happens at all** — Auto Advance over Ethernet re-enrols silently.
6. **The loop closes.** Erasing returns to step 1. Reinstalling does not help; the record is server-side.
7. **Only exit:** the organisation releases the serial in ABM, then erase and restore.
8. If the buyer enrols to make the Mac usable, they hand an unknown organisation remote erase, remote lock,
   FileVault control, Always-On VPN and a global HTTP proxy.

Worst residual state: with `is_mdm_removable: false`, "the MDM payload is **locked onto the device**", and
Apple's "Prevent unenrollment" option blocks removal "from System Settings **as well as from the `profiles`
command-line tool**."

### Yes, an MDM can also remote-lock, remote-wipe and set a Recovery Lock

- **Remote lock:** "Device management service administrators can **lock a Mac with a six-digit PIN**… **The user
  can't restart into macOS until they enter the PIN.**" (Apple silicon: macOS 11.5+.) Managed Lost Mode proper is
  iPhone/iPad only. (<https://support.apple.com/guide/deployment/lock-and-locate-devices-depb980a0be4/web>)
- **Remote wipe:** `EraseDevice`; failed preconditions fall back to **obliteration**, after which "you need to
  reinstall macOS before the Mac can be used"
  (<https://support.apple.com/guide/deployment/erase-devices-dep0a819891e/web>).
- **MDM can block EACS outright:** it "Can use a restriction to prevent erasing all content and settings on a
  Mac" (same URL). A greyed-out EACS on a used Mac is itself a red flag.
- **Recovery Lock:** see [§3](#3-recovery-lock-recoveryos-password).

A four- or six-digit **PIN prompt at boot** is an MDM or Find My remote lock — not Recovery Lock, and not a
firmware password (<https://support.apple.com/en-us/102675>, Published 2025-09-15).

---

## 3. Recovery Lock (recoveryOS password)

&gt; "A Mac with Apple silicon with macOS 11.5 or later supports setting a recoveryOS password using a device
&gt; management service and the `SetRecoveryLock` command. Unless the user enters the recoveryOS password, they
&gt; can't access the recovery environment, **including the Startup Options screen**. **You can set a recoveryOS
&gt; password only using a device management service**… **unenrolling a Mac that has a set recoveryOS password from
&gt; that service also removes the password**."
&gt; — <https://support.apple.com/guide/deployment/startup-security-dep5810e849c/web>

Apple Developer confirms: "**When the device unenrolls MDM the system removes the recovery password.** This
command is only available on a Mac with Apple silicon." macOS 11.5+, **requires supervision**
(<https://developer.apple.com/documentation/devicemanagement/set-recovery-lock-command>).

**A local user cannot set one.** It is MDM-only, which means a Recovery-Locked Mac was, at some point, a
managed Mac.

**It does not block booting macOS.** It gates recoveryOS and the Startup Options screen only. The machine looks
perfect until you try to reinstall — which is precisely when the buyer discovers it.

### ⚠️ It is undetectable from a running system

No unprivileged command, no `system_profiler` field, no Settings pane exposes Recovery Lock. Confirmed by
elimination on the M4 Air (`system_profiler SPHardwareDataType`/`SPSoftwareDataType`/
`SPConfigurationProfileDataType`, `nvram -p`, `csrutil status`, `profiles status -type enrollment` — all
silent), and by two structural facts:

- The only documented programmatic read is **MDM-side**: `SecurityInfo` → `IsRecoveryLockEnabled`
  (<https://developer.apple.com/documentation/devicemanagement/securityinforesponse/securityinfo>). A buyer has
  no MDM server and cannot issue it.
- Apple's LocalPolicy 4CC reference lists every user-configurable policy field and **no Recovery Lock field
  appears** (<https://support.apple.com/guide/security/secc745a0845/web>). So `bputil -d` is not documented to
  expose it — and `bputil` needs root anyway (verified: `The tool requires running as root`).

**The only test is a reboot**, and it must be described to the buyer explicitly:

1. Shut down fully.
2. Press and hold the power / Touch ID button.
3. **Good:** the startup-options screen appears — your startup volume plus **Options** with a gear icon.
4. **Bad:** a password prompt saying recoveryOS is locked. Apple's own deployment guide carries a figure whose
   alt text is "**A Mac showing that recoveryOS is locked**"
   (<https://support.apple.com/guide/deployment/lock-and-locate-devices-depb980a0be4/web>).

Worth doing in the same reboot: continue into Recovery and confirm you can authenticate. Apple silicon Recovery
requires "**Select an administrator account**… Enter the password for the administrator account"
(<https://support.apple.com/guide/mac-help/macos-recovery-a-mac-apple-silicon-mchl82829c17/mac>) — see
[§8](#8-local-account-and-admin-locks).

### Who can clear it

MDM only: `SetRecoveryLock` with the correct **current** password, or MDM unenrollment.

**There is no Apple proof-of-purchase path for Recovery Lock.** Apple documents such an escalation for
Activation Lock and for the Intel firmware password (<https://support.apple.com/en-us/102384>) — **neither
covers Recovery Lock.** Do not tell buyers Apple will clear it.

**But it is not permanent**, because DFU restore beats it. Apple: "**Setting a recoveryOS password doesn't
prevent the restoration of a Mac computer with Apple silicon through DFU Mode using Apple Configurator**, which
also cryptographically renders the previous data on the Mac inaccessible."
(<https://support.apple.com/guide/deployment/startup-security-dep5810e849c/web>) Jamf, having tested it on a
MacBook Air M2, adds the crucial distinction: **revive does not clear it; restore does**
(<https://support.jamf.com/en/articles/11038510-restore-an-apple-silicon-device-with-an-unknown-recovery-lock>,
2025-06-17 — MDM vendor, secondary).

**Practical rule:** Recovery Lock alone is survivable if you own a second Mac. Recovery Lock **plus** an
unresolvable Activation Lock or an ABM assignment is not.

---

## 4. Firmware password — does not exist on Apple silicon

Apple says it twice, in two separate guides:

&gt; "Because of this, a Mac with Apple silicon also won't require (or support) a firmware password — all critical
&gt; changes are already gated by user authorisation."
&gt; — <https://support.apple.com/guide/deployment/startup-security-dep5810e849c/web>, and near-identically at
&gt; <https://support.apple.com/guide/security/sec7d92dc49f/web>

And the consumer article names the replacement:

&gt; "This feature requires a Mac with an Intel processor. For the equivalent level of security on a Mac with
&gt; Apple silicon, simply turn on FileVault. If the Mac is managed by MDM…, the MDM administrator can also
&gt; remotely lock the Mac." — <https://support.apple.com/en-us/102384> (Published 2026-06-22)

**Do not use `firmwarepasswd -check` as a test.** The binary still ships and still runs on Apple silicon, its
man page is dated **2019-04-19** and says nothing about Apple silicon, and it needs root anyway (verified:
`ERROR | main | This tool must be run as root.`). Its result on Apple silicon is not a documented signal.

The ticket listed "Recovery lock / firmware password on Apple silicon" as one item. **They are not one item:**
one does not exist, the other is MDM-only and invisible.

---

## 5. Startup Security / LocalPolicy

Three policies (<https://support.apple.com/guide/deployment/startup-security-dep5810e849c/web>):

- **Full Security** — "allows only booting software that was known to be the latest that was available at
  installation time." Personalised, ECID-bound signature.
- **Reduced Security** — "allows the system to run older versions of macOS"; needed to boot third-party kexts.
  Global signature.
- **Permissive Security** — "supports users that are building, signing and booting their own custom XNU
  kernels. **System Integrity Protection (SIP) needs to be turned off** before enabling Permissive Security
  Mode." Apple: it "provides an architectural capability for running an arbitrary fully untrusted operating
  system kernel."

### Why a buyer cares

1. **Activation Lock silently stops applying.** Its requirements include "Security policy set to Full Security"
   (<https://support.apple.com/en-us/102541>).
2. **A known-vulnerable, non-latest macOS may be booting.**
3. **Third-party kexts may be present** — "vulnerabilities in third-party kexts can compromise the entire
   operating system" (<https://support.apple.com/guide/security/sec7d92dc49f/web>).
4. **Erase Assistant may refuse:** "If you have a modified version of macOS, Erase Assistant can't erase your
   Mac" (<https://support.apple.com/guide/business/axm200a54d59/web>).

### Detection — unprivileged proxies, verified

`bputil -d` needs root, so the script cannot read the LocalPolicy directly. These proxies all ran unprivileged
on the M4 Air:

```
$ csrutil status
System Integrity Protection status: enabled.
$ csrutil authenticated-root status
Authenticated Root status: enabled
$ spctl --status
assessments enabled
$ diskutil apfs listVolumeGroups        # exactly one volume group on a clean machine
```

**SIP off ⇒ Permissive Security ⇒ 🛑.** SIP on Apple silicon lives in the LocalPolicy, and turning it off
requires Permissive Security and a 1TR boot. Anything other than "enabled" from `csrutil` is a strong
walk-away signal. More than one APFS volume group on a supposedly clean machine deserves questions — Apple
notes there is "only a **single OIK for all operating systems on the Mac**"
(<https://support.apple.com/guide/security/secc745a0845/web>), so a second macOS install may mean Ownership was
handed off.

### Fixable by the buyer

Yes, two ways: Startup Security Utility in recoveryOS (needs an **admin password**), or an erase — "For a Mac
with Apple silicon, it also **resets the security settings to their default state (Full Security)**"
(<https://support.apple.com/guide/deployment/erase-devices-dep0a819891e/web>).

**Caveat Apple raises against itself**, from `man bputil`: "it is possible for an OS to report that it is Full
Security **despite not being the latest software version**. Full Security only indicates the state as of the
latest install or upgrade." A Full Security readout is a claim about the past, not a live attestation.

---

## 6. FileVault with an unknown password

`fdesetup` status verbs run **without root** — `man fdesetup`: "Most commands require root access… **Some
status related commands can be run from a non-root session.**" Verified:

```
$ fdesetup status
FileVault is Off.
$ fdesetup isactive
false
```

**Apple's three lock screens are diagnostic and the guide should teach them apart**
(<https://support.apple.com/en-us/102675>, Published 2025-09-15):

| What you see | What it is |
|---|---|
| A normal **login window** you cannot pass | FileVault / unknown account password |
| A window asking for **someone else's Apple Account** | **Activation Lock** |
| A **PIN code** prompt | Remotely locked via Find My or MDM |

**What a buyer can do without the password:** reset via the `?` at the login window or "Forgot all passwords?"
in Recovery (may require the seller's Apple Account or the 24-character recovery key); on macOS Tahoe 26+ the
recovery key may be retrievable from the **Passwords app** on another device signed into the same Apple Account
— worth asking a cooperative seller to do on the spot (<https://support.apple.com/en-us/102633>, Published
2026-05-19). Failing that: Recovery Assistant menu → **Erase Mac**, which needs no password at all.

**What they cannot do:** read any data, or run Erase Assistant — EACS requires administrator credentials
(<https://support.apple.com/guide/mac-help/erase-your-mac-mchl7676b710/mac>). **So EACS is not the fallback for
a locked-out buyer; Recovery's Erase Mac is.**

FileVault is a 📝, not a 🛑 — the *data* is unrecoverable, the *machine* is not. But a seller who cannot unlock
their own machine cannot demonstrate anything else either, which makes every other check unrunnable.

---

## 7. Screen Time — much weaker on macOS than the ticket assumed

The ticket listed Screen Time as one of the locks to resolve. **On a Mac it barely qualifies**, and saying so
is the finding.

Apple's own macOS tables scope it tightly:

- **App & Feature Restrictions** — the macOS-affecting row is titled just "Allowed": *Camera, Book Store, Siri
  & Dictation, SharePlay.* Everything else (Mail, Safari, FaceTime, Wallet, AirDrop, Screen Recording, …) sits
  under a row Apple explicitly labels "**Allowed on iOS**"
  (<https://support.apple.com/guide/mac-help/change-app-feature-restrictions-settings-mchl3a19a9e7/mac>).
- **Preference Restrictions** — the "Allow Changes" row is described as applying "**on iOS or iPadOS
  devices**" (<https://support.apple.com/guide/mac-help/change-preference-restrictions-settings-mchl085d2f8a/mac>).

**No macOS Screen Time restriction is documented to block Erase All Content and Settings**, general app
installs, or Mac account changes. (An *MDM* restriction can block EACS — different mechanism, see
[§2](#2-automated-device-enrollment-ade--the-one-that-actually-bricks-machines).)

**And it is clearable without knowing the passcode**, using the Mac's own login credential:

&gt; "*Remove a passcode for yourself:* Scroll down, then turn off **Lock Screen Time Settings**. **Enter the
&gt; four-digit passcode (or verify your identity with your password or Touch ID).**"
&gt; — <https://support.apple.com/guide/mac-help/set-change-remove-a-screen-time-passcode-mac-mchl336af525/mac>

Plus the Apple Account recovery path — "enter the Apple Account email address and password that you used to set
up the Screen Time passcode" (<https://support.apple.com/en-us/102677>, Published 2026-06-12), with two traps:
for a Family-Sharing child account "**the Family organizer needs to reset the Screen Time passcode on their own
device**", and the recovery account "might be a different Apple Account than the one that you're signed in to".

**Detection:** open System Settings → Screen Time. That is the reliable check and it needs no terminal.
Command-line signals were absent on the Screen-Time-off test machine (`defaults read
com.apple.applicationaccess` → "does not exist"), so they are **untested as positive detectors** and should not
be presented as such.

**Guide verdict: 📝 Note, and a short one.** It survives nothing and blocks almost nothing.

---

## 8. Local account and admin locks

Under-appreciated, and it silently disables most of the other checks. Without an **administrator** password the
buyer cannot:

- enter macOS Recovery normally — Apple's Apple-silicon steps require "**Select an administrator account**…
  Enter the password" (<https://support.apple.com/guide/mac-help/macos-recovery-a-mac-apple-silicon-mchl82829c17/mac>);
- run Erase Assistant — "enter your **administrator information**, then click Unlock"
  (<https://support.apple.com/guide/mac-help/erase-your-mac-mchl7676b710/mac>);
- change the security policy, or turn FileVault on or off.

A seller who retains an admin account retains all of the above **and** the ability to read the machine.

**Detection, unprivileged, verified on the M4 Air:**

```
$ dscl . -read /Groups/admin GroupMembership
GroupMembership: root _mbsetupuser mingrath
$ dscl . -list /Users UniqueID | awk '$2>=500'
$ sysadminctl -secureTokenStatus mingrath
```

`sysadminctl -secureTokenStatus <user>` runs **without sudo** and reports whether the account holds a Secure
Token — the credential class that gates FileVault and LocalPolicy signing. An account with no Secure Token is
second-class even if nominally an admin. Also look for hidden accounts: a seller account under UID 500 does not
appear in the login window by default.

**Escape hatch requiring no password at all:** Recovery → Recovery Assistant menu → **Erase Mac**, which
"permanently removes each user account, its password, and its data" — then lands you at Activate Mac, where
Activation Lock is waiting (<https://support.apple.com/en-us/102633>).

**Best mitigation, and it is Apple's own advice for selling a Mac:** insist the seller runs EACS in front of
you and hands the machine over showing **"Hello"**
(<https://support.apple.com/guide/mac-help/erase-your-mac-mchl7676b710/mac>).

---

## 9. Activation-Locked parts — the lock nobody expects

**This is the largest thing the ticket did not list.** On Apple silicon Macs running **macOS Tahoe 26 or
later**, an individual replaced part carries its own Activation Lock, tied to the Apple Account of the machine
it came out of:

&gt; "When a previously used part is linked to someone else's Apple account, **the part is protected by Activation
&gt; Lock**. Until you take these steps to unlock the part, the part **isn't covered by the Apple Limited Warranty
&gt; or an AppleCare plan, and you can't trade in your device**." … "**Apple can't help remove Activation Lock for
&gt; previously used parts.**"
&gt; — <https://support.apple.com/en-us/120610> (Published 2026-04-29)

**Tracked parts and scope:** logic board, display, Touch ID board, lid angle sensor, top case (with Touch Bar);
MacBook Air model years 2020, 2022–2026 and MacBook Pro 2020–2026
(<https://support.apple.com/en-us/123128>, Published 2026-05-11).

⚠️ **The part list is contested and must be reconciled before the guide prints one.** Sibling research on
[#5](https://github.com/mingrath/mbcheck/issues/5) independently reached this lock under Apple's
**`Finish Repair`** label and reports the covered parts as **battery, display, front camera and Touch ID
sensor** — overlapping this note's list on display and Touch ID, but adding battery and camera while omitting
logic board, lid angle sensor and top case. **This note did not verify #5's list and does not merge the two.**
The discrepancy matters commercially: [#13](https://github.com/mingrath/mbcheck/issues/13) established that a
swapped **battery** is invisible to Parts & Service, which is incompatible with a battery being an
Activation-Lockable part. One of the three findings is wrong, or Apple maintains two different lists
(*calibratable* vs *reportable* vs *lockable*) — exactly the ambiguity #13 already flagged as unresolved.
*To pin: Apple's own table for `Finish Repair` specifically, read side by side with 123128 and 123123, or
first-hand observation on a Tahoe 26 Mac with a third-party part.*

Both findings agree on the part that actually matters for the buyer's decision, and that agreement is safe to
print: **a used part linked to a previous owner's Apple Account is Activation-Locked, Apple will not remove it,
and the part is then ineligible for warranty service and the machine ineligible for trade-in.**

**How it presents:** a persistent "Finish Repair" notification and an entry under System Settings → General →
About → **Parts & Service**. The Mac boots and works — but the part "might not perform as expected or have
features that are critical to privacy, security, or safety."

**Why it is 🛑 and not 💰:** proof of purchase does not help. Apple explicitly will not intervene. Only the
previous owner of the *donor* device can unlock it, and the buyer will never find them.

**Buyer action:** on any Tahoe 26+ Mac, check Parts & Service and run **Repair Assistant** before paying —
Apple itself now leads its Activation Lock article with this step
(<https://support.apple.com/en-us/102541>).

**This sharpens [#13](https://github.com/mingrath/mbcheck/issues/13).** That ticket established that Parts &
Service tracks only four components and never calls the flag permanent. This adds a fifth part (lid angle
sensor / top case with Touch Bar per Repair Assistant's list) and, more importantly, a *second, harsher*
consequence of a repair history that #13 did not cover: not just a cosmetic flag but a warranty-void,
trade-in-void, Apple-won't-help lock. The two findings should be reconciled when the check list is fixed.

---

## 10. Things that are not locks but cost the buyer anyway

### The 90-day Apple Account association lock

&gt; "When you try to associate a device that was previously associated, you might notice a message that says,
&gt; '**This device is associated with another Apple Account. You cannot associate this device with another Apple
&gt; Account for [number] days.**' **You might need to wait up to 90 days.**"
&gt; — <https://support.apple.com/en-us/118412> (Published 2026-05-29)

The Mac works; iCloud signs in; but the App Store / Media & Purchases side refuses to bind, blocking
redownloads of the buyer's *own* purchases. **Preventable, and free:** the seller removes the Mac in advance
via Music/TV app → Account → **Manage Devices** → Remove. Apple lists "If you want to sell or give away an
associated device" as a reason to do exactly that. **Add it to the pre-sale ask.**

### App Store licences do not transfer

Apps, and every App Store-bought licence — Final Cut, Logic, Pixelmator — belong to the **seller's** Apple
Account and stop being available when they sign out. Apple's only sanctioned mechanism, *purchase migration*,
is explicitly for one person consolidating **two of their own accounts**: it needs the password for both, runs
**only from an iPhone or iPad**, requires both accounts in the same country, is one-shot, imposes a **1-year
lockout** if undone, and is blocked outright if either account is **locked or disabled**
(<https://support.apple.com/en-us/117294>, Published 2025-07-10).

**Guide line:** a listing advertising "comes with Final Cut and Logic" is advertising the seller's licence.
Budget to re-buy. Handing over the whole Apple Account is not the workaround — it carries the seller's payment
methods and is the account you would need for Activation Lock removal.

### AppleCare+ may not be transferable

AppleCare is transferable in general, with the agreement number, serial, proof of coverage, **original sales
receipt** and the new owner's details. **But:** "If you make monthly or annual payments for your AppleCare plan,
and your plan is already **linked to an Apple Account, then it can't be transferred to a new owner**"
(<https://support.apple.com/en-us/111801>, Published 2024-12-17).

**This feeds the map's open "AppleCare+ / warranty" gap directly:** a seller advertising coverage until 2028
may be selling coverage that legally cannot follow the machine, and the buyer must check *plan type and payment
mode*, not just the expiry date.

### macOS update ceiling — not an issue, and the guide should not imply one

Every MacBook M1 through M5 is on Apple's macOS Tahoe 26 compatibility list
(<https://support.apple.com/en-us/122867>, Published 2026-06-08); latest release is Tahoe 26.6
(<https://support.apple.com/en-us/109033>, Published 2026-07-27). **Do not warn buyers that an M1 is stranded.**
The real version risk is the opposite: an MDM *holding a Mac back*, or a Recovery Lock preventing reinstall.

---

## 11. Carrier and financing locks — mostly a myth on a Mac

### Carrier lock cannot exist

**No MacBook has ever shipped with a cellular modem, SIM or eSIM.** Apple's spec pages list only Wi-Fi and
Bluetooth, from the first M1 machine to the current lineup (<https://support.apple.com/en-us/111883>,
<https://support.apple.com/en-us/122209>). A modem-level carrier lock is therefore technically impossible. State
it plainly and move on.

### The third-party "financing lock" industry is Android-only

PayJoy's lock is an Android app plus Samsung Knox integration
(<https://www.samsungknox.com/en/partner-solutions/payjoy>); Trustonic's published device-financing material is
entirely smartphone- and carrier-framed. **No published macOS lock agent exists.** Do not warn buyers about a
"PayJoy-style lock on a MacBook" — it is not a thing.

### The one mechanism that does work is ADE

A dealer or lender that wants leverage over a Mac cannot lock the radio. It must put the serial into Apple
Business via Apple Configurator — see
[§2](#2-automated-device-enrollment-ade--the-one-that-actually-bricks-machines). **A "financing lock" on a Mac
*is* an ADE lock**, with all the same properties: server-side, survives everything, org-only release. The guide
needs one mechanism, not two.

### Thailand — no published source establishes a device lock

The published Thai MacBook instalment products read as ordinary consumer credit, with **no device-lock term in
any of them**:

| Provider | Product | Device-lock term published? |
|---|---|---|
| TrueMoney / Ascend Nano | "Pay Next Extra", MacBook 0% up to 36 months, promo 2026-04-01 → 2026-09-30 | **None.** <https://support.truemoney.com/knowledge-base/เป็นเจ้าของ-macbook-ได้ง่ายกว่/> (published 2026-04-01) |
| Studio7 / Comseven | Credit-card 0% up to 24 months | **None** — a pure credit product. <https://instore.studio7thailand.com/promotions/promotion-credit-card/> (retrieved 2026-08-04) |
| UFUND (Thunder FinFin) | No-credit-card instalments; finances MacBook at iStudio by SPVi, 10% down, up to 36 months | **None published.** <https://www.ufundth.com/it-product>, <https://edu.istudiobyspvi.com/u-fund> (retrieved 2026-08-04) |
| AIS | SmartPay 0% up to 36 months | **None** — bank credit-card scheme. <https://www.ais.th/consumers/promotions/smart-pay/smartpay-all-model> |

**But the practice is real and documented only by the people doing it.** Treat all of the following as
**claims**, not facts: a Thai reseller-facing service openly markets turnkey MDM lock systems for instalment
shops covering "iPhone iPad Mac" (<https://www.youtube.com/watch?v=2dYbTnldqxI>); a Thai shop states in its own
reel that "ไม่ติด iCloud ของทางร้าน… แต่เครื่องจะมีการติดตั้งระบบ MDM"
(<https://www.instagram.com/reel/DbZ-OQhy_4H/>, ~2026-07-30); a user review asserts "ค้าง 2 งวด เครื่องติดล็อค"
on a MacBook Air M2 (<https://www.lemon8-app.com/@pn_kluay/7438226343139246599?region=th>, 2025).

**Guide line for the Thailand block:** *the risk is real, the terms are not published — so verify the machine,
don't trust the paperwork.* Which is the same advice ADE already forces.

---

## 12. There is no stolen-device database you can check

- **Apple's iCloud Activation Lock status checker was removed at the end of January 2017**
  (<https://www.macrumors.com/2017/01/29/apple-removes-activation-lock-status-checker/>, 2017-01-29 — press,
  secondary) and **never covered Macs**. This is stated as an inference, not an Apple statement: Activation Lock
  on Mac requires T2 or Apple silicon plus macOS Catalina 10.15+
  (<https://support.apple.com/en-us/102541>), and T2 Macs and Catalina both postdate the checker's withdrawal.
- **`checkcoverage.apple.com` is a warranty tool and nothing more.** Apple's own description: "Check your Apple
  warranty status. Enter a serial number to review your eligibility for support and extended coverage."
  It is **CAPTCHA-gated and not machine-readable** — no public API, not scriptable. It does **not** report
  Activation Lock, Find My, ADE/ABM enrollment, MDM, Recovery Lock, or theft status. What it *is* good for:
  confirming the serial exists, that it identifies as the model in front of you, and the AppleCare position.
  **The map's note that it "may not be machine-readable at all" is confirmed.**
- **Thailand:** no public Royal Thai Police or government serial lookup for stolen electronics was found.
  `thaipoliceonline.go.th` is a cyber-crime *reporting* portal; CRIMES Search is an internal investigative
  tool; the Criminal Records Division does person-based checks only. Absence of a finding is not proof of
  absence — but no such service could be located, and any site claiming to be one should be treated as
  unverified.
- **Commercial:** CheckMEND (fed by Immobilise) sells per-device history reports, but both are **report-driven
  and UK-centred**. **A hit is meaningful; a miss means nothing** for a Mac sold in Thailand, because no Thai
  owner or police force feeds that database.

**Consequence for the guide: provenance cannot be verified by lookup. It can only be verified by paperwork and
by the seller's behaviour.** That is what makes Apple's six receipt criteria (§1) the operative standard.

---

## The detection procedure

Ordered by what it costs the buyer. Everything in Phase 1 is free and instant, so per
[#9](https://github.com/mingrath/mbcheck/issues/9) there is no cap on it.

### Phase 1 — script-read, unprivileged, ~2 seconds

Every line below was verified to run without sudo on macOS 26.5.2:

```bash
system_profiler SPHardwareDataType | grep -Ei "Model Name|Model Identifier|Chip|Memory|Serial|Activation Lock"
profiles status -type enrollment                    # Enrolled via DEP / MDM enrollment
system_profiler SPConfigurationProfileDataType      # empty == clean
system_profiler SPManagedClientDataType             # empty == clean
defaults read /Library/Preferences/com.apple.FindMyMac   # FMMEnabled
fdesetup status
csrutil status
csrutil authenticated-root status
spctl --status
dscl . -read /Groups/admin GroupMembership
dscl . -list /Users UniqueID | awk '$2>=500'
sysadminctl -secureTokenStatus "$(whoami)"
diskutil apfs listVolumeGroups
sw_vers
```

**Any of these is an immediate 🛑:** `Enrolled via DEP: Yes`; `MDM enrollment: Yes`; a non-empty
`SPConfigurationProfileDataType`; `csrutil` not "enabled".

### Phase 2 — GUI reads, no sudo, ~1 minute

- **System Settings → General → Device Management** — an organisation name here is damning. Absence is
  inconclusive.
- **System Settings → General → About → Parts & Service**, and **Repair Assistant** on Tahoe 26+ — the
  Activation-Locked-parts check (§9).
- **System Settings → Screen Time** — is it on, is "Lock Screen Time Settings" on.

### Phase 3 — the two physical tests no script can do

**Test A — the reboot, for Recovery Lock.** Shut down, hold the power button. You want the startup-options
screen with the gear. A password prompt instead is Recovery Lock (§3). *This is the only way to find it.*

**Test B — the erase, and it is the single most valuable test in the whole guide.** Ask the seller to run
Erase All Content and Settings **in front of you, on Wi-Fi**, and watch the machine reach the desktop or the
Hello screen with **no Remote Management pane and no Activation Lock prompt**.

Why it is worth the minutes:

- It is the only test that exercises Apple's **activation-time** checks, where ADE and Activation Lock actually
  bite. Nothing readable from a running system does that.
- It forces the seller to prove they hold the Apple Account password — EACS cannot complete without it.
- It is **irreversible for the seller**, which is precisely why a seller with something to hide will refuse.
- **Wi-Fi, not Ethernet.** Auto Advance can enrol a Mac silently over Ethernet with no pane at all (§2).

Per [#9](https://github.com/mingrath/mbcheck/issues/9), refusing *one method* is free but refusing *every*
method for a fact is itself a 🛑 finding. There is no substitute for Test B.

**Even a clean pass proves only "not currently assigned", not "out of ABM."** Nothing available to a buyer can
prove the latter. That residual risk is irreducible and the guide should say so rather than imply the checks
are complete.

### Phase 4 — the paperwork, which is not optional

Because no lookup can establish provenance (§12) and because Apple's only escalation route requires it (§1):

- The **original Apple-Authorized-Reseller receipt**, meeting Apple's six criteria.
- **Serial matching in three places** — receipt, `About This Mac`, physical marking. A logic-board swap breaks
  this and now also intersects §9.
- The **seller's Apple Account email**, recorded. If a *part* turns out to be locked, that is the only thing
  that could ever unlock it, and Apple will not help.
- Ask the seller to remove the Mac from **Manage Devices** (§10) — free, and saves the buyer 90 days.

---

## Permanent vs removable — the walk-away list

**🛑 Permanent for a buyer. No negotiation, no price makes this correct:**

| Lock | Why it is permanent |
|---|---|
| **ADE / ABM assignment** | Server-side against the serial. Survives EACS and DFU. Apple Support is **not** among the entities that can release a device, and Apple documents no remedy against a defunct or uncooperative organisation. |
| **Organisation Activation Lock** | Apple refers you to "your IT department". |
| **Activation-Locked parts** | Apple states outright: "Apple can't help remove Activation Lock for previously used parts." |
| **Personal Activation Lock with an uncooperative or unreachable seller** | Only Apple's proof-of-purchase request, which needs a compliant reseller receipt the buyer usually will not have. |
| **Recovery Lock with no second Mac** | No Apple proof-of-purchase path exists. DFU restore clears it, but that needs another Mac and a USB-C data cable. |

**Removable by a cooperative seller, before payment, in front of you:**

Personal Activation Lock (sign out) · Find My · MDM profile on a Mac never in ABM · FileVault · Screen Time ·
non-admin account · Reduced/Permissive Security · the 90-day association lock (Manage Devices → Remove).

**The dividing line is simple enough to print:** if the fix requires an *organisation*, it is 🛑. If it requires
only the *seller standing in front of you*, it is a condition of sale — do it now, or no sale.

---

## Naming: "Apple Business", not "Apple Business Manager"

Apple is consolidating **Apple Business Manager, Apple Business Essentials and Apple Business Connect** into a
single product called **Apple Business**, and states the three "will no longer be available once Apple Business
launches" (<https://www.apple.com/newsroom/2026/03/introducing-apple-business-a-new-all-in-one-platform-for-businesses-of-all-sizes/>,
2026-03-24; confirmed in Apple's docs at
<https://support.apple.com/guide/apple-business-manager/apple-business-manager-is-now-apple-business-axmd79d79dea/web>).
Current documentation URLs use `/guide/business/`; the old `/guide/apple-business-manager/` paths still resolve.

**Write "Apple Business (formerly Apple Business Manager) / Apple School Manager"** and expect the older name in
anything published before 2026.

---

## Open questions and contradictions

1. **Apple contradicts Apple on the `profiles` rate limit.** `man profiles` says "10 times every 23 hours" with
   no scope condition; Apple Platform Deployment says "10… per 24 hours" and only "for devices owned by an
   organization that appear in Apple School Manager or Apple Business". If the deployment guide is right, being
   throttled would itself be an ABM signal — but that is unverified, and the limiter state is destroyed by an
   erase anyway, so it is not forensic.
2. **Does EACS clear Recovery Lock?** Apple documents that *MDM unenrollment* removes it, and that EACS resets
   security settings to Full Security — but **no Apple source says EACS itself removes Recovery Lock, and none
   says it doesn't.** Do not assert either way.
3. **Is System Settings → Device Management hidden when no profiles are installed?** Apple's Personal Safety
   guide implies yes (using the legacy "Profiles" pane name); the macOS Tahoe 26 User Guide describes the pane
   as normally reachable with no hidden-state caveat. Unresolved — which is why absence must be treated as
   inconclusive.
4. **`cloudconfigurationd` no longer exists on macOS 26.5.2.** Directly observed: no
   `/usr/libexec/cloudconfigurationd`, no matching LaunchDaemon; `mdmclient` and `ManagedClient` survive. **Any
   guide telling readers to inspect `cloudconfigurationd` logs is stale.** What replaced it is undocumented.
5. **`is_mandatory` may be stale for macOS.** Apple's spec forces mandatory ADE only for "iOS 13 and later";
   macOS still defaults to `false`. Given macOS 14+ enforcement makes the point largely moot, this may simply
   be an un-updated page.
6. **The only Apple-primary source on user-approved MDM is archived** (<https://support.apple.com/en-us/101332>,
   Published 2023-11-17), written in High Sierra vocabulary. The `guide/deployment/…user-approved-mdm…` URLs
   cited by vendor glossaries **404**.
7. **Undocumented local artifacts.** `/private/var/db/ConfigurationProfiles/Settings/.cloudConfigNoActivationRecord`
   and `com.apple.mdm.depnag.plist` are world-readable and appear to record the result of a DEP check-in. **No
   Apple or vendor documentation exists for either.** Corroborating only — never load-bearing.
8. **Apple's compatibility list now includes a "MacBook Neo (13-inch, A18 Pro)"** — an A-series MacBook. The
   map's "M1–M5, Air and Pro" framing silently excludes it, and #13 already found Apple treating MacBook Neo as
   a separate line for repair pricing and Parts & Service.

---

## Unpinned / could not establish

Listed so the guide author knows not to reach for something that does not exist.

| # | Missing | Why | What would pin it |
|---|---|---|---|
| 1 | **Any way to ask, from the device, whether a serial is in ABM** | Apple's design is assignment-triggered; the authoritative record is server-side and gated behind the owning organisation's ABM credentials | Nothing available to a buyer. An Apple-documented public API by serial — which does not exist and, given the design, will not |
| 2 | **A false-negative rate for `profiles status` as a pre-purchase test** | Nobody publishes one | A controlled study over used-market Macs, or Apple telemetry. **Do not put a number on this** |
| 3 | **Apple documentation of the literal strings `Enrolled via DEP:` / `MDM enrollment:`** | `man profiles` documents only the `(User Approved)` suffix | An Apple page defining the CLI's output. The `ManagementStatus` mapping is strong inference, not an Apple statement |
| 4 | **Whether EACS clears Recovery Lock** | No Apple source either way | A controlled test on a Recovery-Locked Mac |
| 5 | **The Recovery Lock prompt's exact on-screen wording** | Apple ships a figure with alt text "A Mac showing that recoveryOS is locked" but no transcript | First-hand observation |
| 6 | **The Remote Management pane's on-screen wording** | Apple names the pane and states it is unskippable, but never quotes or screenshots it | An Apple screenshot. Everything quoting it verbatim is vendor or forum material |
| 7 | **How a Mac user exercises the 30-day provisional release** | Apple documents the *right* for Macs; the only auto-release *mechanism* it spells out is iOS 14+ only | An Apple page describing the macOS release UI, or a test inside the window |
| 8 | **Whether a buyer can tell they are inside the 30-day window** | Nothing buyer-visible exposes the provisional flag or enrollment date | — |
| 9 | **Any Apple support path for a private buyer against a defunct organisation's ABM** | Only the Activation Lock form exists; Apple's release list excludes Apple itself | **The finding is that no defensible primary source exists** |
| 10 | **What `SPConfigurationProfileDataType` / `SPManagedClientDataType` print on a *managed* Mac** | Both empty on the unmanaged test machine | Running them on an ADE-enrolled Mac |
| 11 | **Positive command-line detectors for Screen Time** | Both candidate paths were absent on a Screen-Time-off machine; could not confirm the enabled shape | A Mac with Screen Time on |
| 12 | **Whether "your password" in Apple's Screen Time removal step means the login or Apple Account password** | Apple writes "your password or Touch ID" without disambiguating; the Touch ID pairing implies the local credential | Empirical test |
| 13 | **Polling cadence for a newly-added ABM assignment on a Mac past Setup Assistant** | The `depnag` artifact and macOS 14+ enforcement imply ongoing checks; no source states an interval | **Do not put a number on it** |
| 14 | **Whether UFUND / Thunder FinFin technically locks financed MacBooks** | Its FAQ is a JavaScript accordion that did not render; retail partners publish marketing terms only; BaNANA's page 403s behind Cloudflare | The signed สัญญาเช่าซื้อ, or a statement from Thunder FinFin |
| 15 | **Whether AIS, True or dtac impose any device lock on any Apple product in Thailand** | Their published instalment pages describe bank credit-card schemes only | The full เงื่อนไข PDF behind each promotion |
| 16 | **Whether any Trustonic/PayJoy-class product has ever supported macOS** | Only absence of evidence — no macOS product page, all material smartphone-framed | A vendor platform-support matrix |
| 17 | **Exactly which fields `checkcoverage.apple.com` returns for a Mac serial today** | CAPTCHA-gated; not exercised with a real serial | Running a known serial through it by hand |
| 18 | **Any Thai police or government serial lookup for stolen electronics** | A targeted Thai-language search of the RTP, thaipoliceonline, CRD and CITC surfaced none | A direct enquiry to สำนักงานตำรวจแห่งชาติ |
| 19 | **Publication dates for Apple Platform Deployment and ABM/ASM guide pages** | None carry a date in the body | Nothing — **2026-08-04 is the only date of record** for those pages |
| 20 | **First-hand observation of `Activation Lock Status` in any state other than `Enabled`** | The dedicated Activation Lock investigation did not report back; §1 was assembled from the other three plus command output from one machine, which has Find My on | Sign out of iCloud on any Apple-silicon Mac, re-run `system_profiler SPHardwareDataType`, record the reading. **Ten minutes of work and it de-risks the guide's single most-used check** |
| 21 | **The exact on-screen wording of the Activation Lock window** | Apple describes it only as "an Activation Lock window that asks for someone else's Apple Account" | A screenshot from a locked Mac. Same gap as the Remote Management pane (#6) and the Recovery Lock prompt (#5) — **Apple documents none of the three screens a buyer must actually recognise** |
| 22 | **Whether `Activation Lock Status` distinguishes personal from organisation-linked Activation Lock** | The field is a single enabled/disabled string; nothing observed suggests it carries the flavour, and no Apple source describes one | Observation on an ABM-enrolled Mac. Matters because the two flavours have opposite remedies (§1) |
| 23 | **Mark As Lost / Lost Mode on a Mac** — exact behaviour, persistence, and presentation | Not reached. Apple documents Managed Lost Mode as iPhone/iPad only, and a Find My remote lock as presenting a PIN, but the consumer "Mark As Lost" path on a Mac was not investigated | Apple's Find My user guide for Mac, plus first-hand observation |

---

## Method and tooling

Research ran as four parallel primary-source investigations — Activation Lock and Find My; MDM/ADE/ABM;
Recovery Lock, firmware password, Startup Security, FileVault, Screen Time and local accounts; financing,
carrier, stolen-device databases and everything the ticket's list missed — each instructed to weight Apple
Support, Apple Platform Deployment, Apple Platform Security and Apple developer documentation above all else,
to label forum, video and marketplace material as **claims**, and never to invent a fact to fill a gap.

**Three of the four reported. The Activation Lock and Find My investigation did not return**, so
[§1](#1-activation-lock) was assembled from the other three — which covered Activation Lock substantially, as
it is load-bearing for both the MDM and the Recovery Lock questions — plus first-hand command output. §1 is
well-sourced on mechanism, requirements, EACS and DFU behaviour, the two flavours, and Apple's proof-of-purchase
bar. It is **thin on observation**: see Unpinned [#20](#unpinned--could-not-establish)–[#23](#unpinned--could-not-establish),
which are cheap to close and should be closed before `check.sh` ships.

**Tooling:** AgentKey MCP was the primary search and fetch tool throughout (`Serper/search`,
`Brave/getWebSearch`, `Firecrawl/scrape`), with `wigolo fetch`/`search` as a secondary fetcher where AgentKey
scraping failed. Built-in WebSearch and WebFetch were **not** used for any claim in this document.

**Every command result in this note was produced first-hand** on the dev's MacBook Air (`Mac16,13`, M4, macOS
26.5.2, build 25F84, `profiles` 8.51), unprivileged, on 2026-08-04 — not quoted from documentation. Where a
command needs root, that was verified by running it and recording the refusal, because the map fixes that
`check.sh` takes no sudo.

**Errors caught during verification, recorded so they are not reintroduced:**

1. An initial reading had `profiles show -type enrollment` exiting 0 unprivileged. It exits **1** — the earlier
   result was an artifact of piping through `head`. Testing by exit status is therefore valid.
2. An initial sweep reported that Apple does not name the "Remote Management" Setup Assistant pane. Apple
   **does**, in its pane table — but still never documents the pane's on-screen wording.
3. `system_profiler -detailLevel mini SPHardwareDataType` was assumed equivalent to the default. It is not: it
   **omits both the serial number and the Activation Lock Status**.

**Deliberately excluded rather than quoted unverified:** the Apple Professional Training module on the
provisional period (page would not render; its wording is available only via third-party excerpt); all
Reddit/MacRumors/Apple Discussions threads on stuck MDM enrollments; and every "MDM bypass" or "iCloud unlock"
vendor page encountered, which are out of scope per the map and are not repeated here even to refute them.
