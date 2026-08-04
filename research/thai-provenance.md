# Thai second-hand Mac provenance risks

Research note resolving [issue #7](https://github.com/mingrath/mbcheck/issues/7).
Feeds the **fraudulent provenance** risk axis and the single `## Thailand` block in `README.md`
fixed by [issue #11](https://github.com/mingrath/mbcheck/issues/11). Companion to
[`research/thai-repair-prices.md`](https://github.com/mingrath/mbcheck/tree/research/thai-repair-prices)
(issue #13), which owns every ฿ repair figure — **no repair price is restated here**.

**Research date: 2026-08-04.** Every fact carries its own observed date. Where a source page carries
no publication date, that is stated rather than glossed. Forum, shop and social-media statements are
labelled **CLAIM** and are never promoted to fact.

---

## The one-paragraph answer

Thailand's Mac-specific provenance risk is **not** a stolen-goods registry problem — no such registry
exists to consult — it is a **paperwork and channel** problem, and it converges on a single document.

Nothing on an Apple-silicon Mac reveals where it was sold. Serials went randomised in 2021, so region
decoding is dead on M1–M5; `checkcoverage.apple.com` and About This Mac document no country field; the
keyboard is a soft signal at best because Apple Thailand sells non-Thai layouts to order. **The
original Thai tax invoice is the only real provenance test** — and the same document is what makes
remaining AppleCare+ transferable (§9), what Apple demands for an Activation Lock support request, and
what the police ask for if the machine is ever reported stolen. One piece of paper, four jobs.

Three further findings reshape the Thailand section. **Where you buy changes your legal position more
than any check you can run.** Thai civil law (CCC s.1332) lets a good-faith buyer who bought *in a
market or from a merchant dealing in that kind of goods* keep a stolen machine unless the true owner
refunds the price; a good-faith buyer who bought from *a private individual* hands it back and gets
**nothing**. **MDM in Thailand is a financing lock, not mainly a corporate one** — instalment and pawn
shops enroll devices so they can lock them on non-payment, which feeds MDM-encumbered stock into
ordinary second-hand supply. And **no platform protects this transaction**: Meta excludes local-pickup
cash sales in terms, and Kaidee has no payment rail at all.

---

## ⚠️ Corrections and additions this research forces on the current README

| # | README says / omits | Reality | Where |
|---|---|---|---|
| 1 | Thai phrase list of 5, no MDM question | **MDM is unasked.** Thailand's second-hand supply carries MDM from instalment and pawn shops, not just ex-corporate fleets. Phrase added. | [Phrasebook](#the-phrasebook), [MDM](#mdm-in-thailand-is-an-instalment-lock-not-only-a-corporate-one) |
| 2 | "You got a **receipt** with the serial number and the seller's phone number" | Right ask, wrong justification. **No Thai document is legally required to carry a serial** — not the tax invoice (s.86/4), not the receipt (s.105 ทวิ). Apple itself says a reseller lists the serial only "if the reseller normally lists serial numbers". The receipt's real value is that **Apple requires proof of purchase for an Activation Lock support request**. | [Receipts](#receipts-and-tax-invoices) |
| 3 | "Can I have a receipt? — ขอใบเสร็จด้วยครับ" | Ambiguous between **ใบเสร็จรับเงิน** and **ใบกำกับภาษี**, and a private seller **may not lawfully issue** a tax invoice (s.86/13). Asking the wrong one asks a seller to commit an offence. | [Receipts](#receipts-and-tax-invoices) |
| 4 | Says "Apple ID" throughout | Apple TH copy now says **บัญชี Apple** (Apple Account). Still understood, but not current. | [Terminology](#apple-thailands-own-thai-terminology) |
| 5 | Treats the transaction as machine-only | **Where you buy changes your legal position.** CCC s.1332 protects a buyer from a licensed shop in a market; it does not protect a buyer from a stranger. That is a bigger lever than any check in the guide. | [Stolen](#if-the-mac-turns-out-to-be-stolen) |
| 6 | Implies iCloud sign-out settles the lock question | Thai shop guidance says the quiet part out loud: **"แค่ปลด iCloud ไม่ได้หมายความว่าปลอดภัยเสมอไป"** — signing out of iCloud does not clear MDM/DEP. Matches issue #9's finding about Erase All Content and Settings. | [MDM](#mdm-in-thailand-is-an-instalment-lock-not-only-a-corporate-one) |
| 7 | "check it at checkcoverage.apple.com … you want the model to match" | Stands as a *warranty-date* check, but must not be sold as a provenance check. Apple documents **no country-of-purchase output**, and on an M1–M5 Mac **the serial encodes no region at all** — serials went randomised in 2021. | [Grey imports](#grey-imports-เครื่องหิ้ว-and-regional-warranty) |
| 8 | No mention of AppleCare+ on resale | AppleCare+ bought in Thailand is **Thailand-only** (§10(d)) and transfers to a new owner **once**, and only with the **original proof of purchase** plus written notice to Apple South Asia (Thailand) (§9). "AppleCare+ เหลือ 2 ปี" without the paperwork is worth much less than it sounds. | [Grey imports](#grey-imports-เครื่องหิ้ว-and-regional-warranty) |

---

## Apple Thailand's own Thai terminology

Getting these right matters: the guide is asking a Thai seller questions, and two of Apple's Thai
terms collide with everyday trade usage.

| English | Apple TH's Thai | Source | Page date |
|---|---|---|---|
| Activation Lock (Mac) | **การล็อคการเข้าใช้เครื่อง** | <https://support.apple.com/th-th/102541> | 9 ก.ค. 2569 = 2026-07-09 |
| Apple ID → Apple Account | **บัญชี Apple** | same | 2026-07-09 |
| Find My | **ค้นหาของฉัน** / "ค้นหา Mac ของฉัน" | same | 2026-07-09 |
| System Settings | **การตั้งค่าระบบ** | same | 2026-07-09 |
| Supervision | **การกำกับดูแล** | <https://support.apple.com/th-th/102291> | 22 เม.ย. 2569 = 2026-04-22 |
| Device management / MDM | **การจัดการอุปกรณ์** / **การจัดการอุปกรณ์เคลื่อนที่ (Mobile Device Management)** | same; <https://support.apple.com/th-th/105058> | 2026-04-22 |
| Automated Device Enrollment (DEP) | **การลงทะเบียนอุปกรณ์อัตโนมัติ** | <https://support.apple.com/th-th/109030>, <https://support.apple.com/th-th/124963> | undated on page |
| Setup Assistant | **ผู้ช่วยตั้งค่า** | same | undated on page |

Two traps:

1. **การล็อคการเข้าใช้เครื่อง vs การล็อคการเปิดใช้งาน.** Apple's *own* Thai page 102541 uses the first
   in its title and headings and the second, once, in the offline-removal steps. Both mean Activation
   Lock. A seller may know either. Observed 2026-08-04.
2. **การจัดการระยะไกล is ambiguous and should be avoided.** In macOS's Thai UI it means *Apple Remote
   Desktop* screen sharing, under การตั้งค่าระบบ → ทั่วไป → การแชร์
   (<https://support.apple.com/th-th/guide/mac-help/mh11851/mac>,
   <https://support.apple.com/th-th/guide/mac-help/mchl26e04309/mac>) — **not** MDM. In the Thai
   second-hand trade the identical words are used for the MDM lock screen. Ask with the loanword
   **"ติด MDM"**, which is unambiguous and universally understood in the trade.

Parts & Service History renders as **ชิ้นส่วนและบริการ** — established in
[`research/thai-repair-prices.md`](https://github.com/mingrath/mbcheck/tree/research/thai-repair-prices)
and not re-derived here.

---

## Grey imports (เครื่องหิ้ว) and regional warranty

### What Apple's contract actually says

The folk wisdom in Thai Mac circles is "Mac ประกัน worldwide". **Apple's own contract does not say
that.** It says Apple *may* restrict service to the country of original sale.

Apple One (1) Year Limited Warranty, Rest of Asia Pacific — verbatim, English
(<https://www.apple.com/legal/warranty/products/warranty-rest-of-apac-english.html>, current version
listed as **November 09, 2023 – Present**, observed 2026-08-04), under the heading **IMPORTANT
RESTRICTION FOR SERVICE**:

> "Apple may restrict warranty service for hardware products to the country where Apple or its
> Authorized Distributors originally sold the device."

The same clause in Thai
(<https://www.apple.com/legal/warranty/products/warranty-rest-of-apac-thai.html>, current version
listed as **March 01, 2023 – Present**), under **ข้อจำกัดประการสำคัญสำหรับการให้บริการ**:

> "Apple อาจจำกัดบริการภายใต้การรับประกันสำหรับผลิตภัณฑ์ฮาร์ดแวร์เฉพาะในประเทศที่ Apple หรือผู้แทนจำหน่ายที่ได้รับอนุญาตจาก Apple ขายอุปกรณ์ที่มีการซื้อมาแต่แรกเท่านั้น"

And on cross-border service, English:

> "Service will be limited to the options available in the country where service is requested. Service
> options, parts availability and response times may vary according to country… **If you seek service
> in a country that is not the original country of purchase**, you will comply with all applicable
> import and export laws and regulations and be responsible for all custom duties, V.A.T. and other
> associated taxes and charges. **Where international service is available**, Apple may repair or
> replace Apple Products and parts with comparable Apple Products and parts that comply with local
> standards."

The Thai warranty obligor is **Apple South Asia (Thailand) Limited**, 999/9 The Offices at
CentralWorld, 44th floor, Rama 1 Rd, Pathumwan, Bangkok 10330 — and the obligor is defined
*"สำหรับประเทศหรือภูมิภาคที่ซื้อผลิตภัณฑ์ดังกล่าวเป็นครั้งแรก"*, for the country where the product was **first
purchased**.

⚠️ **The Thai page lags the English page by at least one revision** (Mar 2023 vs Nov 2023). Cite both.

### AppleCare+ bought in Thailand is Thailand-only, and transfers once

From the current Thai AppleCare+ for Mac terms
(<https://www.apple.com/legal/sales-support/applecare/applecareplus/2603/260302_applecareplusmac_th.pdf>,
effective **4 March 2026**, observed 2026-08-04):

| Clause | What it says |
|---|---|
| **§1** | Covered equipment must be bought **new** from Apple or an Apple Authorised Reseller — *"ต้องซื้อหรือเช่าซื้อเป็นของใหม่จาก Apple หรือตัวแทนจำหน่ายที่ได้รับอนุญาตของ Apple"* |
| **§2.3** | If you claim **outside Thailand**, you pay that country's service fee in its currency — so Apple contemplates the Thai plan being used abroad |
| **§3.1** | *"Apple อาจจำกัดบริการด้านฮาร์ดแวร์และบริการ ADH **เฉพาะในประเทศที่คุณซื้ออุปกรณ์ที่ได้รับความคุ้มครองมาตั้งแต่แรกเท่านั้น**"* — Apple may limit hardware and accidental-damage service to the country of original purchase |
| **§8.4** | Apple may **cancel the plan outright** if service parts become unavailable — 30 days' written notice, pro-rata refund |
| **§9** | The plan transfers to a new owner **once, permanently**, on three conditions: you hand over the **original proof of purchase**, plan confirmation, printed plan materials and the contract; you send **written notice** to AppleCare Administration, Apple South Asia (Thailand) Ltd; and the transferee accepts the terms. The notice must state the **plan agreement number, the device serial number**, and the new owner's name, address, phone and email |
| **§10(d)** | *"แผนนี้เสนอและมีผลใช้ได้**เฉพาะในประเทศไทยเท่านั้น**"* — the plan is offered and valid **only in Thailand** |

AppleCare Administration in Thailand: **1800 019 900** (toll-free within Thailand).

**Reading, stated carefully.** §10(d) means a plan bought abroad is a *different contract* under that
country's terms — and **no Apple document says a foreign AppleCare+ plan is honoured in Thailand.** In
practice it often is; that is discretion, not a term. §3.1 and §2.3 look contradictory to a reader but
are not: §3.1 is a reserved right, §2.3 is the fee mechanics for when Apple does not exercise it.

**Buyer consequence.** A listing advertising "AppleCare+ เหลือ 2 ปี" is worth materially less unless the
seller hands over the **original purchase receipt and plan confirmation** and you jointly send the §9
notice — otherwise §9(1) is simply not satisfied and the plan does not follow the machine.

Note also that Apple's own marketing sits in tension with its own contract: apple.com/th/applecare
advertises *"เข้าถึงการซ่อมทั่วโลก … กว่า 5,000 แห่งทั่วโลก"* (worldwide repair access, 5,000+ providers,
undated marketing page, observed 2026-08-04). Both are Apple pages. **The contract governs; the
marketing describes normal practice.**

### Will a Thai AASP actually refuse a grey-import Mac?

Contractually Apple may permit them to (above). In stated practice, the one Thai AASP with a published
position says no — **CLAIM**, iCare, the service arm of Com7/Comseven (Studio7, Banana IT),
<https://icarecomseven.com/service-support/faq/>, `article:modified_time` **2023-03-09**, observed
2026-08-04:

> **"6. Macbook / iPad / Airpod เครื่องซื้อต่างประเทศ ส่งเคลม iCare ได้หรือไม่ ?**
> ตอบ : ปัจจุบันยังสามารถให้บริการระหว่างประเทศได้ตามปกติ ยังไม่มีข้อจำกัดทางด้าน Model รุ่นต่างๆ"

*"Can a MacBook / iPad / AirPods bought abroad be claimed at iCare? — At present international service
can still be provided as normal; there are as yet no model-based restrictions."* Note the hedges:
**ปัจจุบัน** ("at present") and **ยังไม่มี** ("not yet").

The same FAQ's **iPhone** answer is conditional — a replacement is the **local-market** model, because
a US iPhone is eSIM-only while the Thai model has a physical SIM. So the Mac/iPhone asymmetry the
market assumes is real, and a Thai AASP states it itself.

A counter-anecdote shows practice is not uniform — **CLAIM**, Pantip topic 42239163, posted
**2023-09-24**, comment 3: a Japan-market Apple Watch was **refused by iCare** —
*"iCare ให้กลับไปคุยกับ Apple Support เพราะเป็นรหัสญี่ปุ่น"* — and was then handled and replaced free of
charge by the **Apple Store Genius Bar at Apple Iconsiam**. Different product class, but it shows AASP
and Apple-owned-store outcomes diverge, and that **รหัส** (country code) is a live operational concept
at Thai counters. The same thread (comment 2, **CLAIM**) notes that per-model international
serviceability *"ไม่มีบทความที่เป็น public ต้องโทรให้เจ้าหน้าที่เช็ค"* — is not published anywhere; you must
phone and have staff check that specific model. **That is, in fact, the correct buyer procedure:
1800 019 900 with the serial in hand.**

### Detecting a grey import at the shop — what works and what does not

| Signal | Verdict |
|---|---|
| **Serial number region decoding** | ❌ **Dead on M1–M5.** Apple moved to randomised serials in 2021 (**CLAIM**, secondary press: <https://appleinsider.com/articles/21/05/05/apple-begins-transition-to-randomized-device-serial-numbers-with-purple-iphone-12>, 2021-05-05). Apple has **never** published a decoder; the circulating factory-code tables (FC = Fountain, C02, W8 …) decode the **pre-2021 12-character format only**. A shop that decodes a 2021+ serial to "this is a Japanese unit" is reading a pre-2021 machine or making it up |
| **checkcoverage.apple.com** | ❌ for provenance. Apple's documented outputs are purchase date, telephone-support eligibility, and repair/service coverage. **No country-of-purchase field is documented anywhere by Apple.** Keep it as a warranty-date check |
| **About This Mac / Settings → General → About** | ❌ No country field exists in macOS |
| **Keyboard layout** | ⚠️ **Soft, and easy to get backwards.** Apple TH's own store sells MacBook Air with a choice of **4 keyboard languages** (<https://www.apple.com/th/shop/buy-mac/macbook-air>, live, observed 2026-08-04), so a Thai-market machine can legitimately carry a non-Thai keyboard. **Thai-engraved keycaps are positive evidence of a Thai unit; non-Thai keys prove nothing.** A JIS layout is the strongest single tell |
| **AC adapter / duckhead** | ⚠️ Soft. A **Type G** (UK/HK) duckhead or a **JIS 100 V** adapter does not fit Thai outlets and would not be shipped by Apple TH, so it is a strong non-Thai tell. A US-style flat-blade duckhead is ambiguous — it physically fits Thai sockets |
| **NBTC marking** | ⚠️ **The premise needs correcting, then discarding.** A MacBook has Wi-Fi and Bluetooth and *is* within NBTC's scope — SDoC self-declaration, Class A registration, Class B certification under ประกาศ กสทช. … พ.ศ. 2559 (<https://standard.nbtc.go.th/บริการออนไลน์/SDoC-Online.aspx>), public registry <https://mocheck.nbtc.go.th/>. But certification is a **model-level importer obligation, not a per-unit consumer marking**, so its absence on a given laptop proves nothing and its presence proves nothing about that box |
| **The original Thai tax invoice** | ✅ **The only decisive test.** A Thai VAT invoice from Apple TH, iStudio/Copperwired, iStudio by SPVi, Studio7, Banana IT, uFicon or Power Mac Center. It is also the document AppleCare+ §9 transfer requires, the one Apple wants for an Activation Lock support request, and the one the police want if the machine is ever reported stolen |

Supporting fact: apple.com orders cannot be shipped across borders — *"รายการสั่งซื้อซึ่งทำใน apple.com
สามารถจัดส่งได้ภายในประเทศหรือภูมิภาคที่ทำการสั่งซื้อเท่านั้น"* (Apple TH store FAQ, live, observed
2026-08-04). So a US-Apple-Store Mac sitting in Bangkok was hand-carried or freight-forwarded.

### What a grey import costs the buyer

- **Warranty.** Both the base one-year warranty and AppleCare+ reserve the right to confine service to
  the country of original sale. Even where international service *is* granted, Apple states that
  service options, **parts availability** and response times vary by country, and reserves the right to
  substitute parts complying with local standards. AppleCare+ TH §8.4 lets Apple cancel a plan outright
  if parts become unavailable — a real contractual failure mode for an unusual regional configuration.
- **Import duty and VAT.** Thai Customs exempts accompanied personal/professional goods up to
  **฿20,000**, and assesses accompanied goods of non-commercial character up to **฿200,000** on the spot
  at the Red Channel (<https://www.customs.go.th/list_strc_simple_neted.php?ini_content=individual_160503_03_160905_01&lang=th>,
  undated government page, observed 2026-08-04), computing `value × duty rate = duty`, then
  `(value + duty) × 7% = VAT` (<https://www.mof.go.th/document/40684/>). A MacBook Air at Apple TH's
  ฿44,900 RRP is far over the ฿20,000 personal exemption, so a hand-carried unit is declarable.
- **UNPINNED: the import duty rate for portable computers (HS 8471.30).** Widely 0% under the WTO
  Information Technology Agreement, which would leave 7% VAT as the whole exposure — **not verified
  against the Thai tariff and therefore not asserted.**
- **UNPINNED: whether a second-hand buyer inherits liability for a machine that was never declared.**
  In principle the *importer* is liable, but the Customs Act B.E. 2560 contains possession offences for
  duty-evading goods. **Left unresolved rather than reassuring the buyer.**
- **UNPINNED: any price differential between เครื่องศูนย์ and เครื่องหิ้ว for Macs.** Two Thai-language
  searches returned only iPhone-focused social content. The most concrete generic statement found
  (**CLAIM**, <https://www.alottechs.com/article/which-iphone-should-i-buy>, 2025-01-13) says only that
  grey imports are *"มักมีราคาถูกกว่า"* — usually cheaper — with no figure. **No Mac number is invented
  here.**

---

## MDM in Thailand is an instalment lock, not only a corporate one

This is the most consequential finding in the note, because it changes *who* the MDM check is aimed at.

Outside Thailand, MDM-locked second-hand Macs are overwhelmingly ex-corporate or ex-education fleet
stock. In Thailand there is a second, larger population: **devices sold on instalment (ผ่อน) or taken
in pawn (จำนำ), enrolled in MDM by the shop so it can lock the device if payments stop.**

Evidence, all **CLAIM** (forum and shop sources), with dates:

- **Pantip topic 43680532**, posted 13 สิงหาคม 2568 = **2025-08-13**
  (<https://pantip.com/topic/43680532>), verbatim:
  > "ตัวผมได้ทำการผ่อนมือถือรุ่นนึงของค่ายผลไม้ เท่าที่ทราบคร่าวๆคือทางร้านจะฝังระบบที่เรียกว่า MDM ในภายในเครื่อง เพื่อใช้ในการควบคุม กรณีที่ไม่ชำระ,หนีหาย ทางร้านสามารถล็อคเครื่องได้"

  *"I bought a phone from the fruit company on instalments. As far as I know, the shop implants a
  system called MDM inside the device to control it — if you don't pay, or disappear, the shop can
  lock it."* ⚠️ **This is a phone, not a Mac.** The extrapolation to MacBooks is flagged, not assumed.
- **jumnum2go**, a Thai pawn/second-hand shop, article published **2025-07-30**
  (<https://www.jumnum2go.com/check-used-iphone-mdm/>). It lists the MDM/DEP sources as
  *"บริษัทหรือโรงเรียนแจกเครื่องพนักงาน/นักเรียน / โอเปอเรเตอร์ขายเครื่องผ่อน / เครื่องยังติดสัญญาและยังไม่จ่ายครบ"* —
  corporate/school issue, **operators selling on instalment, and devices still under an unpaid
  contract** — and states the point the README misses:
  > "แค่ปลด iCloud ไม่ได้หมายความว่าปลอดภัยเสมอไป เพราะเครื่องที่ยังติด MDM หรือ DEP สามารถถูกล็อกหรือล้างข้อมูลได้ทุกเมื่อ"

  *"Merely releasing iCloud does not always mean it's safe, because a device still on MDM or DEP can
  be locked or wiped at any time."*
  **This is the only Thai-language pre-purchase MDM checklist found, and it is iPhone-only.** No Mac
  equivalent exists in Thai.
- A Thai Facebook buy-list post advertises **"รับซื้อ iPhone 13–17 ProMax ทุกรุ่น รับเครื่องติดผ่อน / MDM / …"**
  — *we buy … including devices still on instalment / on MDM*
  (<https://www.facebook.com/groups/628129734000847/posts/3680717165408740/>). A shop Instagram account
  buying **iPhone · iPad · MacBook** carries the hashtags *#ร้านรับผ่อนมือถือ #จำนำ #MDM #การจัดการระยะ…*
  (<https://www.instagram.com/p/DaUuuKRmz57/>). There is a live Thai trade **in** encumbered devices,
  which is how they re-enter ordinary second-hand supply.
- The **pawn channel reaches Macs specifically**: Pantip topic 42818555, posted
  02 กรกฎาคม 2567 = **2024-07-02** (<https://pantip.com/topic/42818555>):
  *"ได้ MacBook Air มาจากโรงจำนำ เจ้าของเดิมจด icloud กับ อีเมลไว้ให้"* — a MacBook Air bought out of a
  pawnshop, still carrying the previous owner's iCloud account.
- **"จำนำไอคลาวด์"** — pawning the Apple Account itself while keeping physical possession of the device
  — is a distinct Thai practice: Pantip 42169312 (*"เครื่องติดล็อคจากร้านจำนำไอคราว"*, and note the poster's
  own aside *"ใบเสร็จในการซื้อไม่มี"* — no purchase receipt) and Pantip 43823822. It means a machine can
  be **encumbered by a lender who is not the person selling it to you**.
- The only Mac-specific Remote Management account found is old: Pantip topic 38240795,
  **2018-11-05** (<https://pantip.com/topic/38240795>) — *"Mac ซื้อมือสองมา ลง OS ใหม่ติดหน้า Remote
  Management … กดข้ามก็ไม่ได้ มันให้ใส่รหัสอย่างเดียว"* — bought second-hand, reinstalled the OS, hit the
  Remote Management screen, cannot skip. ⚠️ Intel era; flagged.

**Consequence for the guide.** `profiles status -type enrollment` (verified unprivileged while
resolving [#11](https://github.com/mingrath/mbcheck/issues/11)) is not a niche check in Thailand. And
the accompanying *question* to the seller should not be "was this a company machine?" — it should be
**"is it still on instalment, or has it ever been enrolled in MDM?"**, because the Thai population is
financing-driven.

**UNPINNED:** whether Thai instalment and pawn shops apply MDM to **MacBooks** specifically, as
opposed to iPhones and iPads. Every direct account found is about a phone. *To pin:* a Thai instalment
shop's published MacBook terms, or a first-hand Mac account.

---

## Receipts and tax invoices

### What Thai law actually requires

| Document | Thai | Who must issue | Serial number required? |
|---|---|---|---|
| Tax invoice | **ใบกำกับภาษี** | A **VAT-registered** operator, for every sale, delivered to the buyer — Revenue Code **s.86**. A non-registrant is **forbidden** to issue one — **s.86/13**. | **No** — s.86/4's eight fields do not include it |
| Abbreviated tax invoice | **ใบกำกับภาษีอย่างย่อ** | Retail businesses — **s.86/6**. Does not even require the buyer's name. | **No** |
| Receipt | **ใบเสร็จรับเงิน** (the Code's term is **ใบรับ**) | **s.105** — immediately, every time, whether or not asked, above DG-set amounts (statutory caps ฿1,000 for VAT/SBT operators, ฿10,000 in other cases) | **No** — s.105 ทวิ's six particulars do not include it |
| Delivery note | **ใบส่งของ** | **s.105 จัตวา** — manufacturers, importers, exporters, wholesalers selling to VAT operators. A retail second-hand shop selling to a consumer is outside it. | **No** |

Sources, all observed 2026-08-04: <https://www.rd.go.th/5208.html> (ss.86, 86/4, 86/6, 86/8, 86/13;
page updated 16-09-2025), <https://www.rd.go.th/5209.html> (penalties; updated 08-07-2026),
<https://www.rd.go.th/5203.html> (ss.103, 105, 105 ทวิ, 105 จัตวา, 106, 114, 127 ทวิ; updated 07-02-2024),
<https://www.rd.go.th/22646.html> (VAT threshold ฿1,800,000/yr — พ.ร.ฎ. ฉบับที่ 432 พ.ศ. 2548 ม.4).

s.103 is worth quoting because it sets the bar so low: a ใบรับ is *"บันทึก หรือหนังสือใด ๆ ที่เป็นหลักฐานแสดงว่า
ได้รับ … ชำระเงิน"* — any note or writing evidencing receipt of money — and *"จะมีลายมือชื่อของบุคคลใด ๆ หรือไม่
ไม่สำคัญ"*, **it does not matter whether anyone signed it.** A hand-written slip is a legally
recognised receipt.

Penalties for not issuing: **s.89(5)** surcharge of 2× the tax; **s.90(12)** fine ≤ ฿2,000 for
incomplete fields; **s.90/2(3)** ≤ 1 month or ≤ ฿5,000 or both; **s.90/4(5)** intentional evasion,
3 months–7 years **and** ฿2,000–200,000. For receipts: **s.127 ทวิ** ≤ ฿500 or ≤ 1 month or both.

The Revenue Department expressly contemplates the merged slip Thai shops actually hand over —
ประกาศอธิบดีฯ ภาษีมูลค่าเพิ่ม (ฉบับที่ 39) governs an operator that *"ประสงค์จะจัดทำใบกำกับภาษีตามมาตรา 86/4 …
รวมกับเอกสารทางการค้าอื่น เช่น ใบเสร็จรับเงิน ใบส่งของ ใบแจ้งหนี้"* (<https://www.rd.go.th/3400.html>).

### The three practical consequences

1. **Asking a private seller for a ใบกำกับภาษี asks them to commit an offence.** Below ฿1.8m/yr turnover
   they are not VAT-registered, and s.86/13 forbids a non-registrant from issuing one (s.90/4(3):
   3 months–7 years). Ask for **ใบเสร็จรับเงิน**, or just "a paper".
2. **The serial on the receipt is a negotiation, never a right.** Apple's own rule confirms the
   reseller side of this, verbatim (<https://support.apple.com/en-us/102264>, published
   **2025-03-20**): a proof of purchase must show a clear device description, date, invoice/receipt
   number, price, reseller contact info, and *"**The device's serial number if the reseller normally
   lists serial numbers on their receipts.**"* So a genuine iStudio or Studio7 invoice **without** a
   serial is not suspicious — it may simply be what that reseller prints. Cross-check the serial
   against the machine and against Apple's coverage checker; do not rely on the paper.
3. **The receipt's real job is the Activation Lock escape hatch.** Apple TH, verbatim
   (<https://support.apple.com/th-th/102541>, 2026-07-09):
   > "หากคุณต้องการความช่วยเหลือในการปิดใช้งานการล็อคการเข้าใช้เครื่องและ**มีเอกสารหลักฐานการซื้อ** คุณสามารถเริ่มส่งคำขอรับบริการช่วยเหลือเกี่ยวกับล็อคการเข้าใช้เครื่อง"

   *"If you need help turning off Activation Lock **and you have proof of purchase**, you can start an
   Activation Lock support request."* → <https://al-support.apple.com/#/kbase>. Observed 2026-08-04,
   that flow offers exactly two paths: **"For a personally owned device"** and **"For a device owned by
   a business, school, or institution"** — the second being the MDM/institutional case.

   **UNPINNED:** the list of documents Apple accepts as proof of purchase, and whether a hand-written
   Thai shop slip qualifies. The requirements sit behind a JS flow that did not render. *To pin:*
   walking the al-support flow in a real browser, or an Apple TH support statement.

**UNPINNED:** whether Apple Store Thailand / iStudio / Studio7 / Power Mac Center print the serial on
their invoices. No specimen obtained. *To pin:* a redacted specimen invoice, or a reseller help page.
This is the single most worthwhile follow-up in this note, because the guide's advice depends on it.

---

## If the Mac turns out to be stolen

### There is no pre-purchase check

**No Thai state channel lets a buyer check whether a device is reported stolen.** Established by
elimination, all observed 2026-08-04:

- **thaipoliceonline.go.th** (ศูนย์ปราบปรามอาชญากรรมทางเทคโนโลยีสารสนเทศ, บช.สอท., hotline **1441**) —
  its entire service menu is: file an online report, submit a tip-off, chat with an officer,
  **check a mule *bank account*'s status**, upload case documents, read the manual. The only lookup is
  for bank accounts. Its remit is technology/online crime, not burglary.
- **royalthaipolice.go.th** — the public self-service system located is
  **ระบบรับแจ้งเอกสารหายอิเล็กทรอนิกส์**, lost *documents*
  (<https://old.royalthaipolice.go.th/downloads/User_Guide_citc.pdf>). A reporting channel, not a search.
- **NBTC** — <https://3steps.nbtc.go.th/> is SIM/subscriber registration management, not a device
  blacklist. No stolen-IMEI lookup found at NBTC or CIB.
- **Moot for a Mac anyway.** MacBook Air and Pro M1–M5 ship without a cellular modem and have **no
  IMEI**; only the serial identifies them. Any IMEI-based mechanism could not apply.

So the only pre-purchase provenance tools are Apple-side (Activation Lock / Find My state, coverage
check on the serial) and seller-side (paperwork, ID, channel).

### Reporting a stolen Mac

Done in person at the local station (แจ้งความ / ลงบันทึกประจำวัน). Per the Ministry of Justice's
สำนักงานกิจการยุติธรรม (<https://justicechannel.org/watch/interview/อะไรเอ่ยหายต้องรีบหา>, published
2020-09-23, updated 2020-11-17), what to bring under **แจ้งความทรัพย์สินหาย**:

> (1) ใบเสร็จรับเงินซื้อขาย หรือหลักฐานแสดงการซื้อขายทรัพย์สินนั้น
> (2) **รูปพรรณทรัพย์สินนั้น ๆ เช่น หมายเลขเครื่อง ฯลฯ (ถ้ามี)**
> (3) ตำหนิหรือลักษณะพิเศษต่าง ๆ
> (4) เอกสารสำคัญต่าง ๆ ที่เกี่ยวข้องเท่าที่มี

Note the **"(ถ้ามี)"** — "if available". The serial is desirable, not mandatory; the police take the
report either way, record it in the **บันทึกประจำวัน** (station daily blotter), and issue you a written
record.

**The report does not demonstrably enter any queryable registry.** Nothing in the MOJ page, the RTP
e-service or thaipoliceonline indicates a national serial-number database queryable by a third party
or even another station. **Treat "the police will flag the serial" as unsupported.**

### Your criminal exposure — Penal Code s.357 รับของโจร

Verbatim (<https://www.drthawip.com/criminalcode/1-56>; penalties as amended by
พ.ร.บ.แก้ไขเพิ่มเติมประมวลกฎหมายอาญา (ฉบับที่ 26) พ.ศ. 2560, ม.16):

> **มาตรา ๓๕๗** ผู้ใดช่วยซ่อนเร้น ช่วยจำหน่าย ช่วยพาเอาไปเสีย **ซื้อ** รับจำนำหรือรับไว้โดยประการใดซึ่งทรัพย์อันได้มาโดยการกระทำความผิด ถ้าความผิดนั้นเข้าลักษณะลักทรัพย์ … ผู้นั้นกระทำความผิดฐานรับของโจร **ต้องระวางโทษจำคุกไม่เกินห้าปี หรือปรับไม่เกินหนึ่งแสนบาท หรือทั้งจำทั้งปรับ**

Elements: an act (including **buying**), property obtained through a listed predicate offence (theft,
snatching, extortion, blackmail, robbery, gang-robbery, cheating, misappropriation), and **knowledge
at the moment of receipt**. Aggravated tiers: for trading profit — 6 months–10 years and
฿10,000–200,000; property from ss.335 ทวิ / 339 ทวิ / 340 ทวิ — 5–15 years and ฿100,000–300,000.

**"I didn't know" is a real defence** — knowledge is a constitutive element, so without it there is no
s.357 offence. But it is a *fact* the prosecution proves circumstantially. A Thai criminal-defence
practitioner's list of the indicia courts weigh (**CLAIM**, <https://srisunglaw.com/รับซื้อของโจรโดยไม่รู้ตัว/>,
2024-10-04): the price paid, the buyer's occupation and expertise, how credible the seller appeared,
whether the goods looked irregular, whether the item is registrable, whether the deal was done openly,
and where it took place.

A Bangkok police station's own public buyer guidance (สน.อุดมสุข,
<https://policeudomsuk.com/ซื้อของมือสองออนไลน์-ระ/>, post image dated **2022-09-18**) tells second-hand
buyers to check the shop's credibility, ask in detail where the item came from, ask for a guarantee
document, and verify the product code on the manufacturer's site — ending with the warning that
otherwise you may be charged under s.357.

### Your civil position — CCC s.1332, and why the *channel* matters more than the machine

> **มาตรา 1332** บุคคลผู้ซื้อทรัพย์สินมาโดยสุจริตในการขายทอดตลาด หรือในท้องตลาด หรือจากพ่อค้าซึ่งขายของชนิดนั้น ไม่จำต้องคืนให้แก่เจ้าของแท้จริง เว้นแต่เจ้าของจะชดใช้ราคาที่ซื้อมา

*A person who buys property **in good faith** at a public auction, **in a market (ท้องตลาด)**, or **from
a merchant who deals in goods of that kind**, need not return it to the true owner **unless the owner
reimburses the price paid**.*

| Your situation | What happens to the machine |
|---|---|
| **Bad faith** | Return it, no reimbursement — **plus** s.357 liability |
| **Good faith, protected** (bought in a market trading that kind of goods, or from a dealer in them) | **You keep it** unless the true owner pays you exactly what you paid. No s.357 liability |
| **Good faith, not protected** (bought from a private individual not in that trade) | **You return it and get nothing.** Your only remedy is to sue the *seller* for รอนสิทธิ under CCC ss.475/479 |

Case analysis and ฎีกา citations from <https://srisunglaw.com/รับซื้อของโจรโดยไม่รู้ตัว/> (2024-10-04) —
**law-firm content, therefore CLAIM**, though the ฎีกา numbers are checkable: protected —
ฎ.1928/2534, ฎ.1052/2524, ฎ.2922/2522, ฎ.225/2538, ฎ.10499/2555; unprotected — ฎ.185/2508, ฎ.350/2506,
ฎ.1938/2564, ฎ.493/2536, ฎ.390/2518, ฎ.2292/2515.

Three details that bite a Bangkok Mac buyer:

1. **"ท้องตลาด" means "ที่ชุมนุมแห่งการค้า"** — a place of assembly for trade (ฎ.185/2508, ฎ.907/2490) —
   and it must be a market **for that kind of goods**. Pantip Plaza and Fortune Town plausibly qualify
   for computers; a condo lobby or a car park does not.
2. **The protection runs to the person buying *from* the shop, not to the shop buying *in*.**
   ฎ.3110/2539: *"การซื้อทรัพย์ในท้องตลาดหมายถึงการซื้อทรัพย์จากร้านค้าที่ตั้งอยู่ในท้องตลาด ไม่ใช่เป็นการที่ร้านค้าซึ่งตั้งอยู่ในท้องตลาด
   ซื้อทรัพย์จากบุคคลที่นำมาขายให้แก่ร้านค้านั้น"*. ฎ.8816/2563 applied this to a gold shop that bought from a
   walk-in.
3. **Registration is not required to be a "พ่อค้าซึ่งขายของชนิดนั้น"** (ฎ.6500/2540) — and conversely,
   being a licensed dealer does not automatically make the dealer's own premises a "ท้องตลาด"
   (ฎ.493/2536).

**Even where s.1332 protects you, police may still seize the machine as ของกลาง** under
ป.วิ.อ. ม.132(2)&(4). You must comply; your remedy is a คำร้องขอคืนของกลาง or a civil claim
(ฎ.10499/2555 held that an owner who used police seizure specifically to dodge the s.1332
reimbursement duty committed a tort under CCC s.427).

### What actually happens — one real Thai MacBook case (CLAIM)

Pantip topic 39490303, *"Macbook pro โดนขโมยตามเจอแต่ให้ซื้อของคืน"*, posted 16 ธันวาคม 2562 =
**2019-12-16** (<https://pantip.com/topic/39490303>):

- The owner's room was burgled. She located the MacBook Pro through **Find My**: a second-hand shop had
  bought it and sent it to a third-party shop **to have the data wiped**, while it was still locked to
  her password and iCloud account.
- Her account of what the police told her: *"ตร. แจ้งว่าถ้าอยากได้ของต้องซื้อคืนเพราะเจ้าของร้านซื้อถูกต้องตามกฎหมาย"* —
  **"the police said if I want it back I have to buy it back, because the shop owner bought it
  lawfully."**
- The police reasoning she reports: the shop held an **ใบอนุญาตซื้อของเก่า** (second-hand dealer's
  licence), traded within licensed hours, and **the person who sold it showed his national ID card and
  signed a certified copy** during the transaction.
- Police **did not seize it**: *"ตำรวจไม่ได้ยึดไว้เป็นของกลางเลยคะ แจ้งว่าเป็นสิทธิ์ของทางร้าน… ถ้าร้านจะขายต่อก็ทำได้"* —
  the shop was free to resell it.
- Commenters split; several argued that wiping the Apple ID destroyed the shop's good faith and made
  it a clear s.357 case. ⚠️ One comment quotes the **pre-2017** s.357 fine figures (฿10,000 etc.) —
  superseded by Act No. 26 of 2560. Do not quote that version.

**The reading the guide should take from this:** the licensed shop's paperwork — its ใบอนุญาตซื้อของเก่า
and its ID-card record of the person it bought from — is what makes the *shop* a protected buyer, and
it is the same fact that makes *you*, buying from that shop, protected under limb 3 of s.1332. Both
effects flow from the same paperwork, and it holds **even though the shop's receipt will not carry the
serial number**. That is the strongest available argument for buying a used Mac from a licensed IT-mall
shop over a stranger — and it is a legal argument, not a condition argument.

**Note the asymmetry it creates.** The Thai buyer who does everything right and buys privately can end
up worse off than the careless buyer who bought in a mall. This guide cannot fix that; it can only
tell the buyer it is true before they choose where to go.

---

## Buyer protection on the platforms Thai second-hand Macs are sold through

| Platform | Escrow? | "Not as described" covered? | Claim window | Covers C2C / used? | Covers stolen or locked? | Source | Observed |
|---|---|---|---|---|---|---|---|
| **Facebook Marketplace** (local pickup, cash) | **No** | **No** | n/a | n/a | **No** | <https://www.facebook.com/help/310772489111386> | 2026-08-04 |
| Facebook Marketplace (checkout on Facebook) | Yes | Yes | UNPINNED | UNPINNED | UNPINNED | same | 2026-08-04 |
| **Kaidee** | **No — no payment rail at all** | No policy-level cover | n/a | Listing board for used goods | **No** | <https://support.kaidee.com/hc/th/articles/115001065287> | 2026-08-04 |
| **Shopee TH** | Yes — ช้อปปี้การันตี holds release | Yes, via refund/return request | **7–15 days** from "จัดส่งสำเร็จ"; Shopee Mall **15 days** | UNPINNED | UNPINNED | <https://help.shopee.co.th/4/article/80543>, <https://help.shopee.co.th/4/article/80746>, <https://help.shopee.co.th/4/article/172999> | 2026-08-04 |
| **Lazada TH** | UNPINNED | UNPINNED | UNPINNED | UNPINNED | UNPINNED | <https://www.lazada.co.th/helpcenter/overview-of-lazada-return-refund-policy-235514.html> | 2026-08-04 |
| **ประกันร้าน** (shop warranty) | n/a | Hardware faults only | 7 / 30 / 90 days, shop-set | Yes — this is the used market's actual protection | **No** | see below | 2026-08-04 |

**Facebook Marketplace is the important row**, because it is where a Bangkok private sale actually
happens. Meta's own words, verbatim:

> "Although eligible items purchased on Marketplace from sellers and stores using checkout on Facebook
> are covered by Purchase Protection, **local pickup items using person-to-person payment methods are
> not covered. Facebook does not offer refunds for any person-to-person transactions.**"

The same page also states *"Payments in Messenger are only available on your mobile device in the US at
this time."* **UNPINNED:** whether checkout-on-Facebook exists in Thailand at all — Meta's Purchase
Protection policy page (help/1434404397434123) returns "This Page Isn't Available". *To pin:* the
policy page under a Thai account, or Meta's commerce-availability list.

**Kaidee** describes itself, verbatim: *"Kaidee เป็นศูนย์กลางแหล่งซื้อขายของมือสอง เราให้บริการพื้นที่สำหรับผู้ที่
ต้องการขายสินค้าได้มาลงประกาศขาย … คุณสามารถติดต่อเจ้าของสินค้าหรือบริการได้โดยตรง"* — a listing board where
buyer and seller deal directly. No payment rail is described anywhere, therefore no escrow and no
policy-level protection. Terms: <https://www.kaidee.com/terms-and-conditions>. The comment thread on
that same help page is instructive: a buyer paid cash in person for a dead item on 2020-06-28, the
seller refused a return, Kaidee's CS **mediated**, and he was refunded on 2020-07-04. That is
discretionary goodwill from a support team, not a guarantee — do not plan around it.

**Shopee/Lazada have a structural problem for this guide that is worse than any policy gap: you cannot
run the inspection before paying.** The return window is the only protection and it starts at delivery.

**The Thai used market's real protection is ประกันร้าน — the shop's own warranty**, typically 7, 30 or
90 days, advertised in the listing, with stated exclusions. Multiple independent Thai shops advertise
it consistently (**CLAIM**, shop listings, observed 2026-08-04): 30-day ประกันร้าน at Fortune Town and
Pantip Ngamwongwan stalls (<https://www.tiktok.com/@fortunetown/video/7469991535031979271>,
<https://www.tiktok.com/@what.bangkapi/video/7652637834171534600>), 90-day at Houk&Bank
(<https://www.facebook.com/houkandbank/?locale=th_TH>), and a typical exclusion list, verbatim:
*"เครื่องมีประกันร้าน 1เดือน, จอ LCD 1อาทิตย์ ไม่รวม, ความชื้น, โดนน้ำ, ตกหล่น, แกะ"* — one month shop warranty,
LCD one week, **excluding moisture, water, drops and opening the machine**
(<https://www.instagram.com/reel/DO5gB2fERa-/>).

**ประกันร้าน is a hardware warranty and covers none of this note's risks.** It does not cover an
Activation Lock surfacing later, MDM enrollment, or the machine turning out to be stolen. Do not let a
"90-day shop warranty" substitute for the lock checks.

**Apple's own authorised channel** is listed at <https://locate.apple.com/th/th/> —
ตัวแทนจำหน่ายที่ได้รับอนุญาตจาก Apple and service locations (observed 2026-08-04). Useful for deciding
whether a shop is what it claims.

---

## Thai listing vocabulary, evidenced in live listings

Only terms observed in real Thai listings on 2026-08-04 are included; candidate terms that could not be
evidenced were dropped rather than guessed.

| Thai | Literal gloss | What it means to a buyer | Evidenced at |
|---|---|---|---|
| **ศูนย์ไทย** | "Thai centre" | Sold through Apple's Thai channel. Advertised as a **positive** claim | <https://www.mac2hand.com/c=all;m=all/page197/>, <https://mac2hand.com/c=all;m=sale/page52/> |
| **ครบกล่อง** | "complete box" | Box and accessories present | same |
| **ประกันศูนย์ เหลือ / ถึง ⟨date⟩** | "centre warranty remaining/until" | Remaining authorised warranty, quoted with an expiry date — often in **Buddhist-era years** (e.g. "ประกันถึง 01/05/70" = 2027-05-01) | <https://www.facebook.com/groups/628129734000847/posts/3680717165408740/> |
| **สภาพสวย / สวยมาก / สวยกริบ** | "beautiful condition" | Cosmetic grade, seller-assigned, **no published scale** | mac2hand, shop Instagram listings |
| **รอบชาร์จ** / Cycle count | "charge rounds" | Battery cycle count, quoted in listings | <https://www.tiktok.com/@notebookstation/video/7396968638340795666> |
| **สุขภาพแบต / แบต 100%** | "battery health" | Maximum capacity, quoted in listings | <https://www.instagram.com/reel/DWLPyZCk8lr/> |
| **ประกันร้าน** | "shop warranty" | The shop's own warranty, 7–90 days, hardware only | see above |
| **ขาย/แลก** | "sell / trade" | Seller will accept a trade-in | mac2hand |
| **ติด MDM** | "stuck on MDM" | MDM-enrolled and therefore locked or lockable | <https://www.facebook.com/groups/628129734000847/posts/3680717165408740/> |
| **เครื่องติดผ่อน** | "device stuck on instalments" | Still under an unpaid instalment contract | same |
| **เครื่องติดไอคลาวด์** | "device stuck on iCloud" | Activation Lock / iCloud still attached | <https://pantip.com/topic/42169312> |
| **จำนำไอคลาวด์** | "pawning the iCloud" | The Apple Account is pledged to a lender while the owner keeps the device | <https://pantip.com/topic/42169312>, <https://pantip.com/topic/43823822> |

**A finding worth stating on its own: เครื่องหิ้ว (grey import) does not appear as a self-label.**
Across every listing search run, sellers advertise **ศูนย์ไทย** as a positive claim; nobody labels their
own machine a grey import. **The absence of a ศูนย์ไทย claim is the signal, not the presence of a หิ้ว
label.**

---

## What is and is not fakeable on an Apple-silicon Mac

- **RAM and SSD cannot be swapped.** On M1–M5 the memory is on-package and the storage is soldered.
  A "16GB" machine cannot have been quietly downgraded to 8GB by a shop. This narrows the
  misrepresentation surface enormously versus the Intel era.
- **SIP status is readable, unprivileged, and is the check that makes every other reading
  trustworthy.** Verified first-hand on macOS Tahoe 26.5.2 (build 25F84) on 2026-08-04:

  ```
  $ csrutil status
  System Integrity Protection status: enabled.
  ```

  Exit 0, no `sudo`. If SIP is **disabled** on a machine you are being asked to buy, treat every
  software-read fact in the report as unverified and ask why.
- **UNPINNED: whether `About This Mac` / `system_profiler` output can be spoofed on an
  Apple-silicon Mac with SIP enabled.** No evidence either way was found; no Thai or international
  report of a spoofed Apple-silicon spec sheet surfaced. Stated as unknown rather than assumed safe.
  *To pin:* a documented demonstration, or an Apple platform-security statement on the provenance of
  the values `system_profiler` reports.

---

## The phrasebook

Every phrase below is written for a male speaker (**ครับ**); a female speaker substitutes **ค่ะ**
throughout. All are polite register, appropriate for a shop or a stranger.

### Verified or corrected from the current README

| # | English | Thai | Literal gloss | Verdict |
|---|---|---|---|---|
| 1 | Can I check the machine first? | ขอเช็คเครื่องก่อนได้ไหมครับ | request · check · machine · first · get · Q · POLITE | ✅ **Correct.** Natural, idiomatic, keep as is |
| 2 | Please sign out of iCloud | รบกวนออกจากระบบ iCloud ให้หน่อยครับ | trouble-you · exit-from-system · iCloud · for-me · a-bit · POLITE | ✅ **Correct and understood.** Apple's own current Thai UI verb is **ลงชื่อออก**; ออกจากระบบ is the colloquial equivalent. Sharpened version below |
| 3 | How many battery cycles? | แบตเตอรี่กี่รอบครับ | battery · how-many · rounds · POLITE | ⚠️ **Understood, but not the market term.** Thai listings say **รอบชาร์จ** (charge cycles). Sharpened version below |
| 4 | Has it ever been repaired? | เครื่องเคยซ่อมไหมครับ | machine · ever · repair · Q · POLITE | ⚠️ **Grammatical and understood, but too narrow.** A seller who swapped a battery may honestly answer "no" — a battery swap is not "ซ่อม" to them. Replaced below |
| 5 | Can I have a receipt? | ขอใบเสร็จด้วยครับ | request · receipt · also · POLITE | ⚠️ **Correct Thai, wrong ask.** Ambiguous between ใบเสร็จรับเงิน and ใบกำกับภาษี, and does not mention the serial. Replaced below |

### The corrected and expanded list

| English | Thai | Literal gloss |
|---|---|---|
| Can I check the machine first? | **ขอเช็คเครื่องก่อนได้ไหมครับ** | request · check · machine · first · can · Q · POLITE |
| Is it a Thai-market unit or an overseas one? | **เครื่องศูนย์ไทยหรือเครื่องหิ้วครับ** | machine · centre · Thai · or · machine · carried-in · POLITE |
| Please sign out of iCloud in front of me | **รบกวนลงชื่อออกจาก iCloud ต่อหน้าผมเลยได้ไหมครับ** | trouble-you · sign · out-from · iCloud · in-front-of · me · right-now · can · Q · POLITE |
| Is the machine still attached to iCloud? | **เครื่องยังติดไอคลาวด์อยู่ไหมครับ** | machine · still · stuck · iCloud · remain · Q · POLITE |
| **Has this machine ever been enrolled in MDM, or was it a company or school machine?** | **เครื่องนี้เคยลงทะเบียน MDM หรือเป็นเครื่องบริษัท/เครื่องโรงเรียนไหมครับ** | machine · this · ever · register · MDM · or · be · machine · company / machine · school · Q · POLITE |
| **Is the machine still on an instalment plan, or is it on MDM?** | **เครื่องยังติดผ่อนหรือติด MDM อยู่ไหมครับ** | machine · still · stuck · instalment · or · stuck · MDM · remain · Q · POLITE |
| **After a reset, does it go to the "Remote Management" screen?** | **ถ้ารีเซ็ตเครื่องแล้ว มันขึ้นหน้า Remote Management ไหมครับ** | if · reset · machine · then · it · shows · page · Remote Management · Q · POLITE |
| How many charge cycles does the battery have? | **แบตเตอรี่กี่รอบชาร์จครับ** | battery · how-many · charge-cycles · POLITE |
| What is the battery health? | **สุขภาพแบตเตอรี่เท่าไหร่ครับ** | health · battery · how-much · POLITE |
| **Has the machine ever been repaired, or had any part replaced?** | **เครื่องเคยซ่อมหรือเปลี่ยนอะไหล่อะไรบ้างไหมครับ** | machine · ever · repair · or · change · spare-part · what · any · Q · POLITE |
| **Has the machine ever been opened?** | **เครื่องเคยแกะไหมครับ** | machine · ever · pry-open · Q · POLITE |
| **May I have a receipt with the serial number on it?** | **ขอใบเสร็จรับเงินที่มีหมายเลขเครื่อง (Serial Number) ระบุไว้ด้วยได้ไหมครับ** | request · receipt-of-money · that · has · number · machine · (Serial Number) · stated · also · can · Q · POLITE |
| **May I see the original purchase receipt?** | **ขอดูใบเสร็จตอนซื้อเครื่องได้ไหมครับ** | request · see · receipt · at-time · buy · machine · can · Q · POLITE |
| **May I have your name and phone number on the receipt?** | **ขอชื่อกับเบอร์โทรของผู้ขายเขียนในใบเสร็จด้วยได้ไหมครับ** | request · name · and · number · phone · of · seller · write · in · receipt · also · can · Q · POLITE |
| Which shop was it bought from, and in which country? | **ซื้อมาจากร้านไหน ประเทศอะไรครับ** | buy · come · from · shop · which · country · what · POLITE |
| Is there AppleCare+ left, and can it be transferred to me? | **มี AppleCare+ เหลืออยู่ไหมครับ แล้วโอนให้ผมได้ไหมครับ** | have · AppleCare+ · remaining · exist · Q · POLITE · then · transfer · to · me · can · Q · POLITE |

Notes on the new phrases:

- **Use the loanword "MDM".** It is what the Thai trade uses (evidenced above in shop listings, Pantip
  and shop articles) and it avoids the **การจัดการระยะไกล** collision with Apple Remote Desktop
  documented earlier. Saying "Remote Management" in English also works — the setup screen is in
  English in most Thai buyers' experience.
- **Ask about ผ่อน (instalments) explicitly**, not just about corporate ownership. That is where the
  Thai MDM population comes from.
- **Ask for ใบเสร็จรับเงิน, not ใบกำกับภาษี**, unless the shop is visibly a VAT-registered business —
  a private seller cannot lawfully issue a tax invoice.
- **"เครื่องเคยแกะไหมครับ"** ("has it ever been pried open") is a genuinely different question from
  "has it been repaired" in Thai usage, and a seller who has had an independent shop inside the
  machine is more likely to answer it honestly.

**UNPINNED:** these phrases are constructed to be idiomatic and were checked against Apple TH's Thai
terminology and against vocabulary observed in live Thai listings, but **none has been tested on a Thai
seller in a shop.** *To pin:* one field trial.

---

## Unresolved conflicts in the sources

1. **Does an unprotected good-faith buyer who has already resold owe the true owner money?**
   ฎ.1275/2493 (ประชุมใหญ่) and ฎ.3698/2529 say **no**; ฎ.8816/2563 says **yes** (value at filing date
   plus interest, CCC s.213). The srisunglaw author flags it as unsettled and favours "no". Live
   conflict; do not state a rule.
2. **Police seizure practice is inconsistent with the case law.** ฎ.10499/2555 treats using police
   seizure to dodge the s.1332 reimbursement duty as a tort; the 2019 Pantip case has police doing the
   opposite — refusing to seize and leaving the machine with the shop. Practice varies by station.
3. **Apple TH is internally inconsistent on Activation Lock's Thai name** — การล็อคการเข้าใช้เครื่อง in
   the title, การล็อคการเปิดใช้งาน once in the body, on the same page.
4. **The Thai MDM evidence is phone-shaped.** Every direct account of an instalment shop enrolling a
   device in MDM is about an iPhone. The mechanism is identical on a Mac (ADE covers Macs; Apple TH
   102291 names Mac explicitly) but no Thai first-hand Mac account was found.
5. **Apple's contract contradicts Apple's marketing.** The warranty and AppleCare+ terms both reserve
   the right to restrict service to the country of original sale; apple.com/th/applecare simultaneously
   markets *"เข้าถึงการซ่อมทั่วโลก … กว่า 5,000 แห่งทั่วโลก"*. Both are Apple pages. Resolved in favour of the
   contract, with the marketing read as a description of normal practice.
6. **Apple's Thai and English warranty pages are on different revisions** — English "November 09, 2023
   – Present", Thai "March 01, 2023 – Present". Any exact-wording argument must cite both and note the
   lag.
7. **AASP stated policy vs reported practice.** iCare's FAQ (2023-03-09) says foreign-bought MacBooks
   are accepted with no model restriction; a Pantip account (2023-09-24) reports iCare refusing a
   Japan-market Apple Watch on country-code grounds, with Apple's own store then honouring it.
   Different product classes, but AASP counter behaviour is demonstrably not uniform, and the
   Apple-owned store is the better escalation path.
8. **Third-party serial decoders vs randomisation.** Decoder blogs still present factory/region codes
   as current. Resolved in favour of randomisation for all M1–M5 machines.

---

## Unpinned / could not establish

Listed so the guide author knows not to reach for a fact that does not exist.

| # | Missing | Why | What would pin it |
|---|---|---|---|
| 1 | **Whether Apple TH / iStudio / Studio7 / Power Mac Center print the serial on their invoices** | No specimen obtained | A redacted specimen invoice, or a reseller help page. **Highest-value follow-up in this note** |
| 2 | **The documents Apple accepts as proof of purchase for an Activation Lock support request** | The requirements sit behind a JS flow that did not render | Walking <https://al-support.apple.com/#/kbase> in a real browser |
| 3 | **Whether Thai instalment/pawn shops apply MDM to MacBooks specifically** | Every direct account is a phone | A Thai instalment shop's published MacBook terms, or a first-hand Mac account |
| 4 | **Whether checkout-on-Facebook (and therefore Purchase Protection) exists in Thailand at all** | Meta's policy page 404s to a scraper | The policy page under a Thai account, or Meta's commerce-availability list |
| 5 | **Whether Shopee TH permits used MacBooks, and whether a stolen or MDM-locked device is a covered ground** | Prohibited-items policy not read through | <https://help.shopee.co.th/4/article/77249> read in full |
| 6 | **Lazada TH's platform-wide return window for a general marketplace seller** | Only seller-specific and "Choice" figures surfaced; excluded rather than quoted unverified | The platform policy page read under a Thai session |
| 7 | **Whether `system_profiler` output can be spoofed on Apple silicon with SIP enabled** | No evidence either way | A documented demonstration, or an Apple platform-security statement |
| 8 | **Whether a Thai stolen-property report enters any cross-station or national serial database** | Nothing found either way | An RTP regulation on the บันทึกประจำวัน / CRIMES / POLIS systems |
| 9 | **The exact provision requiring a licensed second-hand dealer to register purchases with the seller's ID** | พ.ร.บ.ควบคุมการขายทอดตลาดและค้าของเก่า พ.ศ. 2474 s.13 is the *inspection* power; the record-keeping duty appears to sit in s.11 and/or ระเบียบกระทรวงมหาดไทย พ.ศ. 2533. The DOPA manual is Imperva-blocked | The 2533 MOI Regulation text, or report.dopa.go.th/laws/document/3/302.pdf |
| 10 | **The DG announcements fixing the actual s.105 receipt thresholds** (statutory caps ฿1,000 / ฿10,000; announced figures may be lower) | Not located | The relevant ประกาศอธิบดีกรมสรรพากร เกี่ยวกับอากรแสตมป์ on rd.go.th |
| 11 | **Whether Thai operators or NBTC run any stolen-IMEI blacklist** | Supported only by a consumer-media assertion. Low priority — Macs have no IMEI | An NBTC ประกาศ or an operator page |
| 12 | **Named-mall shop practice on writing serials and taking ID copies** (Fortune Town / Pantip Plaza / MBK / Zeer) | Supported only by one Pantip account about an unnamed shop | Shop policy pages, or several more buyer accounts naming the malls |
| 13 | **Any field test of the phrasebook** | Constructed, not trialled | One shop visit |
| 14 | **Any price differential between เครื่องศูนย์ and เครื่องหิ้ว for Macs** | Two Thai searches returned only iPhone-focused social content; the one generic source says "usually cheaper" with no figure | Same-day, same-config MacBook Air M4/M5 listings tagged เครื่องศูนย์ไทย vs เครื่องหิ้ว on Shopee/Lazada/Facebook, benchmarked to Apple TH RRP ฿44,900 |
| 15 | **The import duty rate for portable computers (HS 8471.30)** | Probably 0% under the WTO ITA, leaving 7% VAT — not verified, so not asserted | The HS 8471.30 line in the Thai Customs Integrated Tariff Database (itd.customs.go.th) |
| 16 | **Whether a second-hand buyer inherits liability for an undeclared import** | The importer is liable in principle, but the Customs Act B.E. 2560 has possession offences for duty-evading goods | Customs Act B.E. 2560 ss.242/246 and any DG interpretation on personal-use second-hand possession |
| 17 | **The four keyboard languages Apple TH offers on MacBook** | The buy page renders a collapsed "เลือกได้ 4 ภาษา" summary; the option list loads client-side | Expand the คีย์บอร์ด configurator on <https://www.apple.com/th/shop/buy-mac/macbook-air> in a real browser |
| 18 | **The plug type in the Thai retail box** | Apple TH's three adapter options are wattage/port variants, not plug shapes | The "ในกล่อง" list on Apple TH's MacBook tech-specs page, or the Apple part number on a known Thai-market duckhead |
| 19 | **Verification-by-absence that checkcoverage and About This Mac never emit a country field** | Apple documents no such field, but no known-foreign serial was run through the tool | Enter the serial of a Mac with documented non-Thai purchase and screenshot the result |
| 20 | **The exact model or date Apple-silicon *Mac* serials became randomised** | The 2021 randomisation reporting is iPhone-led | Compare serial lengths on dated M1 (Nov 2020) / M1 Pro (Oct 2021) / M2 (2022) units, or an Apple Business Manager / MDM release note |
| 21 | **Grey-import policies of iStudio/Copperwired, iStudio by SPVi, uFicon, iBeat, Power Mac Center** | Only iCare (Com7) publishes one | A direct read of each AASP's service/FAQ page, or a phone call |
| 22 | **Whether an M-series MacBook carries a visible NBTC marking** | Not established; and even if it does, certification is model-level, so it is near-useless as a detector either way | Photograph a Thai-market unit's regulatory label, or query <https://mocheck.nbtc.go.th/> for Apple MacBook model numbers |

---

## Method and tooling

Run as four parallel investigations — grey imports and warranty validity; receipts and stolen-device
recourse; marketplace buyer protection; Thai market scam patterns and vocabulary — each instructed
never to invent a figure and to stamp every claim with a source URL and an observed date. Two of the
four slices were executed by the lead after the subagent pool saturated.

**Tooling:** AgentKey MCP throughout (`Serper/search`, `Firecrawl/scrape`). Built-in WebSearch and
WebFetch were **not** used for anything in this document. One fact — `csrutil status` readability —
was verified first-hand on the dev's own Mac rather than sourced.

**Sources deliberately excluded rather than quoted unverified:** Lazada's platform return policy (only
seller-specific figures surfaced); MDM-bypass service pages and SEO spam sites that surfaced on every
"ติด MDM" search (*unlocking or bypassing a lock you find* is explicitly out of scope on the map, and
those pages are not sources in any case); and one Pantip comment quoting **pre-2017** s.357 penalties,
which are superseded by Act No. 26 of 2560.

**One extraction error caught during verification**, recorded so it is not reintroduced: the accidental
damage fee table **inside** the Thai AppleCare+ for Mac PDF extracts as garbage (yen symbols, a
nonsense model column). No ADH figure from that PDF is used in this note. Take AppleCare+ service fees
from Apple TH's HTML pages, or from
[`research/thai-repair-prices.md`](https://github.com/mingrath/mbcheck/tree/research/thai-repair-prices),
which already pinned them (฿3,300 / ฿10,000 for MacBook Air and Pro).
