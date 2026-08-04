# Thai repair prices for common Apple-silicon MacBook faults

Research note resolving [issue #13](https://github.com/mingrath/mbcheck/issues/13).
Feeds the 💰 **Renegotiate** grade defined in [issue #10](https://github.com/mingrath/mbcheck/issues/10),
which requires every renegotiate finding to carry a real Thai repair price with an explicit "as of" date.

**Research date: 2026-08-04.** Every figure carries its own observed date. Where a source page carries no
publication date, that is stated rather than glossed.

---

## ⚠️ Corrections this research forces on the current README

| # | README says | Reality | Where |
|---|---|---|---|
| 1 | "genuine Apple battery for **฿6,990**" (16" M1 Pro) | **฿8,690.** ฿6,990 is Apple TH's **15" MacBook Air** price — a model named in the same sentence. Entered in commit `63d6340` with no citation. | [Battery](#battery-replacement) |
| 2 | "a replacement [140W] is **~฿3,000**" | **฿3,190** at Apple TH; ฿2,890–2,990 at authorised resellers. **And the adapter ships with no cable** — a full kit is ฿4,780. | [Charger](#charger--power-adapter) |
| 3 | Parts & Service has **four** states | **Five.** `Unverified` and `Finish Repair` are missing. `Unverified` is what a replaced logic board usually shows. | [Parts & Service](#parts--service-history--what-actually-sets-the-flag) |
| 4 | "**Unknown** = non-genuine part. Walk away." | Only **four components are tracked** — logic board, Touch ID board, M5 lid angle sensor, MacBook Neo display. A battery, screen, keyboard, speaker, fan or port board swapped by an independent produces **no `Unknown` row**. | [Parts & Service](#parts--service-history--what-actually-sets-the-flag) |
| 5 | "An **Unknown** flag is permanent… you cannot undo it" | **Not established.** Apple says *"only the most recent service appears"*, implying supersession, and never uses the words permanent or irreversible. | [Resale](#resale-impact) |
| 6 | Accepts "macOS **Sequoia 15** or Tahoe 26" | Parts & Service **requires Tahoe 26**. On Sequoia, Step 4's flag check cannot run at all. | [Reach problem](#️-reach-problem-the-pane-needs-macos-tahoe-26) |
| 7 | Fan stress test framed as universal; "total silence" = worst case | **Every MacBook Air M1–M5 is fanless.** On an Air, silence is the correct result. | [Fan](#speaker-camera-microphone-fan) |
| 8 | Photo Booth tests "camera + mic" as one check | **Different parts, different prices.** The camera rides on the **display assembly** (฿10,300–18,600); the mic is in the **top case**. | [Camera/mic](#camera-rides-on-the-display-the-microphone-does-not) |

---

## Summary table — what each fault costs in Thailand

Read the per-category sections before quoting any of these; several carry material caveats.
**"Apple TH" figures are pre-VAT unless noted; AASP figures include VAT 7% — do not compare directly.**

| Fault | Model scope | Apple / AASP THB | Independent THB | Observed | Part availability | Sets `Unknown`? |
|---|---|---|---|---|---|---|
| **Battery** | MBA 13" M1–M3 | **฿5,590** | ฿2,800–4,800 | 2026-08-04 | in guaranteed support | **No** |
| Battery | MBA 13" M4/M5 | **฿6,290** | UNPINNED | 2026-08-04 | in support | No |
| Battery | MBA 15" M2–M5 | **฿6,990** | ฿4,590–5,500 | 2026-08-04 | in support | No |
| Battery | MBP 14" M5 family | **฿7,990** | UNPINNED | 2026-08-04 | in support | No |
| Battery | MBP 13" M1/M2; 14"/16" M1 Pro–M4; 16" M5 | **฿8,690** | ฿3,500–6,800 | 2026-08-04 | in support | No |
| **Display** | MBA 13"/15", all | not published (`—`) | ฿10,300–17,900 | 2026-08-04 | 2–4 hrs, 3–5 days if ordered | **No** (Air/Pro) |
| Display | MBP 14"/16" **mini-LED XDR** | not published (`—`) | **฿17,990–18,990** | 2026-08-04 | 1–3 days | **No** (Air/Pro) |
| Display | MBP 14"/16" **M5** | not published | **UNPINNED** | — | — | No |
| Display — AppleCare+ accidental | All MBA/MBP M1–M5 | **฿3,300** (ADH Tier 1) | n/a | 2026-08-04 | — | No |
| **Thunderbolt port won't charge** | All M1–M5 | not published (`—`); ฿10,000 w/ AppleCare+ | **฿1,500–3,500** | 2026-01-22 / 2026-05 | port flex ฿650–750 | **No** |
| Won't power on / board micro-repair | All M1–M5 | not published | ฿4,000–12,000 | 2026-05-06 | — | **Logic board = Yes** |
| Full logic-board swap, Apple silicon | Any M1–M5 | not published | **UNPINNED** | — | no 14" Pro boards in TH stock | **Yes** (`Unverified`) |
| **Top case / keyboard** | MBA 13" M1–M3 | **฿6,190** + ฿1,605 | ฿3,500–5,500 | list effective 2023-11-01 | — | No |
| Top case / keyboard | MBA 15" M2/M3 | **฿7,490** + ฿1,605 | UNPINNED | 2023-11-01 | — | No |
| Top case / keyboard | MBP 13" M1/M2, 14"/16" 2021–23 | **฿9,490** + ฿1,605 | UNPINNED | 2023-11-01 | — | MBP 2020/2022 only |
| Top case / keyboard | Any M4 / M5 | **UNPINNED** — list predates them | UNPINNED | — | — | — |
| **Speaker** | MBA 13" M1 | UNPINNED | ฿4,000 / pair | undated page | in stock | **No** |
| Speaker | MBP 13" M1 | UNPINNED | ฿4,500 / pair | undated page | InStock | No |
| Speaker | MBP 14"/16"; MBA M2–M5 | UNPINNED | **UNPINNED** | — | — | No |
| **Camera** | All Apple silicon | UNPINNED | priced as a **display assembly** | — | — | No |
| **Microphone** | All Apple silicon | UNPINNED | **UNPINNED** — in the **top case** | — | — | No |
| **Fan** | **All MacBook Air M1–M5** | **N/A — fanless** | N/A | — | — | N/A |
| Fan | All Apple-silicon MBP | UNPINNED | **UNPINNED** | — | — | **No** |
| Fan clean + paste (not replacement) | unspecified | — | ฿1,000–2,000 | 2026-05-06 | same-day | No |
| **Charger 30W** | MBA 13" M5 base | **฿1,190** | ฿1,170–1,190 | 2026-08-04 | retail stock | n/a |
| Charger 35W dual | MBA 13"/15" M5 | **฿1,890** | ฿1,690–1,890 | 2026-08-04 | retail | n/a |
| Charger **67W** | — | **does not exist — discontinued** | — | 2026-08-04 | — | n/a |
| Charger 70W | MBP 14" M5 | **฿1,890** | ฿1,790–1,890 | 2026-08-04 | retail | n/a |
| Charger 96W | MBP 14" M5 Pro/Max | **฿2,490** | ฿2,290–2,490 | 2026-08-04 | retail | n/a |
| **Charger 140W** | **MBP 16", all configs** | **฿3,190** | ฿2,890–2,990 | 2026-08-04 | retail | n/a |
| MagSafe 3 cable (needed with any adapter) | all MBA/MBP | **฿1,590** | ฿1,590 | 2026-08-04 | retail | n/a |

---

## Battery replacement

Apple Thailand publishes per-model Mac battery service prices **openly — no serial number, no login required**.
This is the one repair category where a hard Apple number is obtainable.

- Rendered page: <https://support.apple.com/th-th/mac-laptops/repair?services=service>
- Live pricing API (unauthenticated GET, re-pullable):
  `https://support.apple.com/ols/api/pricing/products/services/pricing-estimate?locale=th-th&pricing_type=OOW&parent_tag_id=TAG_1753920674365`
  (AppleCare+ variant: `pricing_type=AC%2B`)

Apple's own line item is **"บริการเกี่ยวกับแบตเตอรี่"** (battery service).
**Under AppleCare+ the price is ฿0 on all 28 models.**

Neither page carries any publication date — prices are served live from the API, so **2026-08-04 is the only
date of record** for every Apple figure in this section.

| Model / variant | Apple TH (out-of-warranty) | Independent THB | Observed | Sets `Unknown`? |
|---|---|---|---|---|
| MacBook Air 13" M1 (2020) | **฿5,590** | ฿2,800–4,800 | 2026-08-04 | No |
| MacBook Air 13" M2 (2022) | **฿5,590** | ฿2,800–4,800 | 2026-08-04 | No |
| MacBook Air 13" M3 (2024) | **฿5,590** | ฿2,800–6,500 | 2026-08-04 | No |
| MacBook Air 13" M4 (2025) | **฿6,290** | UNPINNED | 2026-08-04 | No |
| MacBook Air 13" M5 (2026) | **฿6,290** | UNPINNED | 2026-08-04 | No |
| MacBook Air 15" M2 (2023) | **฿6,990** | ฿4,590–5,500 | 2026-08-04 | No |
| MacBook Air 15" M3 (2024) | **฿6,990** | contradictory | 2026-08-04 | No |
| MacBook Air 15" M4 (2025) | **฿6,990** | UNPINNED | 2026-08-04 | No |
| MacBook Air 15" M5 (2026) | **฿6,990** | UNPINNED | 2026-08-04 | No |
| MacBook Pro 13" M1 (2020) | **฿8,690** | ฿2,900–5,800 | 2026-08-04 | No |
| MacBook Pro 13" M2 (2022) | **฿8,690** | ฿3,190–3,900 | 2026-08-04 | No |
| MacBook Pro 14" 2021 (M1 Pro/Max) | **฿8,690** | ฿4,500–6,800 | 2026-08-04 | No |
| MacBook Pro 14" M2 Pro/Max (2023) | **฿8,690** | ฿4,500–6,800 | 2026-08-04 | No |
| MacBook Pro 14" M3 (2023) | **฿8,690** | ฿4,590–6,800 | 2026-08-04 | No |
| MacBook Pro 14" M4 (2024) | **฿8,690** | UNPINNED | 2026-08-04 | No |
| MacBook Pro 14" M5 (2025) | **฿7,990** | UNPINNED | 2026-08-04 | No |
| MacBook Pro 14" M5 Pro/Max (2026) | **฿7,990** | UNPINNED | 2026-08-04 | No |
| **MacBook Pro 16" 2021 (M1 Pro/Max)** | **฿8,690** | ฿3,500–6,800 | 2026-08-04 | No |
| MacBook Pro 16" M2 Pro/Max (2023) | **฿8,690** | ฿4,500–6,800 | 2026-08-04 | No |
| MacBook Pro 16" M3 Pro/Max (2023) | **฿8,690** | ฿4,790–6,800 | 2026-08-04 | No |
| MacBook Pro 16" M4 (2024) | **฿8,690** | UNPINNED | 2026-08-04 | No |
| MacBook Pro 16" M5 Pro/Max (2026) | **฿8,690** | UNPINNED | 2026-08-04 | No |

**Model lineup, verified not assumed** (Apple TH <https://support.apple.com/th-th/108052>, published
16 ก.ค. 2569 = 2026-07-16; <https://support.apple.com/th-th/102869>, published 10 ก.ค. 2569):
MacBook Air M5 exists in both 13" and 15" (2026). The 16" MacBook Pro has **never** shipped with a base
M2/M3/M5 chip — Pro/Max only — and there is no 14" with a base M1. Apple TH does not split M1 Pro from
M1 Max; both are one entry, "MacBook Pro (16 นิ้ว, ปี 2021)".

### Independent-shop sources

| Shop | URL | Page date |
|---|---|---|
| HardwareHot | <https://www.hardwarehot.com/content/battery-macbook/> | 2026-07-09 |
| TRUE IT | <https://www.trueit.co.th/content/10763/> | 2026-05-06 |
| Smartzone TH | <https://smatzoneth.co.th/replace-macbook-battery/> | 2025-12-26 |
| BBMacService | <https://www.bbmacservice.com/post/macbook-battery-replacement-price> | 2025-09-07 |
| Freedom Computer | <https://www.freedomcomputerservice.net/battery-macbook/> | undated |

**Every independent shop found is fitting aftermarket cells, not genuine Apple batteries.** HardwareHot
answers its own FAQ explicitly: "ใช้แบตเตอรี่ของเทียบคุณภาพสูง" (high-quality *equivalent* battery).
TRUE IT says "คัดเลือกเกรดสูง" (selected high grade). BBMacService says "แท้หรือเกรดพรีเมียม" — ambiguous.
Any sub-฿8,690 claim of a "genuine" battery should be treated as unverified.

Two independent sources are internally inconsistent and are flagged rather than relied on: BBMacService
carries two different price tables on one page, and Smartzone prices M3 above M4 with model numbers left
as "????".

### Caveats

**Apple's price does not bind AASPs.** Apple states plainly: "ผู้ให้บริการที่ได้รับอนุญาตจาก Apple
สามารถกำหนดค่าธรรมเนียมการให้บริการของตนเองได้" — authorised providers set their own fees. The one AASP
sheet located (iStudio by Copperwired, <https://www.istudio.store/pages/iserve-service-fee>) quotes
MacBook Air ฿6,600 and Apple-silicon MacBook Pro ฿9,600, each **plus a separate ฿1,284 service fee** —
materially above Apple's own ฿8,690. That table is delivered as an image with **no on-page date**; the only
date signal is the asset filename `20240328-iserve-service-fee-37.jpg` (2024-03-28). Treat as stale.

**VAT is ambiguous.** Apple's Thai wording is "ค่าธรรมเนียมการให้บริการโดยประมาณ...จะต้องเสียภาษีมูลค่าเพิ่ม"
— "is subject to VAT". This does not say whether ฿8,690 includes or excludes it. Do not state either.

**Standalone battery or top case?** Two different answers by channel. To a *customer*, Apple bills a flat
"battery service" and the phrase "top case" appears nowhere on the consumer pricing pages. But the genuine
*part* Apple sells for a 2021 16" is the assembly: "Top Case with Battery and Keyboard, Space Gray —
**US$615.12**" (less US$88.00 return credit), at
<https://selfservicerepair.com/en-US/macbook-pro-16-inch-2021/top-case-with-battery-and-keyboard>, undated.
**That is a USD reference only — Self Service Repair is not available in Thailand** (the country selector
lists US, UK, Canada and EU/EEA-and-neighbours only). Apple's footnote there: "The Top Case replacement part
includes a battery. In the future, a battery replacement part will be available." Apple is moving to a
discrete battery part — "Parts Support for MacBook Pro"
(<https://support.apple.com/en-us/123921>, published 2026-03-11) lists Battery as its own row, checked only
for the M5 family. The near-flat ฿8,690 across every Apple-silicon MacBook Pro is *consistent* with a
top-case assembly, but no page states that, so it is not asserted here.

**Turnaround.** Apple TH publishes **no** turnaround time for Mac battery service. At policy level
(<https://support.apple.com/th-th/102772>, published 16 มิ.ย. 2569 = 2026-06-16) parts are available at least
5 years after last distribution, up to 7. No Apple-silicon Mac is listed vintage or obsolete, so a 2021 16"
is comfortably inside guaranteed parts support. Independents quote hours, not days: HardwareHot 1–2 hrs,
TRUE IT 2–3 hrs, BBMacService 1–3 hrs. Warranty: Apple 90 days or the remainder of the Apple warranty;
independents 6 months to 1 year.

---

## Display assembly

### Apple Thailand publishes no out-of-warranty display price at all

Apple's Thai Mac repair page prints a literal em-dash — "ความเสียหายอื่นๆ **—**" — for every non-battery
out-of-warranty repair, with the footnote *"เราจะต้องตรวจสอบผลิตภัณฑ์ของคุณเพื่อประมาณค่าใช้จ่ายให้คุณโดยตรง"*
("We'll need to inspect your product to provide a personalised estimate"). **There is no published Apple TH
display price.** Everything Apple-side below is an AppleCare+ *service fee*, which is a different thing.

| What it covers | Model scope | THB | Date | Source |
|---|---|---|---|---|
| AppleCare+ **ADH Tier 1** — screen-only *or* enclosure-only damage | All MacBook Air & Pro M1–M5 | **฿3,300** | no page date; observed 2026-08-04 | [A1] |
| AppleCare+ **ADH Tier 2** — all other accidental damage | Same | **฿10,000** | no page date; observed 2026-08-04 | [A1] |
| AppleCare+ battery service | Same | **฿0** | observed 2026-08-04 | [A2] |
| **Out-of-warranty display replacement** | All MacBook Air/Pro | **not published — Apple prints "—"** | observed 2026-08-04 | [A2] |
| AASP generic Mac service fee, added on top | All Mac laptops | **฿1,605** | no page date | [A3] |

[A1] <https://www.apple.com/th/legal/sales-support/applecare/applecareplus/docs/applecareplusmac_th_tc.html>
— Apple's Thai AppleCare+ for Mac terms. Verbatim: `กรณีการให้บริการ ADH ระดับ 1 · ความเสียหาย ADH
เฉพาะหน้าจอ · ADH เฉพาะตัวเครื่องภายนอก → ฿3,300` and `กรณีการให้บริการ ADH ระดับ 2 · ความเสียหาย ADH
อื่นๆ ทั้งหมด → ฿10,000`. Fees are **inclusive of tax** (*"ค่าธรรมเนียมจะรวมภาษี"*).
[A2] <https://support.apple.com/th-th/mac-laptops/repair?services=service> ·
[A3] <https://www.istudiobyspvi.com/pages/icenter-pricelist>

> ⚠️ **Do not use ฿1,590 / ฿4,990 for any M1–M5 MacBook.** Those are **MacBook Neo** AppleCare+ figures — a
> different, cheaper product line — and are easy to read off Apple's support widget by accident with the model
> selector parked on Neo. This error was caught and corrected during verification.

**Accidental vs not-accidental — Apple TH draws the line explicitly:** *"การรับประกันของเราไม่ครอบคลุมความ
เสียหายจากอุบัติเหตุ"* [A2]. Cracked panel / drop damage = accidental → ฿3,300 with AppleCare+. **Dead pixels,
backlight failure and mini-LED blooming are manufacturing defects** → free under warranty, or an unpublished
quote-on-inspection out of warranty.

Two further AppleCare+ constraints that matter commercially: ADH service **expires after two service
incidents** (clause 2.2), and clause 3.1(h) voids Apple hardware warranty *and* ADH service entirely if the
machine *"ถูกแกะเครื่อง ซ่อม… โดยผู้ใดก็ตามที่นอกเหนือจาก Apple หรือตัวแทนที่ได้รับอนุญาตจาก Apple"* — opened
or repaired by anyone other than Apple or an authorised agent. **A prior independent repair kills AppleCare+
coverage.** That is a resale-relevant fact independent of any parts flag.

### Independent shops — pinned figures

Two Thai shops publish real model-by-model matrices. They disagree meaningfully on the 14" Pro.

| Model / variant | Panel | Assembly (ยกใบ) THB | Panel only THB |
|---|---|---|---|
| MBA 13" M1 (A2337) | LCD | 12,500 [I2] · 16,900 / 14,500 [I1] | 7,500 [I2] · 7,990 / 7,590 [I1] |
| MBA 13" M2 (A2681) | LCD | 10,300 [I2] · 13,900 [I1] | 7,900 [I2] · 9,990 [I1] |
| MBA 13" M3 (A3113) | LCD | 12,700 [I2] · 13,900 [I1] | 7,900 [I2] · 9,990 [I1] |
| MBA 13" M4 (A3240) | LCD | 12,700 [I2] · 16,900 [I1] | 9,900 [I2] · 12,900 [I1] |
| MBA 15" M2/M3 (A2941/A3114) | LCD | 13,900 [I2] · 11,900–13,900 [I1] | 9,900 [I2] · 11,900 [I1] |
| MBA 15" M4 (A3241) | LCD | 17,900 [I1] — single-sourced | 12,900 [I1] |
| MBA 13"/15" M5 (A3449/A3448) | LCD | 16,900 / 17,900 [I1] | 12,900 [I1] |
| **MBP 14" M1 Pro/Max–M3** (A2442/A2779/A2918) | **mini-LED XDR** | **18,600 [I2] · 17,990 [I1]** | 15,600 [I2] · 16,900 / 14,990 [I1] |
| **MBP 14" M4** (A3112) | **mini-LED XDR** | **18,600 [I2]** | 15,600 [I2] · 16,900 [I1] |
| **MBP 16" M1–M3** (A2485/A2780/A2991) | **mini-LED XDR** | **18,300 [I2] · 18,990 [I1]**; A2485 26,990 [I1] | 14,900–15,600 [I2] · 16,900 [I1] |
| **MBP 16" M4** (A3403/A3186) | **mini-LED XDR** | not published | 17,900 [I1] |
| **MBP 14"/16" M5** | **mini-LED XDR** | **UNPINNED — no shop publishes a price** | — |

[I1] **BBmacservice** (Ramkhamhaeng/Rangsit),
<https://www.bbmacservice.com/post/macbook-screen-replacement-price> — **date on page 2025-09-07**, though the
title claims 2026 and it lists M5 models, so it has been edited since. ⚠️ **This page contradicts itself** —
two price blocks give different numbers for the same models (both reproduced above where they differ).
[I2] **HardwareHot** (Ngamwongwan, Nonthaburi), <https://www.hardwarehot.com/content/screen-macbook/> — **page
body carries no date**; HTML metadata says 2023-05-01 but it lists M4 parts, so it has been updated silently.
Explicitly **จอแท้ (genuine)** throughout. 6-month warranty, 2–4 hrs turnaround, **3–5 days if the part must be
ordered**.

Weaker sources, ranges only, all self-declared approximations: Galaxy M.Fixit
(<https://galaxy-mfixit.com/macbook-repair-bangna/>, metadata 2026-05-18) quotes ฿6,000–12,000 for a
"MacBook Pro 13/14" screen — far below everyone else, almost certainly panel-only or copy parts, but **the
page does not say**. Dr. MacBook (<https://drmacbook.com/ซ่อม-macbook-คุ้มไหม/>, metadata 2026-05-06) quotes
฿5,000–18,000 across all models, labelled *"ราคาโดยประมาณสำหรับกรุงเทพฯ"*. Freedom Computer
(<https://www.freedomcomputerservice.net/service/screen-macbook/>, **no date at all**) splits ORIGINAL vs OEM
but stops at M2.

### The mini-LED premium, quantified

Macparts (Thai parts importer, wholesale to shops), observed 2026-08-04, **pages carry no date**:
<https://www.macparts.in.th/category/a-lcd-display-จอไส้ใน/239> — **14" XDR panel ฿13,900** versus
**13" MacBook Air panel ฿5,000**. Same vendor, same page, same day: **a ~2.8× part-cost gap.** 16" M1 A2485
panel ฿22,000. Assemblies at <https://www.macparts.in.th/category/a-display-assembly-จอยกหัว/172> — 14"
฿17,000 OEM / ฿19,000 non-OEM; 16" M1 A2485 ฿25,500.

**No Thai shop page anywhere labels its 14"/16" prices as "mini-LED" or "XDR", or explains the premium in
words.** It is visible only in the numbers. Note also that HardwareHot's ฿18,600 for a 14" assembly sits
*below* Macparts' ฿17,000–19,000 part cost — near-zero or negative margin, so that figure is either stale or
sourced elsewhere. Press on it.

---

## Logic-board and port faults

### Headline: Thunderbolt ports are NOT soldered to the logic board

On every Apple-silicon MacBook verified, the USB-C / Thunderbolt ports sit on small separate boards that
Apple sells as individual service parts for **US$12–14**. This holds for both the Air and the 14"/16" Pro.
**A dead port is a cheap sub-board swap, not a logic-board replacement.**

The naming differs by generation. The **M1 MacBook Air (2020, A2337)** uses a single **"Input/Output Board"**
carrying both left-side ports — Apple part 923-03553, US$14.00. Every later model uses per-port **"USB-C
Boards"** — e.g. MBA M2 923-07252/3/4/5, MBA 13" M3 923-10325–28, MBA 15" M4 923-12438–41, **MacBook Pro 14"
and 16" (2021) both 923-06760 at US$12.00** (one identical part in all three port positions, on both sizes),
MacBook Pro 14" M5 923-13410. **These USD figures are US Self Service Repair store prices, reference-only —
Self Service Repair is not available in Thailand, and they are deliberately not converted.**

Primary evidence is Apple's own repair manuals, where `USB-C Boards` (or `Input/Output Board`) appears in the
Procedures list as a **standalone repair, entirely separate from the `Logic Board` procedure**. Verified
manual tables of contents with Apple's published dates: MBA 13" M1 <https://support.apple.com/en-us/100586>
(2025-04-08) · MBA 13" M2 <https://support.apple.com/en-us/100603> (2025-04-08) · MBA 15" M2
<https://support.apple.com/en-us/104029> (2025-04-08) · MBA 13" M3 <https://support.apple.com/en-us/119579>
(2025-12-10) · MBA 13" M4 <https://support.apple.com/en-us/122003> (2025-12-10) · MBA 15" M4
<https://support.apple.com/en-us/121977> (2026-03-02) · **MBP 14" M1 Pro/Max
<https://support.apple.com/en-us/100549>** (2025-04-08) · **MBP 16" M1 Pro/Max
<https://support.apple.com/en-us/100568>** (2025-04-08) · MBP 14" M2 Pro/Max
<https://support.apple.com/en-us/102712> (2025-04-08) · MBP 14" M3 <https://support.apple.com/en-us/118618>
(2025-12-10) · MBP 14" M4 Pro/Max <https://support.apple.com/en-us/121126> (2025-12-10) · **MBP 14" M5
<https://support.apple.com/en-us/123173>** (2025-12-16).

The troubleshooting entry that routes there is titled *"USB-C, Thunderbolt, and HDMI issues"* in every one of
those manuals — Apple's own prescribed answer to a dead Thunderbolt port is **replace the sub-board**.

iFixit corroborates independently. **M2 MacBook Air teardown**, dated **2022-07-19**,
<https://www.ifixit.com/News/62674/m2-macbook-air-teardown-apple-forgot-the-heatsink>: *"Even better, every
single port—the endangered headphone jack, prodigal MagSafe charger, and both USB-C ports—are modular, and not
glued down."* For the Pro there is a dedicated guide, **"MacBook Pro 14-Inch 2021 USB-C Ports Replacement"**,
<https://www.ifixit.com/Guide/MacBook+Pro+14-Inch+2021+USB-C+Ports+Replacement/150905> (undated): *"Use this
guide to replace one or all of the USB-C ports in your MacBook Pro 14" 2021"* — confirming **all three
Thunderbolt ports** are on removable boards. iFixit's 2026 scorecard lists as a PRO for the MacBook Pro 14"
M5: *"The Thunderbolt port design is highly modular and repair-friendly"*.

**MagSafe 3 and the audio board are likewise separate procedures and parts** in every manual that has them.
**HDMI and SDXC are not** — no separate board procedure exists in any 14"/16" manual read, so those are
inferred to sit on the logic board. *That last point is inference from the absence of a procedure, not an
affirmative Apple statement.*

Seven model variants were **inferred rather than directly verified** (MBA 15" M3; MBP 16" M2 Pro/Max 2023;
MBP 14" M3 Pro/Max; MBP 16" Nov 2023; MBP 14" M4 non-Pro; MBP 16" M4; MBP 14"/16" M5 Pro/Max). All 12 manuals
actually opened list the identical `USB-C Boards` procedure and sibling 14"/16" models share one part number,
so the inference is strong — but it is inference.

### Prices

| Fault | Model scope | Apple/AASP THB | Independent THB | Date | Source |
|---|---|---|---|---|---|
| TB/USB-C won't charge — AppleCare+, accidental | All M1–M5 | **฿10,000** (ADH Tier 2) | — | no page date | [A1] |
| TB/USB-C won't charge — out of warranty | All M1–M5 | **not published — "—"** | — | observed 2026-08-04 | [A2] |
| Charge port dead — board-level fix | MBA M1 | — | **฿2,500–3,500** | **2026-01-22 on page** | [B1] |
| Charging/USB-C port dead — "ซ่อมเฉพาะจุด" | All incl. M1–M4 | — | **฿1,500–3,000** | metadata 2026-05-18 | [B2] |
| Charging port (USB-C or MagSafe) | All | — | **฿1,500–3,500** (approximate) | metadata 2026-05-06 | [B3] |
| Won't power on — board-level micro-repair | MBA M1 | — | **฿5,500–6,900** | **2026-01-22 on page** | [B1] |
| Logic board, localised fault — micro-repair | All | — | **฿4,000–12,000** (approximate) | metadata 2026-05-06 | [B3] |
| Liquid damage — board clean + IC repair | All | — | **฿2,000–8,000** | metadata 2026-05-18 | [B2] |
| Logic board repair, starting range | All | — | ฿4,500–8,500 | ⚠️ metadata **2016-01-07** — 10 years stale | [B4] |
| Board swap vs board repair | MBP 13" 2019 **(Intel — not Apple silicon)** | — | ฿23,900 swap vs ฿6,500–8,500 repair | no page date | [B5] |
| **Full board swap, Apple silicon** | Any M1–M5 | not published | **UNPINNED** | — | — |
| **Dead TB *data* port, charging still works** | Any M1–M5 | not published | **UNPINNED — nobody prices this** | — | — |

[B1] <https://www.bbmacservice.com/post/macbook-air-m1-can-not-turn-on> — best-dated Apple-silicon port figure
found; page says "โดยประมาณ" · [B2] <https://galaxy-mfixit.com/macbook-repair-bangna/> ·
[B3] <https://drmacbook.com/ซ่อม-macbook-คุ้มไหม/> ·
[B4] <https://www.hardwarehot.com/content/repair-notebook-macbook/> · [B5] <https://www.bbmacservice.com/macbook>

**Part-cost floor:** USB-C charging port flex,
<https://www.macparts.in.th/category/usb-c-charging-port-flex-cable/389> — **฿650–750** for every
Apple-silicon model (A2337, A2681, A2941, A2338, A2442/A2485/A2779/A2780, A2991/A2992). Full logic boards,
<https://www.macparts.in.th/category/macbook-air-13-inch/223> — MBA M1 A2337 board **฿14,500** (no Touch ID) /
**฿17,500** (with Touch ID). **The MacBook Pro 14" logic-board category is empty**
("ไม่พบสินค้าที่ค้นหา") — Thailand's main parts importer stocks no 14" Pro boards at all, which is why every
shop pushes board-level repair on those models.

**Caveat worth stating plainly:** no Thai shop page states the port architecture for any model, and no Thai
source distinguishes a charging-port fault from a Thunderbolt data-line fault. **The Thai market prices
"ชาร์จไม่เข้า" (won't charge) and nothing else.** The README's Step 2 test — plug the charger into each port —
maps onto the one fault Thailand actually prices.

---

## Keyboard / top-case assembly

### Headline: the keyboard is not an orderable part on any M1–M5 MacBook

Apple states the reason itself. MacBook Air (M1, 2020), <https://support.apple.com/en-us/100602>
(published 2023-12-04): *"The top case includes the following nonremovable parts: **Keyboard / Microphone**"*.
MacBook Pro (14-inch, 2021), <https://support.apple.com/en-us/100566> (published 2025-09-15):

> **"Warning: The battery is part of the top case. Don't attempt to remove the battery from the top case."**
> … "The top case includes the following nonremovable parts: **Battery and BMU board / Keyboard and keyboard
> flex cable / Microphone / Speakers**"

Apple sells keycaps and scissor mechanisms only, and that document ends: *"If a keycap replacement doesn't
resolve the issue, **replace the top case**."* (<https://support.apple.com/en-us/101268>, published
2025-12-10). iFixit gives the mechanism — the keyboard is *"riveted to the top case in most models"*
(<https://www.ifixit.com/Troubleshooting/Mac_Laptop/MacBook+Keyboard+Not+Working/505002>, undated), and its
2026 scorecards say of both the MacBook Pro 14" M5 and the Air M4 that *"the keyboard is riveted down"*
(<https://www.ifixit.com/repairability/laptop-repairability-scores>, page date 2026-08-04).

### The battery-bundling question splits Air from Pro

This is the opposite of the common summary and matters for pricing:

| Line | Apple's exact part-name string | Battery in that SKU? |
|---|---|---|
| MacBook **Air**, M1→M5 | "Top Case with Keyboard" | **No** — Apple sells a separate Battery |
| MacBook **Pro**, M1→M4 | "Top Case with Battery and Keyboard" | **Yes** — no standalone battery sold |
| MacBook **Pro**, M5 generation | "Top Case with Battery and Keyboard" | Yes, **but Apple now also sells a standalone Battery** (661-55016) |

Evidence: Air M1 exploded view (<https://support.apple.com/en-us/100587>) lists *"7. Battery — 661-16086"*
and separately *"19. Top case with keyboard — 661-16831"*. MacBook Pro 14" 2021
(<https://support.apple.com/en-us/100550>, published 2025-02-04) lists *"31. Top case with battery and
keyboard — 661-21972"* and **no battery line item**. MacBook Pro 14" M5
(<https://support.apple.com/en-us/123176>, published 2026-03-11) lists **both** *"12. Battery — 661-55016"*
and *"28. Top case with battery and keyboard"*.

**Does a keyboard fault therefore cost the same as a battery fault in Thailand? In practice yes, for both
lines** — not because the Air SKU bundles a battery (it doesn't), but because the Thai authorised channel
bills one exchange for both. iStudio by SPVi's iCenter list has a column headed *"ค่าธรรมเนียมการให้บริการ
แบตเตอรี่ / Exchange Fee"* whose footnote reads verbatim: *"+ ราคานี้เป็นการซ่อมแลกเปลี่ยนชิ้นส่วน (Exchange
Part) เฉพาะคีย์บอร์ดภาษาไทย หรือ US/UK เท่านั้น / Exchange price for TopCase with Thai or US/UK Keyboard
only"*. One price, labelled battery, footnoted top-case-with-keyboard.

**Flagged as strongly indicated, not fully pinned** — the page never says a keyboard-only fault bills at that
rate.

### AASP top-case / keyboard prices

Source: <https://www.istudiobyspvi.com/pages/icenter-pricelist>, **effective 01/11/2023 as stated on the
page**. Figures **include VAT 7%** — do not compare directly against Apple's pre-VAT numbers.

| Model scope | AASP exchange | + service fee | Sets `Unknown`? |
|---|---|---|---|
| Air 13" M1/M2/M3 | **฿6,190** | ฿1,605 | No |
| Air 15" M2/M3 | **฿7,490** | ฿1,605 | No |
| MBP 13" M1/M2, 14"/16" 2021–2023 | **฿9,490** | ฿1,605 | ⚠️ MacBook Pro **2020 & 2022 only** → yes (Touch Bar top case) |
| Any **M4 / M5** model | **UNPINNED** — the list predates them | — | — |

Mac labour / inspection fee at uFicon: **฿1,605** (<https://www.uficon.com/imedic/service-charge/>, section
dates 2025-12 → 2026-06).

### Independent keyboard prices

| Scope | THB | Source | Page date |
|---|---|---|---|
| Keyboard replacement, installed — MBP 13" M1 (A2338), Air 13" (A2337) | **฿3,500** | [Freedom Computer](https://freedomcomputerservice.net/service/apple/keyboard-macbook/) | undated; "รอรับได้เลย" (wait & collect) |
| Keyboard replacement, installed — A2337 / A2338 | **฿5,500** | [Smile IT](https://smileitservice.com/macbookrepairhuaikhwang) | undated; image filenames imply ~2023-06, **possibly stale** |
| Keyboard installed — MBP 16" A2485 | ⚠️ ฿2,500 — implausible against a ฿6,850 part cost; **reported verbatim, treat as a listing error** | Smile IT | undated |
| Air M2/M3/M4/M5, all MBP 14"/16" M2→M5 | **UNPINNED** — no Thai shop publishes one | — | — |

Parts-only prices for reference: top cases at [MacParts](https://macparts.in.th/category/top-case-case-d/253)
— A2337 ฿5,750 · A2681 ฿6,000 · A2338 ฿4,750 · A2442 ฿6,850 · A2485 ฿6,850, all listed "with Keyboard",
**no battery**. Bare keyboard assemblies at [HardwareHot](https://hardwarehot.com/c/kb-mac) — ฿1,600–2,550.

**Caveat: Thai shops are not buying Apple's bundled part.** MacParts' Apple-silicon top cases all read "with
Keyboard" only, while the same vendor's Intel SKUs explicitly read "with Keyboard **Battery**" (A1708 ฿6,500)
and "with Keyboard **Battery Speaker**" (A1707 ฿9,500). Bare keyboards are sold separately, so Thai shops
de-rivet and swap the keyboard alone — a procedure Apple provides no instructions for.

### Two hard facts for a Thai owner

- **Self Service Repair does not operate in Thailand.** `support.apple.com/th-th/self-service-repair` returns
  404. The store's embedded locale config (observed 2026-08-04) lists **37 locales / 34 countries — US, Canada
  and 32 European countries, with no Asia-Pacific entry of any kind.** There is no official THB part catalogue.
- **Apple Thailand publishes no top-case price.** A search of the full raw HTML of the Thai repair page
  (1,166,639 bytes) for "฿", "THB", "บาท", "Top Case" and "แป้นพิมพ์" returned **zero occurrences**. Every
  non-battery repair renders as "—" with the footnote *"เราจะต้องตรวจสอบผลิตภัณฑ์ของคุณเพื่อประมาณค่าใช้จ่าย
  ให้คุณโดยตรง"*. This is global parity, not a Thai gap — the en-us API returns the same shape.

---

## Speaker, camera, microphone, fan

| Part / fault | Model scope | Apple/AASP THB | Independent THB | Observed | Sets `Unknown`? |
|---|---|---|---|---|---|
| Speaker, installed | Air 13" M1 (A2337) | UNPINNED | **฿4,000 / pair** | undated page, read 2026-08-04 | No |
| Speaker, part only | MBP 13" M1 (A2338) | UNPINNED | **฿4,500 / pair** (InStock, 3-mo warranty) | undated page, read 2026-08-04 | No |
| Speaker | MBP 14"/16" Apple silicon; Air M2–M5 | UNPINNED | UNPINNED | — | No |
| FaceTime camera | All Apple silicon | UNPINNED | **UNPINNED** — no Thai vendor sells an Apple-silicon camera part | — | Via display — see below |
| Microphone | All Apple silicon | UNPINNED | **UNPINNED** — no Thai shop publishes a mic price at all | — | No |
| **Cooling fan** | **All MacBook Air M1–M5** | **N/A — no fan exists** | N/A | — | N/A |
| Cooling fan, installed | All Apple-silicon MacBook Pro | UNPINNED | **UNPINNED** — service advertised, no number published | — | No |
| Fan clean + thermal paste *(not replacement)* | model-unspecified | — | **฿1,000–2,000** (shop calls it approximate) | page 2026-05-06, [Dr. MacBook](https://drmacbook.com/ซ่อม-macbook-คุ้มไหม/) | No |
| AppleCare+ incident — other accidental damage | All Apple-silicon MacBooks | **฿10,000** | — | 2026-08-04, no page date | No |

Speaker sources: [Smile IT](https://smileitservice.com/macbookrepairhuaikhwang) and
[Smile IT product page](https://smileitservice.blog/product-page/ลำโพง-macbook-pro-13-2020-m1-a2338).

### Every MacBook Air M1–M5 is fanless — do not price a fan for any Air

Apple's own words, M5 Air press release **2026-03-03**: *"Both models feature a thin, light, and **completely
silent fanless design**"* (<https://www.apple.com/newsroom/2026/03/apple-introduces-the-new-macbook-air-with-m5/>).
M4 Air press release **2025-03-05**: *"its thin and light, **fanless design**"*. M1/M2/M3 Air spec sheets list
no cooling entry at all, while Apple reserves *"active cooling system"* wording for the MacBook Pro 13" M1
(newsroom, 2020-11-10). MacBook Pros do have fans; iFixit notes they are *"straightforward to replace, just
unscrew it and disconnect one cable"*.

**This matters for the README's Step 3.** The fan stress test is a MacBook Pro check. On any Air, "total
silence" is the correct and expected result, not the most expensive failure mode.

### Camera rides on the display; the microphone does NOT

- **Camera → display assembly.** Apple's MacBook Air M1 orderable-parts list has 19 numbered parts and
  **contains no camera**; item 14 is simply *"Display — 661-16806/7/8"*, one assembly. The Thai market
  corroborates by omission: MacParts' entire iSight Camera category is eight SKUs,
  **every one pre-2013 Intel** (<https://macparts.in.th/category/isight-camera-กล้อง/140>). So a camera fault
  in Thailand is priced as a display assembly. Note that จอใน / LCD-only does **not** carry the camera — the
  ยกใบ / ยกฝา (whole-lid) column is the relevant one.
- **Microphone → top case.** Apple states it directly for both lines: the Air M1 top case includes
  nonremovable *"Keyboard / **Microphone**"*, and the MBP 14" 2021 top case includes nonremovable
  *"… **Microphone** / **Speakers**"*. **A genuine mic fault is a top-case job, not a display job** — the
  opposite of the camera. Worth stating explicitly in the guide, since Photo Booth tests both at once and the
  two failures have completely different price tags.
- **Speakers differ by line.** On the MacBook Air M1, *"8. Speakers — 923-03678"* is a **separate orderable
  part**. On the MacBook Pro 14" 2021, speakers are a **nonremovable part of the top case**. Thai shops do
  sell MBP 13" M1 (A2338) speakers standalone at ฿4,500/pair — a different chassis from the 14"/16".
  Treat "14"/16" speakers are top-case" as pinned for the 2021 model quoted and **unverified for M2→M5**.

---

## Charger / power adapter

All Apple figures observed on `apple.com/th/shop` product pages on **2026-08-04**. Those pages carry **no
publication date**; the observation date is the only date of record. The "authorised reseller" column covers
iStudio/Copperwired, iStudio by SPVi, Studio7/Com7 and Advice — not Shopee/Lazada third-party sellers.

| Adapter | Apple TH | Authorised reseller | Observed | Ships in the box with |
|---|---|---|---|---|
| 30W USB-C | **฿1,190** | ฿1,170–1,190 | 2026-08-04 | MacBook Air 13" (M5, 8-core GPU), TH base config |
| 35W Dual USB-C Port | **฿1,890** | ฿1,690–1,890 | 2026-08-04 | MacBook Air 13" (M5, 10-core GPU); MacBook Air 15" (M5, all) |
| 35W Dual USB-C Compact (MNWM3TH/A) | *not listed on Apple TH* | UNPINNED | 2026-08-04 | not an in-box adapter for any current TH model |
| **67W USB-C** | **not sold — discontinued** | not sold | 2026-08-04 | none |
| 70W USB-C | **฿1,890** | ฿1,790–1,890 | 2026-08-04 | MacBook Pro 14" (M5; M5 Pro 15-core). CTO option on both Air sizes |
| 96W USB-C | **฿2,490** | ฿2,290–2,490 | 2026-08-04 | MacBook Pro 14" (M5 Pro 18-core / M5 Max) |
| **140W USB-C** | **฿3,190** | ฿2,890–2,990 | 2026-08-04 | **MacBook Pro 16" (M5 Pro / M5 Max), all configs** |
| USB-C to MagSafe 3 cable (2 m) | **฿1,590** | ฿1,590 | 2026-08-04 | included with every MacBook Air and MacBook Pro |
| USB-C Charge Cable (240W, 2 m) | **฿990** | ฿990–1,190 | 2026-08-04 | not in box; needed for 140W charging over USB-C |
| 20W USB-C *(context)* | ฿790 | ฿599–790 | 2026-08-04 | MacBook Neo (13") |

Product URLs: [30W](https://www.apple.com/th/shop/product/mw2g3th/a) ·
[35W dual](https://www.apple.com/th/shop/product/mw2k3th/a) ·
[70W](https://www.apple.com/th/shop/product/mxn53th/a) ·
[96W](https://www.apple.com/th/shop/product/mw2l3th/a) ·
[140W](https://www.apple.com/th/shop/product/mw2m3th/a) ·
[MagSafe 3 cable](https://www.apple.com/th/shop/product/mdf14za/a) ·
[240W cable](https://www.apple.com/th/shop/product/myqt3za/a) ·
[category page](https://www.apple.com/th/shop/mac/accessories/chargers-adapters/apple)

In-the-box data from <https://www.apple.com/th/macbook-air/specs/> and
<https://www.apple.com/th/macbook-pro/specs/> ("ภายในกล่อง"), cross-checked against the live TH configurator.

### Verdict on the README's "~฿3,000 for a 140W"

**Low.** Apple Thailand charges **฿3,190** — low by ฿190, about 6%. It is a defensible *street* figure since
authorised resellers reach ฿2,890 (iStudio/Copperwired) and ฿2,990 (Advice), but it is not the Apple Store
price, and a buyer walking into an Apple Store expecting ฿3,000 will be short.

Two further corrections to that README line:

1. **The 140W adapter ships without a cable.** Apple's own product page states "สายชาร์จจำหน่ายแยกต่างหาก"
   (cable sold separately). A full replacement kit is **฿3,190 + ฿1,590 MagSafe 3 = ฿4,780**, or
   ฿3,190 + ฿990 for the 240W USB-C cable = ฿4,180.
2. **140W is only correct for the 16".** 14" models ship 70W or 96W. The checklist's "you have the 140W
   charger in hand" line is 16"-specific and should say so.

### Things a guide author must know

- **There is no 67W.** Absent from all TH MacBook specs pages and all TH configurator options;
  `https://www.apple.com/th/search/67W-power-adapter` returns only the legacy 85W MagSafe 2. The US store
  returns no matches either. It is legacy, not a listing gap.
- **MacBook Neo ships no MagSafe cable.** Apple TH sells a third MacBook line
  (<https://www.apple.com/th/macbook-neo/specs/>) with a 20W adapter and a plain USB-C charge cable (1.5 m).
  A checklist that assumes every MacBook comes with a MagSafe 3 cable is wrong for Neo.
- **TH/US divergence on the Air.** The TH page says the 13" base ships **30W**; the US page says a 40W Dynamic
  Power Adapter. Two independent Thai sources agree on 30W, so 30W is the pinned TH answer — but the TH page's
  untranslated image alt-text still reads "40W". Worth confirming at Thai checkout.

### Marketplace discount and counterfeit risk

Shopping around saves roughly **฿100–300** on a genuine adapter, not half price: 140W 6–9% off, 96W 8%,
35W dual 11%, 70W 5%; 30W and the MagSafe 3 cable have no meaningful discount. **Anything advertised as a
genuine Apple 140W far below ~฿2,800 deserves suspicion.**

Counterfeit evidence, sourced:

- Royal Thai Police, Central Investigation Bureau / Economic Crime Suppression Division (บก.ปอศ.),
  press release dated **2025-05-01**, <https://cib.go.th/news/6307> — 504 items seized in Prawet, Bangkok,
  including "ที่ชาร์จแบตเตอร์รี่ … ปลอมเครื่องหมายการค้าของ APPLE จำนวน 17 ชิ้น" (17 chargers bearing
  counterfeit Apple trademarks). Goods confirmed substandard and sold online.
- สวพ.FM91 via LINE TODAY, **2024-12-28**, <https://today.line.me/th/v3/article/KwPMg3r> — separate ECD
  arrest in Bang Kruai, Nonthaburi; 1,026 counterfeit phone accessories including chargers.
- Apple Support TH, "Identify counterfeit or uncertified accessories",
  <https://support.apple.com/th-th/111103> — side-by-side genuine-vs-counterfeit power adapter photographs.

**Scope limit, stated honestly:** the Thai police evidence concerns counterfeit *phone* chargers with Apple
among the counterfeited marks. No Thai government or mainstream-press investigation specific to fake
high-wattage **MacBook** USB-C adapters was found. Do not write the guide as though fake 140W MacBook bricks
are a documented Thai enforcement target — the documented risk is counterfeit Apple-branded chargers sold
online, generally.

---

## Parts & Service History — what actually sets the flag

**This section corrects the README's Step 4 in three material ways.** Canonical source: Apple, "About Mac
parts and service history", <https://support.apple.com/en-us/123123>, **Published 2026-05-26** (Thai:
<https://support.apple.com/th-th/123123>, วันที่เผยแพร่ 29 พฤษภาคม 2569). Observed 2026-08-04.

### Correction 1 — there are five states, not four

| State | Apple's wording (en-US) | Thai UI string |
|---|---|---|
| Genuine | "The repair was done using genuine Apple parts and processes." | ของแท้ |
| **Unverified** | "The Logic Board was previously replaced… may impact your ability to use certain features on your Mac, such as Apple Pay." | ไม่ได้ตรวจสอบยืนยัน |
| Unknown | "In some situations, such as if the part was replaced with a nongenuine part or the part isn't working as expected, you see this label." | ไม่ทราบ |
| Used | "The part was already used or installed in another Mac." | ใช้แล้ว |
| **Finish Repair** | transient state until Repair Assistant calibrates the part | สิ้นสุดการซ่อม |

`Unverified` and `Finish Repair` are missing from the README's table. `Unverified` is the state a
replaced logic board usually produces, and it is the one that can break Apple Pay.

### Correction 2 — only four components are tracked

Apple's actual table of what Parts & Service can report:

| Model | Logic board | Touch ID board | Lid angle sensor | Display |
|---|---|---|---|---|
| MacBook Neo | ✓ | ✓ | | ✓ |
| MacBook Pro | ✓ | ✓ | ✓ (M5 models only) | |
| MacBook Air | ✓ | ✓ | ✓ (M5 models only) | |

**Battery is not in this table for any Mac.** Neither is the top case, speaker, camera, microphone, fan,
trackpad or Thunderbolt/IO board. On MacBook Pro and Air the **display is not reportable either** — only on
MacBook Neo.

**Do not conflate this with Apple's broader calibration list.** "Use Repair Assistant to finish a Mac repair"
(<https://support.apple.com/en-us/123128>, published 2026-05-11) lists parts Repair Assistant can *calibrate*
— a wider set including Battery (**MacBook Neo only**) and Display. Calibratable ≠ reportable. Conflating the
two lists is the easiest way to get this topic wrong.

### Correction 3 — the mechanism is pairing, not "who did the repair"

Apple's four documented triggers for `Unknown` are that the part "Is nongenuine / Isn't functioning as
expected / **Hasn't been verified and linked to your Mac after the repair was completed** / Has been modified
or is otherwise unable to be verified."

Two facts break the "independent shop ⇒ Unknown" model: **Repair Assistant is built into macOS** and is
available to Self Service Repair users — it is not an AASP-only tool; and Apple documents that **Independent
Repair Providers have genuine-parts access** (footnote 2 of 123123). A competent independent using a genuine
part and running Repair Assistant yields `Genuine`. A genuine part harvested from a donor Mac yields `Used`.
The risk is **nongenuine or unpaired**, which is a shop-quality question.

### Does an independent repair set `Unknown`? Component by component

| Component | Sets `Unknown`? | Evidence strength |
|---|---|---|
| Logic board | **Yes** — tracked on every Mac. Usually surfaces as `Unverified`. | Apple doc |
| Touch ID board | **Yes** — the one part Apple says it *will* actively disable third-party versions of | Apple doc + industry |
| Lid angle sensor | **Yes, but M5 MacBook Pro/Air only** | Apple doc |
| Display assembly | **MacBook Neo only.** On Pro/Air an unpaired panel loses True Tone and can show `Finish Repair`, but no evidence of an `Unknown` row | Apple doc + anecdote |
| **Battery** | **No** — absent from the reporting table for every Mac | Apple doc (negative) |
| Top case / keyboard | **No `Unknown` row.** Calibratable only as "Top case (with Touch Bar)" on MacBook Pro 2020 & 2022 | Apple doc (negative) |
| Speaker | **No** — explicitly used-part-supported | Apple doc (negative) |
| Camera | **No** — part of the display assembly on MacBooks, not a listed part | Anecdote only |
| Microphone | **No evidence found** — could not confirm or rule out | None |
| Fan | **No** — used-part-supported on MacBook Pro (Airs are fanless) | Apple doc (negative) |
| Thunderbolt / USB-C / IO board | **No** — USB-C boards are used-part-supported | Apple doc (negative) |
| Trackpad | **No** — explicitly used-part-supported | Apple doc (negative) |

Used-part support sourced from <https://support.apple.com/en-us/123920> and
<https://support.apple.com/en-us/123921> (both published 2026-03-11).

Three cross-cutting caveats: **(a)** no one has publicly tested third-party parts on a Mac — iFixit,
2026-03-13: *"we haven't done any testing with third-party parts yet, not that they even exist"*
(<https://www.ifixit.com/News/116152/macbook-neo-is-the-most-repairable-macbook-in-14-years>); **(b)** across
three search sweeps, **zero first-hand reports of a Mac displaying `Unknown`** were found — every such
anecdote was iPhone; **(c)** Apple's own pages are in tension, 123920/123921 claiming coverage of "most major
parts" against the four-row table of 2026-05-26.

### Two further mechanics the guide should carry

- An unknown part triggers a notification at first unlock after repair **and again five days later**.
- **The pane is disabled entirely if System Integrity Protection is off** — so a missing pane is a signal to
  investigate, not a pass. Likewise Apple says the option "appears only when your Mac detects that it has
  been repaired", so absence is weak evidence, not proof of a clean machine.

### ⚠️ Reach problem: the pane needs macOS Tahoe 26

Parts & Service requires **Apple silicon and macOS Tahoe 26 or later**. The README's Step 1 accepts
"macOS Sequoia 15 **or** Tahoe 26" — on a Sequoia machine **Step 4's Parts & Service check cannot run at all**.
The guide should either require Tahoe 26 for that step or tell the buyer to update first. Most circulating
Thai second-hand stock (Intel 2012–2020 units at roughly ฿8,900–20,000 on mac2hand, plus un-upgraded M1/M2
machines) cannot display the pane.

---

## Resale impact

**The headline, stated plainly: the Thai market discusses this qualitatively and nobody publishes a
percentage.** A targeted Thai search for a published deduction table (run 2026-08-04) returned zero. The
`฿5,000–8,000 off resale` figure used as an example in issue #10 is **not evidenced** and should not be
printed as though it were.

### What Apple itself says

> "An unknown part might affect the trade-in value of your device."
> Thai: "ชิ้นส่วนที่ไม่รู้จักอาจส่งผลต่อมูลค่าการแลกเปลี่ยนอุปกรณ์ของคุณ"

Apple frames the feature explicitly as a resale-disclosure tool: *"If you sell or give away your Mac, the new
owner can also learn its repair history."* (<https://support.apple.com/en-us/123123>, 2026-05-26.)

The README's existing quote — *"Repairs performed by untrained individuals or using nongenuine parts might
affect the functionality, safety, security, and privacy of the device"* — is **verified exact** on that same
page. Note a near-identical but *different* sentence exists at <https://support.apple.com/en-us/123127>
(published 2025-09-15) reading "performance, privacy, security, safety, and reliability of your device".
Cite the right URL for the wording used.

### The one Thai operator that ties the flag to price

MaKaiTeeTum (มาขายที่ตั้ม), an Apple buyback operator at Future Park Rangsit —
<https://makaiteetum.com/check-iphone-repair-history-2026/>, **posted 2026-06-26**:

> "เครื่องที่เคยซ่อมด้วยอะไหล่แท้และมีประวัติชัดเจนอาจยังขายได้ราคาใกล้เคียงเครื่องปกติ แต่ถ้าเป็นเครื่องที่มีรอยแกะชัดเจน ขึ้น Unknown Part หรือฟังก์ชันไม่ครบ ราคาจะตกมากกว่าเดิมทันที"

*A unit repaired with genuine parts and a clear documented history can still sell near a normal device's
price; but one with obvious pry marks, showing "Unknown Part", or with missing functions — the price drops
much further, immediately.* **Direction only, no magnitude. The article is iPhone-framed.**

### The grading engine behind Thai retail trade-in ignores repair history

**CompAsia** — which powers iStudio by SPVi and PowerBuy trade-in — publishes its full grade rubric
(<https://compasia.co.th/blogs/news/3-ประเภทเกรดโทรศัพท์มือถือที่-compasia>, published 2024-06-12).
Excellent / Good / Fair are discriminated **purely cosmetically**, benchmarked on dent visibility
("สังเกตไม่เห็นได้จากระยะห่าง 1 ช่วงแขน" — not noticeable at arm's length), plus a hard floor of
"battery health at least 80%". **Repair history, opened chassis and non-genuine parts appear nowhere.**

Other operators' published factor lists likewise omit repair history: asis.co.th / cyber-toys.com (retrieved
2026-08-04) list model, chip, RAM, SSD, screen, battery condition and cycle count, dents, box completeness,
iCloud status and warranty — but not เคยแกะ / เคยซ่อม / อะไหล่ไม่แท้. UFicon's published trade-in conditions
(data as of 3 พ.ย. 68 = 2025-11-03, <https://www.uficon.com/trade-in/>) name only model, normal function and
external condition. Apple Thailand's own trade-in vendor terms
(<https://appletradein-th.likewize.com/retail/terms-conditions>) carry **no grading schedule at all** — Apple
TH delegates appraisal entirely to the partner.

### Battery health and cycle count — published Thai bands, all qualitative

MaKaiTeeTum, <https://makaiteetum.com/macbook-battery-cycle-count-check-before-sell/> (**posted 2025-07-12**):

| Condition | Effect on price |
|---|---|
| <500 cycles & ≥90% capacity | "ขายได้ราคาเต็มหรือใกล้เคียง" — full or near-full price |
| 500–1,000 cycles & 80–90% | "ราคาจะถูกหักเล็กน้อย" — small deduction |
| >1,000 cycles or <80% | consider replacing before selling |

And <https://makaiteetum.com/macbook-battery-degraded-buyback/> (**posted 2025-10-06**): 60–79% health →
"ราคาลดลงมากขึ้น"; dead or swollen → "หักหนัก" or **"รับซื้อในราคาซาก"** (scrap/parts price only), with some
shops refusing outright.

**Behavioural corroboration that cycle count is genuinely priced:** Thai sellers put it in the listing
*title*. Kaidee, all retrieved 2026-08-04 — "Cycle count เพียง 133 ครั้ง" ฿20,990
(<https://www.kaidee.com/product-371493902>, uploaded 2026-08-02); "แบต 191 รอบ สภาพสวย" ฿18,900
(<https://www.kaidee.com/product-371455079>, 2026-07-07); "รอบชาร์จ 3 รอบ ประกันถึง กพ. 27 ครบกล่อง" ฿51,900
(<https://www.kaidee.com/product-371486535>, 2026-07-28). This evidences that the signal *is* priced; it does
**not** measure by how much.

### Listing language — and a semantic trap

"ไม่เคยแกะ ไม่เคยซ่อม" (never opened, never repaired) is a standard Thai value claim in Mac groups:
<https://www.facebook.com/groups/kgamermarketmacbookpro/>, <https://www.facebook.com/groups/mbpcommth/>,
and mac2hand.com ("เครื่องศูนย์ (ไม่เคยซ่อม) สภาพดี" — 12,479 live MacBook listings as of 2026-08-04,
<https://mac2hand.com/search/macbook/all>, whose template exposes structured "สภาพ : xx% / ตำหนิ :" fields).

**The trap: on Kaidee, "ไม่แกะ" means box-sealed-new, not chassis-never-opened** — e.g. "ของใหม่ยังไม่แกะ
ประกันยังไม่เดิน" ฿41,900 (<https://www.kaidee.com/product-371388436>, 2026-06-30). Anyone building a Kaidee
query on that keyword will measure the wrong thing.

### Pantip — buyers want this and have no tool

- <https://pantip.com/topic/39356378> (**2019-10-27**): *"ซื้อ macbook มือ2 จะรู้ได้ไงว่าเครื่องนั้นเคยผ่านการซ่อมมาแล้ว?"*
  — notes iPhone has a checker; got one non-answer reply.
- <https://pantip.com/topic/34243529> (**2015-09-29**) — coins the local term for parts-harvested machines:
  *"แกะเอามาจากเครื่องอื่นที่พัง มาประกอบร่างรวมกันแบบที่เขาเรียกว่า 'ยำ'"*.
- <https://pantip.com/topic/32093818> (**2014-05-23**) documents why "เคยซ่อม" is a red flag in Thailand
  specifically: a shop returned a MacBook Pro with RAM removed, the **bottom case swapped so the serial no
  longer matched the box**, a degraded battery substituted and a downgraded GPU.
- <https://pantip.com/topic/38841355> (**2019-05-07/09**) — Thai consensus that out-of-centre batteries are
  not genuine regardless of claims: *"อยากได้แท้ก็ศูนย์เท่านั้น ของ Apple จริงๆ ไม่หลุดออกมาหรอก"*.
- The most recent Thai buyer checklist found, <https://pantip.com/topic/44117807> (**2026-06-06**), covers
  dead pixels, keyboard, trackpad, ports and iCloud sign-out — and **does not mention Parts & Service at all**.
  Thai how-to content relies on physical heuristics instead: <https://mister-services.com/spot-serviced-used-macbook/>
  (**2025-07-31**) tells buyers to compare the serial on the bottom case against System Report, check cycle
  count and inspect screws, framing the payoff commercially as *"ควรซื้อหรือควรขอราคาพิเศษ"*.

### Non-Thai corroboration (labelled as such)

**Swappa (US)** is the one marketplace with a published rule
(<https://swappa.com/faq/answer/replaced-devices>, undated, scraped 2026-08-04): *"All repairs must be
disclosed by the seller… **Non-OEM parts are allowed if disclosed** by the seller and the device is fully
functional."* **MacRumors** (iPhone, not Mac; thread started 2023-03-23,
<https://forums.macrumors.com/threads/unknown-part-on-refurbished-iphone-12.2384594/>) shows the community
**split** on whether a non-OEM display affects resale — so even in the better-documented iPhone market the
effect is contested, not quantified.

### The asymmetry, restated honestly

The guide's framing — *"an `Unknown` flag costs ฿0 to fix and a lot to resell"* — needs three corrections:

1. **"You can't fix it" is not established.** Apple states *"If a part has been serviced more than once, only
   the most recent service appears"*, implying a later genuine calibrated repair supersedes the entry. A
   `Finish Repair` state is user-clearable for free by running Repair Assistant. The genuinely
   irreversible-looking case is the logic board's `Unverified`. Apple never uses the words permanent or
   irreversible.
2. **The scope is four parts, not the whole machine.** A battery, screen (on Pro/Air), keyboard, speaker, fan
   or port board replaced by an independent produces **no `Unknown` row**. An asymmetry argument built on
   "any outside repair flags your Mac forever" is unsupported.
3. **The mechanism is pairing, not authorisation.** The real risk is a nongenuine or unpaired part — a
   shop-quality question, not an Apple-Store-versus-not question.

**What survives:** the *cost of avoiding* an Unknown flag is near-zero at repair time (insist on a genuine
part and on Repair Assistant being run); the *cost of carrying* one is real in direction but **unmeasured in
Thailand**. Its practical bite today is limited less by discount size than by **reach** — most circulating
stock cannot display the pane, and no Thai buyer checklist found even mentions it.

---

## Unresolved conflicts in the sources

These are genuine contradictions between primary sources, left visible rather than smoothed over.

1. **Is the display a tracked part on MacBook Air / Pro?** Apple's reporting table
   (<https://support.apple.com/en-us/123123>, 2026-05-26) ticks Display **only for MacBook Neo**. Apple's
   Repair Assistant article (<https://support.apple.com/en-us/123128>, 2026-05-11) lists Display among parts
   it can *calibrate* for MacBook Pro/Air. **The reading adopted here** is that these are two different lists
   — *calibratable* ≠ *reportable* — so an unpaired display on an Air/Pro loses True Tone and can show
   `Finish Repair`, but does **not** produce an `Unknown` row. Two of three independent sweeps reached this
   conclusion; one read 123128 as the operative superset. **Consequence if wrong:** an independent screen
   replacement *would* flag, which would change the display rows from "No" to "Yes" and materially change the
   guide's advice. *To pin: first-hand observation on a Tahoe 26 Mac with a third-party display.*
2. **Apple contradicts itself on scope.** Pages 123920/123921 (2026-03-11) claim the feature covers "most
   major parts"; the four-row table of 2026-05-26 does not. Could be marketing looseness or a lagging table.
3. **Does Apple TH's ฿8,690 include VAT?** The Thai wording "จะต้องเสียภาษีมูลค่าเพิ่ม" ("is subject to VAT")
   does not say. AppleCare+ fees *are* explicitly tax-inclusive; the repair estimates are not so marked.
4. **HardwareHot's 14" display price (฿18,600) sits below the wholesale part cost** (฿17,000–19,000 at
   Macparts, same day). Near-zero or negative margin means the figure is stale or sourced differently.
5. **BBmacservice publishes two contradictory price tables on one page** for both batteries and displays.

---

## Unpinned / could not establish

Everything below is missing on purpose — it is listed so the guide author knows not to reach for a number
that does not exist, and knows what it would take to get one.

### Apple / AASP

| # | Missing | Why | What would pin it |
|---|---|---|---|
| 1 | **Apple TH out-of-warranty price for display, logic board, top case, speaker, camera, mic, fan** | Apple publishes only battery; every other repair renders as `—` with "we must inspect your product". Confirmed by searching the full 1,166,639-byte raw HTML for ฿/THB/บาท — zero hits. **Global parity, not a Thai gap.** | A serial number at <https://getsupport.apple.com>, or an in-person Genius Bar / AASP quote. Apple says the fee is set only after inspection, so even the estimator may not return a fixed number. |
| 2 | **Any AASP price list dated later than 2023-11-01** | iStudio by SPVi's iCenter list is effective 2023-11-01 and stops at M3. Copperwired's is an undated image (asset filename implies 2024-03-28). SPVi's `icenter-pricelist` 302s to homepage on some paths; Studio7/Comseven, uFicon, iBeat, iCare and Power Mac Center publish no repair-price page. | Phone or LINE each AASP. Apple explicitly states authorised providers set their own fees. |
| 3 | **Any AASP top-case price for M4 or M5** | The one published list predates those models | Same as above |
| 4 | **Whether SPVi's ฿6,190 / ฿7,490 / ฿9,490 applies to a keyboard-only fault** | The column header says battery; the footnote says top case with keyboard. Strongly indicated, not stated. | A written quote for a keyboard fault with no battery complaint |
| 5 | **Whether ฿8,690 includes or excludes VAT** | Apple's Thai wording is genuinely ambiguous | An invoice, or a direct question to Apple TH |
| 6 | **Publication dates for Apple's pricing pages** | Neither the Thai nor US repair-pricing page carries any date stamp; prices are served live from an API | Nothing — **2026-08-04 is the only date of record**. Re-pull the API to refresh. |
| 7 | **Stated part wait times in days** | Nobody publishes them for Macs. Apple TH gives none; the only day-scale SLAs found are iPhone-specific. | An AASP quote at intake |
| 8 | **Apple's verbatim wording that the display is one whole assembly** | Circumstantially strong — every manual lists one procedure and one part named "Display" — but the manual body text lives in a JS viewer/PDF that resisted fetching | Download the PDF from the SSR store while signed in |

### Independent shops

| # | Missing | Why |
|---|---|---|
| 9 | **Independent prices for all M4 and M5 machines** (battery, keyboard, display on MBP 14"/16" M5) | Parts too new; the only M4 rows found are self-contradictory. Re-check in 6–12 months. |
| 10 | **Installed keyboard price for Air M2–M5 and all MBP 14"/16" M2–M5** | Nobody publishes one; Freedom's page says ask via LINE |
| 11 | **Installed fan-replacement price for any Apple-silicon MacBook Pro** | Service advertised everywhere, number published nowhere |
| 12 | **Any camera-specific or microphone-specific price, official or independent** | None exists. No Apple-silicon camera part is sold in Thailand at all — MacParts' entire iSight category is eight pre-2013 Intel SKUs. |
| 13 | **Speaker price for MBP 14"/16" Apple silicon and Air M2–M5** | Only A2337 (฿4,000 installed) and A2338 (฿4,500 part) are pinned |
| 14 | **Full logic-board swap price for any Apple-silicon MacBook** | The only published swap figure (฿23,900) is for an **Intel** 2019 machine. Compounded by Macparts stocking zero 14" Pro boards. |
| 15 | **A price for "dead Thunderbolt *data* port, charging still works"** | Every Thai source prices charging faults only. Almost certainly quote-on-inspection everywhere. |
| 16 | **แท้ vs เทียบ (genuine vs equivalent) price pairs for keyboards and top cases** | That two-tier convention exists in Thailand for screens but not for keyboards |
| 17 | **Shopee / Lazada / Facebook prices** | Shopee returns "Page Unavailable" to server-side fetches; Lazada renders price client-side; Facebook price lists are photographed tables inside image posts. All **excluded** rather than quoted unverified. |

### Resale impact

| # | Missing | Why | What would pin it |
|---|---|---|---|
| 18 | **Any Thai percentage or baht figure for the resale impact of repair history, non-genuine parts, or an `Unknown` flag** | **No published Thai source states one.** Not Apple TH, not CompAsia, not UFicon, not Studio7, not any รับซื้อ operator found. Issue #10's example `฿5,000–8,000 off resale` is **not evidenced**. | A paired-listing dataset — same model/year/RAM/SSD on mac2hand and Kaidee, split by "ไม่เคยซ่อม" vs disclosed repair, over ≥3 months; or a controlled quote experiment submitting one spec to 5+ operators over LINE varying only repair status |
| 19 | **Whether an `Unknown` entry is literally permanent** | Apple says only the most recent service shows, but never states whether `Unknown` clears | An Apple/AASP statement, or a documented before/after on one machine |
| 20 | **Whether `Finish Repair` decays into `Unknown` if never completed** | Apple's third trigger ("hasn't been verified and linked…") could be read that way — inference, not evidence | Controlled test, or Apple confirmation |
| 21 | **Any first-hand report of a Mac actually displaying `Unknown`** | **Zero found** across three sweeps; every such anecdote was iPhone. iFixit, 2026-03-13: *"we haven't done any testing with third-party parts yet, not that they even exist"*. | A screenshot from a real Mac, or iFixit repeating their iPhone pairing methodology on a Mac |
| 22 | **Microphone tracking status** | Not named in any of Apple's four tables; no industry or community source located. Could not confirm or rule out. | — |
| 23 | **Studio7 / iStudio / BaNANA / PowerBuy Grade A/B/C definitions for Macs** | All publish that grades exist; none publishes boundary rules. Studio7's only published baht table is iPhone-only. | The in-store CompAsia grading app question flow, or the Trade-in Plus terms PDF |
| 24 | **Whether any Thai operator refuses, or only downgrades, a MacBook with non-genuine parts** | No published policy found either way | — |
| 25 | **Any Thai-language content explaining *Mac* Parts & Service History** | None found — all Thai coverage of the feature is iPhone-only | Searches on macthai.com / iphonemod.net / droidsans.com / beartai.com for Tahoe 26 coverage naming "ชิ้นส่วนและบริการ" |

---

## Method and tooling

Research was run as five parallel investigations (battery; display + logic board; top case + small parts;
chargers; Parts & Service + resale), each instructed never to invent a figure and to stamp every price with
its source URL and observed date.

**Tooling:** AgentKey MCP was the primary tool throughout (`Serper/search`, `Brave/getWebSearch`,
`Serper/searchShopping`, `Firecrawl/scrape`), with `wigolo fetch`/`extract` for page reads and a real browser
plus a direct `curl` against Apple's pricing API for the client-rendered Apple pages. Built-in
WebSearch/WebFetch were **not** used for any price in this document.

**Two errors were caught and corrected during verification** and are recorded here so they are not
reintroduced:

1. AppleCare+ fees of ฿1,590 / ฿4,990 were initially returned for MacBook Air/Pro. Those are **MacBook Neo**
   figures, read off Apple's support widget with the model selector parked on that line. The correct
   MacBook Air / Pro figures are **฿3,300 / ฿10,000**, taken from Apple's Thai legal terms.
2. A claim that macOS has no Parts & Service pane was overruled against Apple's own Tahoe 26 documentation.

**Sources deliberately excluded rather than quoted unverified:** Shopee, Lazada and Facebook price lists
(unreadable to fetchers, or photographed tables); iCare/Comseven's "MacBook Air M1/M2/M3 = ฿7,500" figures
(these are **AppleCare+ plan prices, not repair prices** — a trap); and Pantip threads about Intel-era
machines, which Apple TH no longer services at all.
