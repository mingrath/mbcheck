# Apple's on-device diagnostic and reporting surfaces on Apple silicon

Research note resolving [issue #3](https://github.com/mingrath/mbcheck/issues/3).
Feeds [#17](https://github.com/mingrath/mbcheck/issues/17) (what a flag can and cannot catch) and
[#15](https://github.com/mingrath/mbcheck/issues/15).

Graded against the admission bar fixed in [#9](https://github.com/mingrath/mbcheck/issues/9): a check earns a
place only if a bad result can **on its own** produce a 🛑 walk-away / 💰 renegotiate / 📝 note. **No cap on what
a read-only script reads; hard cap of 8 steps / ~10 minutes by hand.** Every surface below is therefore
labelled with whether a bad reading is *on-its-own actionable*, and whether it costs an **admin password** or a
**reboot** — both expensive in a stranger's shop.

**Research date: 2026-08-04.** Every claim carries a URL and the page's stated publication date, or says
plainly that the page carries none. `UNPINNED` marks a fact that could not be established, with what would pin it.

**Evidence labels:** `Apple doc` · `Apple doc (negative)` (Apple's silence or explicit exclusion, used as
evidence) · `industry` · `anecdote only` · `none` · **`first-hand`** — command output observed directly on a
real Apple-silicon Mac, see [Method](#method-and-test-rig).

---

## ⚠️ What this research refutes or corrects

| # | Claim | Reality | Where |
|---|---|---|---|
| 1 | README Step 4: check repair history via **Parts & Service** as the machine's history surface | Parts & Service tracks **four parts** and needs **Tahoe 26** — already pinned in [#13](https://github.com/mingrath/mbcheck/issues/13). What is new here: **`system_profiler SPiBridgeDataType` is a strictly better first read**, is instant, needs no sudo, and reveals secure-boot downgrade, SIP state and MDM approval flags in one shot. | [SPiBridgeDataType](#spibridgedatatype--the-single-highest-value-command) |
| 2 | Apple Diagnostics is invoked with the **`D`** key | **`D` and `Option-D` are Intel-only.** On Apple silicon: shut down → hold power → wait for **Options** → **hold Command-D**. The vast majority of "Apple Diagnostics" content on the web is Intel-era and wrong for M1–M5. | [Apple Diagnostics](#apple-diagnostics-on-apple-silicon) |
| 3 | Apple Diagnostics has an internet/recovery-server variant on all Macs | **Apple silicon has no `Option-D` equivalent.** Apple bifurcates explicitly inside code **PPT004**, offering the internet re-test to Intel users and withholding it from Apple silicon users. | [Apple Diagnostics](#network-requirement) |
| 4 | Apple Diagnostics reference codes include **`HDD00x`** for storage | **No `HDD*` family exists.** Storage is **`VDH001–VDH004`**. `HDD00x` is pre-2013 *Apple Hardware Test* — a different, Intel-only tool. Any page listing HDD00x as Apple Diagnostics output is stale. | [Reference codes](#reference-codes--the-full-published-table) |
| 5 | Apple Diagnostics can flag a **non-genuine or replaced part** | **Apple never claims this, anywhere.** All ~50 reference codes are fault findings ("There may be an issue with…"). Not one is a provenance verdict. `Apple doc (negative)`. | [Genuineness](#can-apple-diagnostics-detect-a-non-genuine-part-no) |
| 6 | Apple Diagnostics results can be read back afterwards | **Nothing persists.** `SPDiagnosticsDataType` still exists in `-listDataTypes` on Tahoe 26 but returns an **empty array**. Apple's own advice is *"Make a note of any reference codes before you exit"* — which only makes sense if nothing is stored. **Photograph the screen.** | [Persistence](#are-results-stored-anywhere-no) |
| 7 | Battery **Condition** can read *Replace Soon* / *Replace Now* / *Service Battery* | Those three are **legacy**. Current macOS documents **two** states: **Normal** and **Service Recommended**. The old words survive only on pre-Battery-Health Macs via the Option-click menu-bar trick. | [Battery](#battery--the-richest-untracked-surface) |
| 8 | Apple's spec is "80% of original capacity at **1,000 complete charge cycles**" | Apple's current wording is *"up to 80% of its original capacity at its **maximum cycle count**"* and links to a separate table. The verbatim "1,000" string is a **stale revision**. Composing both current pages still gives **80% @ 1000** for every Apple-silicon MacBook. | [Battery](#battery--the-richest-untracked-surface) |
| 9 | `sudo powermetrics --samplers smc` reads fan RPM and die temperature | **The `smc` sampler does not exist on Apple silicon** — `powermetrics: unrecognized sampler: smc`. `first-hand`. That Intel-era recipe is dead. Valid samplers are `tasks battery network disk interrupts cpu_power thermal gpu_power ane_power sfi`. | [Thermal](#thermal--what-actually-works) |
| 10 | `pmset -g therm` reports CPU speed limits | On Apple silicon it emits only *"No thermal warning level has been recorded"* × 3, and **exits 0** — it fails silently. The Intel keys `CPU_Speed_Limit` / `CPU_Scheduler_Limit` / `CPU_Available_CPUs` are never emitted. `first-hand`. | [Thermal](#thermal--what-actually-works) |
| 11 | `SPNVMeDataType` returns nothing on Apple silicon because the SSD is behind the SoC | **False — it returns a full record**, including model, serial and `S.M.A.R.T. status: Verified`. The real negative is narrower: **no wear counter**. No *Percentage Used*, no *Data Units Written*, no *Available Spare*. `first-hand`. | [Storage](#storage--the-wear-counter-you-cannot-have) |
| 12 | SSD wear is unknowable on Apple silicon | **The counter exists on the device; macOS ships nothing that reads it.** Third-party `smartctl` reads it fine. State it as a tooling gap, not a hardware gap. | [Storage](#storage--the-wear-counter-you-cannot-have) |
| 13 | Reading secure-boot policy needs `bputil`, which needs an **admin password** | **It does not.** `bputil -d` does require root (`first-hand`: *"The tool requires running as root"*), but `system_profiler SPiBridgeDataType` prints **`Secure Boot: Full Security`** plus SIP, SSV, Kernel CTRR and MDM approval flags **with no sudo at all**. | [SPiBridgeDataType](#spibridgedatatype--the-single-highest-value-command) |
| 13b | [#13](https://github.com/mingrath/mbcheck/issues/13): *"a missing Parts & Service pane is a signal to investigate"* — but it is weak, since Apple says the option appears only after a repair | **It becomes decidable.** Apple: turning SIP off on Apple silicon **requires** acknowledging a downgrade to **Permissive Security**, which *"can be accessed only from command-line tools"* and cannot be reached from Startup Security Utility. So **SIP off ⇒ Permissive Security ⇒ Parts & Service hidden**, and the downgrade is always deliberate and always visible. A missing pane **with** `Full Security` is benign; a missing pane with anything else is 🛑. | [The chain](#the-chain-that-makes-this-the-guides-best-anti-cover-up-check) |
| 14 | Activation Lock state needs iCloud.com or a reboot to Setup Assistant | **`system_profiler SPHardwareDataType` prints `Activation Lock Status:` directly** (`activation_lock_status` in JSON). `first-hand`, no sudo, instant. The README's reboot-to-Hello-screen check is still worth keeping, but it is no longer the *only* read. | [Locks](#locks-enrollment-and-security-state) |
| 15 | `profiles status -type enrollment` needs `sudo` | **It does not.** `first-hand`: it returns `Enrolled via DEP: No` / `MDM enrollment: No` as an unprivileged user. The map calls MDM the largest known gap; **it costs zero seconds and zero passwords to read**. | [Locks](#locks-enrollment-and-security-state) |
| 16 | Parts & Service is the only surface that can betray a swapped **top case** | **`ioreg` exposes `KeyboardLanguage`** from the physical top case (`first-hand`: `"KeyboardLanguage" = "Thai"`). Cross-check it against the **region suffix of `Model Number`** (`first-hand`: `MC7A4TH/A` → TH). A mismatch is on-device evidence of a **cross-region top-case swap**. See [#17](#answering-17-the-untracked-components). | [Untracked](#answering-17-the-untracked-components) |
| 17 | Nothing on-device can hint at a swapped **battery** | **Partly false.** `system_profiler SPPowerDataType` prints a **battery pack serial**, and `ioreg -rc AppleSmartBattery` adds `LifetimeData.TotalOperatingTime`, `MaximumTemperature`, `CycleCountLastQmax`, `ChemID`/`AlgoChemID` and `DataFlashWriteCount`. **Cycle count wildly inconsistent with the machine's age is the tell.** Not proof — but actionable. | [Untracked](#answering-17-the-untracked-components) |
| 18 | Nothing on-device can hint at a swapped **display** on an Air/Pro | **True, and it is a hard negative.** `SPDisplaysDataType` emits no panel serial, no EDID, no vendor/product ID for the built-in panel, and `ioreg` carries no `IODisplayEDID` / `DisplaySerialNumber` for it. `first-hand`. Nothing on-device can prove an Air/Pro screen swap. | [Untracked](#answering-17-the-untracked-components) |
| 19 | `system_profiler SPAirPortDataType` shows the Wi-Fi network name | **Every SSID renders as `<redacted>`** on Tahoe 26 for an unprivileged caller without Location authorization (`first-hand`, 9 occurrences). Worse, `networksetup -getairportnetwork en0` actively lies — *"You are not associated with an AirPort network"* while connected. Buyer impact is nil (SSID is irrelevant), but a script author will be misled. | [system_profiler sweep](#the-systemprofiler-domain-sweep) |
| 20 | An ex-corporate Mac can always be put into Apple Diagnostics | **No.** Apple Platform Deployment: a **recoveryOS password** set by MDM *"prevent[s] access to the recoveryOS environment, **including the startup options screen**"*. Such a machine cannot run Apple Diagnostics at all — and that refusal is itself a finding. | [Apple Diagnostics](#does-the-seller-have-to-unlock-anything) |
| 21 | [#13](https://github.com/mingrath/mbcheck/issues/13) left it **contested** whether an unpaired display surfaces on an Air/Pro | **Resolved: yes, inside a narrow window.** Apple's Repair Assistant page (123128, 2026-05-11) lists **Display as a calibrated part for MacBook Air *and* MacBook Pro, 2020–2026** — so an *uncalibrated* display swap shows `Finish Repair` and fires a notification. A *finished* one still never reaches the history table. | [#17 answer](#answering-17-the-untracked-components) |
| 22 | [#13](https://github.com/mingrath/mbcheck/issues/13) left open whether a **top-case swap** flags indirectly via the tracked **Touch ID board** | **Dead end — it does not.** Apple's Top Case procedure (121950, 2026-04-17) has the technician **remove the original Touch ID board and reinstall it** into the new top case; the Touch ID procedure (121952, 2025-09-15) triggers Repair Assistant only *"if you replace this part"*. Original board, original pairing, no flag. | [#17 answer](#the-touch-id-cross-link-is-a-dead-end--correction-to-13s-open-question) |
| 23 | Compare the **engraved bottom-case serial to the software serial** to detect a logic-board swap | **Retracted.** Apple documents nowhere where the Apple-silicon system serial lives, nor whether a board swap changes it. The one on-point field report says it **did not** change. The "logic board holds the serial" claim traces to a **2006** Intel-era forum post. It can produce false negatives; do not sell it as a board-swap test. Use Parts & Service → Logic Board → `Unverified` instead. | [Serials](#retraction-do-not-publish-the-engraved-vs-software-serial-test) |
| 24 | `FCClValidationStatus` / `CmPMValidationStatus` in `ioreg` indicate camera tampering | **They read `Invalid` on a factory-original, never-opened machine.** `first-hand`. The most inviting false positive found anywhere in this research. | [Camera](#camera--a-real-serial-and-a-booby-trap-next-to-it) |
| 25 | `/Library/Logs/DiagnosticReports/` is readable by any user | **No — it requires `admin` group membership** (`drwxrwx--- root:_analyticsusers`, and `_analyticsusers` nests `admin`). Apple's Console guide states the gate. The real cost throughout this category is **admin membership, not `sudo`** — a shop that hands you a standard account closes `DiagnosticReports`, `log show` and `last` at once. | [Logs](#sysdiagnose-console-and-logs--mostly-not-worth-a-buyers-time) |
| 26 | Nothing survives an Erase All Content and Settings, so the machine's past is unreadable | **The erase leaves a dated receipt.** `/var/log/install.log` is **world-readable** (`-rw-r--r--`) and logs `mobile_obliterator` / `ObliterateDataPartition`. On the rig: 98 matching lines dated 2026-07-11, agreeing with `.AppleSetupDone` and `wtmp begins`. You cannot read the history, but you can read **the ceiling on how far any history could reach**. | [Logs](#the-one-log-check-that-is-genuinely-worth-it) |
| 27 | A useful screen check is *"no True Tone means the panel was replaced"* | **Fails in both directions and Apple never documented it for Mac.** Apple's True Tone page (102147, 2026-03-10) never mentions repair; and Repair Assistant now restores display calibration on Air/Pro 2020–2026, so its presence no longer proves an original panel. Apple's own tooling broke the signal. | [Display](#display--screen-on-air--pro--partial-and-the-strongest-of-the-untracked-set) |
| 28 | The README's Photo Booth step treats camera and mic as one check; [#13](https://github.com/mingrath/mbcheck/issues/13) split them **by price** | They also split **by detectability**. The camera is inside the display assembly (117310, 2026-03-11) and inherits the display's `Finish Repair` handle; the **microphone ships preinstalled in a replacement top case** (121950, 2026-04-17) and has **no on-device tell whatsoever**. | [Camera](#camera--a-real-serial-and-a-booby-trap-next-to-it) |
| 29 | The map lists on-device **warranty/coverage state** as unknown and blocking | **It exists**: System Settings → General → **AppleCare & Warranty** (`Apple doc` 102607, page age 2026-05-07; `first-hand`: `CoverageSettings.appex`, `com.apple.Coverage-Settings.extension`). **But it is Apple-Account-scoped, not device-local** — its own strings say *"Coverage is shown for devices connected to your Apple Account"* and *"Sign In to View AppleCare & Warranty"*. | [Warranty](#warranty--applecare-coverage--readable-on-device-but-only-before-the-seller-signs-out) |
| 30 | The README's steps are order-independent | **They are not.** The coverage pane **goes blank the moment the seller signs out of iCloud** — which is what Step 1b asks them to do. **Coverage must be read before the sign-out or it is lost for the visit.** This is a hard ordering constraint between two steps the README currently presents as unrelated. | [Warranty](#warranty--applecare-coverage--readable-on-device-but-only-before-the-seller-signs-out) |

---

## The answer in one table

Every surface, graded against [#9](https://github.com/mingrath/mbcheck/issues/9)'s admission bar.
**Cost** columns: 🔑 = needs an admin password · 🔄 = needs a reboot · 🌐 = needs network.

| Surface | Proves | Cannot prove | Runtime | Cost | Bad result actionable alone? |
|---|---|---|---|---|---|
| **`SPHardwareDataType`** | Model ID, chip, cores, RAM, serial, **Activation Lock Status**, region SKU | Anything about condition | <1 s | — | ✅ 🛑 (Activation Lock Enabled + seller can't sign out) |
| **`SPiBridgeDataType`** ⭐ | **Secure Boot level**, SIP, Signed System Volume, Kernel CTRR, **MDM approval flags** | Whether MDM is *currently* enrolled | <1 s | — | ✅ 🛑 (Secure Boot ≠ Full Security) |
| **`profiles status -type enrollment`** ⭐ | Current MDM enrollment + DEP registration | **Whether the machine is still *assigned* in ABM but not yet enrolled — `UNPINNED`, and it is the trap that springs after the buyer erases** | <1 s | — | ✅ 🛑 when bad; **not a clearance when good** |
| **`SPPowerDataType`** | Cycle count, Condition, Maximum Capacity %, **battery pack serial**, charger wattage | Genuineness of the pack; runtime in hours | <1 s | — | ✅ 💰 (Service Recommended / high cycles) |
| **`pmset -g rawlog`** | `Cycles=N/1000` — count **and** the model max in one line | Same as above | ~2 s + Ctrl-C | — | ✅ 💰 |
| **`ioreg -rc AppleSmartBattery`** | Lifetime max/min temperature, total operating time, `PermanentFailureStatus`, `BatteryCellDisconnectCount`, `ChemID` vs `AlgoChemID` | Genuineness (no Apple contract on any key) | <1 s | — | 📝 mostly; ✅ 🛑 if `PermanentFailureStatus ≠ 0` |
| **`SPNVMeDataType`** | SSD model, serial, capacity, TRIM, **binary SMART pass/fail** | **Wear. Percentage used. TBW.** | <1 s | — | ✅ 🛑 (SMART not `Verified`) |
| **`diskutil apfs list`** | True capacity vs advertised; **`Sealed: Yes`** (system volume intact) | Wear | ~1 s | — | ✅ 🛑 (capacity ≠ advertised) |
| **`csrutil status`** / in `SPSoftwareDataType` | SIP on/off | Why it was turned off | <1 s | — | ✅ 🛑 (SIP disabled — also hides Parts & Service) |
| **`fdesetup status`** | FileVault on/off | — | <1 s | — | 📝 |
| **Thermal state (JXA one-liner)** | Current thermal pressure, Apple-documented 4-state enum | Absolute temperature; fan RPM | <1 s (× 2, around a load) | — | 📝 alone; ✅ 💰 with the stress test |
| **`SPDisplaysDataType`** | Resolution, GPU cores, Metal level, panel type | **Any panel identity whatsoever** | <1 s | — | 📝 |
| **`SPInstallHistoryDataType`** | `Source: 3rd Party` + dates — e.g. remote-access software | Hardware anything | ~2 s | — | 📝 (🛑 if remote-access tooling + a resistant seller) |
| **`/var/db/.AppleSetupDone` mtime** | When Setup Assistant last completed = when the machine was last erased | Machine age | <1 s | — | 📝 |
| **`grep mobile_obliterator /var/log/install.log`** | A **dated receipt** of Erase All Content and Settings; world-readable | The history the erase destroyed | ~2 s | — | 📝 (🛑 if it contradicts the seller's story) |
| **`ls /var/db/PanicReporter/`** | A recent kernel panic; world-readable (`drwxrwxrwx`) | Anything before the last erase | <1 s | — | ✅ 🛑 if non-empty |
| **`ioreg` `KeyboardLanguage`** vs device-tree `region-info` | Physical top case's keyboard region vs the machine's sales region | Same-region top case swaps | <1 s | — | ✅ 💰 (mismatch) |
| **`SPSPIDataType` `Serial Number`** | A per-unit **top-case serial** — record it, re-check at collection | That the top case was replaced | <1 s | — | 📝 |
| **Device tree** (`mlb-serial-number`, `region-info`, `coverglass-serial-number`, `product-name`) | Logic-board serial, sales region, panel serial, marketing name | Whether any of them changed on a swap (**`UNPINNED`**) | <1 s | — | ✅ 🛑 on a region/model mismatch |
| **Parts & Service pane** | Logic board · Touch ID board · lid-angle sensor (M5) · display (Neo only) | Battery, screen on Air/Pro, top case, speaker, camera, mic, fan, trackpad, IO board | ~30 s by hand | Tahoe 26 only | ✅ 🛑 — see [#13](https://github.com/mingrath/mbcheck/issues/13) |
| **AppleCare & Warranty pane** | Coverage for devices **on the signed-in Apple Account** | Coverage of the hardware as such; anything once the seller signs out | ~20 s by hand | 🌐 + seller signed in | 📝/💰 — and **must be read before the iCloud sign-out** |
| **Apple Diagnostics** | A per-component fault verdict, incl. battery/display/storage/fan/Wi-Fi/adapter | **Genuineness. Provenance. Cycle count. Cosmetics.** | "a few minutes" | 🔄 (+ 🌐 optional) | ✅ 🛑/💰 depending on code |
| **`bputil -d`** | Nothing `SPiBridgeDataType` doesn't already give | — | <1 s | **🔑** | ❌ **redundant — do not use** |
| **`powermetrics`** | CPU/GPU/ANE power, thermal notifications | **Fan RPM. Die temperature.** | ≥5 s | **🔑** | ❌ **not worth the password** |
| **`sysdiagnose`** | — | — | minutes | **🔑 root** | ❌ **not worth a buyer's time** |
| **`log show --last 7d`** | — | — | **682 s measured** | admin | ❌ **eleven and a half minutes of noise** |
| **`/Library/Logs/DiagnosticReports/`** | Crash/panic reports, if any survived the erase | Anything pre-erase | ~1 s | **admin group** | ❌ mostly empty on a prepped machine |
| **`SPDiagnosticsDataType`** | **Nothing — returns empty on Apple silicon** | Everything | <1 s | — | ❌ **dead surface** |

⭐ = the two commands this research most wants added to the guide.

---

## Method and test rig

Two things were done, and they are kept separate throughout.

**1. Live document research.** AgentKey MCP (`Serper/search`, `Brave/getWebSearch`, `Firecrawl/scrape`) plus
`wigolo` fetch/extract for page reads, run as four parallel investigations (Apple Diagnostics; locks and
security state; untracked-component provenance; battery/storage/thermal counters). Built-in WebSearch/WebFetch
were not used. Apple support pages and the Apple Platform Deployment / Platform Security guides were preferred
over forums; forum material is labelled `anecdote only`.

**2. First-hand execution on a real Apple-silicon Mac.** Everything labelled `first-hand` below is command
output observed directly on:

> **MacBook Air 15-inch · `Mac16,13` · Apple M4 · 10-core (4P/6E) · 16 GB · 256 GB · macOS 26.5.2 (25F84) ·
> Darwin 25.5.0 · arm64 · Model Number `MC7A4TH/A` · device-tree `region-info` `TH/A` ·
> `regulatory-model-number` `A3241` · **never repaired** (so the Parts & Service pane is absent, exactly as
> Apple documents) · observed 2026-08-04.**
> Every command was run **as an unprivileged user** unless the note says otherwise.

**Rig caveats that bound the negatives — read these before trusting any negative below.**

- It is a **fanless Air**, so no claim about fan RPM readability on a MacBook Pro is first-hand.
- It is **one generation (M4)** and **n = 1**, so M1/M2/M3/M5 key sets are extrapolated, and — critically —
  **key *existence* is pinned but key *behaviour on a swap* is not.** There was no swapped machine to diff
  against. Where that distinction matters the text says so explicitly rather than inferring.
- It is **never repaired**, **not enrolled in MDM**, and Activation Lock is enabled by its legitimate owner, so
  in every case only **one branch** of each check was observed.
- No `sudo` was used, deliberately — the whole point is what a buyer can read without asking for a password.
- **Identifiers are redacted.** This repo is public, so every real serial, UUID, UDID and MAC address from the
  rig is truncated with `•` in this note. Where an argument depends on part of a value — the date-code
  characters in [component date-code coherence](#a-novel-observation--component-date-code-coherence-n--1) —
  exactly that part is preserved and the rest masked. Field *lengths* and *formats* are preserved so a script
  author can still parse against them.
- **The account used is in the `admin` group** (`first-hand`: `id -Gn` lists `admin` and `_analyticsusers`).
  That matters for exactly one finding — see the [DiagnosticReports correction](#sysdiagnose-console-and-logs--mostly-not-worth-a-buyers-time).
  Everything else was re-checked as genuinely world-readable.

**Measured runtime of the entire read-only sweep: 5.2 seconds cold** (`first-hand`, `time` around thirteen
`system_profiler` domains plus `profiles`, `csrutil`, `fdesetup`, `diskutil`, two `ioreg` calls, `stat`, a
`grep` and an `ls`). Adding `SPAirPortDataType` takes it to ~13 s, because that one domain runs a live Wi-Fi
scan and costs **8.0 s by itself**. Under [#9](https://github.com/mingrath/mbcheck/issues/9)'s bar, script-read
checks are free, so this whole tier clears on own-outcome alone and consumes **none** of the 8-step by-hand
budget.

One wart for whoever writes the script: `system_profiler` writes `hw.cpufamily: 0x…` to **stderr** on Tahoe 26.
Redirect `2>/dev/null`.

---

## Apple Diagnostics on Apple silicon

### Invocation — it is *not* the `D` key

`Apple doc.` Four independent Apple pages agree, and all four are Apple-silicon-specific:

1. **Shut the Mac down.** *"Shut down your Mac. If you can't shut it down normally, press and hold its power button for up to 10 seconds, until your Mac turns off."*
2. **Press and hold the power button** (on laptops with Touch ID, hold Touch ID).
3. **Keep holding** — the Mac turns on and loads startup options. **When you see Options, release.**
4. **Press and hold Command (⌘)-D until the Mac restarts.**

- "Use Apple Diagnostics to test your Mac", <https://support.apple.com/en-us/102550> — **published 2025-12-19**. Its **"Apple silicon"** section carries the sequence verbatim; `D` and `Option-D` appear only under the sibling **"Intel processor"** heading.
- "If your Mac starts up to Options with a gear icon", <https://support.apple.com/en-us/102342> — **published 2025-03-17**: *"These hidden features are also available in startup options: … Press and hold Command (⌘)-D to open Apple Diagnostics."*
- Apple Platform Support guide, "Identify and troubleshoot hardware issues with Apple Diagnostics", <https://support.apple.com/guide/platform-support/identify-troubleshoot-hardware-issues-apple-supcc5ec6049/web> — no page date; observed 2026-08-04.
- iMac user guide, "Mac resources, service, and support", <https://support.apple.com/guide/imac/mac-resources-service-and-support-apd7bd1310b3/mac> — no page date; observed 2026-08-04.

Apple gives **no hold duration in seconds** — the cue is the event ("when you see Options, release").

**Behaviour change in Tahoe 26** (`Apple doc`, 102550): *"In macOS Tahoe 26 and later, you're asked to choose a
specific diagnostic to run, such as a diagnostic for your built-in display, keyboard, or trackpad. In earlier
versions of macOS, this is automatic."* This is effectively Apple-silicon-only, since Tahoe 26 does not run on Intel.

**There is also an in-macOS `Apple Diagnostics.app`** — `first-hand`:
`/System/Library/CoreServices/Apple Diagnostics.app`, bundle ID `com.apple.DiagnosticsModeAssistant`, version
1.0, present on macOS 26.5.2. **It is not a seller-usable path.** Its own localized strings (read `first-hand`
from `Contents/Resources/Localizable.loctable`) include:

- `DMA_NO_SESSION_ERROR_BODY` — *"You must have an active AppleCare Diagnostics session to use this app."*
- `DMA_RESTART_CONSENT_TITLE` — *"Restart your Mac to Start Apple Diagnostics"*
- `DMA_BATTERY_PERCENTAGE_ALERT_SUBTITLE` — *"Apple Diagnostics requires at least 20% battery or connection to a power source."*
- `DMA_OPEN_LID_BODY` — *"Make sure the lid is open all the way."*

Do not tell a buyer to open this app. It requires an AppleCare-initiated session.

### Network requirement

`Apple doc`, and Apple's own pages differ in emphasis, so all three are recorded:

| Page | Wording |
|---|---|
| 102550 (2025-12-19) | *"If your Mac isn't already connected to the internet, you're asked to choose a Wi-Fi network…"* and *"…you might be given the option to run diagnostics offline. In that case, **click Run Offline**, unless Apple Support or a repair technician has initiated an online Apple Diagnostics session for this Mac."* |
| Platform Support guide (no date) | *"You may be asked to choose a language and make sure that you have an active network connection."* |
| iMac guide (no date) | *"Be sure the computer is connected to the internet."* |

**Net finding:** the test itself **can run offline** — "Run Offline" is an Apple-documented button. What
definitely needs internet is the *post-result* service lookup: *"To get information about service and support
options, **make sure the Mac is connected to the internet**, then click 'Get started' or press Command-G."*
For a shop, run it offline; you only lose the service-options page.

**Apple silicon has no `Option-D` internet variant.** `Apple doc (negative)`, and the cleanest citation is
Apple bifurcating inside a single reference-code row — **PPT004** (<https://support.apple.com/en-us/102334>,
**published 2025-12-15**):

> *"**If you're using a Mac with an Intel processor**, you can confirm this result by using Apple Diagnostics
> over the internet: … press and hold Option-D … If this code appears again **or you're using a Mac with Apple
> silicon**, contact Apple or take your computer to an AASP or Apple Store…"*

Architecturally corroborated: "Boot modes for a Mac with Apple silicon"
(<https://support.apple.com/guide/security/boot-modes-sec10869885b/web>, no page date) lists **exactly four**
boot modes — macOS, Paired recoveryOS, Fallback recoveryOS, Safe mode — **with no Diagnostics mode**. Intel's
separate `diags.efi` environment and its OS-Recovery-Server fallback have their own Platform Security page
(<https://support.apple.com/guide/security/recoveryos-and-diagnostics-environments-sec2512a0c09/web>); **there
is no Apple-silicon counterpart page.** On Apple silicon, Diagnostics is entered *from within* the
startup-options environment, not as a firmware boot mode.

### Runtime

The only Apple figure that could be pinned: *"The basic Apple Diagnostics test takes **a few minutes** to
complete."* — iMac user guide `apd7bd1310b3`, no page date; observed 2026-08-04.

Note that **this sentence has been removed from the MacBook Air version of the same page**, which now carries
no duration at all. 102550 and the Platform Support guide give none either — only *"Apple Diagnostics shows a
progress bar while it's checking the Mac."*

`UNPINNED` — any per-model timing under Tahoe 26's new pick-a-diagnostic flow. To pin: a timed run on an M1–M5 laptop.

**Budget it as a 🔄 reboot plus "a few minutes", i.e. one of the 8 by-hand steps and a meaningful chunk of the
10-minute budget.** Under [#9](https://github.com/mingrath/mbcheck/issues/9)'s ">2 min needs 🛑 and no faster
substitute" rule it survives, because several of its verdicts (PPT005, VDH00x, PPF00x) have no faster substitute.

### Scope — and the exclusions, which matter more

`Apple doc`, Mac User Guide (macOS 26), "Diagnose problems on Mac",
<https://support.apple.com/guide/mac-help/diagnose-problems-mh35727/mac> — no page date; observed 2026-08-04:

> *"Apple Diagnostics is a tool you can use to diagnose problems with your computer's **internal hardware, such
> as the logic board, memory and wireless components**. You may be able to start your Mac with Apple
> Diagnostics, even if it doesn't start using macOS.*
>
> ***Apple Diagnostics doesn't check external hardware components, such as a USB device, or non-Apple devices,
> such as PCI cards from other vendors. It doesn't check for macOS or software-related problems such as app or
> extension conflicts.***"

| Component | Apple prose says tested? | Reference codes exist? | Label |
|---|---|---|---|
| Memory | ✅ named | PPM001–PPM016 | `Apple doc` |
| Logic board | ✅ named | **no dedicated code** — proxies only | `Apple doc` prose; gap at code level |
| Wireless | ✅ named | CNW00x, NDL00x, CNT00x | `Apple doc` |
| Display | ✅ (Tahoe 26+, "a diagnostic for your built-in display") | VFD001–VFD007 | `Apple doc` |
| Keyboard / trackpad | ✅ (Tahoe 26+) | NDK00x, NDR00x | `Apple doc` |
| Battery | ✗ never named in prose | **PPT001–PPT007, PPT021** | `Apple doc` via codes only |
| Storage / SSD | ✗ never named in prose | **VDH001–VDH004** | `Apple doc` via codes only |
| **External USB devices** | **explicitly NOT** | — | `Apple doc (negative)` |
| **Third-party PCI cards** | **explicitly NOT** | — | `Apple doc (negative)` |
| **macOS / software / extension conflicts** | **explicitly NOT** | — | `Apple doc (negative)` |
| **Battery cycle count or health %** | never claimed; codes are qualitative bands with no number | — | `Apple doc (negative)` |
| **Dead pixels, burn-in, blooming, delamination** | never claimed | — | `none` — stays a manual visual check |
| **Hinge, chassis, liquid damage, speaker rattle** | never claimed | — | `none` |
| **Non-genuine or replaced parts** | **never claimed** | — | `Apple doc (negative)` |

### Reference codes — the full published table

Source: **"Apple Diagnostics reference codes", <https://support.apple.com/en-us/102334>, published 2025-12-15.**
This is a **single unified table with no Apple silicon / Intel split** — the only processor-conditional text on
the entire page sits inside PPT004's remediation cell.

`[STOCK]` = Apple's boilerplate *"Contact Apple or take your computer to an AASP or Apple Store to learn which
service and support options are available."*

| Code(s) | Apple's definition (verbatim) | More information |
|---|---|---|
| **ADP000** | No issues found. | No issues found. |
| ALS001 | There may be an issue with the ambient light sensor. | [STOCK] |
| BMT001, BMT003–BMT005 | There may be an issue with the Touch ID sensor. | [STOCK] |
| CEH001, CEH002 | There may be an issue with the case handle. *(Mac Pro only)* | Verify the latch is fully locked, then re-run. |
| CNT001–CNT007 | There may be an issue with the Ethernet hardware. | [STOCK] |
| CNW001, CNW003–CNW006 | There may be an issue with the Wi-Fi hardware. | [STOCK] |
| CNW007, CNW008 | No Wi-Fi networks are detected: no networks in range, or an issue with the Wi-Fi hardware. | Re-run in range of a Wi-Fi network. |
| CNW009 | There may be an issue with the Wi-Fi hardware. | [STOCK] |
| DFR001 | There may be an issue with the Touch Bar. | [STOCK] |
| IMU001 | There may be an issue with the accelerometer or gyroscope. | [STOCK] |
| LAS001–LAS004 | There may be an issue with open/close sensor. | [STOCK] |
| NDC001, NDC003–NDC006 | There may be an issue with the camera. | [STOCK] |
| **NDD001** | There may be an issue with the USB hardware. | Disconnect all external devices, re-run. |
| NDK001, NDK003, NDK004 | There may be an issue with the keyboard. | [STOCK] |
| NDL001, NDL002 | There may be an issue with the Bluetooth hardware. | [STOCK] |
| NDR001, NDR003–NDR006, NDR008 | There may be an issue with the trackpad. | [STOCK] |
| NDR007 | An external input device was detected. | Disconnect external input devices and re-run. |
| NDT001–NDT006 | There may be an issue with the Thunderbolt hardware. | Disconnect external Thunderbolt devices, re-run. |
| **NNN001** | **A serial number was not detected.** | [STOCK] |
| **PFM001–PFM007** | There may be an issue with the System Management Controller (SMC). | [STOCK] |
| PFR001 | There may be an issue with the computer's firmware. | [STOCK] |
| **PPF001, PPF003, PPF004** | **There may be an issue with the fan.** | [STOCK] |
| PPM001 | There may be an issue with a memory module. *(socketed RAM only)* | [STOCK] |
| PPM002–PPM016 | There may be an issue with the onboard memory. | [STOCK] |
| PPN001, PPN002 | There may be an issue with the power-management system. | [STOCK] |
| **PPP001–PPP008** | There may be an issue with the power adapter. | Verify the correct adapter, reseat, re-run. |
| PPP017 | Both ports of the Apple 35W Dual USB-C Port Power Adapter are in use. | Use only one charging port during the test. |
| PPP018 | Fast charging is not supported with the currently connected power adapter. | See *Fast charge your MacBook Air or MacBook Pro*. |
| PPP020 | No power adapter was detected. | Verify the adapter, reseat, re-run. |
| **PPR001** | There may be an issue with the processor. | [STOCK] |
| **PPT001** | **The battery was not detected.** | [STOCK] |
| **PPT002, PPT003** | The battery will need to be replaced soon. It is functioning normally, but holds less charge than when new. | [STOCK] |
| **PPT004** | The battery requires service. Not functioning normally, though you might not notice a change. | *Intel only:* re-test with Option-D. **Apple silicon: go to Apple/AASP.** |
| **PPT005** | **The battery is not installed properly. Shut down and discontinue use. The computer requires service.** | [STOCK] |
| **PPT006** | The battery requires service. Not functioning normally, though you may not notice a change. | [STOCK] |
| **PPT007** | The battery needs to be replaced. Functioning normally but holds significantly less charge than when new. | [STOCK] |
| **PPT021** | The battery charge level is too low to complete the test. | **Charge to 6% or higher** and re-run. |
| VDC001, VDC003–VDC007 | There may be an issue with the SD card reader. | [STOCK] |
| **VDH001–VDH004** | **There may be an issue with a storage device.** | [STOCK] |
| VDH005 | Unable to start macOS Recovery. | [STOCK] |
| **VFD001–VFD007** | **There may be an issue with the display or graphics processor.** | [STOCK] |
| VFD008, VFD009 | There may be an issue with the HDMI controller or controllers. | [STOCK] |
| VFD010 | There may be an issue with the Apple I/O card. *(Mac Pro only)* | If uninstalled, this code is expected. |
| VFD011 | There may be an issue with the Antenna Connector Board. | [STOCK] |
| **VFF001–VFF003** | There may be an issue with the audio hardware. | [STOCK] |

**Buyer's cheat sheet — code to grade.** These map onto [#10](https://github.com/mingrath/mbcheck/issues/10)'s
severities; the ฿ figures live in [#13](https://github.com/mingrath/mbcheck/issues/13).

| You see | Component | Suggested grade |
|---|---|---|
| **ADP000** | clean | pass |
| **PPT005** | battery not installed properly, *"discontinue use"* | 🛑 — this is #10's spreading-fault override |
| **PPT001** | battery not detected | 🛑 |
| PPT002/003/006/007 | battery degraded / needs service | 💰 — battery prices are pinned in [#13](https://github.com/mingrath/mbcheck/issues/13) |
| PPT004 | battery requires service | 💰 |
| PPT021 | *test aborted, charge <6%* | not a fault — charge and re-run |
| **VDH001–VDH004** | storage device | 🛑 — no published Thai SSD price; SSD is soldered |
| **VFD001–VFD007** | display **or** GPU — Apple does not separate them | 🛑 if GPU, 💰 if panel; you cannot tell which |
| **PPF001/003/004** | fan — **MacBook Pro only, every Air M1–M5 is fanless** | 💰 |
| **PPR001 / PFR001 / PPN00x / PPM00x** | processor / firmware / power management / soldered memory = **logic board** | 🛑 |
| **NNN001** | **serial number not detected** | 🛑 — on a second-hand purchase this is a provenance alarm |
| CNW00x / NDL00x | Wi-Fi / Bluetooth | 💰 |
| PPP001–PPP008, PPP020 | power adapter — the *charger*, not the Mac | 💰 (charger prices pinned in [#13](https://github.com/mingrath/mbcheck/issues/13)) |
| NDC00x / NDK00x / NDR00x / BMT00x / VFF00x | camera / keyboard / trackpad / Touch ID / audio | 💰 |
| NDT00x / NDD001 / VDC00x | Thunderbolt / USB / SD reader | 💰 |
| LAS00x / ALS001 / IMU001 | lid sensor / ambient light / accelerometer | 📝 |

**Codes that do not exist** — `Apple doc (negative)`:

- **`HDD001` / `HDD00x`** — no `HDD*` family is on the page. Storage is `VDH00x`. `HDD*` codes belong to the pre-2013 **Apple Hardware Test**, a different, Intel-only tool. **Flag any web page listing HDD00x as Apple Diagnostics output as stale.**
- **CNW002, NDC002, NDK002, NDR002, VDC002, PPF002, BMT002** — Apple's numbering genuinely skips these. Do not infer them.

**Two codes are architecturally Intel-flavoured yet appear unannotated:** `PFM001–PFM007` names the *System
Management Controller*, a discrete Intel-Mac component; `PPM001` distinguishes "a memory module" from onboard
memory, which is meaningless where RAM is in-package. `UNPINNED` — whether an Apple-silicon Mac can emit
PFM00x at all. To pin: an Apple statement segmenting the table by processor, or a captured PFM00x result from
an M-series Mac.

### Does the seller have to unlock anything?

| Requirement | Verdict | Label |
|---|---|---|
| **Reboot** | **Yes, unavoidably.** 🔄 | `Apple doc` |
| **Shut down first** | **Yes.** | `Apple doc` |
| **Login password / admin account** | **Apple never states any password requirement.** 102550, 102342, the Platform Support guide, the Mac User Guide and the iMac guide walk the flow end to end and mention no authentication step. | `Apple doc (negative)` |
| **Can it run without signing in?** | Effectively yes. *"You may be able to start your Mac with Apple Diagnostics, even if it doesn't start using macOS."* Command-D is available *at* the startup-options screen; the user-picker-and-password gate belongs to **macOS Recovery**, a different branch taken after Command-D diverges. | `Apple doc` |
| **Battery floor** | **≥ 6%** to complete (PPT021). Keep the charger attached. | `Apple doc` |
| **Lid fully open** (laptops) | On-device string `DMA_OPEN_LID_TITLE` = *"Completely Open Mac to Continue"*. | `first-hand`, not in Apple docs |
| **Firmware password blocker** | **Intel only.** Apple Platform Deployment: a Mac with Apple silicon *"won't require (or support) a firmware password"*. | `Apple doc` |
| **recoveryOS password blocker** | **This is the one that bites.** "Startup security in macOS", <https://support.apple.com/guide/deployment/startup-security-dep5810e849c/web> (no page date; observed 2026-08-04): *"Organizations can, however, prevent access to the recoveryOS environment, **including the startup options screen**, through the use of a recoveryOS password."* and *"**Unless the user enters the recoveryOS password, they can't access the recovery environment, including the Startup Options screen.**"* Set only via MDM. | **`Apple doc`** |
| **Activation Lock** | `UNPINNED` — no Apple page states whether an Activation-Locked Mac can enter Apple Diagnostics. To pin: a statement in <https://support.apple.com/en-us/102541>, or a test on a locked M-series Mac. | `none` |

**The recoveryOS-password finding is itself a check.** An ex-corporate MacBook may simply refuse to show the
Options screen. Under [#9](https://github.com/mingrath/mbcheck/issues/9), *"refusing every method for a fact is
itself a 🛑 finding"* — and here the machine, not the seller, is doing the refusing. A Mac that will not reach
startup options is 🛑 on its own, because it is telling you it is still under someone's MDM.

### Can Apple Diagnostics detect a non-genuine part? **No.**

This is a strong clean negative and it should be stated in the guide in as many words.

| Claim | Verdict |
|---|---|
| Apple ever states Apple Diagnostics detects a non-genuine part | **No — on any page, in any wording.** 102550, 102334, the Platform Support guide, the Mac User Guide and the iMac guide collectively describe it as identifying *hardware issues* / *which component might be at fault*. Not one sentence mentions genuineness, provenance, part serial, calibration or repair history. `Apple doc (negative)` |
| Any reference code reports part genuineness | **None.** All ~50 rows are fault findings. The three nearest are still not provenance verdicts: **NNN001** *"A serial number was not detected"*, **PPT001** *"The battery was not detected"*, **VFD010** *"If you uninstall the Apple I/O card, this code is expected."* `Apple doc (negative)` |
| Where Apple *does* put the genuine-part check | A **separate feature** — System Settings → General → About → **Parts & Service**. Already pinned in [#13](https://github.com/mingrath/mbcheck/issues/13); see below. |

One adjacent fact, and it is easy to over-read. The Tahoe `Apple Diagnostics.app` consent text
(`DMA_TERMS_AND_CONDITIONS_CONTENT`, read `first-hand`) says Apple may collect *"identifiers related to parts
and paired accessories; performance data from the device, parts, and paired accessories"*. That proves Apple's
**online AppleCare session** ingests part identifiers **server-side**. It is a data-collection consent, not a
promise that the tool shows *you* a genuineness verdict — and it only applies to the session variant a seller
cannot initiate. **Do not cite it as evidence that a buyer can see part provenance.**

### Are results stored anywhere? **No.**

| Claim | Verdict |
|---|---|
| Apple documents a saved log / file / Console entry | **No Apple page says results are stored anywhere.** `Apple doc (negative)` |
| The documented post-test options | *"Run the test again"* (⌘R), *"Restart"* (R), *"Shut Down"* (S), *"Get started"* (⌘G). **No Save, Export, Copy or Email.** `Apple doc (negative)` |
| Apple's own implicit admission | *"**Make a note of any reference codes before you exit Apple Diagnostics**, in case you need to contact AppleCare Support."* — advice that only makes sense if nothing persists. `Apple doc (negative)` |
| `SPDiagnosticsDataType` | **Still advertised by `-listDataTypes` on macOS 26.5.2, returns an empty array.** `first-hand`: `system_profiler -json SPDiagnosticsDataType` → `{"SPDiagnosticsDataType":[]}`; text and XML likewise empty. The historical Intel "Power On Self-Test / Last Run / Result: Passed" record is **not available on Apple silicon**. |
| Could that emptiness just mean "never run"? | `UNPINNED`. An empty array on a machine that may never have run the test cannot distinguish *not populated on Apple silicon* from *never run*. To pin: run Apple Diagnostics on an M-series Mac, boot back to macOS, re-query. |
| Historical Intel behaviour | `anecdote only` — a 2018 Ask Different thread reports `system_profiler SPDiagnosticsDataType \| grep "Reference Code"` working on Intel. Do not present as fact. |
| Other traces looked for | `first-hand`: NVRAM carries `prev-lang-diags:kbd` (records the *language* of a prior diagnostics boot, **not a result**). `/System/Volumes/Preboot/<UUID>/PreLoginData/diagnostics/` is the pre-login unified-log store, not Diagnostics output. **No results file exists.** |

**Guidance for the guide: photograph the result screen with your phone before pressing Restart.** Do not promise
readers a log they can pull afterwards.

---

## `SPiBridgeDataType` — the single highest-value command

This surface is not in the ticket's list and it should be. `first-hand`, unprivileged, instant:

```console
$ system_profiler SPiBridgeDataType
Controller:
      Model Identifier: Mac16,13
      Firmware Version: mBoot-18000.121.3
      Boot UUID: 62236916-...
      Boot Policy:
        Secure Boot: Full Security
        System Integrity Protection: Enabled
        Signed System Volume: Enabled
        Kernel CTRR: Enabled
        Boot Arguments Filtering: Enabled
        Allow All Kernel Extensions: No
        User Approved Privileged MDM Operations: No
        DEP Approved Privileged MDM Operations: No
```

**Why it matters more than `bputil`.** `bputil -d` is the documented way to read an Apple-silicon LocalPolicy —
and `first-hand`, it refuses without root: *"The tool requires running as root."* In a stranger's shop, asking
for an admin password is expensive and often refused. `SPiBridgeDataType` delivers the **same secure-boot
verdict for free**. Under [#9](https://github.com/mingrath/mbcheck/issues/9)'s "the fact is non-negotiable, the
method is not", this is the cheap method for a non-negotiable fact.

**What each line proves:**

| Line | Good value | A bad value means | Grade alone |
|---|---|---|---|
| **Secure Boot** | `Full Security` | `Reduced Security` or `Permissive Security` — someone deliberately downgraded the boot policy, which is what you do to load an unsigned kernel extension or a modified OS | ✅ 🛑 |
| **System Integrity Protection** | `Enabled` | Disabled — and per [#13](https://github.com/mingrath/mbcheck/issues/13), **the Parts & Service pane is hidden entirely when SIP is off**, so this can be a deliberate cover-up | ✅ 🛑 |
| **Signed System Volume** | `Enabled` | Disabled — the sealed system volume has been broken | ✅ 🛑 |
| **Kernel CTRR**, **Boot Arguments Filtering** | `Enabled` | Disabled — same family of deliberate downgrade | ✅ 🛑 |
| **Allow All Kernel Extensions** | `No` | `Yes` — third-party kexts permitted | 📝 → 💰 |
| **User / DEP Approved Privileged MDM Operations** | `No` / `No` | `Yes` — the machine has been granted privileged MDM rights, corroborating enrollment | ✅ 🛑 (with `profiles status`) |

### The three secure-boot levels, in Apple's own words

`Apple doc`, "Startup security in macOS", Apple Platform **Deployment**,
<https://support.apple.com/guide/deployment/startup-security-dep5810e849c/web> (no page date; observed
2026-08-04):

> *"There are three security policies for a Mac with Apple silicon:*
> ***Full Security:** The system behaves like iOS and iPadOS, and allows only booting software that was known
> to be the latest that was available at install time.*
> ***Reduced Security:** This policy level allows the system to run older versions of macOS. … This is also the
> policy level you need to configure manually to support booting kernel extensions (kexts) without using a
> device management service…*
> ***Permissive Security:** This policy level supports users that are building, signing, and booting their own
> custom XNU kernels."*

### The chain that makes this the guide's best anti-cover-up check

Three Apple statements lock together, and the consequence is worth spelling out. `Apple doc`, "Startup Disk
security policy control for a Mac with Apple silicon", Apple Platform **Security**,
<https://support.apple.com/guide/security/startup-disk-security-policy-control-sec7d92dc49f/web> (no page date;
observed 2026-08-04):

1. > *"to turn off SIP on a Mac with Apple silicon, a user must acknowledge that they're putting the system
   > into **Permissive Security**."*
2. > *"Full Security and Reduced Security can be set using Startup Security Utility from recoveryOS. But
   > **Permissive Security can be accessed only from command-line tools** for users who accept the risk of
   > making their Mac less secure."* — and *"It isn't possible to downgrade to Permissive Security from the
   > Startup Security Utility app."*
3. [#13](https://github.com/mingrath/mbcheck/issues/13) established from Apple's own Parts & Service page that
   **the pane is disabled entirely when SIP is off.**

Chaining them: **SIP off ⇒ Permissive Security ⇒ Parts & Service hidden.** And because Permissive Security is
reachable *only* from the command line, from recoveryOS, with the LocalPolicy signing key, it **cannot happen
by accident**.

So a seller who has turned SIP off to suppress the repair-history pane has necessarily left
`Secure Boot: Permissive Security` sitting in `SPiBridgeDataType`, readable in under a second with no password.
**The cover-up is louder than the thing it covers up.** This is the single strongest argument for putting
`SPiBridgeDataType` in the guide: it converts "the Parts & Service section is missing" — which
[#13](https://github.com/mingrath/mbcheck/issues/13) correctly warned is *weak* evidence, since Apple says the
option *"appears only when your Mac detects that it has been repaired"* — into a decidable question. A missing
pane **with** Full Security is benign. A missing pane **with** anything else is 🛑.

`SIP` is also printed by `SPSoftwareDataType` (`first-hand`: `System Integrity Protection: Enabled`) and by
`csrutil status` (`first-hand`, **no sudo**: `System Integrity Protection status: enabled.`). Three independent
routes to the same fact — useful, because a seller can refuse one method for free but not all three
([#9](https://github.com/mingrath/mbcheck/issues/9)).

---

## Locks, enrollment and security state

### MDM / Remote Management — free, instant, no password

`first-hand`, **unprivileged**:

```console
$ profiles status -type enrollment
Enrolled via DEP: No
MDM enrollment: No

$ profiles list
There are no configuration profiles installed for user 'mingrath'
```

The map calls MDM *"the largest known gap"* in the README. It costs **one second and no password** to read.
This is the cheapest 🛑 in the entire procedure.

`system_profiler SPConfigurationProfileDataType` returns **empty** unprivileged (`first-hand`) — use
`profiles`, not the `system_profiler` domain. And `SPiBridgeDataType` corroborates from a second angle with its
`User Approved Privileged MDM Operations` / `DEP Approved Privileged MDM Operations` lines
([above](#spibridgedatatype--the-single-highest-value-command)) — two independent reads of the same fact, which
matters under [#9](https://github.com/mingrath/mbcheck/issues/9)'s "refusing one method is free" rule.

> ### ⚠️ The one question this note could not answer, and it is the most important one
>
> **Does a clean `Enrolled via DEP: No` prove the machine will not re-enrol after an erase?**
>
> The two states are not the same thing. *Currently enrolled in an MDM* is what `MDM enrollment:` reports.
> *Assigned to an organisation in Apple Business Manager / Automated Device Enrollment* is a record that lives
> on **Apple's servers**, and it is what makes a Mac re-enrol when it next reaches Setup Assistant — which is
> precisely what happens after the erase the buyer is going to perform.
> [#9](https://github.com/mingrath/mbcheck/issues/9) already established as fact that **Erase All Content and
> Settings does not clear MDM**.
>
> The rig is unenrolled and unassigned, so **only the negative branch was observed** — `Enrolled via DEP: No`
> on a machine that was never in anyone's ABM. Whether that same output would appear on a machine that *is*
> still assigned in ABM but not currently enrolled is **`UNPINNED`**, and the two possibilities have opposite
> consequences for a buyer:
>
> - If ADE assignment **is** visible pre-erase, `profiles status` is a complete pre-purchase MDM test and the
>   guide can lean on it entirely.
> - If it is **not**, then a clean `profiles status` on an un-erased machine is **worth much less than it
>   looks** — the trap springs only after the buyer wipes it and is standing at Setup Assistant with a
>   Remote Management screen and no recourse.
>
> **Until this is pinned, the guide must not present a clean `profiles status` as proof.** Present it as *a
> 🛑 when bad, and not a clearance when good* — and keep the README's reboot-to-Setup-Assistant step, which is
> the only observation that actually exercises the re-enrolment path.
>
> *To pin:* run `profiles status -type enrollment` on a Mac known to be assigned in an ABM/ASM account but not
> currently enrolled; or find Apple's own statement in the Apple Platform Deployment guide's Automated Device
> Enrollment section.

One further Apple-documented fact from the [Apple Diagnostics section](#does-the-seller-have-to-unlock-anything)
belongs here, because it is an MDM lock the README does not mention at all: an MDM can set a **recoveryOS
password** which *"prevent[s] access to the recoveryOS environment, **including the startup options screen**"*
(`Apple doc`, "Startup security in macOS",
<https://support.apple.com/guide/deployment/startup-security-dep5810e849c/web>, no page date; observed
2026-08-04). **A machine that will not show startup options is telling you it is still managed** — a 🛑 that
needs no interpretation.

### Activation Lock — readable locally, which the README does not know

`first-hand`, in `SPHardwareDataType`:

```
Activation Lock Status: Enabled
```

JSON key: `activation_lock_status`. **No sudo, no reboot, no network, no iCloud.com.** The README's
reboot-to-Setup-Assistant check is still worth keeping — it also proves the seller can actually *sign out* —
but it is no longer the only read, and this one costs nothing.

**Caveat, stated plainly: this key is `first-hand`, not `Apple doc`.** A targeted search of support.apple.com
for `"Activation Lock Status"` returns only the **MDM device-information query** documentation
(<https://support.apple.com/guide/deployment/device-information-queries-depa9e8e14a4/web>, page age 2024-03-07),
which is about what an MDM server can ask a managed device — not about the local System Information field.
**Apple documents the `SPHardwareDataType` field nowhere.** `UNPINNED`: which macOS versions and which models
emit it, and its full value set (only `Enabled` was observed). To pin: read it on a machine with Find My off,
and on an M1 running Sequoia 15. Until then, treat a **missing** `Activation Lock Status` line as inconclusive
rather than as "not locked", and fall back to the reboot check.

### Warranty / AppleCare coverage — readable on-device, but only before the seller signs out

The map lists *"how the guide handles a machine still under AppleCare+ or in its 1-year warranty"* as **not yet
specified**, blocked on knowing what coverage state is actually observable. This pins it.

**macOS does have an on-device coverage pane.** `Apple doc`, "Find information about your warranty or AppleCare
plan", <https://support.apple.com/en-us/102607>, **page age 2026-05-07**:

> *"Choose System Settings, then click General. Click **AppleCare & Warranty**, then select your device."*

`first-hand` confirmation on the rig: the pane ships as `CoverageSettings.appex`
(`/System/Library/ExtensionKit/Extensions/`), bundle ID `com.apple.Coverage-Settings.extension`, display name
**"AppleCare & Warranty"**.

**But it is Apple-Account-scoped, not device-local — and that changes how the guide must sequence itself.** Its
own localized strings, read `first-hand` from the bundle:

| String key | Text |
|---|---|
| `CFBundleDisplayName` | `AppleCare & Warranty` |
| **`COVERAGE_FOOTER`** | ***"Coverage is shown for devices connected to your Apple Account** and select Bluetooth-paired devices."* |
| **`APPLEID_SIGN_IN_TITLE`** | ***"Sign In to View AppleCare & Warranty"*** |
| `APPLEID_SIGN_IN_SUBTITLE` | *"Sign in with your Apple Account and then come back to view Coverage for your devices."* |
| `SOMETHING_WENT_WRONG_DESCRIPTION` | *"We are unable to load coverage information for this device."* |

So the pane reads **the signed-in account's device list**, not the hardware in front of you. Three consequences,
and the third is the one the guide has to act on:

1. **It needs the seller signed in**, and it needs network. What you are reading is the *seller's* Apple
   Account — which also means the seller is exposing their other devices to you, so expect reluctance.
2. **It cannot be used by the buyer on their own account** until they own the machine and it appears there.
3. **⚠️ It goes blank the moment the seller signs out of iCloud — which is exactly what the README's Step 1b
   asks them to do.** Once signed out the pane reads *"Sign In to View AppleCare & Warranty"* and nothing else.
   **The coverage check and the sign-out check are order-dependent: coverage must be read *before* the sign-out,
   or it is lost for the rest of the visit.** No amount of later checking recovers it.

**The buyer-controlled path stays off-device**: the serial number at <https://checkcoverage.apple.com>, which
the README's Step 1 already uses and which requires only the serial — readable from
`SPHardwareDataType` without any seller cooperation at all. Apple also documents `mysupport.apple.com` and its
*"View Proof of Coverage"* (102607, 2026-05-07), but that is account-scoped too.

This matters commercially because of what [#13](https://github.com/mingrath/mbcheck/issues/13) established:
AppleCare+ makes a battery ฿0 and caps accidental damage at ฿3,300 / ฿10,000 — **but a prior independent repair
voids it outright.** So "covered" and "has been repaired" interact, and a guide that reads coverage without also
reading Parts & Service can hand the buyer a number that is not actually available to them.

`UNPINNED` — whether the pane ever displays coverage for a device that is *not* on the signed-in account (e.g.
by serial), and whether it shows an expiry date or only a status. To pin: open it on a Tahoe 26 Mac signed in
to the account that owns the machine.

### The rest of the security state

| Command | sudo? | Output on the rig (`first-hand`) |
|---|---|---|
| `csrutil status` | **no** | `System Integrity Protection status: enabled.` |
| `csrutil authenticated-root status` | **no** | `Authenticated Root status: enabled` |
| `fdesetup status` | **no** | `FileVault is Off.` |
| `bputil -d` | **yes** 🔑 | `The tool requires running as root` — **redundant, skip it** |
| `defaults read /Library/Preferences/com.apple.FindMyMac.plist` | **no** | `{ FMMEnabled = 1; }` — **Find My Mac state, world-readable** (`-rw-r--r--` root:wheel), no sign-in needed |
| `stat -f %SB /var/db/.AppleSetupDone` | **no** | `2026-07-11 14:25` — when Setup Assistant last completed |
| `last reboot` | **admin** | boot/shutdown history; `wtmp begins <date>` bounds how far back the machine's local history goes |

**Find My is worth a line of its own.** `first-hand`: `/Library/Preferences/com.apple.FindMyMac.plist` is
world-readable and contains `FMMEnabled = 1`. Combined with `SPHardwareDataType`'s
`Activation Lock Status` (JSON value `activation_lock_enabled`), a buyer gets **two independent reads of the
lock state with no password, no reboot and no network** — where the README currently has only the
reboot-to-Setup-Assistant test. Keep the reboot test anyway: it is the only one that proves the seller can
actually *perform* the sign-out, which is the thing you are really buying.

`/var/db/.AppleSetupDone` is a quietly useful provenance cross-check. It proves **when this OS install was last
set up**, i.e. when the machine was last erased. A seller who says *"I erased it this morning for you"* and a
timestamp from two years ago do not agree. It **cannot** prove machine age — a fresh erase is the normal,
honest thing for a seller to do.

---

## Battery — the richest untracked surface

### Condition states: two, not five

`Apple doc` — <https://support.apple.com/en-us/108376>, **published 2026-05-11**, and the macOS 26 edition of
<https://support.apple.com/guide/mac-help/check-the-condition-of-your-computers-battery-mh20865/26/mac/26>
(no page date; observed 2026-08-04).

| State | Status |
|---|---|
| **Normal** | current |
| **Service Recommended** | current |
| Replace Soon / Replace Now / Service Battery | **legacy — removed** |

Apple relegates the old three explicitly: *"If you don't see Battery Health, you're using an older Mac or macOS
that doesn't have this feature. Press and hold the Option key while clicking the battery status menu… which
might report battery-health status as Replace Soon, Replace Now, or Service Battery."*

Also worth quoting to a buyer (`Apple doc`, 108376): *"Third-party apps that report battery-health conditions
might not be accurate or conclusively indicate diminished system runtime. It's best to rely on the
battery-health information reported by macOS."* That is Apple pre-emptively discounting a seller's
coconutBattery screenshot.

### Cycle limits and the 80% spec

`Apple doc` — <https://support.apple.com/en-us/102888> (no page date; table read 2026-08-04):
**every Apple-silicon MacBook — Air 13"/15" M1–M5, Pro 13"/14"/16" M1–M5 — has a maximum cycle count of 1000.**
No Apple-silicon model is anything else. (The 300/500-cycle rows are all pre-2011 Intel hardware.)

`Apple doc` — <https://support.apple.com/en-us/102589>, **published 2026-06-08**: *"A normal battery is designed
to retain up to 80% of its original capacity at its **maximum cycle count** when operating under normal
conditions."* Apple no longer writes "1,000" in this sentence; the widely-quoted *"80% at 1,000 complete charge
cycles"* string is a **stale revision**. Composing the two current pages still gives **80% @ 1000**.

### Where the numbers live

| Route | sudo | Output |
|---|---|---|
| `system_profiler SPPowerDataType` | no | `Cycle Count`, `Condition`, `Maximum Capacity`, battery `Serial Number`, `Device Name`, AC `Wattage (W)` |
| **`pmset -g rawlog`** | no | one line: `AC; Not Charging; 100%; Cap=100: FCC=100; Design=5760; Time=1092:15; 0mA; **Cycles=61/1000**; Location=0;` — count **and** the model max together, in ~2 s. Streams until Ctrl-C. `first-hand` |
| `pmset -g batt` | no | charge %, source. Thin. |
| System Settings → Battery → **Battery Health** | no | Condition (GUI). `Apple doc` |
| About This Mac → More Info → System Report → **Power** | no | Cycle Count (GUI). `Apple doc` — **cycle count was never in System Settings** |

### Exact key names

`first-hand`. **Text and JSON renderers use different key names, and disagree on one value.**

| Text key | JSON key | Rig value |
|---|---|---|
| `Cycle Count` | `sppower_battery_cycle_count` | 61 |
| **`Condition`** | **`sppower_battery_health`** | text `Normal` / **JSON `Good`** |
| `Maximum Capacity` | `sppower_battery_health_maximum_capacity` | `100%` |
| `State of Charge (%)` | `sppower_battery_state_of_charge` | 100 |
| `Serial Number` | `sppower_battery_serial_number` | *(pack serial)* |
| `Device Name` | `sppower_battery_device_name` | `bq40z651` |
| `Pack Lot Code` / `PCB Lot Code` / `Firmware Version` / `Hardware Revision` / `Cell Revision` | `sppower_battery_*` | — |

> **Trap for whoever writes the script:** the text renderer says `Condition: Normal`; `-json` says
> `"sppower_battery_health" : "Good"`. A script matching the string `"Normal"` against JSON output **silently
> fails**. `first-hand`.

**Keys the ticket asked about that do not exist** on Apple-silicon Tahoe (`first-hand`, `Apple doc (negative)`):
`Full Charge Capacity (mAh)`, `Manufacturer`, `Amperage (mA)`, `Voltage (mV)` are **not** `SPPowerDataType` keys.
`Manufacturer` is **not** an `AppleSmartBattery` key either. These are Intel-era. Do not print them in a guide.

### `ioreg -rc AppleSmartBattery` — undocumented but rich

**No sudo.** Every key below was observed on the rig. **Apple documents none of them** (`Apple doc (negative)`),
so they are `first-hand` for existence and `anecdote only` for interpretation, and Apple may rename them at any
release. Values live in nested dicts — `BatteryData`, `BatteryData.LifetimeData`, `AdapterDetails`,
`ChargerData`, `PowerTelemetryData` — not at the top level.

| Key | Path | Rig value | Why a buyer cares |
|---|---|---|---|
| `PermanentFailureStatus` | top | 0 | non-zero = a latched permanent fault → 🛑 |
| `BatteryCellDisconnectCount` | top | 0 | non-zero = cells have disconnected → 🛑 |
| `CycleCount` | `BatteryData` | 61 | cross-checks `SPPowerDataType` |
| `Serial` | `BatteryData` | *(pack serial)* | **swap detection** |
| `DesignCapacity` | `BatteryData` | 5760 | mAh |
| `NominalChargeCapacity` / `AppleRawMaxCapacity` | top | 5771 / 5627 | the true health ratio; **both drift between reads** |
| `MaxCapacity` | top | 100 | already a **percentage**, not mAh |
| `ChemID` / `AlgoChemID` | `BatteryData` | 22165 / 22165 | **a mismatch is the classic tell of a mismatched pack** — `anecdote only` |
| **`LifetimeData.MaximumTemperature`** | | **43** °C | **lifetime peak** — evidence of thermal abuse |
| `LifetimeData.MinimumTemperature` | | 21 °C | |
| `LifetimeData.AverageTemperature` | | 268 | scaled; unit `UNPINNED` |
| **`LifetimeData.TotalOperatingTime`** | | **10320** | **lifetime hours-ish** — unit `UNPINNED`, but comparable across machines |
| `LifetimeData.CycleCountLastQmax` | | 61 | should track `CycleCount`; a gap is odd |
| `LifetimeData.MaximumChargeCurrent` / `MaximumDischargeCurrent` / `MaximumPackVoltage` / `MinimumPackVoltage` | | 5527 / −3445 / 13376 / 10995 | lifetime electrical extremes |
| `DataFlashWriteCount` | `BatteryData` | 7173 | gauge flash writes |
| `DateOfFirstUse` | `BatteryData` | **0** | **present but unpopulated on this rig** — see [#17](#answering-17-the-untracked-components) |
| `Temperature` | top | 3122–3133 | **centi-Celsius → 31.2–31.3 °C** — see correction below |
| **`CellVoltage`** | `BatteryData` | **(4356, 4356, 4355)** mV at 100%; **(4111, 4106, 4095)** part-charged | **per-cell balance — but charge-state dependent.** See the caveat below before using it |
| `Qmax` | `BatteryData` | (6060, 6081, 6071) | per-cell measured max charge — the same balance signal, in capacity terms |
| `PresentDOD` / `DOD0` | `BatteryData` | (3,3,3) / (576,640,600) | per-cell depth-of-discharge |
| **`DesignCycleCount9C`** | top | **1000** | **the pack states its own rated life** — a third, machine-readable confirmation of the 1000 figure sourced from Apple above and from `pmset -g rawlog` |

> **⚠️ Correction — `Temperature` is centi-Celsius, not centi-Kelvin.** An earlier pass recorded the unit as
> centi-Kelvin. That cannot be right: 3133 cK would be 31.3 K, or −242 °C. Read as centi-Celsius it is
> **31.33 °C**, which is consistent with a warm laptop battery, with `LifetimeData.MaximumTemperature` = 43
> (whole °C on the same pack), and with the tracked rise under load below. `first-hand`, and now settled
> rather than `anecdote only`. `VirtualTemperature` (3929–4009 → 39.3–40.1 °C) reads on the same scale and
> runs ~8 °C hotter, so it is a different sensor, not a different unit.
>
> **Per-cell balance is the addition that matters — with one caveat that stops it being a rule.** The README's
> trackpad-corner test finds a swollen pack only once it is already deforming the chassis. `CellVoltage` shows
> imbalance for free, in under a second.
>
> **But the spread is charge-state dependent, and this rig demonstrates it.** Two readings of the same healthy
> pack, hours apart (`first-hand`): at 100% charge, `(4356, 4356, 4355)` — **1 mV** spread; later, part-charged,
> `(4111, 4106, 4095)` — **16 mV** spread. Same pack, same day, no fault. A guide that printed "more than
> 10 mV means a failing pack" would flag a perfectly good machine that happened to be off the charger.
>
> `UNPINNED`, and more firmly than it first appeared: **what spread is abnormal, at what state of charge.**
> Apple documents the key nowhere, no threshold could be sourced, and the metric moves with charge level. Treat
> it as a 📝 observation to record, **not** a pass/fail test — and read `PermanentFailureStatus` and
> `BatteryCellDisconnectCount` instead, which are unambiguous at any charge level.

### Is Mac "Maximum Capacity %" the same metric as iPhone's? No.

`industry` — derived from observed values, Apple publishes no formula:

```
DesignCapacity        = 5760
AppleRawMaxCapacity   = 5627  →  97.7% of design
NominalChargeCapacity = 5771  → 100.2% of design
macOS "Maximum Capacity" reports: 100%
```

macOS tracks **`NominalChargeCapacity / DesignCapacity`, clamped to 100** — not the raw counter.

**Buyer consequence, and it is a real one:** a shop Mac showing macOS "100%" can simultaneously read ~97.7% in
coconutBattery-style third-party tools. A seller's "100%" screenshot and a buyer's "97%" reading are **both
true and not contradictory**. Apple's own guidance is to trust the macOS number. Note also that battery health
management *"may temporarily reduce your battery's maximum charge"* (`Apple doc`, 102589) — the number is
policy-influenced, not purely physical.

`UNPINNED` — whether iPhone uses the identical formula. Apple documents neither.

---

## Storage — the wear counter you cannot have

### `SPNVMeDataType` works fine; it just has no wear data

`first-hand`, unprivileged:

```
NVMExpress: → Apple SSD Controller: → APPLE SSD AP0256Z:
  Capacity: 251 GB (251,000,193,024 bytes)
  TRIM Support: Yes · Model · Revision · Serial Number
  Detachable Drive: No · BSD Name: disk0
  S.M.A.R.T. status: Verified
```

JSON keys: `device_model`, `device_revision`, `device_serial`, `bsd_name`, `size_in_bytes`, `smart_status`,
`spnvme_trim_support`, `partition_map_type`, `removable_media`, `detachable_drive`, `volumes[]`.

| Counter | Present? |
|---|---|
| `S.M.A.R.T. status` | **Yes** — value `Verified`. **Binary pass/fail only.** |
| **Percentage Used** | **No** |
| **Data Units Written (TBW)** | **No** |
| Available Spare | **No** |
| Power On Hours / Power Cycles | **No** |

**The clean negative, stated precisely:** *no built-in macOS tool exposes NVMe SMART log page 02 for the
internal SSD.* `first-hand`: macOS ships **neither `nvme` nor `smartctl`**, and `diskutil` has no SMART-detail
verb. `first-hand` on the controller itself: the real class is **`AppleANS3CGv2Controller`** (not
`AppleANS3NVMeController`, not `AppleANS2Controller` — neither exists), and its property list contains **no**
percentage-used, data-units-written, wear-levelling or spare-block counter. It carries only static NAND
descriptors — `nand-marketing-name`, `cell-type`, `package_blocks_at_EOL` (a design parameter, not a live
tally) — plus `AppleNANDStatus = "Ready"`. `IOBlockStorageDriver`'s `Statistics` dict holds `Bytes (Read)` /
`Bytes (Write)`, but those are **since-boot**, not lifetime.

**Do not over-state the negative.** The counter *exists on the device*; third-party `smartctl` reads it fine on
Apple silicon (`industry` — Howard Oakley, <https://eclecticlight.co/2026/02/26/how-long-will-my-macs-ssd-last/>,
**2026-02-26**). The honest framing is: **the data is there, macOS ships nothing that reads it, and the ticket
bars installing third-party software.** So for a shop inspection, SSD wear is **unmeasurable**.

Apple publishes **no TBW rating and no SSD-wear readout** for Mac internal storage anywhere on support.apple.com
or developer.apple.com — `Apple doc (negative)`. Oakley's `industry` estimate is ~3000 cycles, with the
dominant wear driver being **VM swap from insufficient RAM** — which makes a heavily-swapped base-RAM machine
the realistic risk, and exactly the thing a buyer cannot measure.

### What a buyer *can* prove about storage

| Command | Proves | Grade |
|---|---|---|
| `system_profiler SPNVMeDataType` | model, serial, TRIM, `S.M.A.R.T. status: Verified` | ✅ 🛑 if not `Verified` |
| `diskutil info disk0` | `Protocol: Apple Fabric`, `Solid State: Yes`, `Hardware AES Support: Yes`, exact byte capacity | ✅ 🛑 on capacity mismatch |
| **`diskutil apfs list`** | **`Size (Capacity Ceiling)`** vs advertised — a "512 GB" machine that isn't; and **`Sealed: Yes`** on the System volume, proving the Signed System Volume is intact | ✅ 🛑 both |
| `system_profiler SPStorageDataType` | per-volume free/capacity, `Medium Type: SSD` | 📝 |

The README already tells the buyer that a 512 GB drive shows ~494 GB. `diskutil apfs list` makes that check
exact rather than eyeballed.

---

## Thermal — what actually works

### Two Intel-era recipes that are dead on Apple silicon

**`pmset -g therm`** — `first-hand`, complete output, exit code **0**:

```
Note: No thermal warning level has been recorded
Note: No performance warning level has been recorded
Note: No CPU power status has been recorded
```

The Intel keys `CPU_Scheduler_Limit`, `CPU_Available_CPUs`, `CPU_Speed_Limit` are **never emitted**. It fails
silently with a success exit code, which is precisely why Intel-era guides keep repeating it.
`UNPINNED` — whether it ever populates on Apple silicon under sustained load; the rig was near-idle. To pin:
re-run during a sustained load on a fan-equipped MacBook Pro.

**`powermetrics --samplers smc`** — `first-hand`: `powermetrics: unrecognized sampler: smc`. **The `smc` sampler
does not exist on Apple silicon.** The sampler name is validated *before* the privilege check, so this was
confirmed without root. `powermetrics` itself requires sudo 🔑 (`first-hand`: *"powermetrics must be invoked as
the superuser"*). Valid samplers on Apple silicon: `tasks battery network disk interrupts cpu_power thermal
gpu_power ane_power sfi`. **No die temperature and no fan RPM.**

**Consequence for the README's Step 3.** The fan stress test stays a **listening** test, not a measurement.
There is no built-in, no-sudo way to read fan RPM on an Apple-silicon MacBook Pro, and — per
[#13](https://github.com/mingrath/mbcheck/issues/13) — every MacBook Air M1–M5 is fanless, so silence is the
correct result on an Air. `UNPINNED` for the Pro specifically: whether *any* built-in surface exposes fan RPM.
The rig is a fanless Air, so its empty `AppleSMC`/fan-key search proves nothing about a Pro. To pin: run
`ioreg -l | grep -i fan` and `sudo powermetrics --samplers thermal` on a MacBook Pro.

### The one thermal read that does work

`Apple doc` for the enum —
<https://developer.apple.com/documentation/foundation/processinfo/thermalstate-swift.enum> (no page date;
observed 2026-08-04): `nominal` *"within normal limits"* · `fair` *"slightly elevated"* · `serious` *"high"* ·
`critical` *"significantly impacting the performance of the system and the device needs to cool down."*

The API is documented; exposing it from a shell is not. This works with **no sudo, no install, no network**
(`first-hand`, verified, exit 0):

```sh
osascript -l JavaScript -e 'ObjC.import("Foundation"); var m={0:"nominal",1:"fair",2:"serious",3:"critical"}; m[$.NSProcessInfo.processInfo.thermalState]'
# → fair
```

`/usr/bin/python3` on a stock Mac has **no PyObjC** (`first-hand`: `ModuleNotFoundError: No module named
'Foundation'`), so JXA is the only zero-install path.

> **Trap — two different enums.** At the same instant on the rig, JXA returned `fair` (ProcessInfo value **1**)
> while `notifyutil -g com.apple.system.thermalpressurelevel` returned **2**. These are **different scales** —
> the notify key is not the `ProcessInfo` enum. `first-hand`. **Use the JXA form**, because it is the one whose
> value labels Apple actually documents. Do not mix them.

**Shop use:** read it cold, run the stress test for 3–5 minutes, read it again. A machine that climbs to
`serious` under light load has a real thermal problem. Alone this is 📝; paired with the existing stress test it
supports 💰.

### ✅ Closing the `pmset -g therm` UNPINNED — it stays empty under sustained load

The `UNPINNED` above asks whether `pmset -g therm` ever populates on Apple silicon under sustained load,
noting the rig was near-idle. **It was run.** `first-hand`, 2026-08-04: ten in-process workers (one per
logical core, deliberately *not* a separate process name — see the warning below), 4.5 minutes, all ten
verified alive at every sample:

```
              thermalState   batt      load    pmset -g therm
COLD          nominal        31.22 C     5.2   EMPTY
t= 45s        fair           31.22 C    26.1   EMPTY
t= 90s        fair           31.25 C    36.1   EMPTY
t=135s        fair           31.28 C    36.6   EMPTY
t=180s        fair           31.30 C    39.8   EMPTY
t=225s        fair           31.32 C    43.3   EMPTY
t=270s        fair           31.33 C    44.0   EMPTY
COOLDOWN      fair           31.33 C    33.9   EMPTY
```

Three results, in order of usefulness:

1. **`pmset -g therm` never populated.** All three "has been recorded" notes persisted through the entire
   load. The UNPINNED is closed for a fanless Air: it is not a near-idle artefact. It remains open for a
   fan-equipped MacBook Pro, which can reach thermal states an Air cannot.
2. **`thermalState` works, and this is clean corroboration of the recommendation above.** It moved
   `nominal → fair` within 45 s of load and held. But two caveats the shop procedure needs: it is
   **sticky on the way down** — still `fair` 20 s after every worker exited — so a buyer must read it
   *cold, before* starting anything, or a previous test contaminates the baseline. And on this Air it moved
   exactly **one step** under a full pin; `serious` and `critical` were never reached. **Do not expect a
   healthy machine to reach `nominal` again quickly, and do not expect an unhealthy one to announce itself
   as `critical`.**
3. **Battery temperature is not a chassis thermal proxy.** It rose **31.22 → 31.33 °C — 0.11 °C — across
   4.5 minutes of full load.** The pack is thermally isolated from the SoC. `AppleSmartBattery.Temperature`
   is an excellent reading of *the battery* and useless as a stand-in for whether cooling works.

### ❌ Throughput decay cannot substitute for the fan test

Worth recording as a **negative** result, so nobody reaches for it. If cooling were failing, aggregate
compute throughput should decay monotonically under sustained load. Measured on the rig (`first-hand`,
eight consecutive 30-second windows, total work summed per window so scheduler contention cancels out):

```
win  units/s   relative to first
0    240.49    1.000
1    164.68    0.685
2    179.17    0.745
3    205.24    0.853
4    203.26    0.845
5    176.14    0.732
6    206.01    0.857
7    307.10    1.277
```

Throughput fell 31 %, recovered, fell again, and **finished 27.7 % faster than it started.** The variance is
background activity, and in a shop you cannot know what the seller's Mac is running. **A throughput-decay
test cannot distinguish thermal throttling from a background process and would generate false 🛑 findings.**
The fan check stays an ear check on a MacBook Pro, and on an Air there is nothing to check.

> **⚠️ Warning for the script: `killall yes` is indiscriminate.** The README's Step 3 stress test ends with
> `killall yes`. `first-hand`, twice: a `killall yes` issued from an unrelated shell **reaped this test's
> load generators mid-run**, destroying the first attempt at both experiments above. It kills *every* `yes`
> owned by the user, not the ones the script started. `check.sh` must track its own worker PIDs and kill
> those, never a name. The rerun above used in-process workers with no matchable process name for exactly
> this reason.

---

## `sysdiagnose`, Console and logs — mostly not worth a buyer's time

**`sysdiagnose`: skip it.** Its man page says verbatim *"sysdiagnose needs to be run as root."* It writes to
`/var/tmp` and pops a Finder window by default, takes minutes, and produces an archive nobody can triage
standing in a shop. It fails [#9](https://github.com/mingrath/mbcheck/issues/9)'s bar twice over — far more
than 2 minutes, and a "bad" result is not something you can read off it in the time available. Socially it is
also close to impossible: you are asking a stranger for their root password to collect a full system dump.

**`log show`: skip it too.** Measured: **`log show --last 7d` took 682 seconds** — eleven and a half minutes —
on a healthy M4, returning ~8,000 lines that are roughly 99% routine `ApplePPMPolicyCPMS` thermal-budget
chatter. Grepping it for `thermal` is **actively misleading**: hundreds of hits on a perfectly healthy machine.
`"Previous shutdown cause"` never appeared at all across 7 days on Apple silicon. A narrow
`--start`/`--end` window is ~25× faster, but by then you are debugging, not shopping.

**The cost curve, measured** (`first-hand`, same rig, same predicate, so the numbers are comparable):

| Window | Elapsed |
|---|---|
| `--last 2m`, **no predicate** (81 791 lines returned) | **1 s** |
| `--last 1h` + predicate | **20 s** (27 s under load) |
| `--last 6h` + predicate | **111 s** |
| `--last 1d` + predicate | **189 s** |
| `--last 3d` + predicate | **killed at 4 min** |
| `--last 30d` + predicate | **killed at 2 min** |

**The cost tracks the window scanned, not the result count** — two minutes of *completely unfiltered* log is
instant, while one filtered hour is twenty seconds. There is no clever predicate that rescues this. And the
practical consequence is worse than the runtime: a shop check can afford roughly **one hour** of log, so a
Mac the seller rebooted twenty minutes before you walked in has **no history inside the affordable window at
all**. The surface is disqualified twice over.

> **Trap — the predicate matches itself.** `first-hand`: every single hit from
> `--predicate 'eventMessage CONTAINS "Previous shutdown cause"'` over a 1-hour window was a
> `com.apple.log` entry recording *the argument string of an earlier `log show` invocation*. Any predicate a
> script runs is itself logged and will match itself on the next run. A naive "did we find any hits?" test
> returns true on a perfectly healthy machine as soon as it has run once.

**And the whole category is forgeable anyway.** `man log` documents **`log erase --all`**: *"Deletes main log
datastore, and inflight log data as well as time-to-live data (TTL), and the fault and error content."* A
seller can wipe the unified log wholesale, in one command, before you arrive. **Any conclusion a buyer draws
from the *absence* of bad log entries is worthless.** Combined with the runtime numbers above, this settles
the question the ticket asked about Console and the logs: they are not worth a buyer's time, and not because
they are slow — because a clean log proves nothing.

**Shutdown-cause codes: the premise is false on Apple silicon.** There is **no Apple-published list** of what
`Previous shutdown cause: N` integers mean — `site:support.apple.com "shutdown cause"` returns zero results,
which is conspicuous given Apple *does* publish the Apple Diagnostics reference table. But the decode table is
moot, because **the codes are not emitted**: `first-hand` on this rig, which rebooted well inside the window,
`--predicate '…"Previous shutdown cause"' --last 1d` returned only the self-referential entries above, and
`--last boot` returned nothing at all. Corroborated as a `CLAIM` by Howard Oakley (The Eclectic Light Company,
2025-04-17, <https://eclecticlight.co/2025/04/17/why-did-my-mac-restart-or-shut-itself-down-and-wheres-the-cause-code/>):
*"these don't appear to be given for Apple silicon Macs… I've not been successful yet on an Apple silicon
Mac."* His table of negative hardware codes (−3 sensors too hot, −64 kernel panic, −71 memory too hot, −74
battery too hot, −103 battery voltage too low) is the best available and is **third-party, not Apple**. Do not
put it in the guide as fact.

### ⚠️ Correction: `/Library/Logs/DiagnosticReports/` is **not** world-readable

An earlier pass of this research recorded that directory as readable without sudo. **That was wrong, and the
reason is instructive.** It is `drwxrwx--- root:_analyticsusers`, and `_analyticsusers` **nests the `admin`
group**. The listing succeeded on the rig only because the account is an admin (`first-hand`: `id -Gn` lists
both `admin` and `_analyticsusers`).

Apple states the gate directly (`Apple doc`, Console User Guide): *"If you're logged in as an administrator
user, you can view all reports. If you're not logged in as an administrator, you can only view user reports."*

**This reframes the whole log category.** The real gate is **admin-group membership**, not `sudo` — and a shop
that hands you a standard account closes `/Library/Logs/DiagnosticReports`, `log show` and `last` all at once.
Anything that depends on being an admin must be treated as **cooperation-dependent**, exactly like a password.

### The one log check that is genuinely worth it

**`/var/log/install.log` is `-rw-r--r--` root:wheel — genuinely world-readable, no admin, no sudo — and it
records its own erase.** `first-hand` on the rig:

```console
$ ls -l /var/log/install.log
-rw-r--r--@ 1 root  wheel  3831025 Aug  4 18:45 /var/log/install.log

$ grep -c -E 'mobile_obliterator|ObliterateDataPartition' /var/log/install.log
98

$ grep -m1 mobile_obliterator /var/log/install.log
Jul 11 07:05:43 localhost mobile_obliterator[93]: MobileObliteration - XPC version started
```

Those lines are **Erase All Content and Settings** leaving a dated receipt. On the rig they date to
**2026-07-11**, corroborated independently by `/var/db/.AppleSetupDone` (2026-07-11 14:25) and by
`last`'s `wtmp begins Sat Jul 11 2026`. Three independent witnesses to the same date.

**Why this matters more than any panic hunt.** Every diagnostic path — `/Library/Logs/DiagnosticReports`,
`/var/db/PanicReporter`, `/var/db/diagnostics` — lives on the **Data volume**, so a wipe destroys panic history
outright. What survives is a **dated receipt of the wipe**. For a buyer that reframes the whole category: you
are not going to find the machine's history, but you can learn **the ceiling on how far any evidence can
possibly reach** — and a very recent wipe on a machine being sold is itself the expected, benign signal, while
a wipe date that contradicts the seller's story is a finding.

### The rest, ranked

| Surface | Finding | Access |
|---|---|---|
| **`/var/log/install.log`** | ⭐ dated erase receipt (above), plus full macOS install/update history | **world-readable** |
| **`/var/db/PanicReporter/`** | `first-hand`: `drwxrwxrwx` — **genuinely world-readable**. Non-empty, or a `current.panic` present, means a recent kernel panic. **Empty on the rig.** Panic filenames confirmed from Apple's own binary: `strings /usr/libexec/DumpPanic` yields `%s%@.panic`, `%s.%@.panic`, `/var/db/PanicReporter/current.panic` — so `.panic` is still the correct extension in 2026. The widely-repeated `Kernel-<date>.ips` naming has **no** support in the binary and traces to an unofficial GitHub file, not Apple. `industry`/`anecdote only` | **world-readable** |
| `/Library/Logs/DiagnosticReports/` | `.diag`, `.ips`, `.panic` files. Rig had **zero** `.panic`. But see the correction above — **admin only**, and an erase clears it, so an empty listing proves almost nothing | **admin** |
| `last \| grep -E '^(reboot\|shutdown)'` | Every `reboot` not paired with a preceding `shutdown` is an unclean stop — a crude panic/kernel-stop proxy that survives where the panic files do not… except `wtmp` is **also** on the Data volume, so it too resets on erase | **admin** |
| **`SPInstallHistoryDataType`** | The sleeper hit. `first-hand`: `Source: Apple` vs **`Source: 3rd Party`** with install dates. On the rig it surfaced **TeamViewer** — remote-access software. On a second-hand machine that is exactly the flag you want before paying. 📝 alone; escalates if the seller resists an erase | **no sudo** |
| **`SPLogsDataType`** | `first-hand`: dumps ~2.9 MB. **Never put this in a script that prints to a terminal.** | — |
| `pmset -g log` | Sleep/wake/assertion history. Long. Not a shop tool | no sudo |

**Net verdict for the guide:** two greps (`install.log` for the erase receipt, `PanicReporter` for a recent
panic) are worth ~5 seconds inside the read-only script. Everything else in this category — `sysdiagnose`,
`log show`, Console.app, `DiagnosticReports` — is **cut**.

---

## The `system_profiler` domain sweep

`system_profiler -listDataTypes` advertises **50** domains on Tahoe 26 (`first-hand`). "EMPTY" below means the
domain is advertised but returned zero bytes on the rig. **No domain tested required sudo. None triggered a TCC
prompt. None required network.**

| Domain | Exists | Keys a buyer cares about | Verdict |
|---|---|---|---|
| **`SPHardwareDataType`** | ✅ | `Model Name`, `Model Identifier`, **`Model Number`** (region SKU), `Chip`, `Total Number of Cores`, `Memory`, `System Firmware Version`, `OS Loader Version`, `Serial Number (system)`, `Hardware UUID`, `Provisioning UDID`, **`Activation Lock Status`** | ⭐ start here |
| **`SPiBridgeDataType`** | ✅ | Secure Boot, SIP, SSV, Kernel CTRR, Boot Args Filtering, Allow All Kernel Extensions, User/DEP Approved Privileged MDM Operations | ⭐ see [above](#spibridgedatatype--the-single-highest-value-command) |
| **`SPPowerDataType`** | ✅ | battery + AC charger — see [Battery](#battery--the-richest-untracked-surface) | ⭐ |
| **`SPNVMeDataType`** | ✅ | model, serial, SMART — see [Storage](#storage--the-wear-counter-you-cannot-have) | ⭐ |
| `SPSoftwareDataType` | ✅ | `System Version`, `Kernel Version`, **`Boot Mode: Normal`**, **`System Integrity Protection`**, `Computer Name`, `Time since boot` | high |
| `SPStorageDataType` | ✅ | per-volume free/capacity, `Medium Type: SSD`, `Protocol: Apple Fabric`, `S.M.A.R.T. Status` | high |
| `SPDisplaysDataType` | ✅ | `Chipset Model`, GPU `Total Number of Cores`, `Metal Support`, `Resolution`, `Display Type`, `Connection Type`, `Automatically Adjust Brightness` | high — **but no panel identity, see [#17](#answering-17-the-untracked-components)** |
| `SPThunderboltDataType` | ✅ | one bus per port, each with `Status`, `Link Status`, `Speed: Up to 40 Gb/s`, `Receptacle` — **bus count = port count** | high |
| `SPMemoryDataType` | ✅ | `Memory: 16 GB`, `Type: LPDDR5`, `Manufacturer: Micron` | medium — soldered, so it only confirms the spec |
| `SPInstallHistoryDataType` | ✅ | `Source: Apple` / **`3rd Party`** + dates | medium ⭐ |
| `SPAirPortDataType` | ✅ | `Card Type`, `Firmware Version`, `Country Code`, `Supported PHY Modes`, `Supported Channels` (incl. 6 GHz), `Signal / Noise`, MAC — **SSIDs redacted** | medium |
| `SPBluetoothDataType` | ✅ | `Chipset`, `Firmware Version`, `Transport: PCIe`, **paired-device list** | medium — paired devices can leak the prior owner |
| `SPCameraDataType` | ✅ | `Model ID`, `Unique ID` | medium — presence, not function |
| `SPAudioDataType` | ✅ | built-in mic + speakers present, `Manufacturer`, `Transport: Built-in` | medium — presence, not function |
| `SPSecureElementDataType` | ✅ | `SEID`, **`Production Signed: Yes`**, `Restricted Mode: No`, `JCOP OS` | medium — Apple Pay hardware intact |
| **`SPDiagnosticsDataType`** | ⚠️ advertised, **EMPTY** | none | ❌ **dead on Apple silicon** |
| `SPConfigurationProfileDataType` | ⚠️ EMPTY unprivileged | — | ❌ use `profiles` instead |
| `SPSerialATADataType` / `SPEthernetDataType` / `SPPCIDataType` / `SPHardwareRAIDDataType` | ⚠️ EMPTY | — | ❌ not applicable to an Apple-silicon laptop |
| `SPUSBDataType` | ⚠️ EMPTY *(nothing attached)* | — | ⚠️ **not a clean negative** — plug something in first |
| `SPLogsDataType` | ✅ (~2.9 MB) | — | ❌ avoid |

Syntax notes, all `first-hand`: multiple domains in one call work
(`system_profiler SPHardwareDataType SPPowerDataType SPNVMeDataType`); `-json` and `-xml` work; **`-detailLevel
full` produced output identical to `mini`/`basic`** for `SPPowerDataType` — it is a no-op there.

### The SSID redaction

`first-hand`: **every** SSID in `SPAirPortDataType` renders as `<redacted>` (9 occurrences on the rig) for an
unprivileged caller without Location authorization — **with no TCC prompt**, which is why it catches people out.
The redaction is system-wide across CLI surfaces, and one of them actively lies:

| Surface | Result |
|---|---|
| `system_profiler SPAirPortDataType` | `<redacted>` |
| `ipconfig getsummary en0` | SSID **and** BSSID `<redacted>` |
| `networksetup -getairportnetwork en0` | *"You are not associated with an AirPort network."* — **false; it was connected** |
| legacy `airport` binary | **removed from the OS entirely** |

The redaction itself is `first-hand`. The *mechanism* — a deliberate privacy change requiring Location Services
authorization, introduced around macOS 14.5/15 — is `industry` / `anecdote only` (Apple Developer Forums thread
732431, 2024-03-18; pyobjc issue #600, 2024-04-04; fastfetch issue #1874, 2025-07-31). **Apple documents this
nowhere** — `CWInterface.ssid()` still says only that it returns nil "in the case of an error, or if the
interface is not participating in a network". `Apple doc (negative)`.

**Buyer impact: nil.** The SSID is irrelevant when buying a laptop, and every Wi-Fi fact that matters — PHY
modes, 6 GHz channel support, signal/noise, country code, firmware version — is still visible. This is recorded
so a script author is not misled.

### ⚠️ Never use `-detailLevel mini` — it deletes `Activation Lock Status`

`man system_profiler` describes the level as *"report with no personal information"*, which makes it sound
like the obvious choice for a report [#11](https://github.com/mingrath/mbcheck/issues/11) has the buyer
AirDropping off the machine. **It is the wrong choice, in both directions.**

`first-hand`, `diff` of `mini` against `full` on `SPHardwareDataType` — these four lines are exactly what
`mini` removes:

```
>       Serial Number (system): G5G•••••••
>       Hardware UUID: UUID-REDACTED-••••-••••-••••-••••••••••••
>       Provisioning UDID: 00008132-••••••••••••••••
>       Activation Lock Status: Enabled
```

**`mini` deletes the single most important field in the entire procedure**, plus the serial the whole
provenance check rests on. A script that reached for it to be polite would silently lose the cheapest 🛑
available.

And it is **not** a privacy scrub either: run against `SPPowerDataType` it **leaves the battery pack serial
in place**. So it removes what the buyer needs and keeps a unique identifier they do not.

**Rule for `check.sh`: always run at the default detail level and filter the output explicitly by field.**
Never delegate redaction to `-detailLevel`.

> One option in the same man page *is* worth setting: **`-timeout` defaults to 180 seconds.** If any domain
> hangs on a sick machine, the script otherwise sits for three minutes in front of a seller. `man
> system_profiler` documents the options and **not one single data type** — there is no man-page authority
> for what any `SP*DataType` contains, which is why this note quotes so much output verbatim.

---

## Answering #17: the untracked components

[#13](https://github.com/mingrath/mbcheck/issues/13) established that Parts & Service tracks **four** things —
logic board, Touch ID board, lid-angle sensor (M5 Air/Pro only), display (**MacBook Neo only**) — and needs
macOS Tahoe 26, and is hidden entirely when SIP is off. Cited, not re-derived; see
`research/thai-repair-prices.md` on branch `research/thai-repair-prices`.

**One new fact about the pane itself, which matters for script design: there is no command-line read.**
`first-hand`: the machinery is present — `/usr/libexec/corerepaird`, `/usr/libexec/mobilerepaird`, and
`CoreRepairCore.framework` / `CoreRepairKit.framework` / `CoreRepairUI.framework` — but **no user-facing CLI or
`system_profiler` domain exposes parts and service history.** `SPConfigurationProfileDataType`,
`SPDiagnosticsDataType` and `SPHardwareDataType` all carry nothing about it. So Parts & Service **cannot** be
folded into the read-only script: it must be one of the 8 by-hand steps, at roughly 30 seconds of clicking.
`UNPINNED` — whether `corerepaird` exposes a queryable XPC interface. To pin: reverse the framework, which is
out of scope here.

The question [#17](https://github.com/mingrath/mbcheck/issues/17) is waiting on: **for everything Parts &
Service does not track, is there any other on-device surface that reveals a replacement or a non-genuine part?**

**The short answer is better than expected, and it is not "nothing".** Three surfaces exist beyond the Parts &
Service pane:

1. **Repair Assistant covers more parts than the Parts & Service *history table* does.** `Apple doc`, "Use
   Repair Assistant to finish a Mac repair", <https://support.apple.com/en-us/123128>, **published 2026-05-11**
   — under its `MacBook Pro parts` and `MacBook Air parts` headings, **Display is a calibrated part for
   MacBook Air and MacBook Pro, model years 2020–2026**, even though Display appears in the *history* table
   (123123) for **MacBook Neo only**. Since 123128 also says *"If a part is not calibrated, your Mac shows a
   notification that you need to finish your repair of that part"*, and 123123 says the device *"will show
   Finish Repair next to the part until you finish the repair with Repair Assistant"* — **an uncalibrated
   display swap on an Air or Pro *does* surface on-device.** This settles the conflict left open in
   [#13](https://github.com/mingrath/mbcheck/issues/13): **YES, but only inside a narrow window.** A *finished*
   calibration leaves nothing.
2. **The device tree carries per-component serial numbers that no Apple UI shows.** Verified present on the
   rig: a cover-glass/panel serial, a camera-module serial, an ambient-light-sensor serial, a top-case serial,
   and a **logic-board serial separate from the system serial**.
3. **Apple has published why most of these answers are negative** — `Apple doc`,
   <https://support.apple.com/en-us/123920> (Air) and <https://support.apple.com/en-us/123921> (Pro), both
   **published 2026-03-11**:

   > *"Apple won't actively disable a third-party part unless it impacts customer security and privacy, such as
   > parts used in biometric authentication (Touch ID). The other features of these parts, such as buttons,
   > will continue to operate per the capability of the part installed."*

   That is Apple stating its own doctrine. The negatives below are not gaps in the research — they are policy.

**Verdict table. `NO` here is a finding, not a failure.**

| Component | On-device tell? | Best surface | What it actually proves |
|---|---|---|---|
| **Battery** | **PARTIAL (weak)** | `SPPowerDataType` pack serial + cell-maker code; `ioreg` `LifetimeData` | Cycle/lifetime counters **inconsistent with the machine's age**; catches a seller lying about cycles. **Not** a genuineness test |
| **Display / screen (Air & Pro)** | **PARTIAL — strongest of the set** | `Finish Repair` notification; `coverglass-serial-number` / `raw-panel-serial-number` | An **uncalibrated** swap, while it is still uncalibrated. A finished genuine swap leaves nothing |
| **Top case / keyboard** | **PARTIAL** | `SPSPIDataType` `Serial Number`; `ioreg` `KeyboardLanguage` vs device-tree `region-info` | A **cross-region** keyboard/top-case swap. Not that the top case was replaced |
| **Camera** | **PARTIAL (unusable)** | `ioreg AppleH16CamIn` `FrontCameraModuleSerialNumString` | A real per-unit serial with **nothing to check it against**. Camera rides in the display anyway |
| **Speaker** | **NO** | `SPAudioDataType` = presence only | — |
| **Microphone** | **NO** | `SPAudioDataType` = presence only | — |
| **Fan (Pro only)** | **NO** | — | Not even RPM is readable by built-in means |
| **Trackpad** | **NO** | — | No serial, no calibration state, no per-unit identifier |
| **Thunderbolt / IO board** | **PARTIAL (function only)** | `SPThunderboltDataType` bus count + link status | A **dead or missing** port, never a replaced one |
| **Sub-assembly serials** | **PARTIAL** | `mlb-serial-number`, `region-info`, per-component serials | A misrepresented market/SKU. ⚠️ **The engraved-vs-software serial test is retracted — see below** |
| **Spec / model / generation** | **YES** | `SPHardwareDataType` + device tree + `SPMemoryDataType` + `SPNVMeDataType` | The one unambiguous win — exactly what you are buying |
| **Logic board** *(tracked — for contrast)* | **YES** | Parts & Service → usually `Unverified` | Already pinned in [#13](https://github.com/mingrath/mbcheck/issues/13) |

### Battery — PARTIAL, and it is the strongest of the untracked set

`SPPowerDataType` prints a **battery pack serial number** and `Device Name` (the gas-gauge IC — `bq40z651` on
the rig). `ioreg -rc AppleSmartBattery` adds a lifetime record. Together these give **three consistency tests**,
none of them proof, all of them actionable enough for a 💰 or a 📝:

1. **Cycle count vs machine age.** A 2021 machine reporting 40 cycles has almost certainly had a new battery
   fitted. The reverse — 900 cycles on a one-year-old machine — is a different finding but equally readable.
   This is the single most useful signal, and it needs no exotic keys: `Cycle Count` alone does it.
2. **`LifetimeData.TotalOperatingTime` vs machine age.** Same logic, independent counter. Unit is `UNPINNED`
   (10320 on the rig), but it is comparable against the machine's own age and against other counters.
3. **`ChemID` vs `AlgoChemID`.** Equal on the rig (22165 / 22165). A mismatch is the classic signature of a
   pack the gauge does not recognise. **`anecdote only`** — this is TI gas-gauge folklore, not an Apple
   statement, and no first-hand mismatch was observed. Do not print it as a rule; note it as a lead.

**What none of it proves.** Apple publishes **no** reference for a genuine battery serial, and there is no
Apple-documented "non-genuine battery" warning on macOS the way there is on iPhone. `Apple doc (negative)`:
battery is absent from the Parts & Service reporting table for every Mac, and no Apple page describes a Mac
battery-authentication notification. **A genuine-looking, correctly-paired third-party pack reads exactly like
an Apple one.**

Two keys that looked promising and did not deliver, recorded so nobody re-chases them:

- **`DateOfFirstUse` = 0** on the rig (`first-hand`). The key exists in `BatteryData` but is unpopulated on an
  M4 Air. `UNPINNED` — whether it populates on any Apple-silicon MacBook. To pin: read it on several machines of
  different ages. If it ever populates, it would be a *direct* battery-install date and would upgrade this row
  from PARTIAL to YES.
- **`ManufactureDate` = 54087415509811** (`first-hand`) — a large packed integer with no documented encoding.
  `UNPINNED`. To pin: read it across several machines with known build dates and solve the encoding.

Also usable, and cheap: **`LifetimeData.MaximumTemperature`** (43 °C on the rig). A lifetime peak well above
normal is evidence of sustained thermal abuse — 📝 on its own, and useful corroboration next to the stress test.

### Display / screen on Air & Pro — PARTIAL, and the strongest of the untracked set

Three independent handles, of decreasing quality.

**(a) The `Finish Repair` window — Apple-documented, and it does fire on Air and Pro.** See the headline above:
123128 (2026-05-11) lists **Display** as a Repair-Assistant-calibrated part under both `MacBook Air parts` and
`MacBook Pro parts`, model years 2020–2026. An uncalibrated display swap therefore produces a **`Finish Repair`
state and an unlock notification** on an Air or Pro — even though a *completed* one never reaches the Parts &
Service history table (Display column = MacBook Neo only, 123123, 2026-05-26). `Apple doc`.

This is a real check with a real limitation: **it only catches a repair the shop did not finish.** A competent
independent using a genuine panel and running Repair Assistant leaves nothing — exactly the pattern
[#13](https://github.com/mingrath/mbcheck/issues/13) established for the tracked parts.

> **`Finish Repair` that never clears is the strongest single red flag in the pane — and it is a lock, not a
> cosmetic label.** `Apple doc` — <https://support.apple.com/en-us/120610>, **published 2026-04-29**: *"When a
> previously used part… is protected by Activation Lock, it's linked to someone else's Apple Account… In Parts
> & Service on the device, the part will continue to show a **Finish Repair** label."* Apple adds that
> **"Apple can't help remove Activation Lock for previously used parts."** So a persistent `Finish Repair`
> can mean the component is Activation-Locked to a stranger, is ineligible for warranty service, and blocks
> trade-in. This sits on the **software-locks** axis, not the condition axis, and it is a 🛑 — it is a lock
> nobody can lift, exactly like MDM. Note the asymmetry in Apple's own docs: the Platform Security guide's
> parts-Activation-Lock section is scoped to iPhone, while 120610 covers Mac.

**(a2) The one documented way to suppress the pane — and it leaves a visible tell.** `Apple doc` (123123,
2026-05-26): if System Integrity Protection is disabled, the feature is disabled with it, and the Mac shows
*"**Parts & Service has been disabled because the security settings of this Mac were modified**"*. Apple's
remedy is to install updates, restart, and *"If you've disabled System Integrity Protection, enable it."*

This matters more than it first looks. A seller wanting to hide a tracked-part swap **can** turn the pane
off — but doing so replaces it with an explicit accusation rather than a silent blank. **Absence and
suppression look different**, which is the question [#3](https://github.com/mingrath/mbcheck/issues/3) asked.
Two consequences for the guide:

- **That message is a 🛑 on sight.** It is not a benign empty section.
- **Verify SIP independently** with `csrutil status` (free, no sudo — see the security-state section above)
  rather than trusting the pane to report on its own disablement.

**(a3) Absence is near-worthless as evidence, and the reason is broader than #13 recorded.** Apple's wording
is *"This option appears only when your Mac detects that it has been repaired"* (123123) — but the Repair
Assistant page narrows it to *"…that a **qualifying part** has been repaired"* (123128, 2026-05-11). Stack the
benign causes: never repaired · **the replaced part is not one of the four tracked** · macOS older than Tahoe
26 · **Intel or T2 Mac** (Apple's stated gate is *"a Mac with Apple silicon using macOS Tahoe 26 or later"*,
so the Apple-silicon requirement is as binding as the OS one) · the model's row does not cover that part.
A missing section is the **default** state of a healthy *and* a badly-repaired Mac alike.

> **Nomenclature correction to [#13](https://github.com/mingrath/mbcheck/issues/13):** the state string is
> **`Used`**, not `Genuine Used` — Apple's four messages on 123123 are `Genuine`, `Unknown`, `Unverified`,
> `Used`, with `Finish Repair` shown as a label until Repair Assistant completes. There is also a **sixth**
> label #13 did not record: **`Issue`**. Both sub-pages use it as a state — *"If the parts and service history
> shows that the Lid Angle Sensor has an **Issue**, your Mac won't detect that the lid is closed…"*
> (<https://support.apple.com/en-us/123126>, 2025-09-15) and the same construction for Touch ID
> (<https://support.apple.com/en-us/123127>, 2025-09-15). `UNPINNED`: whether `Issue` is a formal pane label
> or descriptive prose — 123123 describes the mechanism (*"a one-time notification… remains in Parts and
> Service History until you dismiss it"*) without naming the label.

**(a4) Offline, the labels still show — but the date does not.** `Apple doc` (123123): *"After service is
completed and **your Mac connects to the internet**, you can click the part for more information, **including
the date of the service**."* The labels come from local detection; only the detail view is gated on
connectivity. **A seller keeping the Mac off Wi-Fi does not blank the pane — but they do withhold the service
date**, which is the field a buyer most wants. If the shop's Wi-Fi is "not working", ask again.

**(b) Per-panel serials that exist but cannot be validated.** `first-hand`, no sudo:

```console
$ ioreg -lw0 -p IODeviceTree | grep -E 'coverglass|ambient-light'
"coverglass-serial-number" = <"F0YHGZ••••••••••••">
"ambient-light-sensor-serial-num" = <"070102••••••••••">
```

`raw-panel-serial-number` is also present (one match in the registry), and `IOMobileFramebufferAP` carries the
same long string as `Panel_ID`. `coverglass-serial-number` is exactly the first 18 characters of
`raw-panel-serial-number`, and `tcon-path` points at a Parade timing controller on SPI — consistent with the
value being read from the display assembly's TCON at boot.

**That last sentence is inference, not documentation, and the distinction is the whole ballgame.** Whether
these strings are read *live from the panel* — so a swap changes them — or cached in a **logic-board**
provisioning blob — so a swap leaves them silently wrong — is **`UNPINNED`**, and it is the difference between
a real tell and a useless one. **Do not build a check on it until it is pinned.** To pin: capture the device
tree on one machine before and after a genuine display swap.

There is also a hidden serial in the JSON renderer that the text renderer omits (`first-hand`):

```console
$ system_profiler -json SPDisplaysDataType   # keys absent from the plain-text output
  _spdisplays_display-vendor-id     = 610
  _spdisplays_display-product-id    = a065
  _spdisplays_display-serial-number = fd••••••
  _spdisplays_display-week          = 0
  _spdisplays_display-year          = 0
```

**Manufacture week and year are both zero** — there is no panel date available. Whether
`_spdisplays_display-serial-number` varies per unit or is derived is `UNPINNED`.

The classic Intel-era EDID route is **gone**: `first-hand`, there is **no `IODisplayEDID`, no
`DisplayProductID`, no `DisplayVendorID`, no `DisplaySerialNumber`, no `IODisplayPrefsKey`, no `AppleDisplay`**
node for the internal panel anywhere in the registry. Do not publish those key names for Apple silicon.

**(c) True Tone — decaying, and never Apple-documented for Mac. Do not use it.** `Apple doc (negative)`:
Apple's own True Tone page, <https://support.apple.com/en-us/102147>, **published 2026-03-10**, never mentions
repair, replacement or calibration even once; the only stated reasons for its absence are *"This setting appears
only for displays that support True Tone"* and certain accessibility settings. 123128 says only that an
uncalibrated part *"might not perform as expected"*. And because Repair Assistant now calibrates displays on
Air/Pro 2020–2026, **a present True Tone toggle no longer proves an original panel and an absent one no longer
proves a swap** — the signal fails in both directions, and Apple's own tooling is what broke it.
`first-hand` besides: True Tone state is not exposed to `ioreg` or `system_profiler` at all, so it is a
GUI-only observation that cannot go in a script.

**One structural fact worth carrying into the guide.** `Apple doc`, "Mac Laptops Troubleshooting Display
Issues", <https://support.apple.com/en-us/117310>, **published 2026-03-11** (scoped to *"2024 and later Mac
laptops with Apple silicon"*): the ambient light sensor *"is located at the top of the computer display near
the camera"*, and for **both** camera faults and ALS faults the prescribed remedies are *"Replace the display.
Replace the logic board."* There is no separate camera or ALS part. **A display swap takes the camera and the
ambient light sensor with it** — which is why the camera section below collapses into this one.

### Top case / keyboard — PARTIAL, and this is the new finding

`first-hand`, no sudo:

```console
$ ioreg -rc AppleHIDKeyboardEventDriverV2 -d1 | grep KeyboardLanguage
      "KeyboardLanguage" = "Thai"

$ system_profiler SPHardwareDataType | grep "Model Number"
      Model Number: MC7A4TH/A
```

The keyboard's **physical language comes from the top case**; the **region suffix of `Model Number`** records
the market the machine was sold into. On the rig both say Thailand and they agree.

**This is a hardware property, not a software setting — and the rig proves it.** At the moment
`KeyboardLanguage` read `"Thai"`, the *software* layout in use was
`com.apple.keylayout.ABC` (a US layout) — `first-hand`,
`defaults read /Library/Preferences/com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID`. The two
disagree, which means `KeyboardLanguage` is **not** echoing the user's chosen input source. It is reported by
the HID driver for the physically attached keyboard. A seller cannot change it from System Settings.

**A mismatch is on-device evidence that the top case is not the one the machine shipped with.** That is a real,
free, instant tell for a component Parts & Service does not track at all. It is also directly relevant to a
Thai second-hand buyer, where grey imports (`LL/A` US, `ZP/A` HK, `ZA/A` SG) circulate alongside `TH/A` stock.

**Its limits, stated honestly:**

- It only catches a **cross-region** swap. A Thai top case fitted to a Thai machine is invisible.
- A mismatch has an innocent explanation — a grey-import machine whose owner had a Thai keyboard fitted
  deliberately. Under [#9](https://github.com/mingrath/mbcheck/issues/9)'s "often-innocent check" rule this
  caps at **💰**, and reaches 🛑 only if a reliable check agrees.
- **Do not confuse it with the user's locale.** `system_profiler SPInternationalDataType` also reports a
  country code, but that is a **freely settable preference**. `KeyboardLanguage` and `region-info` are hardware
  facts. Both read `TH` on the rig; only the latter two mean anything.
- `alt_handler_id` (91 on the rig) and `CountryCode` (**0** on the rig) also relate to keyboard type, but
  `CountryCode = 0` did **not** encode ANSI/ISO/JIS here and neither value table is documented. **`UNPINNED`** —
  do not claim physical ANSI/ISO/JIS layout is detectable until someone reads these on a known JIS and a known
  ISO machine.

**Apple confirms keyboards are region-coded at the part-number level.** `Apple doc`,
<https://support.apple.com/en-us/121934>, **published 2026-06-22** — top-case part numbers carry a regional
prefix, including **`TH` (Thai)** and **`TG` (Thailand, English)**, alongside `J` (Japanese), `B` (British) and
the rest. So the region genuinely travels with the physical part.

**There is also a real top-case serial, which no prior research in this repo mentions.** `first-hand`, no sudo:

```console
$ system_profiler SPSPIDataType
SPI:
    Apple Internal Keyboard / Trackpad:
      Product ID: 0x035c        Vendor ID: 0
      ST Version: 5.20          MT Version: 7.95
      Serial Number: FM7HG9•••••••••••••••••
      Manufacturer: Apple       Location ID: 0x000000e3
```

JSON key `d_serial_num`. The same value appears in `ioreg` under `AppleDeviceManagementHIDEventService` as
`SerialNumber`. **This is the most accessible per-component serial on the machine.** It cannot be validated
against anything at purchase time — but it is worth recording, because it makes "the top case I was shown is
the top case I received" verifiable at collection, which is exactly the re-check rule
[#14](https://github.com/mingrath/mbcheck/issues/14) already fixed.

### ⚠️ The Touch ID cross-link is a dead end — correction to [#13](https://github.com/mingrath/mbcheck/issues/13)'s open question

[#13](https://github.com/mingrath/mbcheck/issues/13) left open whether a top-case swap indirectly flags via the
tracked Touch ID board. **It does not.** `Apple doc`, three sources:

- **Orderable parts**, <https://support.apple.com/en-us/121934> (**2026-06-22**): `Touch ID board`, `Top case
  with keyboard`, `Battery` and `Trackpad` are **four distinct part numbers**. The top case is annotated
  *"Includes interposer board"*.
- **Top Case procedure**, <https://support.apple.com/en-us/121950> (**2026-04-17**): a replacement top case
  *"includes the following preinstalled parts: Interposer board; Keyboard and keyboard flex cable; Keyboard
  backlight flex cable; **Microphone** and microphone flex cable"* — and the Touch ID board is listed under
  *remove before you begin* and *reinstall to complete reassembly*. **It comes out of the old top case and goes
  back into the new one.**
- **Touch ID Board procedure**, <https://support.apple.com/en-us/121952> (**2025-09-15**): *"**If you replace
  this part**, it's recommended to run Repair Assistant in order to finish the repair."* The trigger is
  *replacement*, not removal and reinstallation.

So the original board returns to the original logic board, the pairing is unchanged, and Parts & Service should
stay silent. `UNPINNED` — whether the disconnect/reconnect cycle alone ever trips a Repair Assistant prompt in
practice; Apple's wording says it should not.

**A model split the guide must not flatten** (`Apple doc`, 121934 and
<https://support.apple.com/en-us/120922>, **2025-12-10**), consistent with what
[#13](https://github.com/mingrath/mbcheck/issues/13) found on the parts side:

| | MacBook **Air** (M-series) | MacBook **Pro** (M-series) |
|---|---|---|
| Battery orderable separately? | **Yes** | **No** — sold as "Top Case with **Battery** and Keyboard" |
| So a top-case swap implies… | keyboard + microphone + interposer | keyboard + microphone + interposer **+ the whole battery** |
| Top case a Repair-Assistant part? | never | **only the 2020 & 2022 Touch Bar models** |

On the Pro, then, a top-case swap and a battery swap are the same event — which means the battery-age
inconsistency test below is doing double duty as a top-case test on that line.

### Camera — a real serial, and a booby trap next to it

`first-hand`, `ioreg -rc AppleH16CamIn`:

| Key | Value on a **factory-original, never-opened** machine |
|---|---|
| `FrontCameraModuleSerialNumString` | `DNMHGC••••••••••••` — **a genuine per-unit camera-module serial** |
| `FrontCameraExpected` | `Yes` |
| **`FCClValidationStatus`** | **`Invalid`** |
| **`CmPMValidationStatus`** | **`Invalid`** |

> ⚠️ **Publish this warning, not the check.** Those `…ValidationStatus` keys read **`Invalid`** on a machine
> that has never been opened. `first-hand`. They are **not** tamper flags. Anyone who writes *"if
> `FCClValidationStatus` is Invalid the camera was replaced"* will be wrong on every stock machine. This is the
> most inviting false positive found anywhere in this research.

`system_profiler SPCameraDataType`'s `spcamera_unique-id` is **not** a serial either — `first-hand`, on the rig
it reads `6C707041-05AC-••••-••••-••••••••••••`, whose leading `6C707041` is little-endian ASCII `"Appl"` and
whose `05AC` is Apple's vendor ID. It is constructed, not per-unit. Do not use it.

And per the display section, **the camera is inside the display assembly** (`Apple doc` 117310, 2026-03-11), so
there is no such thing as an isolated camera swap — a camera replacement *is* a display replacement. Use the
display route.

**Verdict: PARTIAL but unusable.** A real serial exists with nothing to check it against.

### Speaker, microphone, trackpad — NO

`first-hand`, and these are honest, confirmed negatives.

- **Microphone.** `SPAudioDataType` shows `MacBook Air Microphone`, `Input Channels: 1`,
  `Manufacturer: Apple Inc.`, `Transport: Built-in` — nothing per-unit. The device tree records
  `builtin-mics = 3`, a count, not an ID. Per the top-case section, the mic ships **preinstalled in a
  replacement top case** (`Apple doc` 121950, 2026-04-17), so a mic swap *is* a top-case swap. Note this
  corrects the intuition behind the README's Photo Booth step: camera and mic are not merely different prices
  ([#13](https://github.com/mingrath/mbcheck/issues/13)), they are **different assemblies with different
  detectability** — the camera has a display-side handle, the mic has none.
- **Speaker.** `SPAudioDataType` shows `MacBook Air Speakers`, `Manufacturer: Apple Inc.`, output channels —
  nothing per-unit. Apple sells them as one part, *"Left and right speakers with antennas"* (`Apple doc` 121934,
  2026-06-22), and lists Speakers as used-part-supported with no tracking (`Apple doc` 123920/123921,
  2026-03-11).
- **Trackpad.** A full property dump of `AppleMultitouchDevice`, `AppleActuatorDevice` and
  `AppleMultitouchTrackpadHIDEventDriver` yields **no serial**. The one unique-looking value, `Multitouch ID`
  (`0x0700000000000063` on the rig), is **identical** to `Multitouch Actuator ID` and `mt-device-id` — it is
  bus/address-derived, not per-unit. `ActuatorRevision` is a hardware revision. `Sensor Surface Descriptor`'s
  first 8 bytes are just the surface width and height; its trailing 8 bytes are unidentified (`UNPINNED` — do
  not call it a serial). The trackpad reports through the same SPI node as the keyboard, and that node's
  serial is the **top case's**, not the trackpad's — Apple sells the trackpad as its own part number
  (`Apple doc` 121934, 2026-06-22) with no identifier of its own. No haptic calibration state is exposed.

`Apple doc (negative)`: [#13](https://github.com/mingrath/mbcheck/issues/13) already established that speaker,
trackpad, USB-C boards and fan are **used-part-supported** by Apple — Apple explicitly expects harvested parts
in these positions and does not flag them. There is nothing to detect and Apple has said so, which is why
123920/123921's *"Apple won't actively disable a third-party part unless it impacts customer security and
privacy"* is the honest answer here.

**Nothing on-device can prove a replaced speaker, microphone or trackpad.** These stay physical checks: Photo
Booth for camera and mic, a bass-heavy track for the speakers, four-corner pressure for the trackpad (which the
README already uses as the swollen-battery test — it doubles as the trackpad function test).

### Fan — NO, and you cannot even read RPM

Every MacBook Air M1–M5 is fanless ([#13](https://github.com/mingrath/mbcheck/issues/13)). On a MacBook Pro,
`first-hand` evidence bounds the answer: `powermetrics` has **no `smc` sampler** on Apple silicon, and it needs
sudo anyway. No fan identity, no fan serial, no fan-genuineness surface exists.

`UNPINNED` — whether **fan RPM** is readable by *any* built-in means on an Apple-silicon MacBook Pro. The rig is
a fanless Air, so its empty fan-key search proves nothing. To pin: `ioreg -l | grep -i fan` and
`sudo powermetrics -n1 --samplers thermal` on a MacBook Pro.

The README's listening test therefore remains the only fan check, and Apple Diagnostics' **PPF001/003/004** the
only authoritative verdict — at the cost of a 🔄 reboot.

### Thunderbolt / IO board — PARTIAL, and only for absence

`first-hand`: `SPThunderboltDataType` emits **one bus per physical port**, each with `Status`, `Link Status`,
`Speed: Up to 40 Gb/s`, `Receptacle`, `UID` and `Domain UUID`. Two buses on a 13" Air; a 14"/16" Pro should show
three.

**A missing bus is a strong tell that a port is dead or its sub-board is absent** — and per
[#13](https://github.com/mingrath/mbcheck/issues/13), those sub-boards are separate US$12–14 parts, so this is a
cheap fix, not a logic-board job. But a *replaced* port board reads identically to an original one. There is no
per-board serial.

Counting buses is a **useful free pre-check before** the README's plug-the-charger-into-every-port test, not a
replacement for it — the charger test proves the port actually delivers power, which the bus count does not.

### Serial numbers — eight identifiers, and one retraction

An Apple-silicon MacBook stores **at least eight distinct identifiers readable in software**, all without sudo
(`first-hand`, values truncated):

| Identifier | Route | Scope |
|---|---|---|
| System serial | `SPHardwareDataType` `serial_number`; device-tree `serial-number` | the machine |
| **`mlb-serial-number`** | `ioreg -lw0 -p IODeviceTree` | **main logic board — a genuinely separate identifier** |
| `Provisioning UDID` | `SPHardwareDataType` | **SoC die** — prefix `00008132` = T8132, matching the kernel's own `RELEASE_ARM64_T8132`; suffix is the ECID |
| `Hardware UUID` | `SPHardwareDataType` | derived, per-machine |
| `regulatory-model-number` | device tree | the A-number (`A3241` on the rig) |
| `model-number` / `Model Number` | device tree / `SPHardwareDataType` | the SKU (`MC7A4TH/A`) |
| **`region-info`** | device tree | **intended sales region** (`TH/A`) |
| Top case / cover glass / camera / ALS / battery / SSD serials | see the sections above | per component |

`mlb-serial-number` is corroborated as a real, distinct concept: it appears in Jonathan Levin's IODeviceTree
dump alongside `region-info` (`industry`, *Mac OS X and iOS Internals*, no page date; observed 2026-08-04), and
OpenCore's SMBIOS configuration exposes `PlatformInfo → Generic → MLB` explicitly distinguished from
`SystemSerialNumber` (`industry`, <https://dortania.github.io/docs/latest/Configuration.html>, no page date;
observed 2026-08-04). Apple's own service guidance says the **board** serial is what gets reported for a board
swap — *"enter the Known Bad Board (KBB) and Known Good Board (KGB) **logic board serial numbers** into the
repair system"* (`Apple doc`, Apple-authored service guide, mirror-hosted at
<https://documents.cdn.ifixit.com/6IeXYJSxmbRSNeeI.pdf>, no page date; observed 2026-08-04) — which lines up
exactly with 123123's `Unverified` label for a previously-replaced logic board.

### ⚠️ Retraction: do NOT publish the engraved-vs-software serial test

The Thai market knows this scam and [#13](https://github.com/mingrath/mbcheck/issues/13) documents a Pantip
case of exactly it — a shop returning a machine with the bottom case swapped so the serial no longer matched
the box. The obvious check is *compare the engraved serial to the software serial to detect a board swap*.
**On Apple silicon that check is unverified in both directions and should not be printed as a board-swap test.**

| Question | Answer | Label |
|---|---|---|
| Does Apple document where the Apple-silicon system serial is stored? | **No.** Platform Security, the SSR manuals and the Apple-silicon reference guide are all silent | `none` |
| Does Apple say the software serial changes after a board swap? | **No** | `none` |
| Does Apple say it is preserved? | **No** | `none` |
| Does System Configuration write the original serial to a new board? | **Not stated for Apple silicon.** Apple's text describes *registration* — KBB/KGB reporting, enabling iCloud/FaceTime/Messages/Apple Pay, assigning the wireless region — not serial-writing | `Apple doc` (service guide, observed 2026-08-04) |
| Field report | An M2 Air owner reports the serial **did not change** after a shop board replacement — the opposite of the premise, with the obvious confound that the shop may not have replaced it | `anecdote only`, <https://www.reddit.com/r/macbookair/comments/13qcjya/>, **2023-05-24** |
| The "logic board contains the serial" claim | Traces to an Apple Discussions thread from **2006** — Intel-era, fourteen years before Apple silicon. **Do not carry it forward** | `anecdote only` |

**What to publish instead:** Parts & Service showing **`Unverified` next to Logic Board**. That is Apple's own
first-party statement that the board was replaced, and unlike Display it applies to **every** Mac family in the
table (`Apple doc` 123123, **2026-05-26**). It costs a Tahoe 26 machine and 30 seconds of clicking, and
[#13](https://github.com/mingrath/mbcheck/issues/13) already priced its reach problem.

An engraved-vs-software mismatch is still *a* finding — it means something is inconsistent — but it must not be
sold to a reader as "this proves the logic board was swapped", because it may equally produce a **false
negative** (board swapped, serials still match).

### A novel observation — component date-code coherence, n = 1

`first-hand`, from the single never-repaired rig. Apple's 18-character part serials carry a code at characters
4–5:

| Component | Serial | chars 4–5 |
|---|---|---|
| Display cover glass | `F0YHGZ••••••••••••` | **`HG`** |
| Camera module | `DNMHGC••••••••••••` | **`HG`** |
| Top case | `FM7HG9•••••••••••••••••` | **`HG`** |
| Logic board (`mlb-serial-number`) | `C02HHE••••••••••••` | `HH` *(adjacent)* |

Four major sub-assemblies from the same manufacturing window. The system serial is the post-2021 randomised
10-character format and encodes **no** date, so it cannot participate.

> ⚠️ **This is n = 1 and Apple has never published the encoding.** It is a *heuristic worth testing*, not a
> proof — and even if it holds, a repair using a same-vintage harvested part defeats it. **`UNPINNED`.** To
> pin: capture the same four values across several known-original units of one model, plus one known-repaired
> unit.

### Spec, model and generation — the one unambiguous YES

`first-hand`, `system_profiler -json SPHardwareDataType` plus the device tree. Every one of these cross-checks
works, needs no sudo, and takes under a second:

| Check | Source | Catches |
|---|---|---|
| Marketing name | device-tree `product-name` (e.g. `MacBook Air (15-inch, M4, 2025)`) | a 13" sold as a 15" |
| A-number | device-tree `regulatory-model-number` (`A3241`) | the wrong model entirely |
| **Sales region** | device-tree `region-info` (`TH/A`) | grey-import / warranty-region misrepresentation |
| SoC identity | `provisioning_UDID` prefix (`00008132` = T8132) vs `uname -a` (`RELEASE_ARM64_T8132`) vs `Chip` ("Apple M4") — **all three must agree** | a lower-generation board swapped in |
| RAM | `physical_memory` + `SPMemoryDataType` (`LPDDR5`, `Micron`) | RAM misrepresentation |
| SSD | `SPNVMeDataType` model + capacity, and `diskutil apfs list` | capacity misrepresentation |
| Core counts | `number_processors` (`proc 10:4:6:0`) + GPU `sppci_cores` | a binned chip sold as a full one |
| Activation Lock | `activation_lock_status` | a stolen or locked machine |
| Security posture | `SPiBridgeDataType` + `csrutil status` | a downgraded boot policy — and **SIP off hides Parts & Service entirely** |

**The logic-board-swap angle is real and Apple documents it.** Apple sells logic boards *per configuration* —
for the M4 Air alone, thirteen distinct SKUs spanning 8/10-core GPU, 16–32 GB and 256 GB–2 TB (`Apple doc`,
121934, **2026-06-22**). So a board swap **changes the reported spec**, and `SPHardwareDataType` reports the
**board's** configuration, not the enclosure's label.

That has a clean consequence for the guide: **the mismatch to hunt is software-spec versus the box, the
listing and the engraved model — not software versus software.** And since on Apple silicon RAM is in-package
and the SSD is soldered, a spec mismatch can never be an owner's upgrade. It means the listing is wrong, or the
board is not the original.

---

## What this means for the guide's shape

[#9](https://github.com/mingrath/mbcheck/issues/9) put **no cap on what a read-only script reads** and a hard
cap of **8 steps / ~10 minutes by hand**. This research says the split falls in an unusually convenient place.

### Tier 1 — the read-only script. Free, no password, ~5 seconds, costs **zero** by-hand steps

**Measured on the rig** (`first-hand`, `time` around the whole block): **5.2 s** cold, **3.4 s** warm for the
`system_profiler` sweep alone. Everything here is unprivileged and needs no network.

> **One domain is the whole latency budget: `SPAirPortDataType` takes 8.0 seconds on its own** (`first-hand`)
> because it performs a live Wi-Fi scan — longer than every other domain combined. An earlier timing of 13.0 s
> was entirely explained by including it. It is **omitted below**: its buyer-relevant content (PHY modes, 6 GHz
> support, country code) is a 📝 at best, and its SSIDs are redacted anyway. Add it only if Wi-Fi capability is
> actually in question, and expect it to triple the script's runtime.

```sh
system_profiler SPHardwareDataType SPSoftwareDataType SPiBridgeDataType \
                SPPowerDataType SPNVMeDataType SPStorageDataType \
                SPDisplaysDataType SPMemoryDataType SPThunderboltDataType \
                SPCameraDataType SPAudioDataType SPSPIDataType \
                SPInstallHistoryDataType 2>/dev/null

profiles status -type enrollment          # MDM + DEP — the cheapest 🛑 in the procedure
csrutil status                            # SIP (also gates the Parts & Service pane)
fdesetup status                           # FileVault
diskutil apfs list                        # true capacity + Sealed: Yes

ioreg -arc AppleSmartBattery -d1          # lifetime temps, PermanentFailureStatus, pack serial
ioreg -lw0 -p IODeviceTree | grep -iE 'serial|region-info|model-number|product-name'
ioreg -lw0 | grep -iE 'KeyboardLanguage|FrontCameraModuleSerialNumString'

stat -f "%SB" -t "%F %T" /var/db/.AppleSetupDone   # when it was last erased
grep -c -E 'mobile_obliterator' /var/log/install.log
ls /var/db/PanicReporter/                          # non-empty = recent kernel panic

osascript -l JavaScript -e 'ObjC.import("Foundation"); var m={0:"nominal",1:"fair",2:"serious",3:"critical"}; m[$.NSProcessInfo.processInfo.thermalState]'
```

**Everything in Tier 1 clears the admission bar on own-outcome alone**, because its marginal cost is zero.

### Tier 2 — the by-hand steps this research argues for, against the 8-step budget

| # | Step | Time | Cost | Why it cannot be scripted |
|---|---|---|---|---|
| 1 | **Parts & Service** pane | ~30 s | Tahoe 26 | **No CLI exists** — `corerepaird` has no user-facing query |
| 2 | **Apple Diagnostics** (⌘-D from Options) | "a few minutes" | **🔄 reboot** | Separate boot environment; results are ephemeral — **photograph the screen** |
| 3 | **AppleCare & Warranty** pane | ~20 s | 🌐 + seller signed in | Account-scoped; **must happen before the iCloud sign-out** |
| 4 | **Thermal state before/after the stress test** | 2 × 1 s around the existing 5-min load | — | Needs a load applied by hand; folds into the README's existing Step 3 |

That is **four** of the eight, leaving four for the physical checks the README already has (trackpad corners,
screen white/black/tilt, every port charges, keyboard + speakers + camera/mic) — which this research confirms
are **irreplaceable**, because speaker, microphone, trackpad and fan have **no on-device tell at all**.

### Two structural recommendations

**1. Run the script before Apple Diagnostics, not after.** The script is free and tells you whether Apple
Diagnostics is even reachable: an ex-corporate machine with an MDM-set recoveryOS password cannot show the
startup-options screen at all, and `profiles status` plus `SPiBridgeDataType`'s MDM approval flags will have
warned you a full reboot earlier. Spending a 🔄 reboot to discover a lock the script would have shown for free
is the worst trade in the procedure.

**2. The visit has a hard ordering constraint, and the README does not currently know about it.** Two of its
steps destroy evidence that other steps need:

| Must happen **before** | Because |
|---|---|
| **AppleCare & Warranty** before the **iCloud sign-out** | The pane is account-scoped and goes blank on sign-out |
| **Everything read-only** before the **reboot into Apple Diagnostics** | The reboot costs minutes and may be blocked; and `Time since boot`, `pmset` state and the thermal reading all reset |
| **`grep mobile_obliterator /var/log/install.log`** before any **erase** | The buyer's own erase overwrites the seller's erase receipt |

None of these is expensive — they are free if the guide simply fixes the order, and unrecoverable if it does not.

---

## Unresolved conflicts and open questions

1. **Does `profiles status -type enrollment` see an ABM/ADE *assignment* on a machine that is not currently
   enrolled?** This is the highest-stakes unknown in the note. The rig is unenrolled, so only the negative
   branch was observed. See the [locks section](#locks-enrollment-and-security-state) and the `UNPINNED` table.
2. **Can an Apple-silicon Mac emit `PFM00x` (SMC) codes at all?** Apple's table is unsegmented but the SMC is an
   Intel-era component.
3. **Does an Apple Diagnostics run on Apple silicon populate `SPDiagnosticsDataType`?** Empty on the rig, but
   the rig may simply never have run it.
4. **~~Does a top-case swap carry the Touch ID board?~~ — RESOLVED, negative.** Apple's Top Case procedure has
   the technician reinstall the *original* Touch ID board, and the Touch ID procedure triggers Repair Assistant
   only on *replacement*. No indirect flag. See the [correction](#the-touch-id-cross-link-is-a-dead-end--correction-to-13s-open-question).
5. **`DateOfFirstUse` reads 0 on an M4 Air.** If it populates on other models it becomes a direct
   battery-install date and upgrades the battery row from PARTIAL to YES.
6. **The thermal-pressure enum mismatch** between JXA/`ProcessInfo` and
   `notifyutil com.apple.system.thermalpressurelevel` is observed but the second scale is undocumented.
7. **Apple contradicts itself on Display coverage — and this note takes a different reading than
   [#13](https://github.com/mingrath/mbcheck/issues/13) did.** 123123 (2026-05-26) ticks Display for MacBook
   Neo only; 123128 (2026-05-11) lists Display as a calibrated part for Air and Pro 2020–2026. #13 read these
   as two lists and concluded an unpaired Air/Pro panel produces no row. **That still holds for the *history
   table*.** What is new is that the *calibration* list has a user-visible consequence of its own — the
   `Finish Repair` state and its notification — so the two readings are compatible: **calibratable ≠
   reportable, but calibratable ⇒ visible while uncalibrated.** If that is wrong, the display row drops back to
   NO. *To pin: observe a Tahoe 26 Air or Pro with a freshly-fitted, uncalibrated panel.*
8. **Are the per-component serials live or cached?** If `coverglass-serial-number` is read from the panel at
   boot, it is a real display-swap tell; if it is cached in a logic-board provisioning blob, it is worse than
   useless because it will confidently report the *original* panel. This single question decides whether the
   display section's handle (b) is worth anything.

## Unpinned — could not establish

| # | Missing | Why | What would pin it |
|---|---|---|---|
| 1 | Whether ABM/ADE assignment is visible pre-enrollment | Rig is unenrolled | An enrolled or ABM-assigned Mac to read |
| 2 | Runtime of Apple Diagnostics under Tahoe 26's per-component flow | Apple removed the duration sentence from the MacBook page | A timed run on an M1–M5 laptop |
| 3 | Whether Activation Lock blocks Apple Diagnostics | No Apple page says | A test on a locked M-series Mac |
| 4 | Whether Apple silicon emits `PFM00x` | Apple's table is unsegmented | An Apple statement, or a captured result |
| 5 | Whether `SPDiagnosticsDataType` ever populates on Apple silicon | Empty on a machine that may never have run the test | Run Diagnostics, reboot, re-query |
| 6 | **Fan RPM by any built-in means on a MacBook Pro** | Rig is a fanless Air | `ioreg -l \| grep -i fan` + `sudo powermetrics --samplers thermal` on a Pro |
| 7 | Whether `pmset -g therm` ever populates on Apple silicon | Rig was near-idle | Re-run under sustained load on a Pro |
| 8 | `LifetimeData.TotalOperatingTime` unit | Undocumented | Correlate across machines of known age |
| 9 | `BatteryData.ManufactureDate` encoding | Packed integer, undocumented | Correlate across machines of known build date |
| 10 | Whether `DateOfFirstUse` populates on any Apple-silicon MacBook | 0 on the rig | Read across several machines |
| 11 | `alt_handler_id` value table (keyboard type) | Undocumented | Collect across known ANSI/ISO/JIS machines |
| 12 | Whether a top-case swap carries the Touch ID board | Apple manuals treat them as separate parts; real-world practice unknown | An Apple repair manual's Touch ID procedure, or an observed swap |
| 13 | Whether the software serial follows the logic board or the enclosure | Both readings circulate; neither documented | An Apple statement, or an observed before/after |
| 14 | Whether True Tone absence reliably indicates an unpaired panel | Not exposed to `ioreg` or `system_profiler` at all; GUI-only and user-toggleable | Observation on a Tahoe 26 Mac with a known third-party panel |
| 15 | Whether sudo or Location authorization un-redacts SSIDs on Tahoe 26 | Not tested — no sudo used, by design | Grant Terminal Location permission; retest |
| 16 | Whether Tahoe's Battery pane shows a numeric Maximum Capacity % in the GUI | Read via CLI, not GUI | Open System Settings → Battery |
| 17 | M1/M2/M3/M5 key-set parity with the M4 rig | Single-generation rig | Re-run the sweep on other generations |
| 18 | Whether macOS and iOS "Maximum Capacity" use the same formula | Apple documents neither | Likely unpinnable publicly |
| 19 | **Whether `coverglass-serial-number` / `raw-panel-serial-number` change on a display swap, or are cached on the logic board** | Never-repaired rig only | Capture the device tree on one machine before and after a genuine display swap |
| 20 | **Whether `mlb-serial-number` changes on a board swap while the system serial stays put** | Never-repaired rig only | `ioreg -lw0 -p IODeviceTree \| grep -i serial` on a known-original and a known-board-swapped unit of the same model. **If it does, this is a novel board-swap tell no source currently documents** |
| 21 | What `SPPowerDataType` shows with a third-party battery fitted | No swapped machine available | One before/after `system_profiler -json SPPowerDataType` diff across a known third-party swap |
| 22 | Whether `CountryCode` is non-zero on ISO/JIS keyboards | `0` on the rig's Thai keyboard; single sample | Run the same `ioreg` grep on a JIS and an ISO machine — would upgrade "language readable" to "physical layout verifiable" |
| 23 | Whether the component date-code coherence heuristic (chars 4–5 of each part serial) holds | n = 1 | Capture the four serials across several known-original units of one model, plus one known-repaired unit |
| 24 | Whether `_spdisplays_display-serial-number` is per-unit or derived | Single sample; week/year both read `0` | Compare across two machines of the same model |
| 25 | Whether `corerepaird` exposes a queryable interface for Parts & Service | No CLI or `system_profiler` domain found | Reverse `CoreRepairKit.framework` — out of scope here |
| 26 | Apple's stated `sysdiagnose` duration | Apple's doc page is a JS app that renders nothing to a fetcher | Open it in a real browser |
| 27 | Retention semantics of `/Library/Logs/DiagnosticReports/Retired/` | No Apple doc; `osanalyticshelper` is in the dyld shared cache so `strings` yields nothing | An Apple statement, or observation over time |
