# The Thai resale penalty for repair history and non-genuine parts

Research note resolving [issue #18](https://github.com/mingrath/mbcheck/issues/18).
Re-evidences the `est. ฿5,000–8,000 off resale` figure that [issue #10](https://github.com/mingrath/mbcheck/issues/10)
attached to a permanent Parts & Service `Unknown` flag, and which
[issue #13](https://github.com/mingrath/mbcheck/issues/13) found had no source.

**Research date: 2026-08-04.** Every listing was retrieved that day; each carries its own posting date.
Nothing in this note is an estimate, a percentage inferred from a neighbouring market, or a figure carried
over from #10. Where a number does not exist, this note says so and says what it would take to get one.

**Do not read the headline range as "the resale penalty".** It measures one fault (a disclosed display
replacement), in one channel (shop asking prices), from two usable pairs. Read
[the scope limits](#what-the-range-is-not) before quoting it.

---

## ⚠️ Corrections this research forces on [#10](https://github.com/mingrath/mbcheck/issues/10)

| # | #10 says | Reality | Where |
|---|---|---|---|
| 1 | Parts & Service `Unknown` → `Financial impact: ฿0 to fix · **est. ฿5,000–8,000 off resale**` | **Struck, not replaced.** Across **2,045** Thai second-hand MacBook listings read in full, **zero** mention `Unknown`, a non-genuine part, or an aftermarket part in the machine. No Thai buyback operator prices the flag. There is no number to put here. | [The `Unknown` flag](#the-unknown-flag-there-is-no-number-and-there-is-no-market-that-could-produce-one) |
| 2 | The resale penalty is a single figure that applies to "a permanent `Unknown` flag" | **The measurable penalty attaches to a *disclosed repair*, not to a flag.** The one repair Thai sellers do disclose is a **replaced display**; that is priced. Everything the pane can actually see is not. | [Paired listings](#arm-1--paired-listings) |
| 3 | Implicitly, any repair history costs the seller money | **A replaced battery is advertised as a selling point and carries a price premium in the listing market**, while landing the same machine in Grade C in the buyback market. The sign of the penalty is channel-dependent. | [Battery is a feature](#the-battery-exception-a-replacement-is-advertised-not-hidden) |
| 4 | Every 💰 finding carries a real Thai number, and the report tallies the 💰 figures against the asking price | A resale penalty is **not a repair cost** and must not enter that tally — it would double-count a machine whose screen was replaced *and* whose replacement is priced. | [What the guide should say](#what-the-guide-should-say) |

---

## Headline

| Question #18 asked | Answer | Confidence |
|---|---|---|
| Resale penalty for a **documented repair history** | **฿3,000–฿5,400 off a ฿26,900–฿33,900 asking price — 10%–16% — for a disclosed *display* replacement.** Two usable matched pairs, one corroborating pair. Observed 2026-08-04; listings dated 2025-06-10 to 2026-08-01. | Low–medium. Two pairs, both with a named confound, and these are **asking** prices, not transacted prices. |
| Penalty for a **battery** replacement | **Negative in the listing market** — it is a headline selling point, not a defect line. **Grade C in the buyback market** (below the published table). Do not price it as a resale loss. | Medium |
| Penalty for a **top case / keyboard** replacement | **Not observed once** in 2,045 listings. No figure exists. | — |
| Penalty for an **`Unknown` / non-genuine-part flag** | **No defensible number exists.** Not one listing, not one buyback schedule, not one shop statement quantifies it. | High — this is a well-searched negative |
| Do Thai buyers price this at all, or is it **time on market**? | **Both, weakly.** The one shop that discloses does not discount over time — 38 units re-listed, **not one price change**. Disclosed units sat a median **83 days** against **40 days** undisclosed (n = 5 vs 33). Suggestive; not significant. | Low |
| Is there any **published** Thai deduction schedule? | **Yes — one, found by this research.** BKK APPLE publishes Grade A / Grade B buyback prices for every Apple-silicon Mac. Grade A requires *"never opened for repair or had any part replaced"*. Grade B is a flat **−15%**. A genuine battery-or-screen replacement is **Grade C, which is not priced at all.** | High |

**The one number the guide can print with a date and a source:** a Thai buyback operator's published
schedule prices a Grade B machine at **exactly 85% of Grade A across all 466 rows**, and puts any machine
with a replaced battery or screen **below** that, in an unpriced grade — *BKK APPLE, observed 2026-08-04*.

---

## Method and sample

Method arms were run in #18's stated order of preference.

### Arm 1 corpus — paired listings

| Source | What was taken | Count |
|---|---|---|
| **mac2hand.com** (<https://mac2hand.com/search/macbook/all>) — Thailand's dedicated Mac classifieds | All **139** result pages, retrieved 2026-08-04 | **12,478** distinct listings |
| → filtered to Apple silicon (M1–M5 named in title, badges or seller text; Intel excluded) | | **1,858** |
| → detail page fetched for **every one** of those, seller-written body isolated from site chrome | | **1,858** bodies read |
| **Kaidee** (<https://www.kaidee.com/c82-computer-notebook>) — Thailand's largest general classifieds, notebook category | All **26** pages, retrieved 2026-08-04 | **603** ads |
| → MacBook ads | | **191** |
| → product page fetched, full seller description read (4 fetch failures) | | **187** descriptions read |
| **Total MacBook listings read in full** | | **2,045** |

Facebook Marketplace and the Thai Mac buy/sell groups
(`groups/mbpcommth`, `groups/kgamermarketmacbookpro`) are **not machine-readable without an authenticated
session** and were excluded rather than sampled by hand and quoted as if systematic — the same rule #13
applied to Shopee and Lazada. Shopee/Lazada were re-checked and still return no server-rendered prices;
they are in any case a *new*-goods channel and would not have produced pairs.

**Keyword scanning was done on the seller's own text only.** An early pass over whole pages returned 129
hits for `เทียบ` (aftermarket/equivalent part); every one was the site's own `เปรียบเทียบ` ("compare")
chrome. Every count below excludes navigation, hashtags and shop boilerplate.

### Arm 2 — buyback / trade-in deduction schedules

Targeted Thai searches for a published grade rubric that names repair history. #13 had already cleared
CompAsia, UFicon, asis.co.th, cyber-toys and Apple TH's own trade-in partner terms and found repair history
absent from all of them; those were not re-run. **One new operator was found** that does publish it — see
[Arm 2](#arm-2--buyback-deduction-schedules).

### Arm 3 — seller and shop statements

Pantip and Thai Mac group statements about what a repaired machine fetches. #13 had already pinned the
MaKaiTeeTum material and the Pantip threads; those are cited here, not re-derived. Two new statements were
found, both direction-only.

---

## The disclosure base rate — the finding that governs everything else

**Of 2,045 Thai second-hand MacBook listings, 8 distinct machines disclose any repair at all. That is
0.39%.**

| Disclosure | mac2hand (1,858) | Kaidee (187) | Distinct machines |
|---|---|---|---|
| Display replaced (`เคยเปลี่ยนหน้าจอ` / `เคยเปลี่ยนจอ`) | 10 ads | 7 ads | **5** |
| Battery replaced (`เปลี่ยนแบตเตอร์รี่มาใหม่`, `เคลมแบตใหม่มาจากศูนย์`) | 1 ad | 2 ads | **2** (+1 Intel 2013) |
| Contradictory duplicate (same unit advertised both ways) | 2 ads | 2 ads | **1** |
| Keyboard / top case replaced | **0** | **0** | **0** |
| Logic board, port board, speaker, camera, mic, fan replaced | **0** | **0** | **0** |
| `Unknown` / `Unknown Part` | **0** | **0** | **0** |
| Non-genuine or aftermarket part **in the machine** (`อะไหล่เทียบ`, `อะไหล่ไม่แท้`) | **0** | **0** | **0** |
| — but **`ชุดชาร์จไม่แท้` / `หัวชาร์จไม่แท้` (non-genuine *charger*)** | 6 ads | 7 ads | several |
| `ไม่เคยซ่อม` (never repaired) — the **claim**, not the disclosure | 32 ads | 1 ad | — |
| `ไม่เคยแกะ` (never opened) — the claim | 46 ads | 3 ads | — |

Three things follow, and they are the substance of this note.

1. **The only "non-genuine part" a Thai MacBook seller ever discloses is the charger.** Thirteen ads say
   the charger is not genuine. Zero say anything in the machine is not genuine. A market that will not
   name a non-genuine part cannot price one.
2. **Every occurrence of `เคยซ่อม` and `เคยแกะ` in the mac2hand corpus is the negated form** — `ไม่เคยซ่อม`,
   `ไม่เคยแกะ`. The market's mechanism is not a disclosed penalty; it is a **claimed absence**. What the
   buyer is meant to notice is the missing "never opened, never repaired" line, and 96% of listings do not
   carry that line either way.
3. **Six of the eight disclosing machines come from one operator** — a Bangkok shop trading as *Double Mac*
   on Kaidee and mac2hand and as *mactrue* on a second Kaidee account, cross-posting identical stock under
   matching internal product codes. Effectively, one shop in Thailand itemises repair history in a
   structured `ตำหนิ` (defects) field. The measurement below is largely a measurement of that shop.

**Consequence for #18's third question:** the penalty for a non-genuine part cannot be measured in this
market because it is never disclosed. That is not a gap in the search; it is a property of the market.

---

## Arm 1 — paired listings

### Pair A — same seller, same day, same model, same config, same colour ★ strongest

Seller: **J-Group / Appleclub.th** (086-048-9494), on mac2hand. Both listings posted **2025-06-10**, both
`MacBook Pro 14-inch M1 Pro 2021, Space Gray, RAM 16GB, SSD 512GB`, both `ประกันร้าน 1 เดือน` (1-month shop
warranty).

| Listing | Price | Seller's own words | Accessories |
|---|---|---|---|
| <https://mac2hand.com/detail/367882/x> | **฿29,900** | no condition note | `ครบกล่อง` — complete with box |
| <https://mac2hand.com/detail/367892/x> | **฿26,900** | **`เครื่องเปลี่ยนจอมาเนื่องจากจอเดิมแตก`** — *display replaced because the original was cracked* | `ตัวเครื่อง ชุดชาร์จ` — machine + charger, no box |

**Δ = ฿3,000 = −10.0%.**

*Confound:* the cheaper machine also lacks its box. *Partial control:* the same seller's
<https://mac2hand.com/detail/364260/x> (2025-05-01) was the same model and config, also **without** a box
(`ตัวเครื่อง , อแด๊ปเตอร์ชาร์จ`) and with visible marks (`มีรอยตามรูป ไม่มีผลกับการใช้งาน`), and was
priced at **฿29,900** — this seller's standard price for the config at that time. A missing box did not
move his price five weeks earlier. On that control the ฿3,000 is attributable to the display.

### Pair B — same config, same marketplace, same week, different sellers

Kaidee, `MacBook Pro 14-inch M1 Pro 2021, 16GB / 512GB`:

| Listing | Posted | Price | Seller's own words |
|---|---|---|---|
| <https://www.kaidee.com/product-371465346> (Double Mac; also as <https://www.kaidee.com/product-371215564>, mactrue, 2026-02-05) | 2026-07-14 | **฿28,500** | `สภาพดี มีรอยการใช้งาน` **`เคยเปลี่ยนหน้าจอ`** · Cycle Count 181 · Maximum Capacity 86% |
| <https://www.kaidee.com/product-371475497> (private seller) | 2026-07-20 | **฿33,900** | `ใส่เคสตลอด ครบกล่อง สภาพมือ1` — always cased, complete box, as-new |

**Δ = ฿5,400 = −15.9%.**

*Confounds:* shop stock versus a private seller, and a stronger cosmetic claim on the dearer machine. The
same shop's mirror of the disclosed unit sits on mac2hand at the same ฿28,500
(<https://mac2hand.com/detail/1000489/x>, <https://mac2hand.com/detail/1000484/x>, 2026-08-01), so the price
is stable across both marketplaces and across five months.

### Pair C — same shop, same model, same RAM/SSD, two different units (corroborating)

Double Mac / mactrue, `MacBook Pro 16-inch M2 Pro 2023, 16GB / 512GB`:

| Unit | Price | Seller's own words | Battery |
|---|---|---|---|
| code 61270, Space Gray — <https://www.kaidee.com/product-371216985> (2026-02-06), <https://www.kaidee.com/product-371320343> (2026-04-11) | **฿41,900** | `สภาพดีมาก` **`เปลี่ยนแบตเตอร์รี่มาใหม่ ใช้งานต่อได้ยาวๆหายห่วง`** — *battery replaced with a new one, will last a long time, no worries* | 3 cycles · 100% |
| code 61257, Silver — <https://www.kaidee.com/product-371459899> (2026-07-10), <https://www.kaidee.com/product-371472931> (2026-07-19) | **฿38,900** | `สภาพดีมาก` **`เคยเปลี่ยนหน้าจอแท้จากศูนย์จอขาวสวย`** — *display previously replaced, genuine, from the service centre, panel is clean and white* | 583 cycles · 80% |

**Δ = ฿3,000 = −7.2%.**

*Confounds:* different colours, a 3–5 month gap, and — decisively — very different battery states. This
pair does **not** isolate the display. It is reported because it is the sharpest available demonstration of
the direction reversal: within one shop's own pricing, **a replaced battery is worth more and a replaced
display is worth less**, and even a *genuine Apple-service* display replacement is filed under `ตำหนิ`
(defects), not under features.

### Two further disclosed machines, directional only

- `MacBook Air 13-inch M1 2020, **16GB**/256GB, Gold` — `สภาพมีรอยบุบบิ่น เคยเปลี่ยนหน้าจอ` (dents and
  chips, display previously replaced), 235 cycles / 92% — **฿15,900**
  (<https://www.kaidee.com/product-371362169> 2026-05-09, <https://www.kaidee.com/product-371466045>
  2026-07-14, <https://mac2hand.com/detail/1000454/x> 2026-07-31). Clean **8GB**/256GB M1 Airs in the same
  corpus and the same fortnight sit at ฿12,900–฿15,900 (<https://mac2hand.com/detail/1000137/x>,
  `/1000159/x`, `/1000106/x`, `/1000521/x`). The disclosed 16GB machine prices like a clean 8GB one —
  implying roughly the RAM premium, ฿3,000–4,000. **Not counted in the range**: it rests on an assumed spec
  premium and it bundles dents with the display.
- `MacBook Pro 13-inch M2 2022, 8GB/512GB` — `มีรอยสติ๊กเกอร์ที่วางมือ เคยเปลี่ยนจอ กล้องไม่ค่อยชัด`
  (sticker marks on the palm rest, display previously replaced, **camera not very clear**), 369 cycles /
  85% — **฿21,900** (<https://www.kaidee.com/product-371328974> 2026-04-18,
  <https://mac2hand.com/detail/1000426/x> 2026-07-30). A clean 8GB/**256GB** M2 Pro 13 with 133 cycles was
  ฿20,990 on 2026-08-02 (<https://www.kaidee.com/product-371493902>) — again, the disclosed 512GB machine
  prices like a clean 256GB one. **Not counted**: no matched-capacity comparator exists.

  This listing is also the corpus's only evidence of the *second-order* cost the guide should care about:
  the replacement display carries a **worse camera**, because — as #13 established — the camera rides on
  the display assembly. The seller prices the camera fault, not the repair.

### The range

| | |
|---|---|
| **Observed penalty for a disclosed display replacement** | **฿3,000 – ฿5,400** |
| **As a share of asking price** | **−10.0% to −15.9%** |
| **On machines asking** | ฿26,900 – ฿33,900 (14" MacBook Pro, M1 Pro, 16/512) |
| **Pairs** | 2 usable, 1 corroborating |
| **Listings dated** | 2025-06-10 to 2026-08-01 |
| **Observed** | **2026-08-04** |

### What the range is *not*

- **Not transacted prices.** Every figure is an *asking* price on a live listing. Pair B's ฿28,500 unit has
  been asking the same ฿28,500 since 2026-02-05 without selling — so its asking price is, if anything, an
  over-estimate of what the machine fetches.
- **Not a general "repair history" penalty.** It covers **display** replacement only. Battery has the
  opposite sign; keyboard, top case, board, ports, speakers, camera and fan were never disclosed once.
- **Not the `Unknown` flag.** Per #13, an independently replaced display on an Air or Pro sets **no**
  `Unknown` row at all. This range measures *disclosure*, not *what the pane can see*. The two barely
  overlap.
- **Not a distribution.** n = 2. It is a floor-level observation with named confounds, not a sample.
- **Largely one shop.** Six of eight disclosing machines are one Bangkok operator's stock.

---

## The `Unknown` flag: there is no number, and there is no market that could produce one

`Unknown` appears **0 times in 2,045 listings**. `อะไหล่เทียบ` and `อะไหล่ไม่แท้` describing a part *in the
machine* appear **0 times**. No Thai buyback schedule names the flag. #13 found no Thai-language content
explaining Mac Parts & Service History at all — that remains true; nothing found here changes it.

`฿5,000–8,000` therefore has no evidential basis in the Thai market and **must be struck from #10**, not
adjusted, not widened, not replaced with another number. Four independent reasons it cannot be rescued:

1. **Nobody discloses it,** so it never enters an asking price.
2. **Nobody can read it.** Per #13, the pane requires macOS Tahoe 26; most circulating stock cannot display
   it, and no Thai buyer checklist found mentions it.
3. **It would be attached to the wrong repairs.** Per #13 the pane tracks four components; the display,
   battery and top case swaps that Thai sellers actually perform set no flag.
4. **Direction is all any source claims.** Apple: *"An unknown part might affect the trade-in value of your
   device."* MaKaiTeeTum: a machine showing `Unknown Part` *"ราคาจะตกมากกว่าเดิมทันที"* — the price drops
   further, immediately. Neither states a magnitude. Both were already on record in #13.

**What the guide should say instead** is written out [below](#what-the-guide-should-say).

---

## Arm 2 — buyback deduction schedules

### BKK APPLE — the one Thai operator that publishes a grade rubric naming repair history

**BKK APPLE** (บริษัท เก็ทโมบี้ จำกัด), <https://www.bkkapple.com>. Two pages, both retrieved
**2026-08-04**, neither carrying a publication date; the price table states it is refreshed automatically
from *"Live Market Data"*.

**Grading criteria** — <https://www.bkkapple.com/grading>, verbatim:

| Grade | Name | Criteria as published |
|---|---|---|
| **A** | สภาพนางฟ้า — "angel condition" | No scratches, drops or dents · 100% functional · Battery Health **≥ 90%** · **`ไม่เคยผ่านการแกะซ่อม หรือเปลี่ยนอะไหล่ใดๆ`** — *never opened for repair or had any part replaced* |
| **B** | สภาพดี — good | Hairline marks or light case-bite at the edges · no drop/dent damage · 100% functional · Battery Health **80–89%** |
| **C** | สภาพพอใช้ — fair; headed **`มีรอยตกหล่น / เปลี่ยนอะไหล่แท้`** (drop marks / **genuine parts replaced**) | Dents, chips, visible drop damage · deep screen scratches (not cracked) · overall still working · Battery Health **< 80% (Service warning)** **`หรือเคยเปลี่ยนแบต/จอแท้มา`** — *or has had a genuine battery / display replaced* |
| **!** | มีตำหนิหนัก / เครื่องเสีย | Cracked or lined screen, failed functions, won't power on, locked. *"Priced by the value of the parts still usable."* |

**Price table** — <https://www.bkkapple.com/ตารางราคารับซื้อ-mac>, titled
*"ตารางราคารับซื้อ Mac / MacBook ทุกรุ่น เกรด A และ เกรด B"*. Every Apple-silicon Mac, every RAM/SSD
permutation, two columns.

> **Verified across all 466 rows in the table: Grade B is exactly 85% of Grade A, rounded to the nearest
> ฿100. Every single row. There is no Grade C column anywhere on the page.**

Sample rows, observed 2026-08-04:

| Model | Spec | Grade A | Grade B | B ÷ A |
|---|---|---|---|---|
| MacBook Pro 14" (M1 Pro, 2021) | 16GB / 512GB | ฿18,000 | ฿15,300 | 0.85 |
| MacBook Pro 14" (M1 Pro, 2021) | 32GB / 1TB | ฿22,000 | ฿18,700 | 0.85 |
| MacBook Pro 14" (M5, 2025) | 16GB / 512GB, standard glass | ฿35,000 | ฿29,800 | 0.85 |
| MacBook Pro 14" (M4, 2024) | 16GB / 512GB, standard glass | ฿35,000 | ฿29,800 | 0.85 |
| MacBook Pro 14" (M5, 2025) | 32GB / 2TB, nano-texture | ฿49,000 | ฿41,700 | 0.85 |

**What this establishes, and what it does not.**

- ✅ **Repair history is a named grading criterion in Thailand.** #13's survey found it absent from
  CompAsia, UFicon, asis, cyber-toys and Apple TH's partner terms. It is not absent everywhere. A machine
  that has ever been opened or had any part replaced **cannot be Grade A** at this operator.
- ✅ **A genuine battery or screen replacement is explicitly Grade C** — *below* the published table. This
  is the only Thai source found in this effort or #13 that ties a specific repair to a specific grade.
- ❌ **It does not give a number for the repair.** Grade A → B is **−15%**, but Grade A is a bundle of three
  requirements (cosmetics **and** battery ≥90% **and** never opened); the −15% cannot be attributed to any
  one of them. And Grade B does not restate the repair criterion, so a repaired machine does not sit at
  −15% — it sits in Grade C.
- ❌ **Grade C is not priced.** The published schedule proves a repaired machine is worth **less than 85% of
  Grade A** in this channel and puts **no floor under it at all**.

The site's model pages (`/mac/model/…`) render their quote client-side and returned no figure to a
server-side fetch, so no Grade C number could be obtained without submitting a real machine — which is
what a controlled quote experiment would be, and is left [unpinned](#unpinned--could-not-establish).

### Other operators, re-checked

- **sys.co.th** (รับซื้อซากโน๊ตบุ๊ค, retrieved 2026-08-04): *"เคยแกะซ่อมหรือเปลี่ยนอะไหล่ควรบอกทีมงานตรง ๆ"*
  — if it has been opened for repair or had parts replaced, tell the team straight. A disclosure duty, no
  deduction.
- **asis.co.th** (retrieved 2026-08-04) advertises paying top prices for machines *"ไม่เคยแกะซ่อม ไม่เคย
  ตกกระแทก"* — never opened, never dropped. Direction; no schedule. #13 had already established that its
  published *factor list* omits repair history.
- **MaKaiTeeTum**, <https://makaiteetum.com/macbook-m4-market-price-trends/> — read in full for this ticket
  because it is MacBook-specific rather than iPhone-framed. It prices **generation churn** (M3/M2 fell
  10–20% within two months of the M4 launch) and says >500 charge cycles *"อาจต้องหักราคาลงตามสภาพการใช้งาน"*
  (may need a deduction). **It says nothing about repair history.** Its iPhone-framed `Unknown Part`
  statement, already quoted in #13, remains the strongest Thai statement on the flag and remains
  magnitude-free.
- **168bnt.com**, <https://www.168bnt.com/blog/sell-macbook> (buyback table, "อัปเดต ก.ค. 2026"): quantifies
  only the Apple Trade In channel penalty — *"ได้ราคาต่ำกว่าตลาดมือสอง 30-50%"*, and as store credit. No
  repair-history line.

---

## Arm 3 — seller and shop statements

Nothing new of substance; #13 had already collected the usable Thai statements. Two additions, both
direction-only:

- Thai MacBook Pro community group `facebook.com/groups/mbpcommth`, post 3577102792440905 (indexed
  2026-08-04): a buyer asks whether a machine's display had been swapped and the seller was evasive; a
  replier answers *"มันไม่น่าจะบัคนะครับ มันไม่ขึ้นแน่นอนครับถ้าไม่ได้เปลี่ยนอะไหล่มา"* — the warning
  wouldn't appear unless a part had been swapped. **Buyers in this market treat a swapped part as
  something to detect and argue about, not something with a price.** Retrievable only as a search snippet;
  the group requires a session.
- Double Mac's own listing text is the market's clearest statement, and it is a *behavioural* one: a
  replaced battery goes in the **headline** (`เปลี่ยนแบตเตอร์รี่มาใหม่ ใช้งานต่อได้ยาวๆหายห่วง`), a replaced
  display goes in the **`ตำหนิ` (defects) field** — *even when the seller says it was genuine and done at
  the Apple service centre*.

---

## The battery exception: a replacement is advertised, not hidden

This inverts an assumption running through #10 and the current README.

| Channel | A replaced battery is… | Evidence |
|---|---|---|
| **Retail listing** (what the buyer will face at the shop) | **A selling point, priced up.** Double Mac's battery-replaced 16" M2 Pro asks ฿41,900 against ฿38,900 for the same model with a replaced screen and an 80% battery. J-Group's 2024 Air M1 leads with `พึ่งเคลมแบตใหม่มาจากศูนย์` (battery just replaced under warranty at the service centre) — <https://mac2hand.com/detail/339505/x>, 2024-07-08 | Medium |
| **Buyback** (what the buyer will face when *they* sell) | **Grade C** — below the published table | BKK APPLE `/grading`, 2026-08-04 |

Both are true at once and they are not in conflict: a fresh battery removes a cost the *next* buyer would
otherwise carry (฿5,590–฿8,690 at Apple TH per #13), which the listing market pays for; the buyback market
prices the opened chassis, which it does not.

**For the guide:** "the battery has been replaced" is **not** a 💰 finding on resale grounds. If anything
it is a 📝 with an upside. Whether the replacement was genuine is a separate question — and per #13 every
Thai independent found was fitting aftermarket cells, so `เปลี่ยนแบตใหม่` on a listing usually means an
aftermarket cell, not an Apple one.

---

## Does the penalty land as time on market instead?

The one shop that discloses is also the only shop whose stock can be tracked across re-listings, because it
carries an internal product code (`รหัสสินค้า`) in every ad, on both marketplaces and both Kaidee accounts.
**38 distinct units** could be followed.

> **Not one of the 38 units ever changed price across a re-listing.** Same product code, same baht, months
> apart. This shop does not mark down. Whatever adjustment happens, happens in time, not in price.

| | n | Median days between first and last sighting |
|---|---|---|
| Disclosed a repair | **5** | **83** |
| No disclosure | **33** | **40** |

Longest-running disclosed unit: code 61283, the ฿28,500 M1 Pro 14", first seen **2026-02-05**, still live
**2026-08-01** — **177 days** unsold at an unchanged price. But two *undisclosed* units ran longer (194 and
192 days), so disclosure is plainly not the only driver, the observation window right-censors everything,
and n = 5 will not carry a claim.

**Verdict: consistent with a time-on-market penalty, insufficient to assert one.** The guide should not
claim it.

---

## What the guide should say

Concretely, for [#10](https://github.com/mingrath/mbcheck/issues/10)'s five-field report:

**Parts & Service shows `Unknown` — replace the `Financial impact` line with:**

> ฿0 to fix · **resale impact: real in direction, unmeasured in Thailand.** Apple says only that an unknown
> part *"might affect the trade-in value"*. No Thai marketplace listing, buyback schedule or shop statement
> puts a number on it — checked against 2,045 Thai second-hand MacBook listings, 2026-08-04, in which the
> flag is mentioned zero times.

**A disclosed repair history (display) — a new, separate row, if the guide wants one:**

> ฿0 to fix (it is already fixed) · **resale: ฿3,000–฿5,400 off a ฿27,000–฿34,000 asking price (10–16%),
> from 2 matched Thai listing pairs, observed 2026-08-04.** Asking prices, not sale prices. Display only.

**A disclosed battery replacement:**

> 📝 Note, not 💰. It is advertised as a selling point in Thailand and prices *up*, not down — though the
> cell is probably aftermarket. It does cost you a grade when you resell to a buyback shop.

**The one thing worth teaching the buyer, which is not a number:**

> In Thailand the seller's phrase to look for is **`ไม่เคยแกะ ไม่เคยซ่อม`** — *never opened, never
> repaired*. Only **2.7%** of listings make that claim (56 of 2,045), and only 1 in 256 discloses a
> repair, so its absence proves nothing on its own — but a seller who has written it has made a statement you can hold
> them to. If the listing does not say it, ask, and ask them to say it in writing in the chat.

And the useful negative, which the report should carry so the reader does not go looking:

> Whether a repaired machine has been *repriced* or is simply *sitting* is not knowable from the outside.
> The one Thai shop that discloses repairs never marks a machine down; its disclosed stock simply stays on
> sale longer.

---

## Unresolved conflicts in the sources

1. **One machine is advertised, by the same shop, both with and without a display replacement.** Product
   code 62547, `MacBook Air 13-inch M2 2022 16GB/1TB Midnight`, AppleCare+ to 2027-02-20, 210 cycles / 83%,
   **฿32,500 in both ads** — but <https://mac2hand.com/detail/1000490/x> gives `ตำหนิ : สภาพดี สเปคดีหายากมาก
   ยังมีประกันศูนย์` while <https://mac2hand.com/detail/1000487/x> gives `ตำหนิ : สภาพดี มีรอยการใช้งานเคยเปลี่ยน
   หน้าจอ`. Same unit, same price, same day, contradictory disclosure. Either the shop copy-pastes its
   defect field carelessly, or a disclosure is being dropped from one copy. **Consequence:** even the one
   Thai shop that does disclose is not reliable at it, which further weakens any inference from disclosure
   frequency.
2. **BKK APPLE grades a genuine screen replacement to C, but Grade C requires physical damage** ("dents,
   chips, visible drop damage") **or** low battery **or** a replaced battery/screen. A cosmetically perfect
   machine with a genuine Apple screen replacement therefore satisfies a C criterion while failing every
   other C description. Which the appraiser applies in the shop is not published.
3. **Apple TH's own trade-in partner publishes no grading schedule at all** (#13), while a private operator
   publishes a detailed one. The "official" channel is the *less* transparent one on this question.
4. **Direction of the battery effect reverses by channel** — see above. Not a contradiction in the
   evidence, but it will read as one to anybody who meets only half of it.

---

## Unpinned / could not establish

| # | Missing | Why | What would pin it |
|---|---|---|---|
| 1 | **Any Thai baht or percentage figure for an `Unknown` / non-genuine-part flag** | Zero mentions in 2,045 listings; no buyback schedule names it; no shop statement quantifies it. This is now a **twice-searched** negative (#13 and #18). | Realistically nothing until the pane is readable on ordinary Thai stock. A controlled quote experiment could not even stage it, since no machine in the market is known to display `Unknown`. |
| 2 | **BKK APPLE's Grade C prices** | The published table stops at Grade B; model pages compute quotes client-side | Submit one real machine through `/quote` twice, varying only the repair answer. That is the controlled quote experiment #18 authorised, and it needs a physical machine. |
| 3 | **Any second Thai operator publishing a grade rubric that names repair history** | Only BKK APPLE found. #13 cleared five others; four more (Studio7, iStudio, BaNANA, PowerBuy) publish that grades exist without publishing boundaries | Ask each directly over LINE |
| 4 | **Penalty for a replaced top case / keyboard, logic board, port board, speaker, camera, mic or fan** | **Never disclosed once in 2,045 listings.** Not a sampling failure — the disclosure does not exist in this market | Nothing observational. Would need a quote experiment per component |
| 5 | **Transacted prices** | Neither mac2hand nor Kaidee publishes a sold price or a sold flag; listings simply disappear or are re-posted | A cooperating shop's sales ledger |
| 6 | **Facebook Marketplace and the Thai Mac groups** | Both require an authenticated session; group price lists are frequently photographed tables inside image posts. Excluded rather than hand-sampled and presented as systematic | A logged-in browser session, and hand-coding — the groups are where private sellers trade, so this is the largest known blind spot |
| 7 | **A private-seller-only estimate** | Six of eight disclosing machines are one shop. Private sellers in this corpus effectively never disclose | Same as #6 |
| 8 | **Whether the ฿3,000–5,400 gap is a discount or a different machine** | Asking prices only; no way to confirm the disclosed units ever sold, and one has been asking the same price for 177 days | #5 |
| 9 | **Whether Thai buyers *ask* about repair history at the shop** | The one community thread found suggests yes; a single thread is not evidence of a norm | A survey, or a larger group corpus |
| 10 | **Whether any Thai operator refuses a MacBook with non-genuine parts outright** | Still no published policy either way. Carried forward unchanged from #13 | Direct enquiry |

---

## Method and tooling

Retrieval was run **2026-08-04** in one session.

- **Marketplace corpora** were harvested directly with `curl` against the two sites' own server-rendered
  pages: mac2hand returns complete HTML cards and detail pages; Kaidee embeds a full `__NEXT_DATA__` JSON
  payload carrying price, title, seller, description, `firstApprovedTime` and status on both category and
  product pages. All parsing was done locally in Python. Kaidee rate-limits parallel requests (returns
  49-byte bodies); its pages were fetched sequentially with a delay after that was detected. mac2hand
  tolerated 12-way parallelism — 1,858 detail pages in 75 seconds.
- **AgentKey** MCP (`Serper/search`) was used for all discovery searching, per #18 and the map. Built-in
  WebSearch/WebFetch were **not** used. The BKK APPLE schedule — the one genuinely new source in this note
  — came from the Thai-language query `ตารางราคารับซื้อ MacBook มือสอง เกรด A B C สภาพ หักกี่บาท 2569`;
  it does not surface on English queries.
- **Thai-language searching was necessary and decisive.** Three of the four English-shaped angles returned
  nothing usable. The Thai terms that actually paid: `เคยเปลี่ยนหน้าจอ` (the phrase disclosing sellers
  actually use — **not** #18's suggested `เปลี่ยนแบต MacBook มือสอง ราคา`, which returns repair-shop
  advertising), `ไม่เคยแกะ ไม่เคยซ่อม` (the value claim), `ตำหนิ` (the structured defects field),
  `เกรด A / เกรด B` (the buyback rubric).

**Three traps caught during verification**, recorded so they are not reintroduced:

1. **`เทียบ` is not "aftermarket part" on these sites.** Scanning whole pages returned 129 hits; every one
   was `เปรียบเทียบ` ("compare") in the site's own Geekbench chrome. All keyword counts in this note are
   over seller-written text only.
2. **`ซ่อม` is not a disclosure.** 142 mac2hand listings contain it; every occurrence is either the shop's
   own hashtag (`#ซ่อมMacBook`, `#รับซื้อซากเครื่อง MAC ตกน้ำ`) or the negated claim `ไม่เคยซ่อม`. Counting
   raw `ซ่อม` hits would have produced a 7.6% "disclosure rate" instead of the true 0.39%.
3. **`ไม่แท้` on a Thai MacBook listing means the *charger*.** All 13 occurrences are `ชุดชาร์จไม่แท้` /
   `หัวชาร์จไม่แท้`. Reading them as non-genuine machine parts would have manufactured exactly the figure
   #18 forbids.

**Sources deliberately excluded rather than quoted unverified:** Facebook Marketplace and Thai Mac groups
(session-gated; group price lists are images), Shopee and Lazada (no server-rendered prices, and a
new-goods channel), and any listing whose model could not be resolved to a specific Apple-silicon
generation.
