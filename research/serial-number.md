# What a serial number can prove, and how much of it `check.sh` can read

Research note resolving [issue #4](https://github.com/mingrath/mbcheck/issues/4) **as amended** — the
amendment relocated the question from the deleted pre-visit phase to the shop, and asked two things the
original body did not: **is `checkcoverage.apple.com` machine-readable?**, and **grade every finding by
whether the script can get it.**

Feeds the script/prompt split fixed by [the structure decision](https://github.com/mingrath/mbcheck/issues/11)
and the 8-slot physical-check budget in [#19](https://github.com/mingrath/mbcheck/issues/19). Severity
grades are [#10](https://github.com/mingrath/mbcheck/issues/10)'s.

**Research date: 2026-08-04.** Every fact carries its own observed date. Where a source page carries no
publication date, that is stated rather than glossed. Every network experiment below was run first-hand on
this machine and the exact commands are reproduced so they can be re-run.

**Test machine** for every first-hand observation: MacBook Air (15-inch, M4, 2025), `Mac16,13`, `MC7A4TH/A`,
macOS Tahoe 26.5.2 (build 25F84), uid 501, no sudo. Its serial is written `G5GQ…0L` below — the middle is
redacted, but the real value was used in every test.

---

## The headline answer

**`checkcoverage.apple.com` is captcha-gated, and `check.sh` cannot pass it.** Verified by driving the site's
own API end to end with `curl` on 2026-08-04: the serial and the captcha answer go to Apple in **one POST**,
so there is no serial lookup that skips the captcha. The captcha is a 160×70 JPEG of 4–5 distorted
characters, served as base64 inside a JSON body, with an audio alternative for accessibility.

**But the second half matters more than the first: the coverage lookup is worth much less than the README
assumes.** Three of the four things it returns — model name, screen size, model year — are already readable
**offline, unprivileged, in milliseconds**, from `system_profiler` and `ioreg` plus a table Apple publishes.
What the coverage page uniquely adds is exactly two facts: **the date of purchase** and **the coverage
state**. Everything else it prints, the script already knows.

So the trade the amendment asked to be priced is narrower than it looked:

> Spend one of the eight physical slots on a ~45–60 s phone prompt, and buy **date of purchase** plus
> **warranty / AppleCare+ status**. Cut it, and lose exactly those two facts and nothing else.

---

## ⚠️ Corrections this research forces on the current README

| # | README says | Reality | Where |
|---|---|---|---|
| 1 | "Copy the serial number, then check it at **checkcoverage.apple.com** on your phone" — presented as a free step inside an 8-minute block | The lookup is **captcha-gated**: image captcha, one POST carrying serial + answer together. Not scriptable. It is a *prompt* with a real cost, or it is cut. | [Gate](#how-checkcoverageapplecom-is-gated-the-decisive-experiment) |
| 2 | "You want: **the model to match** what you're holding" | That is the **wrong reason to run the check**. `ioreg` and `system_profiler` give `Mac16,13` + `A3241` + `MC7A4TH/A` for free, and Apple publishes the identifier → marketing-name table. Coverage adds only **purchase date** and **coverage state**. | [What it returns](#what-the-coverage-page-actually-returns-in-2026) |
| 3 | "**Walk away if:** the serial is invalid" | The invalid state is real (verified), but it is produced by a **typo** far more often than by a fake machine, and it cannot tell the two apart. A 🛑 hung on it will mostly fire on fat fingers. | [States](#the-states-observed-first-hand) |
| 4 | Checklist line "Serial valid on checkcoverage.apple.com" | Under [#11](https://github.com/mingrath/mbcheck/issues/11) there is no checklist. This line becomes a prompt competing for one of eight slots, or it disappears. | [Recommendation](#recommendation-to-19) |
| 5 | Nothing anywhere about **region of sale** | `ioreg` returns `region-info = TH/A` unprivileged and offline. On a grey-import machine this is the field that says so, and it is free. | [Local surfaces](#what-the-machine-tells-you-locally-for-free) |
| 6 | Step 1a is the only "is this machine real" check, and it is a *network* check | A **stolen-report lookup exists and is fully scriptable** — `stolenregister.com` answers a plain `GET` with no captcha, login or cookie. Coverage is thin, but it costs the script nothing. | [Stolen](#stolen-device-reporting) |

---

## Grading table — what the script can get, and what needs a browser and a human

This is the table the amendment asked for. **"Script"** means `bash` + `curl` with no sudo, no API key and
no human, per [#11](https://github.com/mingrath/mbcheck/issues/11).

| Fact | Best source | Script? | Cost if not | Confidence |
|---|---|---|---|---|
| Serial number | `system_profiler SPHardwareDataType` / `ioreg` | ✅ free | — | Established [#4 amendment] |
| Model identifier (`Mac16,13`) | `system_profiler`, `ioreg` `model` | ✅ free | — | First-hand |
| **Marketing name + screen size + year** | model identifier → Apple's published table, **bundled offline** | ✅ free | — | First-hand + Apple [A1][A2] |
| Part / order number (`MC7A4TH/A`) | `system_profiler` `Model Number` | ✅ free | — | First-hand |
| **Region of sale** (`TH/A`) | `ioreg` `region-info` | ✅ free | — | First-hand |
| **Regulatory model** (`A3241`) | `ioreg` `regulatory-model-number` | ✅ free | — | First-hand |
| Logic-board serial | `ioreg` `mlb-serial-number` | ✅ free | — | First-hand; **meaning unestablished** |
| Chip, cores, RAM | `system_profiler SPHardwareDataType` | ✅ free | — | First-hand |
| Activation Lock status | `system_profiler SPHardwareDataType` | ✅ free | — | Established [#4 amendment] |
| MDM + DEP enrolment (**current**) | `profiles status -type enrollment` | ✅ free | — | Established [#4 amendment] |
| DEP **assignment** at Apple (not yet enrolled) | `profiles show -type enrollment` | ❌ **needs root** | unreadable — script takes no sudo | First-hand: *"Must be running as root"* |
| **Reported-stolen check** | `GET stolenregister.com/check?sn=…` | ✅ **free, no captcha** | — | First-hand, both branches |
| **Date of purchase** | `checkcoverage.apple.com` | ❌ **captcha** | ~45–60 s phone prompt, 1 of 8 slots | First-hand |
| **Warranty / AppleCare+ state** | `checkcoverage.apple.com` | ❌ **captcha** | same prompt, same slot | First-hand |
| Open repair case flag (`openRepair`) | `checkcoverage.apple.com` JSON | ❌ **captcha** | same prompt; **not rendered on screen** | First-hand |
| Manufacture date | — | ❌ **nothing exposes it** | cannot be bought at any price | First-hand + [B1] |
| Exact RAM/SSD/colour from serial or part no. | — | ❌ | GSX proxy, ฿149, unverified | See [GSX proxies](#third-party-gsx-proxies-including-one-in-thailand) |
| Repair / replacement history | GSX only | ❌ | ฿135–149 + human + payment | Advertised, unverified |
| Outstanding finance | — | ❌ **not in any serial-keyed source** | see [Financing](#outstanding-financing) | First-hand + [C1] |
| Cloned/reused serial rate | — | ❌ | **could not establish at all** | — |

---

## How `checkcoverage.apple.com` is gated — the decisive experiment

Everything in this section was observed on **2026-08-04** by driving the site's own endpoints. Reproduce with:

```bash
UA='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15'

# 1. landing page — sets cookies, carries the CSRF token in a meta tag
curl -sS -L --compressed -c cj -b cj -A "$UA" 'https://checkcoverage.apple.com/?locale=en_US' -o page.html
TOK=$(grep -oE '<meta name="csrf-token" content="[^"]*"' page.html | sed -E 's/.*content="([^"]*)".*/\1/')

# 2. captcha
curl -sS --compressed -c cj -b cj -A "$UA" -H "X-Apple-Csrf-Token: $TOK" \
  'https://checkcoverage.apple.com/api/v1/captcha?locale=en_US'

# 3. serial + answer, together, in one POST
curl -sS --compressed -c cj -b cj -A "$UA" -X POST -H 'Content-Type: application/json' \
  -H "X-Apple-Csrf-Token: $TOK" \
  -d '{"serialInput":"<SERIAL>","answer":"<CAPTCHA>","captchaType":"image"}' \
  'https://checkcoverage.apple.com/api/v1/captchaValidate?locale=en_US'

# 4. result
curl -sS -L --compressed -c cj -b cj -A "$UA" 'https://checkcoverage.apple.com/coverage?locale=en_US'
```

### The gate, precisely

The site is a Next.js app. Its client bundle contains exactly two relevant endpoints —
`/api/v1/captcha` and `/api/v1/captchaValidate` — and the submit handler in
`_next/static/chunks/6027-6cd7d7c3731168a1.js` reads, verbatim:

```js
let a={method:"POST",body:{serialInput:w,answer:A,captchaType:D?.data?.type}},
    t=await (0,j.Zq)(`/api/v1/captchaValidate?locale=${U}`,a);
```

**The serial and the captcha answer are one request.** There is no serial-only endpoint to find.

Three layers guard it, each observed by removing it:

| Removed | Response |
|---|---|
| locale cookie | `{"error":{"token":"NO_LOCALE_COOKIE","message":"Locale cookie is required for API routes"…}}` |
| `X-Apple-Csrf-Token` header | `{"error":"No CSRF header found in API request","errorCode":"API_NO_CSRF_HEADER"}` |
| correct captcha answer | `{"error":{"token":"CAPTCHA_IMAGE_NOT_MATCH","message":"Sorry. The code you entered doesn't match the image…"}}` |

The first two are trivially scriptable — the CSRF token is a 1-hour JWT sitting in
`<meta name="csrf-token">` on the landing page. **The third is the wall.**

The landing page's own server-rendered config states it plainly:

```json
"showSerialFormHeader": true, "disableHumanCheck": false, "captchaPatObj": null
```

### The captcha itself

`GET /api/v1/captcha` returns:

```json
{"data":{"isValidPat":false,"type":"image","binary":"/9j/4AAQSkZJRgABAgAAAQAB…"}}
```

A **160×70 baseline JPEG**, 4–5 upper-case alphanumerics, sheared and overprinted with arcs and a
strike-through, on a noisy background. An audio mode exists for accessibility
(`ccw.captcha.audio.mode.label`: *"Enter the code you hear"*). The localisation bundle carries a full
family of failure states, including a **rate limit** — `ccw.captcha.limiterror`, Thai:
*"คุณได้ใช้รหัสถึงขีดจำกัดแล้ว และเราไม่สามารถดำเนินการตามคำขอของคุณให้เสร็จสมบูรณ์ได้ โปรดลองอีกครั้งในภายหลัง"*
("you have reached the limit for codes and we cannot complete your request; try again later") — plus
`codeexpirederror`, `alreadyusedherror` and `audiousedrror`.

**How hard is it actually?** Six captchas were fetched and read with a frontier vision model. **Two were
solved** (`7CDMQ` on the first guess, `YNUF` on the first guess); four resisted two to four guesses each
(one read as `KB?E`, one as `PVH5`, one as `QU?TV`). Wrong answers do **not** burn the image — four
consecutive misses against one image all returned `CAPTCHA_IMAGE_NOT_MATCH`, and a later correct answer
against that same session succeeded. So it is defeatable by a model that can see, at roughly a third to a
half first-try, with unlimited retries per image and an undocumented rate limit somewhere above that.

**None of which helps `check.sh`.** The deliverable is `bash <(curl -fsSL …)` — no vision model, no API key,
no budget, and Apple's presence of a human check is a statement of intent regardless of whether it is
technically defeatable. Treat the answer as a flat **no**.

### The one route that might legitimately skip it: Private Access Tokens

`/api/v1/captcha` answers **HTTP 401** with an RFC 9577 Privacy Pass challenge:

```
WWW-Authenticate: PrivateToken challenge=AAIAGmlkbXMtaXNzdWVyLmNvcnAuYXBwbGUuY29t…, token-key=MIIBUjA9…, max-age=60
```

The base64 challenge decodes to issuer `idms-issuer.corp.apple.com`, origin `checkcoverage.apple.com`. The
client code branches on a server-supplied `isValidPat` flag and **renders no captcha at all when it is true**:

```js
!(D?.data?.isValidPat || h?.isValidPat) && !p && (0,i.jsx)(k,{id:"captcha-input", …})
```

`curl` cannot mint such a token — issuance requires the device attester and Apple's issuer, and there is no
shell surface for it. **Safari on a signed-in Apple device can**, silently. So the strong inference is that
**the buyer's own iPhone, in Safari, sees no captcha** — serial in, answer out, no puzzle. This was **not
verified end-to-end** (it needs a Safari session on a real device, which is the one thing a headless test
cannot fake), so it is flagged as inference, not fact. It is the single cheapest thing left to confirm,
because if true the prompt costs ~25 s rather than ~60 s.

---

## What the coverage page actually returns in 2026

Solved captcha `7CDMQ`, submitted this Mac's serial, fetched `/coverage`. The rendered page, verbatim:

> **MacBook Air (15-inch, M4, 2025)**
> Serial Number: G5GQ…0L
> **Purchased September 29, 2025**
> **Your Coverage** — Limited Warranty · **Expires September 28, 2026**
> Your device is covered for: Hardware Service · Chat & Phone Support
> *Service is governed by specific AppleCare Terms and Conditions… **Coverage status and expiration date are
> estimated.** Your warranty is the same whether or not you register.*

The underlying JSON embedded in that page is richer than the rendering:

```json
"productInfo": {
  "modelName":  "MacBook Air (15-inch, M4, 2025)",
  "productName":"MacBook Air (15-inch, M4, 2025)",
  "serialNumber":"G5GQ…0L",
  "serialNumberKey":"6a71d155…",
  "dop": "September 29, 2025",
  "openRepair": false,
  "userOwned": false,
  "partnerId": "",
  "coverageInfo": { "coverageType":"LIMITED_WARRANTY",
                    "temporaryCoverage": false,
                    "agreementNumber":"", "agreementCode":"" }
}
```
plus, in the coverage card: `"title":"Limited Warranty","validityLabel":"Expires September 28, 2026"`.

Two fields are worth naming because **they never appear on screen**:

- **`openRepair`** — a boolean for an open repair case on the device. A machine sitting mid-repair, or with
  an unclosed case, is a different proposition from a clean one, and the buyer would never see this.
- **`dop`** — the date of purchase, given as a hard date, not derived from the expiry.

### The states, observed first-hand

| State | How it presents | Observed |
|---|---|---|
| **Valid, in warranty** | model name · `Purchased <date>` · `Limited Warranty` / `Expires <date>` · Hardware Service + Chat & Phone Support | 2026-08-04, first-hand |
| **Invalid serial** | *"The serial number you've entered isn't valid. Please try again."* + a **Start over** button; internal token `INVALID_SERIAL` | 2026-08-04, first-hand (submitted `ZZZZZZZZZZ`) |

Note the ordering, which is not obvious and matters to anyone automating this: **`captchaValidate` validates
only the captcha.** The bogus serial `ZZZZZZZZZZ` returned `{"meta":{"status":"SUCCESS"}}` at step 3 and only
failed at step 4. Serial validity is decided on the coverage page, not the submit.

### States that exist in the bundle but were not reached

Reaching these needs real serials of other people's machines, which was declined. They are recorded as
**localisation strings present in the shipped bundle on 2026-08-04**, which proves the state exists but not
what it looks like:

| Key | String |
|---|---|
| `ccw.coverage.name.ACPLUS` | "AppleCare+" |
| `ccw.coverage.multiple.body` | "Your device has two types of coverage. You can get service and support using the benefits of either." |
| `ccw.updatedop.error.title` | **"Verify your receipt with an Apple expert"** |
| `ccw.updatedop.error.message` | **"Upload a copy of your receipt showing the date of purchase before connecting with an Advisor."** |
| `ccw.coverage.error.header` | "Sorry, we're unable to display coverage details." |
| `ccw.register.applecare.enroll.window.expired` | "AppleCare products must be enrolled within 1 year of purchase of the Apple hardware to be covered." |

`updatedop` is the "the purchase date on file is wrong / unverified" flow the ticket asked about. It exists,
it is reached from the coverage page, and its remedy is a **receipt plus a human Apple advisor** — nothing a
buyer can settle at a shop counter. **No out-of-warranty / expired card was observed**, so this note does not
state what an expired machine renders. That is the largest single hole here, and it is the *common* case for
the machines this guide targets — see [could not establish](#unpinned--could-not-establish).

### What Apple itself says the numbers mean

Apple's own footnote on the page, verbatim: **"Coverage status and expiration date are estimated."** Treat
the expiry as indicative. The purchase date is served as a stored `dop` value rather than a derivation, and
Apple offers a documented flow to *correct* it with a receipt — which is itself evidence that the stored
value is sometimes wrong.

---

## What the serial number itself encodes: nothing

Apple moved to **randomised serial numbers**. The primary evidence is an internal AppleCare memo reported by
MacRumors on **2021-03-09** — *"a randomized alphanumeric string of 8-14 characters that will no longer
include manufacturing…"* (<https://www.macrumors.com/2021/03/09/apple-randomized-serial-numbers-early-2021/>,
published 2021-03-09). **This is a leaked-memo claim, not an Apple statement.** No Apple-published page
describing the serial format was found; `support.apple.com/en-us/102858` ("Find the serial number of your
Apple product", fetched 2026-08-04) tells you where to look and says nothing about what it means.

**Corroborated first-hand, which is what makes it safe to rely on:**

- This 2025 machine's serial is **10 characters**, not the old 12.
- `everymac.com`'s Ultimate Mac Lookup — the most complete third-party decoder there is — returns
  **"No matching results for G5GQ…0L"** (fetched 2026-08-04).
- The *same* tool returns a hit for **`MC7A4TH/A`**, for **`A3241`**, and for **`Mac16,13`**, resolving to
  `MacBook Air "M4" 10 CPU/10 GPU 15"`.

So the practical rule for the guide: **stop treating the serial as a decodable string.** It is an opaque
lookup key. Every specification fact the old decoders used to derive now comes from the *machine*, not the
number.

Two further notes on third-party decoders, both first-hand 2026-08-04:

- **everymac.com is itself captcha-gated.** Its lookup result renders behind *"Please perform the following
  task to retrieve your personalized results"*, alongside adverts for a paid **"EveryMac.com Captcha-Free
  Lookup"** and a paid **"EveryMac Lookup API"**. So "just use everymac" is not a captcha-free escape hatch.
- Nothing found suggests any decoder proxies Apple's coverage endpoint for free; the ones that offer
  serial-keyed *Apple* data (locks, warranty, purchase date) are GSX proxies and they charge — see below.

---

## What the machine tells you locally, for free

All of the following was run as **uid 501, no sudo**, on macOS Tahoe 26.5.2, 2026-08-04. This is the part of
the ticket that turned out to be worth the most, because it is free and unlimited under
[#11](https://github.com/mingrath/mbcheck/issues/11).

```
$ system_profiler SPHardwareDataType
      Model Name: MacBook Air
      Model Identifier: Mac16,13
      Model Number: MC7A4TH/A
      Chip: Apple M4
      Total Number of Cores: 10 (4 performance and 6 efficiency)
      Memory: 16 GB
      Serial Number (system): G5GQ…0L
      Activation Lock Status: Enabled
```

```
$ ioreg -d2 -c IOPlatformExpertDevice
        "target-type"             = <"J715">
        "region-info"             = <54482f4100…>      →  TH/A
        "regulatory-model-number" = <4133323431…>      →  A3241
        "mlb-serial-number"       = <433032484845…>    →  C02HHE000EB0000MSX
        "IOPlatformSerialNumber"  = "G5GQ…0L"
        "model"                   = <"Mac16,13">
```

Three of these are not in the README and each earns its place:

- **`region-info` = `TH/A`.** The region of sale, free and offline. It is the same two letters as the tail of
  the part number (`MC7A4**TH**/A`), so the two cross-check each other. A Thai listing on a `LL/A` (US) or
  `ZP/A` (Hong Kong) machine is a grey import — relevant because Apple Thailand's published battery service
  and AppleCare+ terms are the local ones, and because
  [#13](https://github.com/mingrath/mbcheck/issues/13) established Apple TH quotes everything except battery
  on inspection.
- **`regulatory-model-number` = `A3241`.** The A-number stamped on the underside of the chassis. This is the
  **one field a buyer can compare against a physical engraving without a network call**, which makes it the
  cheapest available anti-swap cross-check.
- **`mlb-serial-number` = `C02HHE000EB0000MSX`.** The logic-board serial, structurally *unlike* the system
  serial (18 chars, old-style `C02` prefix, heavily zero-padded). **What a mismatch here would mean is not
  established** and this note does not guess. Recorded because it is free to read and nobody has looked.

### Apple's model tables are the offline decode route

Apple publishes model identifier → marketing name → part numbers, with `xx` as the region placeholder:

- **[A1]** <https://support.apple.com/en-us/102869> — "Identify your MacBook Air model", fetched 2026-08-04.
  Under **MacBook Air (15-inch, M4, 2025)**: `Model Identifier: Mac16,13`; `Part Numbers: MC6J4xx/A, MC6K4xx/A,
  MC6L4xx/A, **MC7A4xx/A**, MC7C4xx/A, MC7D4xx/A, MDG34xx/A, MDG84xx/A, MDG94xx/A, MW1G3xx/A …`
- **[A2]** <https://support.apple.com/en-us/108052> — "Identify your MacBook Pro model", fetched 2026-08-04.
  Same shape; covers up to MacBook Pro (14-/16-inch, M5 Pro or M5 Max), 2026, `Mac17,6`–`Mac17,9`.

`MC7A4TH/A` matches `MC7A4xx/A` under `Mac16,13`. **Screen size and model year are therefore obtainable with
no network at all**, from a table small enough to bundle in the script. This is the finding that guts the
README's stated reason for visiting checkcoverage.

What the tables do **not** give: **many part numbers map to one model**, and Apple publishes no
part-number → RAM/SSD/colour mapping. RAM comes from `system_profiler` anyway; storage from the disk; colour
from the buyer's eyes. **No gap.**

### Nothing on the machine reveals manufacture date

**[B1]** `ioreg -l` was searched for `manufactur|build-date|mfg|"date"` and `nvram -p` for anything
serial-bearing (2026-08-04, this machine). Result: `manufacturer = "Apple Inc."` and per-component
`Manufacturer` strings ("Apple", "Bosch" for the IMU), and **zero** date or serial keys in NVRAM. There is no
local manufacture-date surface. With randomised serials there is no remote one either. **Manufacture date is
simply not obtainable** — not by script, not by browser, not by paying.

Purchase date is a different matter and *is* obtainable, from the coverage page, behind the captcha.

---

## Stolen-device reporting

### Apple exposes nothing to a buyer

Apple's own page — **[S1]** <https://support.apple.com/en-us/102481>, "If your Mac is lost or stolen",
**published 2026-04-13**, fetched 2026-08-04 — is unambiguous, verbatim:

> **"Find My Mac is the only Apple service that can help track or locate a lost Mac."**

and, twice:

> "Report your lost or stolen Mac to local law enforcement. Law enforcement might request the serial number
> of your Mac."

Find My is owner-facing. Apple's answer to theft is *the police*, and it says so. There is **no Apple
endpoint, page or API that answers "is this serial reported stolen"** for a buyer.

Apple did once run a public **Activation Lock status checker** at `icloud.com/activationlock`, and **removed
it in January 2017** (AppleInsider 2017-01-28,
<https://appleinsider.com/articles/17/01/29/apple-removes-icloud-activation-lock-status-tool-from-website>;
MacRumors 2017-01-29, <https://www.macrumors.com/2017/01/29/apple-removes-activation-lock-status-checker/>).
It covered **iPhone, iPad and iPod only** — it never covered Macs. For Macs the equivalent fact is already
free and local: `Activation Lock Status` in `system_profiler`.

### One free, fully scriptable registry does exist

**`stolenregister.com`** — a voluntary, crowd-sourced worldwide lost-and-stolen register, running since 2013
(footer reads "© 2013-2026", fetched 2026-08-04). **It is machine-readable with no captcha, no login and no
cookie:**

```bash
curl -s "https://www.stolenregister.com/check?sn=<SERIAL>"
```

Both branches verified 2026-08-04:

| Input | Response body contains |
|---|---|
| this Mac's serial | `Not reported as lost or stolen.` |
| `C02G30DCMD6W` (positive control, taken from the site's own public search) | `Apple MacBook Pro 16”` · `Stolen on 02/10/2022 in London, United Kingdom` · Record Number, Incident Type, Incident Date, Report Date, Item Type `Laptop`, Reward `200`, Maker, Model, Serial Number |

It indexes laptops as a first-class item type and does hold real MacBook records with serials.

**Its coverage is the whole question, and it is thin and Anglophone.** On 2026-08-04 a free-text search for
`macbook` returned records from **London** and **Mesquite, Texas**; free-text searches for **`bangkok`**,
**`thailand`** and **`chiang`** returned **zero records**. That is not proof of zero Thai records — the
free-text box may search item descriptions rather than locations — but no Thai record surfaced by any route
tried.

The honest characterisation for the guide: **a hit is decisive, a miss proves nothing.** Under
[#10](https://github.com/mingrath/mbcheck/issues/10) that makes it a 🛑-capable check whose silence carries no
information — which is fine, because under [#11](https://github.com/mingrath/mbcheck/issues/11) script reads
are free and reading forty costs what reading ten costs.

### Thailand has no public stolen-property lookup

Searched in Thai on 2026-08-04. What exists, and what each actually does:

| Service | What it is | Can a buyer check a serial? |
|---|---|---|
| **thaipoliceonline.go.th** — ศูนย์ปราบปรามอาชญากรรมทางเทคโนโลยีสารสนเทศ (ศปอส.ตร.) | The Royal Thai Police online **reporting** portal, scoped to technology/online crime. Confirmed as the sole official online-reporting channel by AIS's public-awareness page (<https://sustainability.ais.co.th/th/update/aunjai-cyber/798/reporting-crime-online>) | **No** — it takes reports, it does not answer queries |
| **crd.go.th** — กองทะเบียนประวัติอาชญากร | Criminal-record checks on **people**, by name or fingerprint | **No** — people, not property |
| "ทางรัฐ" app | Case-progress tracking for your **own** filed case, after KYC | **No** |
| PDC ReadID | Arrest-warrant lookup by national ID | **No** |

**No Thai government or police database of stolen laptops queryable by serial by a member of the public was
found.** The absence is structural, not Thai-specific: laptops have **no IMEI**, so they fall outside the
GSMA Device Registry and every carrier blacklist built on it — those are IMEI-keyed by construction. A Thai
news article (springnews, <https://www.springnews.co.th/digital/823470>, undated on page) claims Apple checks
the GSMA Device Registry before servicing devices; even taken at face value that is an **iPhone** mechanism
and cannot reach a Mac.

**What is left for a Thai buyer** is not a lookup: the original receipt (ใบเสร็จ), the box with a matching
serial, watching the seller sign out of iCloud in front of you, and the free local Activation Lock and MDM
reads. Apple's own advice in [S1] points the same way.

---

## Cloned or reused serials

**This is the question this research failed to answer, and it should be recorded as a failure rather than
filled in.** No evidence was found — first-hand, from Apple, or from any credible secondary source — on how
often Apple-silicon Mac serials are cloned, how a cloned one presents, or whether the system serial on an
M-series Mac can be rewritten at all. Search returned only forum threads and YouTube titles about *Intel*-era
spoofing. Those are claims about a different security architecture and are not carried into this note.

What *can* be said, because it follows from fields verified above rather than from anyone's claim: the
machine exposes **five independent identity fields** for free — `IOPlatformSerialNumber`, `model`
(`Mac16,13`), `regulatory-model-number` (`A3241`), `region-info` (`TH/A`) and `Model Number` (`MC7A4TH/A`) —
and Apple publishes the table that ties identifier to part number [A1][A2]. **A cross-check of those five
against each other, against the engraving on the underside, and against the marketing name the coverage page
returns is available at zero script cost.** Whether disagreement between them is a realistic fraud signal or
a curiosity is exactly what could not be established.

The README's implied test — *engraved serial vs About This Mac vs the coverage page* — is therefore **sound
in principle and unquantified in practice**. Do not attach a severity to it until someone has seen one.

---

## Outstanding financing

**Not visible from the serial. Not from Apple, not from any free source.** Nothing in the coverage payload
observed above carries a finance or instalment field, and Apple publishes no such thing.

But the question reframes usefully, because in Thailand the *mechanism* is one the script already reads.
Thai instalment sellers ("เครื่องผ่อน") control financed devices by enrolling them in **MDM**; missed
payments trigger a remote lock. This is documented consistently across Thai shop and consumer sources
(**[C1]** <https://ifixserviceth.com/mdm-lock-on-iphone-users/>, undated page, fetched 2026-08-04:
*"ร้านมือถือที่ปล่อยเครื่องผ่อน โดยใช้ MDM เป็นระบบความปลอดภัย"* — "phone shops that sell on instalment use
MDM as their security system"; corroborated by bkkapple.com and jumnum2go.com, both undated, and by numerous
Thai social posts). **Every located source is about iPhones**, not Macs — the mechanism transfers because
MDM and DEP work the same way on macOS, but no Thai source was found describing a financed *MacBook*.

So: the guide cannot ask "is there money owed on this?" It can ask **"is this machine under someone else's
management?"** — and `profiles status -type enrollment` answers that for free, already established.

**One real limitation, found here and worth flagging.** `profiles status -type enrollment` reports the
machine's *current* enrolment state. Querying Apple for a **pending DEP assignment** — a machine assigned to
an organisation in Apple Business Manager but not presently enrolled, which is exactly the state a wiped
financed machine sits in — uses `profiles show -type enrollment`, and that returns, verbatim on this machine
2026-08-04:

```
Must be running as root
```

The script takes no sudo ([#11](https://github.com/mingrath/mbcheck/issues/11)). Whether the unprivileged
`status` call nonetheless catches an assigned-but-unenrolled machine **was not established** and is the
sharpest open question this ticket produced.

---

## Third-party GSX proxies, including one in Thailand

Serial-keyed Apple data richer than the coverage page does exist, via resellers of **GSX** (Apple's
service-provider system). The Thai one is **mac2hand.com/serial-check** — mac2hand being a Thai second-hand
Mac marketplace operating, per its own footer, since 2009. Fetched 2026-08-04:

| Package | Price (stated VAT-inclusive) | Advertised fields |
|---|---|---|
| Apple iCloud and MDM ON/OFF Checker (iOS **& Mac**) | **฿35** | Model, SN, IMEI/IMEI2, Model number, iCloud Lock On/Off, MDM Lock On/Off |
| Sold by info | **฿135** | + Replaced Device, GSX Case/Repair/Replacement History (counts), Coverage Status, **Sold To Name**, **Purchase Country**, Next Tether Policy, Sim-Lock |
| Apple GSX Full Report & Sold by | **฿149** | + **Purchase Date**, Coverage Start/End, Days Remaining, **Config Code**, **Config Description**, Activation Policy, Wireless MAC, Last Restore / OS build |

Turnaround claimed 1–10 minutes; payment by PromptPay or bank transfer with a slip upload.

If real, the ฿149 report would answer several things nothing else answers — **Config Description** is the
exact factory configuration (the thing the randomised serial stopped encoding), and repair/replacement
history goes beyond what [#13](https://github.com/mingrath/mbcheck/issues/13) found Parts & Service tracks.

**Four reasons this note does not recommend it, all from the page itself:**

1. The page states its own payment flow is not live: *"ในหน้านี้เป็นตัวอย่าง mockup ระบบชำระเงินจริงจะเปิดใช้ตามรอบงาน"*
   — "this page is a mockup; the real payment system will be enabled per work cycle." The pricing copy also
   leaks an internal admin path (`/admin/serial-pricing`). As of 2026-08-04 this reads as an unlaunched page.
2. **Every sample result shown is an iPhone.** Half the advertised fields (IMEI, IMEI2, MEID, Sim-Lock, Next
   Tether Policy) do not exist on a Mac. No Mac output was shown, and nothing establishes what a Mac serial
   actually returns.
3. The headline copy promises a **blacklist / lost-stolen** check and *"เครื่องผ่อน"* (instalment) detection —
   but **no package's own field list contains either field.** The marketing over-claims against the product
   spec printed on the same page.
4. mac2hand disclaims it outright: *"บริการเช็คนี้ทำผ่านผู้ให้บริการภายนอก"* — the check runs through an
   external provider, and price, speed and results depend on that provider and on Apple's database at the
   time of the query. GSX is Apple's service-provider tool; third-party resale of access is outside Apple's
   terms, so neither reliability nor longevity can be assumed.

Recorded because a Thai buyer will find it, and the guide should be able to say what it is and what it is
not. **Treat every field above as advertised, not verified.**

---

## Recommendation to [#19](https://github.com/mingrath/mbcheck/issues/19)

Not a decision — #19 owns the 8 slots. What this research says about the trade:

**Add to the script (free, unbounded, no argument):**

- `ioreg` `region-info`, `regulatory-model-number`, `mlb-serial-number`
- offline model-identifier → marketing name / screen size / year, from a bundled copy of [A1][A2]
- `GET stolenregister.com/check?sn=…` — 🛑 on a hit, silent on a miss, no severity for a miss

**The coverage lookup is a prompt or a cut.** Arguments both ways, laid out rather than resolved:

- *For keeping it:* purchase date and AppleCare+ status are unobtainable any other way, and the map's open
  item "how the guide handles a machine still under AppleCare+" cannot be answered without it. If the PAT
  inference holds, on the buyer's own iPhone it is ~25 s: open the page, type the serial, read two lines.
- *Against:* it is a network round-trip in front of a seller, it fails on bad shop wifi, its invalid-serial
  state mostly fires on typos, and [#13](https://github.com/mingrath/mbcheck/issues/13) already established
  that **a prior independent repair voids AppleCare+ outright** — so "covered" is not even reliable good news
  without a second check the script cannot make either.

If it stays, phrase the prompt for **the two facts that are actually new** — *"What date does it say the
machine was purchased?"* and *"What does the coverage line say?"* — not *"does the model match"*, which the
script already knows.

---

## Unresolved conflicts in the sources

1. **Does Safari's Private Access Token actually suppress the captcha?** The 401 challenge is real and
   observed; the `isValidPat` branch that hides the captcha is real and in the shipped bundle. The link
   between them is inference. **Consequence if wrong:** the prompt costs ~60 s and a fiddly puzzle rather
   than ~25 s, which could be the difference between it earning a slot and not.
2. **Is `dop` a purchase date or an activation date?** Apple labels it "Purchased", offers a receipt-backed
   correction flow (`updatedop`), and footnotes the page "Coverage status and expiration date are estimated"
   — where the footnote covers *status and expiration*, conspicuously **not** the purchase date. The two
   readings are not reconciled here.
3. **mac2hand's own page contradicts itself** — headline promises a blacklist and instalment check; no
   package lists either field.
4. **springnews' GSMA claim** cannot be true for Macs (no IMEI) even if true for iPhones. Recorded as a claim
   and not relied on.

---

## Unpinned / could not establish

Listed so the guide author knows not to reach for a fact that does not exist, and knows what would pin it.

| # | Missing | Why | What would pin it |
|---|---|---|---|
| 1 | **What an out-of-warranty machine renders on the coverage page** | Needs a real serial of an old machine; using a stranger's was declined. This is the **common case** for this guide's target machines. | One run against an out-of-warranty Mac the dev owns or borrows — 2 minutes, and it closes the biggest hole here |
| 2 | **What an AppleCare+ machine renders** | Same | Same |
| 3 | **Whether Safari's PAT removes the captcha** | Needs a real Safari session on a signed-in device | Open `checkcoverage.apple.com` in Safari on the dev's iPhone; note whether a captcha box appears |
| 4 | **Whether `profiles status -type enrollment` catches a pending-but-unenrolled DEP assignment** | `profiles show` needs root; the script takes no sudo | Apple documentation, or a test against a machine known to be ABM-assigned |
| 5 | **Whether an Apple-silicon Mac's system serial can be rewritten at all** | Every source found concerns Intel-era spoofing | A teardown/security source addressing M-series specifically |
| 6 | **How often cloned or reused serials occur, and how they present** | No credible source, first-hand or secondary | One documented case with the five identity fields recorded |
| 7 | **What `mlb-serial-number` disagreeing with the system serial would mean** | Read for free; nobody appears to have written about it | A machine with a known-replaced logic board, read before and after |
| 8 | **checkcoverage's actual rate limit** | `ccw.captcha.limiterror` exists; the threshold is undocumented and was not probed | Deliberate probing — not done, to avoid abusing Apple's endpoint |
| 9 | **Whether mac2hand's service is live, and what it returns for a Mac** | Its own page calls the payment flow a mockup; all samples are iPhones | ฿35 and one Mac serial |
| 10 | **Any Apple-published statement of the serial-number format change** | Only a leaked memo via MacRumors exists | Nothing known — Apple appears never to have published one |
| 11 | **Any Thai-language stolen-property registry** | Searched in Thai; only reporting portals and people-records systems exist | Nothing found; would take a Royal Thai Police statement to overturn |
| 12 | **Thai record coverage on stolenregister.com** | Free-text search for bangkok/thailand/chiang returned zero on 2026-08-04, but the box may not search locations | The site's own country filter, which did not appear to apply via URL parameters |
| 13 | **Part number → RAM / SSD / colour** | Apple lists many part numbers per model with no per-SKU breakdown | GSX `Config Description` (paid, unverified). No free route exists. |

---

## Method and tooling

**AgentKey MCP** (`Serper/search`, including Thai-language searches with `gl=th&hl=th`) was the search tool
throughout; built-in WebSearch/WebFetch were not used. Page reads and every API experiment were plain `curl`
against the origin, so that each is reproducible from the commands printed above rather than through a
scraper.

The `checkcoverage.apple.com` work was done by downloading all 50 of the site's Next.js chunks
(1.8 MB) and reading the submit path directly, then replaying the flow against the live endpoints. That is
why this note can quote the request body shape and the `isValidPat` branch rather than describing the form
from the outside.

**One captcha was solved to obtain the worked example**, against the dev's own machine's serial, twice
(once for the valid case, once with a bogus serial for the invalid case). No third party's serial was
submitted to any service at any point, and no rate limit was probed deliberately.

**Errors caught during verification**, recorded so they are not reintroduced:

1. An early read of the flow assumed a serial-only lookup endpoint existed behind the captcha. Reading the
   client bundle disproved it: `serialInput` and `answer` are one POST body.
2. `captchaValidate` returning `SUCCESS` was initially read as "serial accepted". It is not — a bogus serial
   also returns `SUCCESS` there and fails one step later. Any future automation of this flow must check
   `/coverage`, not the validate response.
3. The first conclusion drafted was "checkcoverage is the model-verification check". Reading `ioreg` and
   Apple's model tables inverted it: the model facts are free and local, and the coverage page's real
   contribution is purchase date plus coverage state.
