# Model-specific defects, recalls and service programmes — Apple-silicon MacBooks

Research note resolving [issue #5](https://github.com/mingrath/mbcheck/issues/5).
Feeds the **per-model appendix** the README gains under
[issue #11](https://github.com/mingrath/mbcheck/issues/11), and competes for the ≤ 8 physical prompts
capped by [issue #9](https://github.com/mingrath/mbcheck/issues/9).

**Research date: 2026-08-04.** Every claim carries its source URL; every stale-able fact carries an
"as of" date. Where a source page shows no publication date, that is stated rather than glossed.
Forum, video and press claims are labelled as claims and are never promoted to fact.

Scope is the map's scope: **MacBook Air 13"/15" and MacBook Pro 13"/14"/16", M1–M5.** That is
**24 distinct model + chip-tier configurations**, enumerated in
[the port matrix](#the-port-matrix--24-configurations-the-readme-assumes-one).

---

## The answer in three sentences

**Apple has never run a service programme, repair-extension programme, exchange programme or recall
for any Apple-silicon MacBook** — the per-model catalogue the ticket asked for does not exist,
and the honest structure is a **short universal core plus a per-model *configuration* appendix**,
because what actually varies model to model is how many ports, how many fans, how many NAND chips
and which display technology, not which defect. The defects that *are* real on Apple silicon —
spontaneous panel cracking, speaker rattle, backlight bleed — are **uncovered by anything, invisible
to Parts & Service on an Air or Pro, and expensive**, so they are exactly the buyer's risk to carry.
The single largest addition this research produces is universal, not per-model: **Apple Diagnostics**,
a free, no-sudo, no-extra-hardware test that Apple documents as covering 18 subsystems including
several the current README cannot test at all.

---

## ⚠️ Corrections this research forces on the current README

| # | README says | Reality | Where |
|---|---|---|---|
| 1 | "plug the charger into **each of the three Thunderbolt ports** — all three must charge" | **Wrong for 12 of the 24 configurations.** Every MacBook Air ever made has **2** USB-C ports. Both 13" MacBook Pros have **2**. The 14" MacBook Pro with **base M3** has **2** — while still having MagSafe, HDMI and SDXC, so it looks like a 3-port machine from the outside. | [Port matrix](#the-port-matrix--24-configurations-the-readme-assumes-one) |
| 2 | The word **MagSafe** appears nowhere in the port test | **15 of 24 configurations have MagSafe 3**, including the exact machine the README was written for (16" M1 Pro 2021). It is the primary charge port and a *separate board* from the USB-C ports. Untested by the current procedure. | [Port matrix](#the-port-matrix--24-configurations-the-readme-assumes-one) |
| 3 | Ports test lists only Thunderbolt | The 2021 16" also has **HDMI** and an **SDXC slot**. Both have their own Apple Diagnostics failure codes (`VFD008/009`, `VDC00x`) and neither needs an external monitor or a card to test. | [Universal core](#the-universal-core--apple-diagnostics) |
| 4 | "check the mini-LED blooming is **even, not blotchy**" | Apple documents blooming, and "a slight blur or color change while scrolling against black backgrounds", as **normal behaviour** of mini-LED local dimming. The map has separately ruled **screen glow/blooming out of scope as cosmetic** under [#9](https://github.com/mingrath/mbcheck/issues/9). **Delete the line** — but keep a *black-screen* check, because that is where cracks and dead zones show. | [Displays](#4-mini-led-blooming-normal-vs-a-dead-zone-not-normal) |
| 5 | `for i in {1..8}; do yes …` — "pins all **8** performance cores" | 8 P-cores is an **M1 Pro/Max number**. A base M2/M3 has fewer; an M4 Max has more. The loop count must be derived (`sysctl -n hw.perflevel0.physicalcpu`, unprivileged), not hard-coded. And the base-M3 14" Pro has **one fan, not two**. | [Fans and thermals](#fans-and-thermals) |
| 6 | Parts & Service table has four states; "**Unknown** = walk away" | Five states, already corrected by [#13](https://github.com/mingrath/mbcheck/issues/13). **New here:** a `Finish Repair` label can mean the fitted part is **Activation-Locked to a previous owner's Apple Account**. Apple states plainly that **Apple cannot remove it**, that the part is then ineligible for warranty/AppleCare service, and that **you cannot trade the machine in**. That is a *lock*, not a condition finding. | [Locked parts](#a-locked-part-is-a-lock-not-a-condition-finding) |
| 7 | Cycle count "~150 · **over 300 = renegotiate**" | Apple rates **every** Apple-silicon MacBook at a **maximum cycle count of 1000**, and says the battery is designed to retain up to 80% of original capacity *at* that count. 300 is 30% of design life. Keep 300 if the market supports it, but do not present it as a health limit. | [Battery](#battery) |
| 8 | No mention of **Apple Diagnostics** | A free, unprivileged, one-restart test Apple documents as covering 18 subsystems, several of which the README cannot test by hand at all (SMC, storage, Thunderbolt controller, HDMI controller, SD reader, ambient light sensor, lid sensor). | [Universal core](#the-universal-core--apple-diagnostics) |
| 9 | "Fans become audible within 30–60 seconds… **Total silence** = dead fans" | Already refuted for the Air by [#13](https://github.com/mingrath/mbcheck/issues/13) (every Air is fanless). **New:** the Air has no correct acoustic test at all — see [the Air thermal test](#the-fanless-air-what-to-test-instead). | [Fans and thermals](#fans-and-thermals) |
| 10 | Screen test is "dead pixels, stuck pixels, blooming, tilt for flicker" | The **highest-value display check is none of those**: it is a hairline **panel crack at the bottom edge / hinge line with unmarked outer glass**, which is uncovered by any warranty, undetectable in Parts & Service on an Air or Pro, and a whole-assembly repair. | [Cracking](#2-spontaneous-panel-cracking--the-highest-value-display-check) |

---

## Apple service programmes: the properly-evidenced negative

**Apple has never listed an Apple-silicon MacBook on its service-programme index.**

Apple's index — `support.apple.com/exchange_repair`, which 301-redirects to
<https://support.apple.com/service-programs>, described by Apple as *"all programs currently offered
by Apple, including Replacement programs, Exchange programs, Repair Extension programs and
Recalls"* — listed **8 programmes when read 2026-08-04**:

| Programme (Apple's wording) | Apple's date | In scope? |
|---|---|---|
| Mac mini Service Program for No Power Issue | June 13, 2025 | No — Mac mini (2023), M2, a **desktop** |
| iPhone 14 Plus Service Program for Rear Camera Issue | November 1, 2024 | No |
| 15-inch MacBook Pro Battery Recall Program | June 20, 2019 | No — **Intel** |
| Apple Three-prong AC Wall Plug Adapter Recall Program | April 25, 2019 | No |
| Apple AC Wall Plug Adapter Recall Program | January 28, 2016 | No |
| Beats Pill XL Speaker Recall Program | June 3, 2015 | No |
| Apple 5W European USB Power Adapter Exchange Program | June 13, 2014 | No |
| Apple Ultracompact USB Power Adapter Exchange Program | September 20, 2008 | No |

The same index was swept backwards through the Wayback Machine at four points spanning the whole
Apple-silicon era — **2022-06-10 (22 programmes), 2023-06-13 (18), 2024-06-14 (10), 2025-06-15
(10)** — and **no snapshot ever lists an M-series MacBook.**

**Every MacBook programme Apple has ever run was Intel**, and they matter here only as boundary
markers a seller may misquote:

| Programme | Scope | Status as of 2026-08-04 |
|---|---|---|
| **15-inch MacBook Pro Battery Recall** (<https://support.apple.com/15-inch-macbook-pro-battery-recall>, footer *"Information as of 2019-10-07"*) | MacBook Pro (Retina, 15-inch, **Mid 2015**) only, sold ~Sept 2015–Feb 2017, eligibility by serial. Defect: *"the battery may overheat and pose a fire safety risk"*; Apple says *"stop using it."* | **Still live. No expiry stated on the page.** Intel only. |
| **Keyboard Service Program for MacBook, MacBook Air, and MacBook Pro** (butterfly keyboards) | Butterfly-keyboard machines only | **Expired.** The URL now redirects to `support.apple.com/service-programs/status`: *"The Apple Service Program you are looking for has ended."* End dated mid-November 2024 by MacRumors (<https://www.macrumors.com/2024/11/19/apple-ends-mac-butterfly-keyboard-service-program/>) — **Apple's own end date: UNPINNED**, the page is dead. **The M1 MacBook Air/Pro (2020) use the scissor Magic Keyboard and were never eligible.** |
| 13-inch MacBook Pro Display Backlight Service Program ("stage light") | Intel 2016 13" | **Expired** — present in the 2023-06 snapshot, gone by 2024-06-14 |
| 13-inch MacBook Pro (non Touch Bar) Solid-State Drive Service Program | Intel | **Expired** — present 2022-06, gone by 2023-06 |
| 13-inch MacBook Pro (non Touch Bar) Battery Replacement Program | Intel | **Expired** — present 2022-06, gone by 2023-06 |

**No CPSC, EU Safety Gate or ACCC recall for any Apple-silicon MacBook surfaced.** (Caveat: those
databases were checked via search results, not by querying each database's own interface.)

Two things stop this from being an "Apple silicon is flawless" story:

1. **Apple does still open Apple-silicon Mac programmes when a defect emerges** — the *Mac mini
   Service Program for No Power Issue* (<https://support.apple.com/mac-mini-2023-service-program-for-no-power-issue>,
   June 13, 2025) covers the M2 Mac mini (2023). It is a desktop and out of scope, but it proves the
   mechanism is alive.
2. **Apple runs dealer-facing, unpublished "Quality Programs"** that never appear on this index.
   Whether any covers an M-series MacBook is **not verifiable from public sources**; it would take an
   Apple GSX or AASP service bulletin.

**Nor is there any Apple-published support document acknowledging a hardware defect in any M1–M5
MacBook**, across three separate search passes.

---

## The universal core — Apple Diagnostics

Apple ships a hardware self-test on every Mac. It needs **no sudo, no internet, no external
hardware and no software install**, and it is the highest-yield check found in this research.

**How to start it on Apple silicon** (Apple, *Use Apple Diagnostics to test your Mac*,
<https://support.apple.com/en-us/102550>, published 2025-12-19): shut down → press and hold the power
button (the Touch ID button) until **Options** appears → release → hold **Command-D**.

**What it covers and the code it returns** — Apple, *Apple Diagnostics reference codes*,
<https://support.apple.com/en-us/102334>, published 2025-12-15:

| Subsystem | Code | Testable by hand at a shop? |
|---|---|---|
| No issues found | `ADP000` | — |
| Fan | `PPF001/003/004` | Only by ear, and only under load |
| Battery — replace soon / **requires service** / not installed properly / not detected | `PPT001`–`PPT007` | Partly (System Information) |
| Wi-Fi hardware | `CNW001`–`CNW009` | Yes, by joining a network |
| Bluetooth hardware | `NDL001/002` | Yes, with a phone |
| Camera | `NDC001`–`NDC006` | Yes, Photo Booth |
| Trackpad | `NDR001`–`NDR008` | Yes |
| Keyboard | `NDK001/003/004` | Yes, TextEdit |
| **Thunderbolt hardware** | `NDT001`–`NDT006` | Only for *charging*, not data |
| **USB hardware** | `NDD001` | No |
| **SD card reader** | `VDC001`–`VDC007` | Only with a card in hand |
| **HDMI controller** | `VFD008/009` | Only with a monitor and cable |
| Display / GPU | `VFD001`–`VFD007` | Partly, by eye |
| Audio hardware | `VFF001`–`VFF003` | Partly, by ear |
| **Touch ID sensor** | `BMT001`–`BMT005` | Only by enrolling a fingerprint |
| **Lid open/close sensor** | `LAS001`–`LAS004` | Yes — close the lid |
| **Ambient light sensor** | `ALS001` | No |
| **Storage device** | `VDH001`–`VDH005` | No |
| **SMC / power management** | `PFM001`–`PFM007`, `PPN001/002` | No |
| **Firmware** | `PFR001` | No |
| **Serial number not detected** | `NNN001` | No — and this is a **provenance** signal |
| Power adapter | `PPP001`–`PPP020` | Partly |
| Onboard memory | `PPM001`–`PPM016` | No |
| Processor | `PPR001` | No |
| **Antenna connector board** | `VFD011` | No |

**Four caveats the guide must carry:**

1. **macOS Tahoe 26 changed it.** Apple: *"In macOS Tahoe 26 and later, you're asked to choose a
   specific diagnostic to run, such as a diagnostic for your built-in display, keyboard, or
   trackpad. In earlier versions of macOS, this is automatic."* (102550). On Tahoe it is a **menu of
   targeted tests**, not one sweep — the buyer must choose, and wall-clock cost depends on how many.
2. **UNPINNED: Apple publishes no run time**, for the whole sweep or for any targeted test. That
   blocks admission under [#9](https://github.com/mingrath/mbcheck/issues/9), which budgets physical
   checks in minutes.
3. **It costs the same restart** the README already spends proving the machine boots to Setup
   Assistant. Those two checks compete, or must be sequenced.
4. **It cannot see what the buyer's hands are for.** Nothing in the code list detects speaker
   *rattle* (mechanical, not electrical), a swollen battery, a cracked or delaminated panel, backlight
   bleed, a loose hinge, worn port contacts or dead pixels. `PPF00x` detects a fan that fails to spin
   or report — not one that grinds. **The physical prompts survive.**

`NNN001` — "A serial number was not detected" — deserves separate mention: it is filed as a hardware
code, but for this guide it reads as a provenance flag. A machine whose serial does not read is a
machine whose coverage lookup and Activation Lock status cannot be trusted.

---

## A locked part is a lock, not a condition finding

Apple, *If a part is locked to someone else's Apple Account*,
<https://support.apple.com/en-us/120610>, published **2026-04-29**:

> "When a previously used part, such as a **battery, built-in display, front camera, or Touch ID
> sensor** is protected by Activation Lock, it's linked to someone else's Apple Account."

> "**Apple can't help remove Activation Lock for previously used parts.**"

> "You can use a part that is locked, but because it isn't configured, it might not perform as
> expected… In Parts & Service on the device, the part will continue to show a **Finish Repair**
> label. If you can't unlock the part, the part is **ineligible for service under the Apple Limited
> Warranty or an AppleCare plan**. You also **can't trade in your device** if the part is locked."

Consequences:

- `Finish Repair` is not merely "an unfinished repair". On a second-hand machine it is a candidate
  **third lock**, alongside Activation Lock and MDM — and the *seller* cannot clear it either,
  because it needs the Apple Account of whoever owned the **donor** machine.
- It is unlockable only by that donor account, via Repair Assistant or by removing Activation Lock at
  iCloud.com/find on the donor device.
- It closes Apple trade-in on the machine outright.
- Apple's list of lockable parts (**battery, display, front camera, Touch ID sensor**) is *wider*
  than the parts Parts & Service *reports* on a Mac. See
  [unresolved conflicts](#unresolved-conflicts-in-the-sources).

---

## The port matrix — 24 configurations, the README assumes one

Every cell is from that model's Apple tech-spec page, "Charging and Expansion" and "Audio" sections;
those sections enumerate the complete port set, so an absent item is a pinned negative. **All read
2026-08-04; Apple's tech-spec pages carry no publication date.**

| # | Model (year, chip tier) | USB-C — Thunderbolt gen | MagSafe 3 | HDMI | SDXC | 3.5 mm (high-Z?) | Spec page |
|---|---|---|---|---|---|---|---|
| 1 | MBA 13" 2020, **M1** | **2** — Thunderbolt **3** / USB 4 | **No** | No | No | Yes — no high-Z claim | [111883](https://support.apple.com/en-us/111883) |
| 2 | MBA 13.6" 2022, **M2** | **2** — Thunderbolt **3** / USB 4 | Yes | No | No | Yes — high-Z | [111867](https://support.apple.com/en-us/111867) |
| 3 | MBA 15" 2023, **M2** | **2** — Thunderbolt **3** / USB 4 | Yes | No | No | Yes — high-Z | [111346](https://support.apple.com/en-us/111346) |
| 4 | MBA 13" 2024, **M3** | **2** — Thunderbolt **3** / USB 4 | Yes | No | No | Yes — high-Z | [118551](https://support.apple.com/en-us/118551) |
| 5 | MBA 15" 2024, **M3** | **2** — Thunderbolt **3** / USB 4 | Yes | No | No | Yes — high-Z | [118552](https://support.apple.com/en-us/118552) |
| 6 | MBA 13" 2025, **M4** | **2** — **Thunderbolt 4** | Yes | No | No | Yes — high-Z | [122209](https://support.apple.com/en-us/122209) |
| 7 | MBA 15" 2025, **M4** | **2** — **Thunderbolt 4** | Yes | No | No | Yes — high-Z | [122210](https://support.apple.com/en-us/122210) |
| 8 | MBA 13" 2026, **M5** | **2** — **Thunderbolt 4** | Yes | No | No | Yes — high-Z | [126320](https://support.apple.com/en-us/126320) |
| 9 | MBA 15" 2026, **M5** | **2** — **Thunderbolt 4** | Yes | No | No | Yes — high-Z | [126321](https://support.apple.com/en-us/126321) |
| 10 | MBP 13" 2020, **M1** | **2** — Thunderbolt **3** / USB 4 | **No** | No | No | Yes — no high-Z claim | [111893](https://support.apple.com/en-us/111893) |
| 11 | MBP 13" 2022, **M2** | **2** — Thunderbolt **3** / USB 4 | **No** | No | No | Yes — high-Z | [111869](https://support.apple.com/en-us/111869) |
| 12 | MBP 14" 2021, **M1 Pro/Max** | **3** — Thunderbolt 4 | Yes | Yes — max 4K@60 | Yes | Yes — high-Z | [111902](https://support.apple.com/en-us/111902) |
| 13 | MBP 16" 2021, **M1 Pro/Max** | **3** — Thunderbolt 4 | Yes | Yes — max 4K@60 | Yes | Yes — high-Z | [111901](https://support.apple.com/en-us/111901) |
| 14 | MBP 14" 2023, **M2 Pro/Max** | **3** — Thunderbolt 4 | Yes | Yes — 8K@60 / 4K@240 | Yes | Yes — high-Z | [111340](https://support.apple.com/en-us/111340) |
| 15 | MBP 16" 2023, **M2 Pro/Max** | **3** — Thunderbolt 4 | Yes | Yes — 8K@60 / 4K@240 | Yes | Yes — high-Z | [111838](https://support.apple.com/en-us/111838) |
| 16 | **MBP 14" Nov 2023, M3 (base)** ⚠️ | **2** — Thunderbolt **3** / USB 4 | Yes | Yes | Yes | Yes — high-Z | [117735](https://support.apple.com/en-us/117735) |
| 17 | MBP 14" Nov 2023, **M3 Pro/Max** | **3** — Thunderbolt 4 | Yes | Yes — 8K@60 / 4K@240 | Yes | Yes — high-Z | [117736](https://support.apple.com/en-us/117736) |
| 18 | MBP 16" Nov 2023, **M3 Pro/Max** | **3** — Thunderbolt 4 | Yes | Yes — 8K@60 / 4K@240 | Yes | Yes — high-Z | [117737](https://support.apple.com/en-us/117737) |
| 19 | MBP 14" 2024, **M4 (base)** | **3** — Thunderbolt 4 | Yes | Yes — 8K@60 / 4K@240 | Yes | Yes — high-Z | [121552](https://support.apple.com/en-us/121552) |
| 20 | MBP 14" 2024, **M4 Pro/Max** | **3** — **Thunderbolt 5** | Yes | Yes — 8K@60 / 4K@240 | Yes | Yes — high-Z | [121553](https://support.apple.com/en-us/121553) |
| 21 | MBP 16" 2024, **M4 Pro/Max** | **3** — **Thunderbolt 5** | Yes | Yes — 8K@60 / 4K@240 | Yes | Yes — high-Z | [121554](https://support.apple.com/en-us/121554) |
| 22 | MBP 14" 2025, **M5 (base)** | **3** — Thunderbolt 4 | Yes | Yes — 8K@60 / 5K@120 / 4K@240 | Yes | Yes — high-Z | [125405](https://support.apple.com/en-us/125405) |
| 23 | MBP 14" 2026, **M5 Pro/Max** | **3** — **Thunderbolt 5** | Yes | Yes — 8K@60 / 5K@120 / 4K@240 | Yes | Yes — high-Z | [126318](https://support.apple.com/en-us/126318) |
| 24 | MBP 16" 2026, **M5 Pro/Max** | **3** — **Thunderbolt 5** | Yes | Yes — 8K@60 / 5K@120 / 4K@240 | Yes | Yes — high-Z | [126319](https://support.apple.com/en-us/126319) |

### What the matrix means for the charging test

Apple, *Charge your Mac laptop computer*, <https://support.apple.com/en-us/102397>, published
**2026-07-30**:

> "If your Mac has a MagSafe 3 port, it might also have USB-C ports. **Your Mac charges over only one
> port at a time, using the source that provides the most power.** Connecting a charging solution to
> more than one port… doesn't charge your Mac faster."

> "USB-C ports are on the left side or both sides of the Mac, and **any of them can be used for
> charging**."

The same page independently confirms the MagSafe roster: *"MacBook Pro introduced in 2021 or later,
**excluding MacBook Pro (13-inch, M2, 2022)**; MacBook Air introduced in 2022 or later."*

Corrected instruction: **plug the charger into every charge-capable port on this specific machine,
one at a time — 2 or 3 USB-C ports, plus MagSafe where fitted.** Simultaneous plugging proves nothing.

### Lineup facts, verified not assumed

- **There is no 16" MacBook Pro with a base chip in any generation** — the 16" has only ever shipped
  Pro/Max in the Apple-silicon era.
- **No 13" MacBook Pro after the M2 (2022)**, and **no 15" MacBook Pro at all** in Apple silicon.
- **M5 lineup as of 2026-08-04:** MBP 14" M5 (2025); MBP 14" and 16" M5 Pro/Max (2026); MBA 13" and
  15" M5 (2026). Corroborated independently by Apple's battery-cycle table
  (<https://support.apple.com/en-us/102888>, published 2026-03-10) and Apple's Wi-Fi specification
  table.
- **The base-chip 14" has no stable rule.** M3 base → 2 ports, TB3-class. M4 base → 3 ports, TB4.
  M5 base → 3 ports, TB4 (while M5 Pro/Max moved to TB5). Look it up per machine.
- **HDMI version is UNPINNED for every row.** Apple states a maximum output resolution but never an
  HDMI version number, on any of the 13 MacBook Pro spec pages or on apple.com/macbook-pro/specs.
  iFixit calls the base-M3 14" "HDMI 2.1". Treat "2.0" / "2.1" as an inference from the resolution
  ceiling (4K@60 vs 8K@60), never as an Apple claim.

### Radios per model

Apple, *Wi-Fi and Ethernet specifications for Apple devices*,
<https://support.apple.com/guide/deployment/wi-fi-ethernet-specifications-apple-devices-dep268652e6c/web>
(no on-page publication date; read 2026-08-04):

| Generation | Wi-Fi |
|---|---|
| MBA M1 2020, MBA M2 2022, MBA 15" M2 2023 · MBP 13" M1 2020, MBP 13" M2 2022, MBP 14"/16" 2021 | **Wi-Fi 6** (no 6 GHz) |
| MBA M3 2024, MBA M4 2025 · MBP 14"/16" M2 2023, M4 2024, MBP 14" M5 2025 | **Wi-Fi 6E** |
| MBA 13"/15" M5 2026 · MBP 14"/16" M5 Pro/Max 2026 | **Wi-Fi 7 + MLO** (Apple "N1" chip) |

Two flags: the **M3-generation MacBook Pros are absent from Apple's own table entirely** (see
[unresolved conflicts](#unresolved-conflicts-in-the-sources)); and the **base M5 14" Pro is on
Wi-Fi 6E while the cheaper M5 Air is on Wi-Fi 7** — a counter-intuitive per-model fact a buyer
comparing the two should know.

---

## Displays

### 1. Anti-reflective coating delamination ("staingate")

- **Models:** Apple's repair-extension programme covered **Intel-era Retina machines only**
  (roughly 2012–2017; 2013–2014 models dropped from eligibility in December 2019 —
  <https://forums.macrumors.com/threads/…2216662>, Dec 2019;
  <https://www.imore.com/apple-extended-free-repairs-anti-reflective-coating-select-macbooks>,
  2018-04-18). It is **not on Apple's current service-programme index** and its page appears to have
  been removed. **Apple's exact model list and formal end date: UNPINNED.**
- **On Apple silicon:** no Apple acknowledgement, no programme, no teardown-grade source. **Claims
  only:** a 128-reply r/macbookpro thread *"Staingate also happens to M-series Macbooks"*
  (2026-05-10, <https://www.reddit.com/r/macbookpro/comments/1t96ogg/>), a 42-reply r/applesucks
  thread on AR-coating rot (2026-01-10), and an r/mac post on an M1 Air. **Incidence: UNPINNED.**
- **Presentation:** cloudy, matte patches that do not wipe off, typically mirroring the keyboard and
  trackpad contact points.
- **Shop test (< 1 min):** full-screen **black**, tilt the lid so a ceiling light reflects, and look
  across the glass at a **grazing angle** — delamination reads as matte islands in a glossy field.
  Wipe firmly with a dry cloth: a smudge goes, delamination does not.
- **Coverage:** none for Apple silicon. **Cost:** whole display assembly (Apple sells no separate
  front glass).

### 2. Spontaneous panel cracking — the highest-value display check

**Models:** reports span the whole Apple-silicon era — M1 Air / M1 13" Pro (2020–21), M2 13" Air
(A2681, 2022), M2 15" Air (A2941, 2023), M2 MacBook Pro, M3 Air (2024).

**Evidence, by tier:**

- **Litigation.** A class action was filed 2021-09 alleging M1 MacBook Air and M1 MacBook Pro
  displays are *"extraordinarily fragile"* and crack in normal use, producing large black blotches;
  the alleged mechanism is torque transferred through the thin lid.
  (<https://www.classaction.org/blog/defective-apple-m1-macbook-screens-are-extraordinarily-fragile-class-action-alleges>,
  2021-09-16; <https://www.pcmag.com/news/apple-facing-m1-macbook-cracked-screen-class-action-lawsuit>,
  2021-09-17.)
- **Apple's position.** Apple **moved to dismiss**, and in practice treats these as accidental damage
  (chargeable), not warranty. (<https://6abc.com/post/apple-m1-macbook-laptop-screen-cracked-class-action-lawsuit-computer-help/12300724/>,
  2022-10-07.) **Case outcome: UNPINNED.**
- **A second, M2-generation investigation.** Miller Shah LLP ran an *"M2 MacBook Screen Defect
  Investigation"* into MacBook Air and MacBook Pro with M2/M2 Pro, citing screens *"cracking
  spontaneously, blacking out, or displaying boxes or lines."* Page status: **"Closed
  Investigation."** (<https://www.millershah.com/class-action/m2-macbook-screen-defect-investigation/>,
  page last updated 2025-08-05.)
- **Forum claims (labelled):** Apple Support Communities threads on M2 Pro (2023-09,
  <https://discussions.apple.com/thread/255074382>), M2 Air cracking *at the hinge* (2023-11-01,
  thread/255247190), M2 15" Air (2023-10-02, thread/255173557), M1 Air (2024-01-28,
  thread/255436815); Reddit r/macbook on an M3 Air (2024-06).

**No published incidence rate exists, from Apple or from any teardown source. Do not quote a
percentage.**

**Presentation:** a hairline fracture originating **at or near the bottom edge / hinge line**, often
visible only when lit, frequently with a vertical black band or coloured lines. The **outer glass is
smooth and unmarked** — a fingernail run across the line feels nothing.

**Shop test (< 1 min):**

1. Max brightness, **full-screen white**. Look at the **bottom ~15 mm** and both bottom corners.
2. Switch to **full-screen black** — cracks invisible on white often show as bright fractures.
3. Run a **fingernail along the line**: no tactile ridge = internal panel crack. It will be sold as
   "cosmetic". It is a whole-assembly repair.
4. **Tilt the lid through its full range** on white: a stressed panel shows lines or blotches
   appearing and disappearing at particular angles.

**Coverage:** no Apple programme, past or present. Not warranty. Covered only under AppleCare+
accidental damage — which [#13](https://github.com/mingrath/mbcheck/issues/13) priced at **฿3,300
(ADH Tier 1)** in Thailand, and which **a prior independent repair voids outright**.

**Cost:** see [display prices](#display-assembly-prices-parts-only-usd).

### 3. Backlight bleed / "flashlighting" at the bottom edge

- **Models:** reported most on MacBook Air M2 (2022) and M3 (2024), also M1 MacBook Pro. **All claims,
  no Apple acknowledgement.** MacRumors *"M2 MBA backlight bleed issue?"* running to at least page 7
  from 2022-07-28 (thread 2352944); MacRumors *"MacBook Air M3 Screen Bleed – Acceptable?"*
  (2024-04-21, thread 2424635); Apple Support Communities *"Macbook Air M2 Backlight Bleed"*
  (2023-12-28, thread/255375811); a 41-post r/macbook thread (2026-06-17).
- **Presentation:** discrete bright cones fanning up from the **bottom bezel**, usually near the lower
  corners — localised and asymmetric, unlike uniform IPS glow. Pressure points show as round bright
  dots on grey.
- **Shop test (< 1 min):** full-screen **black** at ~70–100% brightness, **shielded from room light
  with your body** — bleed is invisible under shop lighting. Then a **mid-grey** field for pressure
  points. Repeat at two lid angles: bleed that *changes as the lid flexes* points at chassis or
  pressure, which is worse than fixed bleed.
- **Coverage:** never a programme for Apple silicon. In-warranty swaps happen case by case at Apple's
  discretion (a claim from the Apple Communities thread above). Out of warranty: whole assembly.
- *For contrast only:* Apple **did** run a free 13" MacBook Pro Display Backlight programme for the
  Intel "stage light" fault. **No equivalent exists for any Apple-silicon model.**

### 4. mini-LED blooming: normal; a *dead zone* is not normal

- **Models: MacBook Pro 14" and 16" only**, 2021 (M1 Pro/Max) through M5 Pro/Max. Every MacBook Air
  and both 13" MacBook Pros are conventional IPS and **cannot bloom**.
- **It is expected behaviour.** Apple's own XDR explainer (written for iPad Pro, same architecture,
  <https://support.apple.com/en-us/102255>, published 2026-06-01): *"the extreme brightness of LEDs
  might cause a slight blooming effect because the LED zones are larger than the LCD pixel size"*,
  and *"Transitional characteristics of local dimming zones, such as a slight blur or color change
  while scrolling against black backgrounds, are normal behavior."* The Verge's analysis of the 2021
  panels adds that uniformity **deliberately falls off at the extreme edges** where the dimming zones
  trail off (<https://www.theverge.com/2021/10/23/22740783/>, 2021-10-23).
- **Abnormal, and worth finding:** a dimming zone that stays **permanently lit** on a full-black
  screen; halos that are blotchy, rectangular and **stationary regardless of content**; a whole
  quadrant visibly off at flat grey; a halo that persists after the bright object has moved away.
  Claims of such units: Apple Support Communities on M3 (2024-10-28, thread/255821612) and 16" M4
  (2024-12-11, thread/255883957).
- **Shop test (< 1 min):** full-screen **black**, max brightness, shielded. Move the cursor slowly
  across the field — the halo must **travel with it**. Anything stationary or persistent is abnormal.
  Finish on flat **mid-grey** and look for large-area patchiness.
- **Note the scope conflict:** [#9](https://github.com/mingrath/mbcheck/issues/9) ruled screen glow
  and blooming **out of scope as cosmetic**. That ruling stands for *blooming*. A permanently-lit or
  dead dimming zone is a **failed panel**, not glow, and is the thing worth keeping — reachable by the
  same black-screen look that already catches cracks and stuck pixels.

### 5. Stuck / dead / hot pixels

- **No model-specific incidence data exists for any Apple-silicon MacBook. UNPINNED.**
- **Apple's policy:** *About LCD display pixel anomalies for Apple products released in 2010 and
  later* (<https://support.apple.com/en-us/102187>, published 2024-03-09) acknowledges pixel
  anomalies and directs the customer to an Apple Store or AASP if there are more than an acceptable
  number — **but Apple does not publish the numeric threshold.** Widely circulated numbers trace to a
  2010 leak, not to Apple. **Do not quote a pixel count.**
- **Shop test (< 1 min):** cycle full-screen **red, green, blue, white, black**. Dead pixels show
  black on colour; stuck pixels show as a persistent bright dot on black. At 254 ppi you must be
  within ~30 cm — get close, and check the corners.

### 6. Nano-texture display

- **Models:** a build-to-order option on the **14"/16" MacBook Pro from the M4 generation (Oct 2024)
  onward**, continuing on M5. Apple's cleaning document names MacBook Pro among nano-texture devices
  (<https://support.apple.com/en-us/104948>, published 2024-11-08). **No MacBook Air is known to offer
  it — UNPINNED**, not confirmed against a spec page.
- **Why a buyer must check:** nano-texture is **etched into the glass**. Damage is permanent and only
  fixable by replacing the whole display. Apple's instruction is to clean it **only with the supplied
  polishing cloth**; paper towel, abrasives or household cleaner mark the etch permanently. A
  second-hand machine is at real risk of having been cleaned wrongly.
- **Shop test (< 1 min):** confirm it *is* nano-texture (matte, no mirror reflection at any angle),
  then **full-screen white** tilted under a bright light at a **grazing angle**, looking for glossy
  patches where the etch has been polished away, fine parallel scratch tracks, or a permanent haze
  ring. **Ask whether the polishing cloth is included** — its absence is a red flag for both cleaning
  history and resale.
- **Coverage:** none. **Nano-texture parts premium: UNPINNED.**

### 7. True Tone loss — how to spot a swapped display when Parts & Service cannot

**Critical:** in Apple's Parts & Service table (<https://support.apple.com/en-us/123123>, published
**2026-05-26**), **Display** is a tracked part **only for MacBook Neo**. On every MacBook Air and
MacBook Pro the tracked parts are **logic board, Touch ID board, and lid angle sensor (M5 models)** —
**not the display.** So **a swapped screen on an Air or Pro does not appear in Parts & Service at
all.** It must be detected behaviourally.

**Shop test (< 1 min), all in System Settings:**

1. **Displays → True Tone** must be present and toggleable, and toggling it must visibly shift colour
   under warm indoor light. Missing, or present with no effect, points at a non-genuine or
   uncalibrated panel.
2. **Displays → Preset** (14"/16" only): the full set of **reference modes** should be listed
   (Apple XDR Display, HDR Video, Photography, …; Apple's reference-mode doc:
   <https://support.apple.com/en-us/108321>). Missing presets point at an uncalibrated panel.
3. **General → About → Parts & Service** (Tahoe 26+): read every label. `Unverified` on the logic
   board specifically may break Apple Pay, per Apple.
4. Cover the **ambient light sensor** next to the camera and confirm auto-brightness responds.

Repair-channel claims (video tier) hold that replacing an Apple-silicon MacBook Pro display without
transferring the original calibration data causes True Tone loss plus "shadowing" / uneven shading —
<https://www.youtube.com/watch?v=CV3_ZYENaV0>, ~2025; and iFixit community discussion of which
MacBook screen repairs need Apple's System Configuration tool
(<https://www.ifixit.com/Answers/View/852832>, 2024-06-04). **Labelled as claims.**

### 8. Display cable / flex

**No Apple-silicon equivalent of "flexgate" is established, and no programme exists.** No teardown-
grade or Apple source was found describing a characteristic display-flex failure on M1–M5. The
architectural reason is that the flex is integrated into the display assembly rather than running as
a separate ribbon over the hinge — so the failure mode presents as "replace the whole display".
**Confirmation that any Apple-silicon flex-specific failure mode exists: UNPINNED.**

What does occur is failure of the **display daughterboard inside the assembly**, presenting exactly
like §2 (vertical lines, black bands, backlight dead but image faintly visible).

**Shop test (< 1 min):** full-screen white, then **open and close the lid slowly through the whole
arc, twice**, watching for flicker, momentary lines, or the backlight cutting out at a particular
angle. Any angle-dependent flicker is internal display wiring and is a whole-assembly repair. If the
screen looks black but the machine is on, shine a phone torch at it: a faint visible image means the
**backlight** circuit failed, not the panel.

### Display assembly prices (parts only, USD)

Apple publishes **no** out-of-warranty display price — its Mac laptop repair page lists battery
service and then "we'll provide a personalized estimate" for everything else
(<https://support.apple.com/mac-laptops/repair>), matching what
[#13](https://github.com/mingrath/mbcheck/issues/13) found on the Thai page. iFixit retail parts,
fetched 2026-08-04 from `ifixit.com/Parts/MacBook_Pro/Screens` and `ifixit.com/Parts/MacBook_Air/Screens`
— **parts only, labour extra**:

| Machine | Part | USD |
|---|---|---|
| MacBook Air 13" **A2681 (M2, 2022)** | Display Assembly | **$499.99** |
| MacBook Pro 13" **A2338 (M1 2020 / M2 2022)** | Display Assembly (incl. True Tone panel, bezel, camera, **clutch hinges**, display daughterboard) | **$494.99** |
| MacBook Pro 14" **A2442 (2021, M1 Pro/Max)** | Display Assembly (incl. clutch hinges) | **$574.99** |
| MacBook Pro 14" **A2779 (2023, M2 Pro/Max)** | Display Assembly | **$489.99** |
| MacBook Pro 16" **A2485 / A2780 / A2991** (2021 M1 Pro/Max, 2023 M2 Pro/Max, 2023 M3 Pro/Max) | Display Assembly — **mini-LED XDR**, incl. clutch hinges | **$729.99** |

For Thailand these are a sanity check only; the pinned baht figures are
[#13](https://github.com/mingrath/mbcheck/issues/13)'s ฿10,300–17,900 (Air) and ฿17,990–18,990
(mini-LED XDR), as of 2026-08-04. **Prices for MacBook Air M3/M4/M5, MacBook Pro M4/M5 and any
nano-texture assembly: UNPINNED.**

---

## The lid, the hinge, and the lid angle sensor

### Lid angle sensor

Apple, *About Lid Angle Sensor repair for Mac*, <https://support.apple.com/en-us/123126>, published
**2025-09-15**, states the failure signature exactly:

> "If the parts and service history shows that the Lid Angle Sensor has an Issue, **your Mac won't
> detect that the lid is closed, it won't go to sleep when closing the lid**, and the secure audio
> and video lights might not function properly."

- **Reported as a part on MacBook Pro (M5 models) and MacBook Air (M5 models) only**
  (<https://support.apple.com/en-us/123123>, 2026-05-26). **But the hardware predates M5** — a repair
  shop (claim tier) lists LAS calibration as required after screen replacement on A2681 (Air 13" M2),
  A2941 (Air 15" M2), A2442 (Pro 14" 2021–23), A2485 and A2780 (Pro 16" 2021–23)
  (<https://smashedit.co.nz/lid-angle-sensor-issues-in-macbook-air-and-macbook-pro/>, updated
  2026-02-22). **Apple reports it on M5; Apple does not say it exists only on M5.**
- **Shop test (~10 s, and it doubles as a swapped-screen check):** close the lid, wait 5 seconds —
  the machine should sleep. Reopen — it should wake. Then open Photo Booth and confirm the **green
  camera indicator light** illuminates and goes out when you quit. Also covered electrically by Apple
  Diagnostics `LAS001`–`LAS004`.
- **Coverage:** none. **Standalone LAS repair price: UNPINNED**, in any currency.

### Hinges

**No systematic hinge defect is established for any Apple-silicon MacBook, and no programme exists.**
Complaints run in both directions — too tight *and* too loose — across unrelated models, which is the
signature of unit variation rather than a design fault. iFixit's community answers treat looseness as
a screws-or-bent-frame issue (<https://www.ifixit.com/Answers/View/860237>, 2024-07-19). Claims:
a 28-answer r/macbookpro thread on a 2021 M1 Max 16" *"Hinge Uncomfortably Loose"* (2021-12-29), a
33-answer r/macbookpro thread on weak hinge feel (2023-12-12), a 23-post MacRumors *"How's your
hinge?"* (2021-12-28), and a **19-answer Apple Support Communities thread "MacBook Air M2 2022 Hinge
Issues"** describing a hinge too tight to open one-handed
(<https://discussions.apple.com/thread/255622846>, 2024-05-22).

The over-tight case is worth taking seriously for a non-obvious reason: **it is exactly the torque
condition the M1/M2 cracking litigation alleges stresses the panel.**

**Shop test (< 1 min):**

1. **One-finger open.** Open the lid with one finger at the centre of the front edge. If the base
   lifts off the table, the clutch is over-tight.
2. **Angle hold.** Set ~110° and tap the top-left corner firmly. It must not creep or oscillate.
3. **Full sweep**, feeling for notches, grinding, or a sudden loose zone. A healthy clutch is uniform.
4. **Close and sight down the seam** at eye level: an even hairline gap the whole width. A wedge gap
   means a bent lid or a bad reassembly.
5. Look at the **hinge cover** for prise marks — evidence of a prior display swap.

**Cost:** the clutch hinges ship **inside the display assembly** on these machines, so a hinge fix is
a display-assembly price.

---

## Fans and thermals

| Model | Fans |
|---|---|
| **Every MacBook Air, M1–M5, 13" and 15"** | **0 — fanless.** First established by [#13](https://github.com/mingrath/mbcheck/issues/13); re-confirmed here. |
| MacBook Pro 13" M1 (2020), M2 (2022) | **UNPINNED** |
| **MacBook Pro 14" Nov 2023, base M3** | **1** |
| MacBook Pro 14"/16" Pro/Max | 2 for M3 Pro/Max by contrast below; **UNPINNED for M1/M2/M4/M5** |

iFixit's device page for the base-M3 14" MacBook Pro states the differences from its Pro/Max siblings
outright: *"one less Thunderbolt port, **one less fan**, and a smaller battery"*
(<https://www.ifixit.com/Device/MacBook_Pro_14%22_Late_2023_%28M3%29>, no page date; read 2026-08-04;
its Parts index lists **Fans (1)**). This matters because a buyer told "listen for the fans" on a
one-fan machine may hear less than expected and wrongly call it a fault.

**The `yes`-loop is mis-sized.** The README hard-codes 8 workers for "all 8 performance cores" — an
M1 Pro/Max number. The count should be read at runtime with `sysctl -n hw.perflevel0.physicalcpu`
(unprivileged). **UNPINNED: per-chip P-core counts were not enumerated in this pass.**

**Fan bearing wear.** Apple Diagnostics `PPF001/003/004` reports "an issue with the fan" but Apple
never says whether that covers *acoustic* degradation or only a fan that fails to spin or report.
Read conservatively, it detects a dead fan, not a grinding one — so **the ear check survives** as a
hand check with no script substitute. **UNPINNED: no source quantifies bearing-wear incidence on any
Apple-silicon MacBook Pro.**

### The fanless Air: what to test instead

There is nothing to listen for, and silence is the correct result. iFixit's M2 Air teardown found not
merely no fan but **no heat spreader** — *"where's the heat spreader? What's with this big gap? …this
shield is super thin, so it's not helping much"*
(<https://www.ifixit.com/News/62674/m2-macbook-air-teardown-apple-forgot-the-heatsink>, 2022-07-19).
An Air that throttles hard and gets hot under sustained load is **behaving as designed**; no source
found treats that as a defect.

What *is* a fault on an Air is what the README already lists for the Pro, minus the acoustics: a
**sudden shutdown or reboot under load**, which is a thermal or battery fault on any machine.
**UNPINNED: no source establishes a normal-vs-abnormal chassis temperature, throttled-clock floor or
time-to-throttle for any Air. Apple publishes none, so the guide cannot set a numeric threshold.**

---

## Battery

**Apple rates every Apple-silicon MacBook at a maximum cycle count of 1000**, and states the battery
is *"designed to retain up to 80% of its original charge capacity at its maximum cycle count"*
(Apple, *Determine battery cycle count for Mac laptops*, <https://support.apple.com/en-us/102888>,
published **2026-03-10**). That page also serves as an independent check on the model lineup — it
names every Apple-silicon MacBook Air and Pro, and 1000 is the figure for all of them.

Apple Diagnostics distinguishes states the System Information pane does not
(<https://support.apple.com/en-us/102334>):

- `PPT002` / `PPT003` — will need replacing soon; functioning normally
- `PPT004` / `PPT006` — **requires service**; not functioning normally, *"though you might not notice
  a change in its behavior"*
- `PPT007` — needs replacing; functioning normally but holds significantly less charge
- `PPT005` — **"The battery is not installed properly. Shut down and discontinue use."** The only code
  in Apple's entire list that tells the user to stop using the machine — and therefore an automatic
  🛑 under [#10](https://github.com/mingrath/mbcheck/issues/10)'s spreading-fault override.
- `PPT001` — battery not detected

`PPT004` / `PPT006` are the ones that matter to a buyer: Apple explicitly says the fault may be
invisible in use. A machine reading 90% capacity on a low cycle count can still return `PPT004`.

**Swelling.** The four-corner trackpad press stands; nothing found supersedes it. Thai battery prices
are pinned per model by [#13](https://github.com/mingrath/mbcheck/issues/13) (฿5,590–8,690 at Apple
TH, ฿0 under AppleCare+, as of 2026-08-04) and are not repeated here. **UNPINNED: no source
quantifies swelling incidence by model on Apple silicon.**

---

## Storage — a configuration trap, not a defect

The base **256 GB MacBook Air (M2, 2022)** ships a **single NAND flash chip** instead of two and
benchmarks materially slower than the 256 GB M1 it replaced. iFixit's teardown found the second NAND
pad **present but empty** — *"The empty pad makes sense—it's for the extra SSD chip we didn't pay
for"* (<https://www.ifixit.com/News/62674/m2-macbook-air-teardown-apple-forgot-the-heatsink>,
2022-07-19). PCMag on the same teardown: *"read speeds are 50% slower"*
(<https://www.pcmag.com/news/teardown-confirms-m2-macbook-air-contains-slower-ssd>, 2022-07-19).
Apple reversed it on the M3 Air, which uses two 128 GB chips (iFixit teardown as reported by
TweakTown <https://www.tweaktown.com/news/96858/>, 2024-03-14, and Wccftech
<https://wccftech.com/m3-macbook-air-faster-ssd-speeds-thanks-to-dual-nand-flash-chips/>,
2024-03-09).

This is **not a defect and not a fault** — it is a factory configuration, and Apple confirmed it via
press statement rather than a support page (**UNPINNED: no Apple-hosted page states it**). But it is
exactly what a second-hand buyer pays full price for without knowing, and it is invisible to every
check in the README. It is also **capacity-specific**: only the 256 GB SKU.

- **Affects:** MacBook Air (M2, 2022) 256 GB, and — per the same secondary reporting of Apple's
  statement — the **13" MacBook Pro (M2, 2022) 256 GB**. Not verified against a teardown here.
- **Fixed from:** MacBook Air (M3, 2024) onward.
- **Shop treatment:** model and capacity are script-readable; the *speed* is not without a benchmark.
  Treat as a 📝 note keyed off model + capacity, not as a test.

---

## Speakers

The **14" and 16" MacBook Pro (2021)** attracted a large volume of reports of crackling, popping and
rattling, especially at low frequencies and high volume. **This is a claim, not an established
defect.** Evidence located, all forum-level:

- r/macbookpro, *"2021 Macbook Pro Speakers Crackling and Popping"*, **673 posts**, 2021-11-04
  (<https://www.reddit.com/r/macbookpro/comments/qmpg3k/>)
- r/macbookpro, *"New 2021 MACBOOK PRO 14" and 16" SPEAKER ISSUE"*, 2022-04
  (<https://www.reddit.com/r/macbookpro/comments/u9xp3y/>)
- Apple Support Communities, *"MacBook Pro M1 pro 16inch"*, 22 answers, 2021-11-02
  (<https://discussions.apple.com/thread/253323747>)
- iFixit Answers, 2023-07-06 (<https://www.ifixit.com/Answers/View/800285/>) and, for the **M1 Air**,
  2024-03-21 (<https://www.ifixit.com/Answers/View/841796/>)

**No Apple acknowledgement, service programme or release-note fix was found.** Competing explanations
in those threads include a software/audio-stack cause and grille debris (a MacRumors thread on the M1
Air blames dirt in the grille,
<https://forums.macrumors.com/threads/crackling-sound-at-right-speaker-of-2020-m1-macbook-air.2329194/>,
2021-12-28) — which, if true, means the finding is sometimes free to fix and should be capped below
🛑 under [#9](https://github.com/mingrath/mbcheck/issues/9)'s often-innocent rule.

**Shop test (unchanged, now justified):** play a bass-heavy track loud and listen for rattle or buzz.
Apple Diagnostics `VFF001`–`VFF003` tests the audio hardware **electrically** and will not catch a
mechanical rattle — so this check does **not** collapse into the diagnostics run.

**UNPINNED:** incidence, mechanism, and any Thai speaker price for the 14"/16" Pro
([#13](https://github.com/mingrath/mbcheck/issues/13) pinned only the 13" M1 and the Air M1).

---

## Keyboard, Touch ID, trackpad

**Keyboard.** Apple silicon has never shipped a butterfly keyboard. Every M1–M5 MacBook uses the
scissor Magic Keyboard, and **no Apple-silicon machine was ever eligible for the Keyboard Service
Program** — which has itself now ended. **No keyboard defect with a known signature was found on
M1–M5.** The README's type-every-key test stands, backed by Apple Diagnostics `NDK001/003/004`.

**Touch ID.** Apple confirms the Touch ID board is a **paired, calibrated part**: *"If the parts and
service history shows that the Touch ID board has an issue, you might not be able to use Touch ID to
authenticate, such as to unlock your Mac or authorize purchases"* (Apple, *About Touch ID repair for
Mac*, <https://support.apple.com/en-us/123127>, published **2025-09-15**). It is one of only four
parts Apple reports on a Mac.

- **Shop test:** Apple Diagnostics `BMT001`–`BMT005`; or, with no restart, System Settings → Touch ID
  & Password → try to add a fingerprint. **This requires the seller to have signed out**, so it sits
  naturally right after the iCloud sign-out step.
- **Coverage:** none, no programme.

**Trackpad.** Covered by Apple Diagnostics `NDR001`–`NDR008` electrically, and by the README's
four-corner press mechanically. Both are needed: the diagnostics code will not detect a battery
swelling underneath a still-functional trackpad.

---

## Ports, radios, camera and board-level faults

**Ports are modular on Apple silicon, which caps the cost of a dead port.** iFixit's M2 Air teardown:
*"every single port—the endangered headphone jack, prodigal MagSafe charger, and both USB-C
ports—are **modular, and not glued down**"* (<https://www.ifixit.com/News/62674/>, 2022-07-19).
iFixit publishes discrete replacement guides for **USB-C Ports**, **MagSafe Port**, **Headphone
Jack** and **Antenna Bar** on the base-M3 14" Pro. This corroborates
[#13](https://github.com/mingrath/mbcheck/issues/13): a charge-port repair is ฿1,500–3,500 in
Thailand, not a board swap.

**Antennas ride in the lid.** iFixit lists an "Antenna Bar" as a display-side replaceable part, and
Apple Diagnostics carries a dedicated `VFD011` "issue with the Antenna Connector Board" code.
Consequence: **a third-party screen replacement can plausibly degrade Wi-Fi**, so a machine with
display work in its history deserves the Wi-Fi check even if the screen looks perfect.

**Camera.** [#13](https://github.com/mingrath/mbcheck/issues/13) established the camera rides on the
display assembly and is priced as one. New here: Apple Diagnostics returns `NDC001`–`NDC006` for a
camera fault, so the camera is covered by the diagnostics run as well as by Photo Booth — but only
Photo Booth also proves the **microphone**, which lives in the top case, a different part. Keep both.

**Liquid damage — the buyer cannot see it.** Apple publishes *About liquid damage to Mac computers
and accessories* (<https://support.apple.com/en-us/102249>, published 2025-11-04) confirming liquid
damage is not covered by warranty. But the liquid contact indicators on Apple-silicon MacBooks are
**internal**; iFixit Answers threads asking where they are answer with internal locations only
(<https://www.ifixit.com/Answers/View/710311/>, 2021-10-28). **Nothing is visible to a buyer without
opening the machine.** This belongs in the README's "what the script cannot see" section, not in the
checks.

**Board-level faults.** [#13](https://github.com/mingrath/mbcheck/issues/13) pinned the Thai
economics (board micro-repair ฿4,000–12,000; full swap UNPINNED; a replaced logic board shows
`Unverified`). Apple Diagnostics adds signatures a buyer can read but cannot otherwise test:
`PFM001`–`PFM007` (SMC), `PPN001/002` (power management), `PFR001` (firmware), `PPM001`–`PPM016`
(onboard memory), `PPR001` (processor). **This is the strongest single argument for adding the
diagnostics run.**

---

## Unresolved conflicts in the sources

Left visible rather than smoothed over.

1. **Two different lists of "parts Apple cares about", and they do not match.** Apple's Parts &
   Service reporting table (<https://support.apple.com/en-us/123123>, 2026-05-26) reports four parts
   on a Mac: logic board, Touch ID board, lid angle sensor (M5 only), display (MacBook Neo only).
   Apple's locked-parts article (<https://support.apple.com/en-us/120610>, 2026-04-29) names
   **battery, built-in display, front camera, Touch ID sensor** as Activation-Lockable. Neither page
   scopes the second list to a device family — 120610 is written across iPhone, iPad and Mac.
   **Consequence if the wider list applies to Macs:** a second-hand MacBook could carry a locked
   *battery* or *display*, which the guide would have to check for and which no Parts & Service row
   would surface on an Air or Pro. *To pin: first-hand observation on a Tahoe 26 Mac with a donor
   part, or an Apple statement scoped to Mac.*
2. **The lid angle sensor: reported on M5, present earlier.** Apple ticks LAS only for M5 Air and M5
   Pro in its reporting table, but a repair shop (claim tier) lists LAS calibration as required after
   screen replacement on M2-era Airs and 2021–23 Pros. **Adopted here:** the *reporting* is M5-only;
   the *hardware* is older, and the close-the-lid test is worth running on any model. *To pin: an
   Apple statement, or a teardown identifying the sensor on a pre-M5 machine.*
3. **Apple's own Wi-Fi table omits the entire M3 MacBook Pro generation.** The deployment guide lists
   MBP 14"/16" M2 2023, M4 2024, M5 2025 and M5 Pro/Max 2026 — but no Nov-2023 M3 model in any table.
   iFixit's device page independently states the base M3 14" is Wi-Fi 6E / Bluetooth 5.3. **Adopted
   here:** M3 is Wi-Fi 6E, on iFixit's authority, flagged as secondary. *To pin: the model's Apple
   tech-spec page.*
4. **Whether Apple Diagnostics' fan code covers bearing wear.** `PPF001/003/004` says only "There may
   be an issue with the fan". If it covers acoustics, the by-ear check is redundant; if not, the
   by-ear check is essential. **Adopted here: the conservative reading** — Apple does not say
   acoustics, so assume it does not test them. *To pin: a machine with a known-noisy fan and a
   diagnostics run.*
5. **Whether blooming is ever a defect.** Apple documents blooming and transitional blur as normal
   *for iPad Pro* (<https://support.apple.com/en-us/102255>, 2026-06-01) and publishes **no equivalent
   article for the MacBook Pro's Liquid Retina XDR display**, which uses the same architecture. The
   README's "even, not blotchy" test has no source behind it either way. *To pin: an Apple
   MacBook-scoped XDR article, if one exists.*
6. **Wayback sampling gaps in the service-programme sweep.** The index was sampled at June 2022, June
   2023, June 2024, June 2025 and live August 2026. A programme both created *and* expired entirely
   inside one gap would be missed. Improbable — Apple programmes typically run 3–5 years from first
   retail sale — but not excluded. *To pin: a full Wayback CDX enumeration of all captures of
   `/service-programs`.*

---

## Unpinned / could not establish

Listed so the guide author knows not to reach for a number that does not exist.

| # | Missing | Why | What would pin it |
|---|---|---|---|
| 1 | **Run time for Apple Diagnostics**, total or per targeted test on Tahoe 26 | Apple publishes none, and Tahoe 26 turned it into a menu with variable cost | Time it on a real machine. **This blocks admission under [#9](https://github.com/mingrath/mbcheck/issues/9), which budgets physical checks in minutes.** |
| 2 | **What Apple Diagnostics omits when run offline**, and whether it runs at all on a machine still signed into the seller's account | Apple offers "Run Offline" but does not say what is skipped | A real offline run at a shop |
| 3 | **Whether any non-public Apple "Quality Program" covers an M-series MacBook** | Those programmes are dealer-facing and never published | An Apple GSX or AASP service bulletin |
| 4 | **Apple's own end date and eligible-model list for the Keyboard Service Program** | The page is dead and redirects to a generic "this program has ended" notice; the archived copy timed out twice | A working Wayback capture of the programme page |
| 5 | **Incidence rate for spontaneous panel cracking**, on any model | Neither Apple nor any teardown source publishes one; the two law-firm sources allege a pattern without a rate | A court filing with discovery data, or Apple |
| 6 | **Outcome of the M1 cracked-display class action** | Followed only to Apple's motion to dismiss (2022-10) | Court docket |
| 7 | **Fan counts for the 13" MacBook Pro (M1/M2) and for M4/M5 Pro/Max** | Not verified against a teardown in this pass | iFixit device pages for each |
| 8 | **Per-chip performance-core counts** (to size the load test) | Not enumerated in this pass | Apple tech specs, or `sysctl` on each machine |
| 9 | **Any normal-vs-abnormal thermal threshold for a fanless Air** | Apple publishes no chassis temperature, throttle floor or time-to-throttle; no third-party source found one | Instrumented testing across several Airs — out of reach for this guide |
| 10 | **Apple's numeric threshold for acceptable pixel anomalies** | Apple's own page (102187) deliberately does not state it; circulating numbers trace to a 2010 leak | Apple, or an Apple Store evaluation |
| 11 | **Speaker-rattle incidence, cause, and whether it is mechanical or software** | Only forum reports, with competing explanations | A repair-industry teardown analysis, or Apple |
| 12 | **HDMI version for every model** | Apple states resolution ceilings, never a version number, anywhere | Apple would have to publish it |
| 13 | **Display prices for MacBook Air M3/M4/M5, MacBook Pro M4/M5, and the nano-texture premium** | iFixit does not list them; Apple publishes no display price at all | An AASP quote, or the Self Service Repair store (serial-gated) |
| 14 | **Standalone lid angle sensor price, any currency** | Nobody publishes one | An AASP or IRP quote |
| 15 | **Any Thai price for a 14"/16" Pro speaker, fan, or antenna bar** | [#13](https://github.com/mingrath/mbcheck/issues/13) found none; none found here | An AASP or independent quote |
| 16 | **Whether a MacBook Air offers nano-texture** | Not confirmed against a spec page in this pass | Apple tech specs for the M4/M5 Air |
| 17 | **Whether the 13" MacBook Pro (M2, 2022) 256 GB shares the single-NAND slowdown** | Reported via secondary coverage of an Apple statement; no teardown checked here | An iFixit teardown or a benchmark pair |
| 18 | **Swelling incidence, and fan bearing-wear incidence, by model** | No source quantifies either for Apple silicon | Repair-shop failure data |
| 19 | **Whether `PPT004`/`PPT006` can appear while System Information still reads Condition: Normal** | Apple's wording implies it can but never relates the two readings | A machine showing both |
| 20 | **Direct queries of CPSC / EU Safety Gate / ACCC recall databases** | Checked via search results only, not via each database's own interface | Query each database directly |

---

## Out of scope but newly named: MacBook Neo

Apple sells a laptop called **MacBook Neo**, and it is **not an M-series machine**: 13.0" Liquid
Retina (2408×1506, 219 ppi, 500 nits, sRGB), **Apple A18 Pro** (6-core CPU / 5-core GPU), 8 GB
unified memory, 256/512 GB SSD, 36.5 Wh battery, 20 W USB-C adapter, one USB 3 and one USB 2 USB-C
port plus a 3.5 mm jack, Wi-Fi 6E, Bluetooth 6, 1080p camera, 2.7 lb, Touch ID on the higher model
only. Announced **2026-03-04**, on sale **2026-03-11**
(<https://www.apple.com/macbook-neo/specs/>; Apple's environmental report `MacBook_Neo_PER_Mar2026.pdf`).
Apple's spec page showed **$699 / $799** on 2026-08-04 against a **$599** launch price in press
coverage — **the reason for the gap is UNPINNED.**

It is **out of the map's scope** (Air and Pro, M1–M5 only) and was not investigated. Two facts make
it worth a line anyway: it is **the only Mac whose display Apple reports in Parts & Service**, and it
is the cheapest new Apple laptop — so it will show up as a comparison point in the Thai second-hand
market whether or not the guide covers it.

---

## Method and tooling

Research ran as four parallel investigations — Apple service programmes and recalls; the per-model
port matrix; display, hinge and lid defects; and thermals, storage, audio, ports and board-level
faults — each instructed never to invent a figure and to stamp every claim with its source URL and
observed date.

**Tooling:** AgentKey MCP throughout — `Serper/search`, `Firecrawl/scrape`, `Tavily/extract` for bulk
tech-spec reads, and the Wayback Machine for the historical service-programme sweep. Built-in
WebSearch/WebFetch were **not** used for any claim in this document.

**Source hierarchy applied:** Apple Support and Apple deployment documentation first; iFixit
teardowns and device pages second, labelled as such; law-firm filings and investigations third,
labelled as allegations; Apple Support Communities, Reddit, MacRumors and YouTube last, always
labelled as claims and always with an indication of how widespread (thread reply counts are given
wherever they were visible).

**One error caught during synthesis and recorded so it is not reintroduced:** an early draft asserted
that no Apple-silicon MacBook before M5 *has* a lid angle sensor. Apple's table shows only that it
does not *report* one — a repair-industry source lists the hardware on M2-era Airs and 2021–23 Pros.
Reporting scope and hardware scope are different claims.

**Deliberately excluded rather than quoted unverified:** repair-shop marketing pages quoting prices
for models they do not name; YouTube "fix your crackling speakers" content, which is remedy advice
rather than evidence of a defect; the circulating "Apple dead pixel policy" numbers, which trace to a
2010 leak rather than to Apple; and any per-model reliability statistic, because no source found
publishes one.
