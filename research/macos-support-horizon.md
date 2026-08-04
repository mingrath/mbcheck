# The macOS support horizon for Apple-silicon MacBooks

Research note resolving [issue #8](https://github.com/mingrath/mbcheck/issues/8).
Answers the "given its age" question the guide has never answered: whether a mechanically perfect
second-hand MacBook can still be a bad buy because its software life is nearly over.

**Research date: 2026-08-04.** Every fact carries its own observed date. Where an Apple page prints a
publication date it is quoted; where it does not, 2026-08-04 is the only date of record.

**Everything in this note about the future is a prediction and is labelled as one.** Apple has never
published a support-length commitment for any Mac, and the one law that would have forced it to
[explicitly excludes laptops](#no-commitment-exists--and-the-law-that-would-have-forced-one-excludes-laptops).
Every forward-looking statement below names the pattern it rests on, the size of that sample, and a
confidence level.

---

## The answer, before the evidence

**No Apple-silicon Mac has ever been dropped from a macOS release.** Apple has now shipped seven
macOS versions across the Apple-silicon era — Big Sur 11 through the announced macOS 27 — and the
number of Apple-silicon Macs cut in that time is **zero**. macOS 27 "Golden Gate", whose
compatibility list Apple published in June 2026, still supports the **November 2020 M1 MacBook Air**.

What macOS 27 *does* drop is **every remaining Intel Mac**. The entire "which Macs get cut" story of
2025–2026 is the Intel transition finishing, not Apple-silicon machines ageing out. The guide covers
Apple silicon only, so **that story does not touch a single machine in its scope**.

The buyer-facing consequence:

> **Age alone is not currently a reason to decline any M1–M5 MacBook, and the guide should say so
> plainly rather than leaving "given its age" as an unexplained worry.** The one genuine
> age-linked cost is not the OS at all — it is the battery, which is a 💰 with a real baht price
> ([#13](https://github.com/mingrath/mbcheck/issues/13)), and the loss of Rosetta 2 after macOS 27,
> which is a 📝 that affects *old apps*, not old machines.

And the reason to say it out loud rather than stay silent: **the Thai market gives the buyer no
signal either way.** No mac2hand listing read for this note mentions macOS support at all, and a
Pantip advisor in June 2025 was steering a budget buyer toward 2017–2019 *Intel* Macs — weeks after
Apple announced those were the machines about to be cut. A buyer worried about age is worried in an
information vacuum, and the guide is well placed to fill it.

The full rule, with the trigger that would change this answer, is in
[The rule](#the-rule--when-age-alone-is-a-reason-to-decline).

---

## ⚠️ Corrections and additions this research forces on the current README

| # | README / map says | Reality | Where |
|---|---|---|---|
| 1 | README Step 1a accepts "macOS **Sequoia 15** or Tahoe 26" as a pass | Both are supported *versions*, but the check is being read wrong. **The macOS a machine is *running* says nothing about its support horizon** — a second-hand M1 on Sequoia is merely un-updated, and updating is free. The horizon question is *which macOS the model can still install*, which is a different fact. | [Running vs supported](#running-an-old-macos-is-not-the-same-as-being-an-old-mac) |
| 2 | The guide has no age or support-horizon check at all | It does not need a per-model one. Today the correct check is a single Boolean: **is this model on the compatibility list of the newest announced macOS?** For every M1–M5 MacBook the answer is yes. | [The rule](#the-rule--when-age-alone-is-a-reason-to-decline) |
| 3 | [#13](https://github.com/mingrath/mbcheck/issues/13) established Parts & Service needs **macOS Tahoe 26** | Still true, and now sharper: **every M1–M5 MacBook *can* run Tahoe 26**, so the pane is always reachable in principle. When it is missing, the cause is an un-updated machine, not an unsupported one — and the buyer can ask the seller to update. | [Running vs supported](#running-an-old-macos-is-not-the-same-as-being-an-old-mac) |
| 4 | Nothing anywhere mentions Rosetta 2 | **macOS 27 is the last release with full Rosetta 2**, in Apple's own words. From macOS 28 it survives only for "certain older, unmaintained games". This is a genuine dated cliff — but it hits Intel-only *apps* on every Apple-silicon Mac equally, M1 and M5 alike, so it is **not** an age discriminator between models. | [Rosetta](#the-one-real-dated-cliff-is-rosetta-2--and-it-hits-every-model-equally) |
| 5 | README is built for a **MacBook Pro 16" M1 Pro 2021 at ฿31,500** | **That machine has left the Thai market.** mac2hand carries **zero live 16-inch M1 Pro/Max listings** and no 2026-dated 13" M1 Pro listings; the 14" M1 Pro has three ads site-wide. The M1 *Air* remains abundant. A worked example built on a machine a buyer cannot find is a worked example that will not be followed. | [Second-hand market](#second-hand-market-is-anything-close-enough-to-the-edge-to-say-so) |
| 6 | Nothing anywhere compares a used machine to a new one | **A brand-new, warrantied MacBook Neo is ฿24,900** — about ฿10,000 more than a five-year-old M1 Air (median ฿14,700) and on the same macOS 27 list. The "given its age" decision is a ฿10,000-and-a-battery decision, not a software-life decision. | [Second-hand market](#second-hand-market-is-anything-close-enough-to-the-edge-to-say-so) |
| 7 | The map's scope is "M1 through M5, Air and Pro" | Apple now ships a **MacBook Neo (13-inch, A18 Pro, 2026)** — a laptop that is neither Air nor Pro and is not M-series. It is in Apple's Tahoe 26 and macOS 27 compatibility lists. Out of scope by the map's wording, and too new to be second-hand, but the scope line will need re-reading eventually. | [Scope](#a-scope-question-the-macbook-neo) |

---

## What Tahoe 26 dropped, and what macOS 27 drops

Apple publishes a per-version compatibility list. Diffing consecutive lists gives the exact cut, with
no interpretation.

**macOS Sequoia 15** — <https://support.apple.com/en-us/120282>, published 2025-09-15.
**macOS Tahoe 26** — <https://support.apple.com/en-us/122867>, published 2026-06-08.
**macOS 27 "Golden Gate"** — <https://www.apple.com/os/macos/>, observed 2026-08-04 (preview page,
no publication date; page states "macOS 27 Golden Gate coming this fall").

### Tahoe 26 dropped eleven models. Every one of them is Intel.

| Dropped by Tahoe 26 (present in Sequoia 15, absent from Tahoe 26) | Architecture |
|---|---|
| MacBook Air (Retina, 13-inch, 2020) | Intel |
| MacBook Pro (13-inch, 2020, **Two** Thunderbolt 3 ports) | Intel |
| MacBook Pro (13-inch, 2019, Two Thunderbolt 3 ports) | Intel |
| MacBook Pro (13-inch, 2019, Four Thunderbolt 3 ports) | Intel |
| MacBook Pro (15-inch, 2019) | Intel |
| MacBook Pro (13-inch, 2018, Four Thunderbolt 3 ports) | Intel |
| MacBook Pro (15-inch, 2018) | Intel |
| iMac (Retina 5K, 27-inch, 2019) · iMac (Retina 4K, 21.5-inch, 2019) | Intel |
| iMac Pro (2017) | Intel |
| Mac mini (2018) | Intel |

**Apple-silicon models dropped by Tahoe 26: none.**

Note the trap in row 2: the **13-inch 2020 MacBook Pro exists in two variants** and Tahoe splits
them. The *Two* Thunderbolt 3 port model is Intel and was dropped; the *Four* Thunderbolt 3 port
model is also Intel but was **kept**. A buyer reading "2020 MacBook Pro" off a listing cannot tell
which is which, and neither can the guide — but this only matters for Intel machines, which the map
rules out of scope.

### Tahoe 26 kept four Intel Macs. macOS 27 drops all four.

Tahoe 26's list retains MacBook Pro (16-inch, 2019), MacBook Pro (13-inch, 2020, Four Thunderbolt 3
ports), iMac (Retina 5K, 27-inch, 2020) and Mac Pro (2019). macOS 27's list contains **no Intel Mac
of any kind** — only "MacBook Air with Apple silicon (2020 and later)", "MacBook Pro with Apple
silicon (2020 and later)", MacBook Neo (2026), and the Apple-silicon iMac / mini / Studio / Pro.

That derivation — comparing Apple's own two lists — is how this note establishes that **macOS Tahoe
26 is the last macOS for Intel Macs**. Apple states the same thing obliquely on its Rosetta page
(below) but the two compatibility lists are the harder evidence.

### macOS 27's list, in full, for the models in scope

> - MacBook Air with Apple silicon (2020 and later)
> - MacBook Pro with Apple silicon (2020 and later)

— <https://www.apple.com/os/macos/>, observed 2026-08-04.

Two caveats stated rather than glossed. First, **this is a preview page, not a shipped OS**: macOS 27
"comes this fall" and the final compatibility list could in principle differ. Second, the page gives
a *family* rule ("2020 and later") rather than the per-model enumeration Apple publishes once a
version ships; the enumerated list will appear at a `support.apple.com` article in September. Neither
caveat is load-bearing here, because the rule "2020 and later" has no Apple-silicon exclusions to
hide — the first Apple-silicon MacBook shipped in 2020.

---

## Every Apple-silicon MacBook, and how many macOS versions it has received

Model years and model identifiers from Apple, ["Identify your MacBook Air
model"](https://support.apple.com/en-us/102869) (published 2026-07-02) and ["Identify your MacBook
Pro model"](https://support.apple.com/en-us/108052). Supported-through columns from the three
compatibility lists above.

**This is the small table the guide can carry.**

| Model | Chip | Year | Shipped with | macOS versions received, incl. 27 | On macOS 27 list? | Age at fall 2026 |
|---|---|---|---|---|---|---|
| MacBook Air (M1, 2020) — `MacBookAir10,1` | M1 | 2020 | Big Sur 11 | **7** (11·12·13·14·15·26·27) | ✅ | ~6 yr |
| MacBook Pro (13-inch, M1, 2020) | M1 | 2020 | Big Sur 11 | **7** | ✅ | ~6 yr |
| MacBook Pro (14-inch / 16-inch, 2021) | M1 Pro / Max | 2021 | Monterey 12 | **6** (12·13·14·15·26·27) | ✅ | ~5 yr |
| MacBook Air (M2, 2022) — `Mac14,2` | M2 | 2022 | Monterey 12 | **6** | ✅ | ~4 yr |
| MacBook Pro (13-inch, M2, 2022) | M2 | 2022 | Monterey 12 | **6** | ✅ | ~4 yr |
| MacBook Air (15-inch, M2, 2023) — `Mac14,15` | M2 | 2023 | Ventura 13 | **5** (13·14·15·26·27) | ✅ | ~3 yr |
| MacBook Pro (14-inch / 16-inch, 2023) † | M2 Pro/Max, M3 family | 2023 | Ventura 13 / Sonoma 14 | **5** / **4** | ✅ | ~3 yr |
| MacBook Air (13-inch / 15-inch, M3, 2024) — `Mac15,12` / `Mac15,13` | M3 | 2024 | Sonoma 14 | **4** (14·15·26·27) | ✅ | ~2 yr |
| MacBook Pro (14-inch / 16-inch, 2024) | M4 family | 2024 | Sequoia 15 | **3** (15·26·27) | ✅ | ~2 yr |
| MacBook Air (13-inch / 15-inch, M4, 2025) — `Mac16,12` / `Mac16,13` | M4 | 2025 | Sequoia 15 | **3** | ✅ | ~1 yr |
| MacBook Pro (14-inch, M5) | M5 | 2025 | Tahoe 26 | **2** (26·27) | ✅ | <1 yr |
| MacBook Pro (14-inch / 16-inch, M5 Pro or M5 Max) | M5 Pro/Max | 2026 | Tahoe 26 | **2** | ✅ | new |
| MacBook Air (13-inch / 15-inch, M5) — `Mac17,3` / `Mac17,4` | M5 | 2026 | Tahoe 26 | **2** | ✅ | new |

Model-year attributions for the M5 line are consistent with those pinned in
[#13](https://github.com/mingrath/mbcheck/issues/13) from Apple TH's identify pages.

**The "shipped with" column is derived**, not quoted: it is the earliest macOS whose compatibility
list contains the model, cross-checked against release timing. Verified directly for the M1 and M2
generations against [macOS Ventura's list](https://support.apple.com/en-us/102861) (published
2025-09-17), which contains MacBook Air (M1, 2020), MacBook Air (M2, 2022), MacBook Air (15-inch, M2,
2023), MacBook Pro (13-inch, M1, 2020), MacBook Pro (13-inch, M2, 2022) and MacBook Pro (14-inch /
16-inch, 2021 and 2023). The load-bearing number in the table is the **version count**, not the
starting version.

† **Apple's compatibility lists are coarser than the product line here.** Apple uses one entry,
"MacBook Pro (14-inch, 2023)", for both the January 2023 M2 Pro/Max machines and the October 2023 M3
machines. The M2 Pro/Max variant starts at Ventura 13; the M3 variant shipped with Sonoma 14 and
cannot install anything older. Hence two counts in one row.

> ⚠️ **Model identifier is unique for Apple silicon but not for Intel.** Apple's Air page lists
> `MacBookAir7,2` twice — for both the "13-inch, Early 2015" and the "13-inch, 2017". Every
> Apple-silicon identifier in the table above is unique, so a script keying on
> `sysctl hw.model` is safe **within the guide's scope** and would not be outside it.

---

## Apple's security-only tail, measured from Apple's own release record

Apple publishes no support-duration policy, so the tail has to be measured rather than quoted. The
measurement below comes from Apple's ["Apple security releases"](https://support.apple.com/en-us/100100)
index and its archives ([120989](https://support.apple.com/en-us/120989),
[121012](https://support.apple.com/en-us/121012)), read 2026-08-04.

"Superseded" = the day the successor shipped. "Tail" = superseded → last CVE-bearing update.

| macOS | Released | Superseded | Last security update | Tail | Total patched life |
|---|---|---|---|---|---|
| Catalina 10.15 | 2019-10-07 | 2020-11-12 | 2022-07-20 (Safari 2022-08-18) | 20.3–21.2 mo | ~34 mo |
| Big Sur 11 | 2020-11-12 | 2021-10-25 | 2023-09-11 (Safari 2023-09-21) | 22.5–22.9 mo | ~34 mo |
| Monterey 12 | 2021-10-25 | 2022-10-24 | 2024-07-29 (12.7.6) | 21.2 mo | 33.1 mo |
| Ventura 13 | 2022-10-24 | 2023-09-26 | 2025-08-20 (13.7.8) | 22.8 mo | 33.9 mo |
| Sonoma 14 | 2023-09-26 | 2024-09-16 | **still patched** (14.8.8, 2026-07-27) | ≥22.3 mo | ≥34 mo |
| Sequoia 15 | 2024-09-16 | 2025-09-15 | **still patched** (15.7.8, 2026-07-27) | ≥10.3 mo | ≥22.3 mo |
| Tahoe 26 | 2025-09-15 | — (current, 26.6) | — | n/a | n/a |

**Observed pattern.** A macOS version keeps receiving CVE-bearing updates for roughly **21–23 months
after it stops being current**, i.e. about **33–34 months of total patch coverage from its own
release date**, with the final patch landing in the July–September window as it becomes N‑3.

**Sample: four closed cases (Catalina, Big Sur, Monterey, Ventura) plus two in flight (Sonoma,
Sequoia).** Consistent to within about two months across all four closed cases. **This is a pattern
Apple has followed, not a commitment Apple has made** — see below.

*Independent cross-check from an unrelated direction:* Thai outlet **Sanook**, writing about macOS 27
on 2026-06-04, tells readers the Intel Macs being dropped come *"พร้อมอัปเดตความปลอดภัยต่ออีก 3 ปี"* —
with a further three years of security updates (<https://www.sanook.com/hitech/1625178/>). That is a
secondary source and a rounded figure, but it lands on the same 33–34 months this note measured from
Apple's own release record.

> **Anomaly, recorded rather than smoothed over:** Apple's index lists **macOS Big Sur 11.7.11 dated
> 2026-02-02** with *"This update has no published CVE entries"*, about 2⅓ years after Big Sur's last
> CVE-bearing patch. It carries no advisory, so it does not extend Big Sur's tail — but it shows
> Apple occasionally shipping to a dead train without explanation.

### The derived rule that actually matters to a buyer

Combining the two halves — the compatibility list and the tail:

> **A Mac stops receiving security patches roughly 33–34 months after the release date of the last
> macOS version it can install.**

Applied to the M1, taking the **most pessimistic reading available** (that macOS 27, shipping
autumn 2026, turns out to be the M1's last):

> **Prediction — moderate confidence.** An M1 MacBook bought today would still receive Apple security
> updates until approximately **mid-2029**. Basis: macOS 27 ships ≈ Sept/Oct 2026; +33–34 months.
> Sample: the four closed tails above. This is a *floor*, because it assumes a drop for which there
> is currently no evidence.

### "Still gets security updates" is weaker than it sounds — and Apple says so

This is the single most important qualification in the note, and it comes from Apple's own words.

Apple Platform Deployment, ["About software updates for Apple
devices"](https://support.apple.com/guide/deployment/about-software-updates-depc4c80847a/web),
live as of 2026-08-04:

> *"Note: Because of dependency on architecture and system changes to any current version of Apple
> operating systems (for example, macOS 26, iOS 26, and so on), not all known security issues are
> addressed in previous versions (for example, macOS 15, iOS 18, and so on)."*

Apple has kept that note current, rolling the version numbers forward — so **Apple still asserts in
2026 that N‑1 and N‑2 are not fully patched**. Ars Technica first reported the wording in
[October 2022](https://arstechnica.com/gadgets/2022/10/apple-clarifies-security-update-policy-only-the-latest-oses-are-fully-patched/).

Three concrete demonstrations:

1. **A 234-day backport lag on an actively exploited bug.** CVE-2021-30869 was patched in Big Sur
   11.2 on 2021-02-01 and only reached Catalina in Security Update 2021-006 on 2021-09-23 — while
   Apple was actively updating both. Both dates confirmed in Apple's own archive
   ([120989](https://support.apple.com/en-us/120989)); the gap was documented by Intego via
   [Ars Technica, 2021-11-12](https://arstechnica.com/gadgets/2021/11/psa-apple-isnt-actually-patching-all-the-security-holes-in-older-versions-of-macos/).
2. **Present-day, from Apple's own release notes.** Comparing [macOS Tahoe
   26.6](https://support.apple.com/en-us/128067) (N) with [macOS Sonoma
   14.8.8](https://support.apple.com/en-us/128072) (N‑2), *released the same day, 2026-07-27*:
   fixes present in Tahoe and absent from Sonoma include CloudAttestation (CVE‑2026‑43813, code-signing
   bypass), Kernel (CVE‑2026‑28931, CVE‑2026‑64751), AppleDouble (CVE‑2026‑43776, arbitrary code
   execution) and PackageKit (CVE‑2026‑28912, privilege escalation). One Kernel entry appears in
   *both* advisories with identical text but a **shorter CVE list on Sonoma** — same bug class, same
   day, fewer fixes. *Fair caveat:* Sonoma's advisory has no WebKit section because WebKit for
   Sonoma/Sequoia ships inside Safari, so WebKit gaps should not be counted against N‑1/N‑2. A second
   caveat left open: some Tahoe-only components (Apple Neural Engine, CloudAttestation) may simply not
   exist in Sonoma, which would be a legitimate reason for absence — see [Unpinned](#unpinned--could-not-establish).
3. **Background Security Improvements are latest-version-only.** Apple, same deployment page:
   *"Background Security Improvements are delivered only for the latest versions of iOS, iPadOS, and
   macOS."* An N‑1 or N‑2 Mac receives **none** of that channel.

**XProtect is the partial consolation.** Apple states malware-definition updates are pushed
*"independent from system updates"* and checked daily
([Protecting against malware in macOS](https://support.apple.com/guide/security/protecting-against-malware-sec469d47bd8/web)),
but **never says which macOS versions still receive them** — another documented absence rather than a
reassurance. Empirically the delivery path has forked: from Sequoia onward the primary XProtect
bundle moved out of `softwareupdate`'s control, and Apple has shipped Sequoia-only XProtect versions
using a new rule format ([Eclectic Light, 2026-07-30](https://eclecticlight.co/2026/07/30/take-control-of-updates-using-softwareupdate/)).
Malware-definition coverage on an old macOS therefore **degrades gradually rather than stopping
cleanly** — which is harder to give a buyer a date for, not easier.

---

## No commitment exists — and the law that would have forced one excludes laptops

Apple publishes a formal lifecycle policy for Mac **hardware** (vintage at 5 years, obsolete at 7 —
[support.apple.com/en-us/102772](https://support.apple.com/en-us/102772), published 2026-06-16) and
**no policy at all** for macOS software support. The asymmetry is deliberate, not an oversight.

It is worth knowing *why* no number exists, because a buyer will reasonably ask. The UK's Product
Security and Telecommunications Infrastructure regime is the one law that forced Apple to publish a
"defined support period" — which is how the world learned Apple commits to **a minimum five years of
iPhone security updates from first supply**, filed for the iPhone 15 Pro Max
([MacRumors, 2024-06-06](https://www.macrumors.com/2024/06/06/apple-iphone-security-updates-five-year-minimum/)).

**That regime does not cover MacBooks.** The Product Security and Telecommunications Infrastructure
(Security Requirements for Relevant Connectable Products) Regulations 2023, **Schedule 3, paragraph
5**, "Excepted connectable products":

> *"Products are excepted under this paragraph if they are computers which are — (a) desktop
> computers; (b) **laptop computers**; (c) tablet computers which do not have the capability to
> connect to cellular networks."*

— <https://www.legislation.gov.uk/uksi/2023/1007/schedule/3/made>, read 2026-08-04.

So there is no Apple commitment, no regulator forcing one, and consequently **no number a guide can
honestly promise a buyer.** Everything a guide says about a MacBook's future software life is an
extrapolation, and should be written as one.

---

## What the Intel era predicts — and why it under-predicts

The only evidence about how long Apple supports a Mac comes from the Intel era. Derived from Apple's
compatibility lists ([Monterey 103260](https://support.apple.com/en-us/103260),
[Ventura 102861](https://support.apple.com/en-us/102861),
[Sonoma 105113](https://support.apple.com/en-us/105113),
[Sequoia 120282](https://support.apple.com/en-us/120282),
[Tahoe 122867](https://support.apple.com/en-us/122867)), a model's **last new macOS** landed:

| Intel MacBook | Introduced | Last macOS | Gap |
|---|---|---|---|
| MacBook Air (11-inch / 13-inch, Early 2015) | 2015 | Monterey 12 (2021-10) | ~6.6 yr |
| MacBook Pro (Retina, 13-inch, Early 2015) | 2015 | Monterey 12 | ~6.6 yr |
| MacBook Pro (Retina, 15-inch, Mid 2015) | 2015 | Monterey 12 | ~6.4 yr |
| MacBook (Retina, 12-inch, Early 2016) | 2016 | Monterey 12 | ~5.5 yr |
| MacBook Air (13-inch, 2017) | 2017 | Monterey 12 | ~4.4 yr |
| MacBook Pro (13-inch / 15-inch, 2017) | 2017 | Ventura 13 (2022-10) | ~5.4 yr |
| MacBook Air (Retina, 13-inch, 2018) | 2018 | Sonoma 14 (2023-09) | ~4.9 yr |
| MacBook Air (Retina, 13-inch, 2019) | 2019 | Sonoma 14 | ~4.2 yr |
| MacBook Air (Retina, 13-inch, 2020) | 2020 | Sequoia 15 (2024-09) | ~4.5 yr |
| MacBook Pro (13-inch / 15-inch, 2018) | 2018 | Sequoia 15 | ~6.2 yr |
| MacBook Pro (16-inch, 2019) | 2019 | **Tahoe 26** (2025-09) | ~5.9 yr |
| MacBook Pro (13-inch, 2020, Four TB3) | 2020 | **Tahoe 26** | ~5.4 yr |

**Observed range: 4.2 – 6.6 years from introduction to last new macOS. n = 12 laptop model groups**,
drawn from Apple's own compatibility lists for Monterey 12, Ventura 13, Sonoma 14, Sequoia 15 and
Tahoe 26. Median ≈ 5.5 years.

The naive extrapolation would put the M1 (November 2020) at its last macOS somewhere between
**2025 and 2027**. It is now August 2026 and the M1 has already been confirmed for macOS 27, its
seventh macOS, ~5.9 years after introduction — **at the top of the Intel range, and still going.**

Two reasons the Intel sample is a poor guide, and both point the same way:

1. **Intel-era cuts were partly an architecture-transition artefact.** The 2018–2020 Intel Airs got
   unusually short lives (4.2–4.9 years) because Apple was winding a whole architecture down. Apple
   silicon has no such wind-down pending.
2. **Apple silicon is one architecture with one baseline.** Every Mac from the M1 to the M5 shares an
   instruction set, a Secure Enclave generation lineage, a unified-memory model and a GPU family.
   The Intel line Apple had to support spanned a decade of chipsets. There is no equivalent
   engineering pressure to cut an M1.

> **Prediction — low-to-moderate confidence.** The first Apple-silicon MacBook to lose new-macOS
> support will be an M1, and the earliest plausible release to do it is **macOS 28 (autumn 2027)**;
> a central estimate is **macOS 28–30 (autumn 2027 – autumn 2029)**. Basis: an Intel sample of ten
> laptop models with an observed 4.2–6.6-year range, which the M1 has already reached and passed
> without being cut. Confidence is capped low because the sample is drawn from a different
> architecture under transition pressure, and because **the actual Apple-silicon drop count is zero
> — a sample of zero supports no rate estimate at all.**

Restating the honest version: *nothing observed so far tells us when Apple will drop an M1, because
Apple never has dropped an Apple-silicon Mac. The Intel range is the only anchor available and it has
already been exceeded.*

---

## Running an old macOS is not the same as being an old Mac

The README's Step 1a currently checks the macOS version a machine is *running*. That is a useful
check, but not for this question, and the guide should not let the two blur.

- **A machine running Sequoia 15 in August 2026 is un-updated, not unsupported.** Every M1–M5
  MacBook can install Tahoe 26 today. Updating costs the buyer time and bandwidth and nothing else.
- **This directly repairs the Parts & Service reach problem** that
  [#13](https://github.com/mingrath/mbcheck/issues/13) flagged. Parts & Service needs Tahoe 26; the
  worry was that most circulating stock could not display the pane. Within the guide's scope that
  worry is **not about capability** — every in-scope machine can run Tahoe 26. If the pane is
  missing, the correct reading is "this machine has not been updated", and the buyer can ask the
  seller to update it, or accept that the flag check cannot run and grade accordingly.
- **An unusually old macOS is a soft signal about the seller, not the hardware** — a machine on
  Monterey in 2026 has been ignored for years. That is worth a 📝 at most, and it is not what this
  ticket asked about.

---

## The one real dated cliff is Rosetta 2 — and it hits every model equally

Apple, ["Using Intel-based apps on a Mac with Apple
silicon"](https://support.apple.com/en-us/102527), published 2026-02-16:

> *"Rosetta is currently available for any Mac with Apple silicon, and it will remain available
> through the forthcoming macOS 27 — the next major macOS release. Starting with computers using
> macOS 28, Rosetta functionality will be available only for certain older, unmaintained games that
> rely on Intel-based frameworks."*

This is the only hard, Apple-stated, dated software cliff in the whole Apple-silicon lineup. But note
what it is and is not:

- It is a cliff for **Intel-only applications**, not for machines.
- It arrives at the same moment for an M1 Air and an M5 Pro. **It does not discriminate by model
  age**, so it cannot support any "given its age" argument.
- Practical consequence for a buyer: if they depend on a specific Intel-only app, that dependency has
  a deadline of roughly autumn 2027 regardless of which MacBook they buy. On macOS 27 they can check
  by Get Info → *Kind: Application (Intel)*, and macOS 27 betas surface the list under System
  Settings → General → About → macOS → Details.

Grade: **📝 Note.** It costs nothing to live with and cannot be renegotiated against the seller.

---

## Feature-level cutoffs: where age does start to bite

Apple's *device requirement* for Apple Intelligence is flat across the whole line. ["How to get Apple
Intelligence"](https://support.apple.com/en-us/121115), published 2026-07-07, lists simply:

> - Mac computers with Apple silicon

No chip-generation floor. No RAM floor. By Apple's own statement an **8 GB M1 MacBook Air is an
Apple Intelligence machine**, the same as an M5 Pro.

**There is, however, a widely-reported second tier that Apple does not document on that page.**
Several outlets report that the *most advanced on-device model* introduced with the 2026 releases
requires **an M3 or later chip with 12 GB of unified memory**, with 8 GB machines getting the
standard experience and routing heavier requests to Private Cloud Compute
([Fello AI, 2026-06-12](https://felloai.com/which-devices-support-apple-intelligence/);
[Geeky Gadgets, 2026-06-16](https://www.geeky-gadgets.com/apple-intelligence-siri-ai-requirements/);
[Macworld, 2026-06-09](https://www.macworld.com/article/3160007/siri-ai-and-apple-intelligence-do-you-need-to-buy-a-new-iphone-ipad-or-mac.html)).

**These are secondary sources and are labelled as such** — the claim is *not* on Apple's requirements
page, and this note does not assert it as fact. If it holds, it is the first place where buying an M1
or M2 instead of an M3+ costs a *named feature* rather than just speed. Even then, on the reporting's
own terms, the feature still works via Private Cloud Compute.

Grade if it holds: **📝 Note**, not 💰 — there is no repair to price and no leverage over the seller.

---

## Browsers and apps: how long a Mac stays genuinely usable after its last macOS

Falling off Apple's patch list is not the moment a Mac becomes useless. The moment that actually
strands a buyer is when the **browser** stops updating — and that happens on a separate, later clock,
which can be measured the same way.

### Minimum macOS today, vendor-stated

Every row below is the vendor's own published number, observed 2026-08-04. Community reports that an
app "still runs" on older macOS are excluded.

| Software | Minimum macOS today | Last version supporting an older macOS | Source |
|---|---|---|---|
| **Google Chrome** | **macOS 13 Ventura** | Chrome 150 last for macOS 12 · Chrome 138 last for macOS 11 · Chrome 128 last for macOS 10.15 | [support.google.com](https://support.google.com/chrome/a/answer/7100626) |
| **Microsoft Edge** | **macOS 13 Ventura** (Edge 151+) | macOS 12 → Edge 139–150 · macOS 11 → Edge 129–138 | [learn.microsoft.com](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-supported-operating-systems) (ms.date 2025-12-05, updated 2026-07-07) |
| **Mozilla Firefox** 153.0.1 | **macOS 10.15 Catalina** | ESR 115 for macOS 10.12–10.14, security updates **to March 2027** | [mozilla.org](https://www.mozilla.org/en-US/firefox/system-requirements/) · [ESR notice](https://support.mozilla.org/en-US/kb/firefox-users-macos-1012-1013-1014-moving-to-extended-support) |
| **Safari** 26.6 (2026-07-27) | **macOS Sonoma 14** — ships for 26.6, Sequoia and Sonoma | Safari 18.6 (2025-07-29) last for Ventura | [developer.apple.com](https://developer.apple.com/documentation/safari-release-notes/safari-26_6-release-notes) |
| **Microsoft 365 / Office for Mac** | **macOS Sonoma 14** (rolling "three most recent versions") | 16.101 (2025-09) last for Ventura · 16.88 (2024-08) last for Monterey | [support.microsoft.com](https://support.microsoft.com/en-US/Office/lifecycle/officeinstall/upgrade-macos-to-continue-receiving-microsoft-365-and-office-for-mac-updates) (page 2026-06-15) |
| **Adobe Photoshop** 27.x | **macOS 14** | 26.x line listed macOS 13 | [helpx.adobe.com](https://helpx.adobe.com/photoshop/system-requirements.html) (page 2026-06-04) |
| **Adobe Lightroom** 9.0+ | **macOS Sonoma 14** | not stated | [helpx.adobe.com](https://helpx.adobe.com/lightroom-cc/system-requirements.html) (page 2026-01-22) |
| **Zoom Workplace** | **macOS 10.15 Catalina** | 6.7.7 last below 10.15 | [support.zoom.com](https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0060748) (page 2026-03-23) |
| **Slack desktop** | **macOS 13** → **macOS 14 from 2026-11-09** | macOS 12 EOL 2026-05-18 · macOS 11 EOL 2024-09-01 | [slack.com/help](https://slack.com/help/articles/115002037526) |
| **Google Drive for desktop** | **macOS Ventura 13.0** | v91.0 (2024-05-09) last for 10.15.7 | [support.google.com](https://support.google.com/drive/answer/2375082) (page undated) |
| **Dropbox** | **macOS 11 Big Sur** (full app); 10.13–10.15 get a reduced "simplified version" | — | [help.dropbox.com](https://help.dropbox.com/installs/system-requirements) (page 2026-06-30) |
| **Docker Desktop** | ⚠️ **no number published** — policy only: "current and two previous major macOS releases" (⇒ macOS 14, **derived, not vendor-stated**) | not stated | [docs.docker.com](https://docs.docker.com/desktop/setup/install/mac-install/) (page 2026-05-28) |
| **Xcode** 26.6 (2026-06-25) | **macOS Tahoe 26.2** — *and a Mac with M1 or later* | Xcode 26.0 → macOS 15.6 · Xcode 16 → 14.5 · Xcode 15 → 13.5 | [developer.apple.com](https://developer.apple.com/documentation/xcode-release-notes/xcode-26_6-release-notes) |

> Note the Xcode row's hardware floor: Apple's own App Store listing requires "a Mac with Apple M1
> chip or later." **The M1 is the floor, not below it.** For a developer buyer this is one more
> confirmation that M1-era hardware is inside Apple's current line, not outside it.

### The measured grace period after Apple stops patching

Measuring from **Apple's last security update for a macOS version** to **the vendor's cutoff**:

| Vendor | Grace after Apple's last patch | Sample | Failure mode when it ends |
|---|---|---|---|
| **Chrome** | **22.8 – 26.0 months** (mean 24.3) | n = 3 closed: Catalina 26.0 · Big Sur 22.8 · Monterey 24.0. Ventura in progress at 11.5 months. | Google: *"Chrome will continue to work, showing a warning infobar, but will not update any further."* |
| **Edge** | **identical to Chrome** | Edge's cutoffs land on the same milestones — 129 / 139 / 151 | Same clock. Edge is **not** an escape hatch from Chrome's. |
| **Safari** | **≈ zero** | n = 2. Ventura's last Safari (18.6, 2025-07-29) shipped *three weeks before* Ventura's last OS patch; Catalina's came one month after. | Tracks N/N‑1/N‑2 and stops when Apple stops. |
| **Microsoft 365** | **≈ zero** | n = 2. Last Ventura build 2025-09 vs Ventura EOL 2025-08; last Monterey build 2024-08 vs EOL 2024-07. | Rolling three-version floor moves the day Apple ships a major, with no separate announcement. |
| **Firefox** | **≈ 68 months and counting** | n = 1. macOS 10.14's last Apple patch was 2021-07; Mozilla ships ESR 115 security updates **through March 2027**, reached via five successive six-month extensions. | The genuine long tail — but one data point, and repeatedly re-dated. |

Mozilla's own framing of Apple's behaviour, from the ESR notice, is worth quoting because it is a
third party stating the same absence this note found independently:

> *"While Apple doesn't have an official policy governing security updates for older macOS releases,
> its ongoing practice has been to support the three most recent releases."*

### The full chain, and what it means for an M1

Chaining the two measured clocks gives the honest end-to-end answer to *"how long does this machine
stay genuinely usable?"*:

> **Prediction — moderate confidence.** Taking the most pessimistic assumption available (macOS 27,
> autumn 2026, is the M1's last), an M1 MacBook bought today would receive:
> - **Apple security updates until ≈ mid-2029** — 33–34 months from macOS 27's release, on a
>   four-case sample;
> - **an updating Chrome or Edge until ≈ mid-2031** — a further 23–26 months, on a three-case sample;
> - **Safari and Microsoft 365 stopping at ≈ mid-2029**, together with Apple's patches, on a
>   two-case sample each;
> - **Firefox beyond all of the above**, on a one-case sample.
>
> Both clocks are observed vendor behaviour, not commitments. Chrome's is the one with the least
> variance (22.8–26.0 months across three cases). None of these dates is guaranteed by anyone.

The practical reading for the guide: even under the worst plausible assumption, **an M1 bought in
2026 has roughly three years of full patching and about five years of a working, updating browser
ahead of it.** That is not a machine at the end of its software life.

> ⚠️ **One anomaly against the tidiness of all this.** Apple shipped **macOS Big Sur 11.7.11 and
> Security Update 2026-001 Catalina on 2026-02-02**, both listed with *"no published CVE entries"* —
> patching Big Sur five months *after* Chrome had already dropped it. So "Apple's last security
> update" is not strictly monotonic, and the grace-period arithmetic above should be read as
> approximate.

---

## Second-hand market: is anything close enough to the edge to say so?

**No.** The oldest Apple-silicon MacBook that circulates in Thailand at any volume is the M1 Air
(2020), and it is on Apple's macOS 27 compatibility list. There is no machine in the market that the
guide should flag on support grounds.

That said, the market data changes *how* the guide should frame the answer, so it is worth carrying.

### What the oldest machines actually cost, 2026-08-04

Asking prices from **mac2hand** (`mac2hand.com`), Thailand's main used-Mac listing site. mac2hand
does not delist sold items, so only current-format listings and ads whose image paths encode a 2026
posting month were counted; everything older is context, not a price. **These are asking prices, and
Thai shops negotiate.**

| Model | THB range | Median | Obs. (n) |
|---|---|---|---|
| **MacBook Air 13" M1 (2020)**, 8/256 typical | **฿12,900 – ฿16,900** | ~฿14,700 | 14 |
| MacBook Air 13" M1, CTO 16 GB | ฿16,900 – ฿21,900 | — | 4 |
| **MacBook Air 13" M2 (2022)**, used | **฿22,900 – ฿27,900** | ~฿25,700 | 8 |
| MacBook Air 15" M2 (2023) | ฿23,900 – ฿27,900 — **scarce** | — | 4 (none current-format) |
| **MacBook Pro 13" M1 (2020)** | **฿15,900 – ฿22,500** — **thinning** | ~฿17,400 | 8 (newest dated Nov 2025) |
| **MacBook Pro 14" M1 Pro (2021)** | ฿28,500 (16/512, ×2) · ฿39,900 (32 GB/1 TB, AppleCare+ 191 days) | — | **3 live ads site-wide** |
| **MacBook Pro 16" M1 Pro/Max (2021)** | **effectively absent** — no live ads; only pre-2025 stale ads | — | **0 live** |

New-price anchors, Apple Thailand `apple.com/th/shop/buy-mac`, observed 2026-08-04:
**MacBook Neo เริ่มต้นที่ ฿24,900** · **MacBook Air เริ่มต้นที่ ฿44,900** · **MacBook Pro เริ่มต้นที่ ฿69,900**.
A **brand-new M1 Air** is still sold by authorised resellers at **฿25,500** — iStudio by SPVi
(<https://www.istudiobyspvi.com/products/13-inch-macbook-air-m1-mgn63th-a>) and Studio7 education
(<https://www.education.studio7thailand.com/th/p/apple-macbook-air-13-m1-chip-8c-cpu7c-gpu8gb256gb-gold-2020-mgnd3tha_zwlklg>);
stock status not verified.

Derived ratios: a used M1 Air at ฿14,700 is **33 %** of a new MacBook Air, **59 %** of a new MacBook
Neo, and **45 %** of its own Thai launch price of ฿32,900
([Thairath, 24 Nov 2020 / 2563](https://www.thairath.co.th/news/tech/1982071)) after ~5.7 years.

> ### The comparison the guide should actually carry
>
> **A brand-new, warrantied MacBook Neo costs ฿24,900 — roughly ฿10,000 more than a five-year-old M1
> Air with a worn battery, and it is on Apple's macOS 27 list too.** That, not the support horizon,
> is the real "given its age" question. The M1 Air's software life is long enough that the decision
> turns on battery, warranty and ฿10,000 — all things the guide already prices.

### Two market facts that matter more than the prices

1. **The README's own target machine has left the market.** The README is built for a *MacBook Pro
   16" M1 Pro 2021 at ฿31,500*. mac2hand currently carries **zero live 16-inch M1 Pro/Max listings**,
   and the 13" M1 Pro has no 2026-dated listings at all. Whatever the guide says about that machine,
   it should not assume a buyer can readily find one. This is a market observation, not a support
   finding, and it is recorded because it affects the worked example
   [#11](https://github.com/mingrath/mbcheck/issues/11) asked the README to carry.
2. **Scarcity, not obsolescence, is what removed them.** The M1 Air is abundant (365 ads under one
   query). The Pro line is thin. Nothing in either pattern is driven by macOS support.

### Does any Thai source price software life? A qualified null.

**Not one mac2hand listing read — M1 Air, M2 Air, 13" M1 Pro, 14" M1 Pro — mentions macOS, OS
updates, or software support.** The value axes in Thai listings are entirely `ศูนย์ไทย` (Thai-market
unit), `สภาพ` (cosmetic condition), `รอบชาร์จ` (charge cycles), `แบตเตอรี่ %` (battery health),
`ครบยกกล่อง` (complete box) and `ประกันศูนย์ / AppleCare+` (remaining warranty). **Software life is not a
priced attribute in this market.**

This mirrors the null that [#13](https://github.com/mingrath/mbcheck/issues/13) found for repair
history: Thai second-hand pricing runs on condition and warranty, and on very little else.

The sharpest evidence is a Pantip thread, [pantip.com/topic/43588877](https://pantip.com/topic/43588877),
"macbook air m1 มือสองงบ ไม่เกิน 15k", posted **28 มิถุนายน 2568 = 2025-06-28**. It independently
confirms the ฿12–15k street band. It also contains a senior member advising the buyer:

> *"งั้นคงไม่ต้องถึง Apple silicon ตระกูล M ก็ได้ เอา Intel-based Mac รุ่นปี 2017-2019 ก็ยังไหว"*
> — "you don't even need to go up to Apple silicon M-series; a 2017–2019 Intel-based Mac would still do."

That advice was given **weeks after WWDC 2025**, at which Apple announced that macOS Tahoe 26 would be
the last release for Intel Macs. A Thai buyer was being steered toward exactly the machines about to
be cut, and software life never entered the conversation. **This is the strongest argument in the
whole note for the guide saying something explicit about support horizon** — not because
Apple-silicon buyers are at risk, but because the Thai market gives a buyer no signal at all, in
either direction.

### The exception — and it draws the line where this note draws it

Thai tech media and at least one authorised reseller *do* cover macOS 27 compatibility, and every one
of them draws the line at **Intel vs Apple silicon**, never at M1 vs newer:

- **UFicon / iStudio by UFicon** (authorised Apple reseller), 2026-06-12,
  <https://www.uficon.com/macos-27-new-features/>: *"เป็น macOS รุ่นแรกที่รันเฉพาะ Mac ชิป Apple
  silicon เท่านั้น (ทิ้ง Mac ชิป Intel อย่างเป็นทางการ)"* — the first macOS to run only on Apple
  silicon — under a heading that then pitches new machines. A Thai shop using software support as a
  buy-new argument.
- **Sanook**, 2026-06-04, <https://www.sanook.com/hitech/1625178/>: macOS 27 supports only Apple
  silicon and MacBook Neo, *"พร้อมอัปเดตความปลอดภัยต่ออีก 3 ปี"* — with a further three years of
  security updates. **That Thai-language figure independently matches the 33–34-month tail measured
  above from Apple's release record**, from a completely different direction.
- **DroidSans**, 2026-06-09, <https://droidsans.com/apple-new-os-27-device-support-list-macos-watchos/>:
  the full Thai compatibility list, *"MacBook Air รุ่นชิป Apple silicon (2020 และใหม่กว่า)"*.

**In Thai discourse an M1 is on the safe side of the only line anyone is drawing.** The consequence
is that the M1's real, distant horizon is neither discounted into the price nor communicated to the
buyer — the ฿12,900–16,900 band is set by battery cycles and box completeness.

### So: walk away, or price it in?

**Neither, and the guide should say so in those words.** There is nothing to walk away from and
nothing to discount. What the buyer should take away is a *reassurance with an expiry date on it* —
the support horizon is long, it was checked on 2026-08-04, and the thing actually worth pricing on an
old machine is the battery, at the ฿5,590–8,690 Apple TH prices already pinned by
[#13](https://github.com/mingrath/mbcheck/issues/13).

---

## The rule — when age alone is a reason to decline

Framed to slot into the three grades of [#10](https://github.com/mingrath/mbcheck/issues/10)
(🛑 High risk / 💰 Renegotiate / 📝 Note) and to satisfy the admission bar of
[#9](https://github.com/mingrath/mbcheck/issues/9) — a check earns its place only if a bad result can
on its own produce a grade. This one can, and it is free for the script to read.

> ### The rule
>
> **1 — Read the model, not the year.** Take the machine's model identifier and ask a single
> question: *is this model present in the compatibility list of the newest macOS Apple has announced?*
>
> **2 — Present on the list → age is not a finding.** No grade. Not a 📝. The guide should say
> explicitly that age is not a concern, because the buyer arrived worried about it and silence reads
> as evasion.
>
> **3 — Absent from the newest announced list → 💰 Renegotiate, not 🛑.** A machine dropped from new
> macOS versions is not broken. It keeps its current macOS, and on the observed pattern that macOS
> keeps receiving Apple security updates for roughly **33–34 months from its release date**, and an
> updating Chrome or Edge for roughly **24 months beyond that**. The buyer is losing future features
> and taking a degraded patch stream, which is a discount argument, not a walk-away.
>
> **4 — 🛑 only when the machine is genuinely unpatched.** Promote to High risk when the newest macOS
> the model can install has *itself* fallen off Apple's security-release list — i.e. it is N‑3 or
> older. That is the point at which the machine stops receiving CVE fixes at all, and unlike every
> other 🛑 in this guide it cannot be repaired at any price, which is exactly what
> [#10](https://github.com/mingrath/mbcheck/issues/10) reserves 🛑 for. Note that Safari and
> Microsoft 365 stop at that same moment (grace ≈ zero), so a step‑4 machine is losing its browser
> and its office suite together — the 🛑 is not merely theoretical.
>
> **5 — Never let a *running* macOS version trigger any of the above.** Steps 1–4 key on what the
> model *can install*, never on what is installed. An out-of-date machine is a free fix.

### What the rule returns today

**For every MacBook Air and MacBook Pro from M1 to M5: step 2. No grade. Age is not a finding.**

The earliest date on which any in-scope machine could reach step 3 is **autumn 2027**, when macOS 28
ships — and only if Apple drops the M1 then, which nothing observed so far predicts. The earliest
date any in-scope machine could reach step 4 is later still: an M1 whose last macOS were 27 would not
fall off the patch list until approximately **mid-2029**, and would keep an updating Chrome until
approximately **mid-2031**.

So the guide's honest sentence to a nervous buyer looking at a five-year-old M1 is:

> *"This machine is on Apple's list for the macOS shipping this autumn. On how Apple has behaved so
> far — which is not a promise — it should keep getting security updates until around 2029 and a
> working, updating browser until around 2031. Its age is a reason to check the battery, not a
> reason to walk away."*

### Why the rule is written as a lookup and not as a number of years

A "decline anything older than N years" rule would be the natural shape and it is the wrong one.
Apple's cut is **by model, not by age** — the 2019 16-inch MacBook Pro received its last macOS 5.9
years after introduction while the 2019 13-inch Air got 4.2, a 40 % spread inside one model year. A
year-count rule would have been wrong for both. The lookup is also the only form that stays correct
without maintenance of a horizon table.

### Maintenance instruction

**This section goes stale every September**, when Apple ships a macOS and publishes its enumerated
compatibility list. The guide should carry:

- the URL of the newest compatibility list — the stable entry point is Apple's
  ["Find out which macOS your Mac is using"](https://support.apple.com/en-us/109033), which links the
  current list for every version and was itself published 2026-07-27;
- the date the rule was last checked (**2026-08-04**);
- a one-line statement of what would change the answer: *the first appearance of an Apple-silicon
  MacBook Air or MacBook Pro missing from a new macOS compatibility list.*

---

## What this costs `check.sh` — near nothing

[#11](https://github.com/mingrath/mbcheck/issues/11) fixed that the script reads every software fact
silently and that script-read facts are free. This one is at the cheap end even of that.

- **The fact is already being read.** The model identifier comes from `sysctl -n hw.model`, and the
  running macOS from `sw_vers -productVersion`. Both are unprivileged, instant, and #11 already has
  the script reading model and chip.
- **The lookup is a hard-coded set, not a table.** Because the answer is currently *yes* for every
  in-scope model, the script does not need a model → last-macOS mapping. It needs one list — the
  Apple-silicon MacBook identifiers on the newest macOS compatibility list — and a membership test.
  If the identifier is in the set: no finding. If it is not: the machine is either out of scope
  (Intel, desktop, MacBook Neo) or newly dropped, and both cases want a human-readable message rather
  than a grade.
- **It needs a hard-coded "last verified" date**, because a stale set is worse than none. The script
  should print the date the list was checked (**2026-08-04**) alongside the result, so a buyer
  running a two-year-old copy of the script can see that it is two years old.
- **The one line worth printing even on a pass.** The buyer arrived worried about age. A silent pass
  does not answer them. The report should carry an explicit line — *"macOS support: on Apple's list
  for the newest macOS (checked 2026-08-04). Not a concern."* — which costs one line and removes the
  worry the ticket was opened about.

This is consistent with [#9](https://github.com/mingrath/mbcheck/issues/9)'s bar: the check is
script-read, therefore free, therefore admitted on own-outcome alone — and its bad outcome (step 3 or
4 of [the rule](#the-rule--when-age-alone-is-a-reason-to-decline)) is a real 💰 or 🛑.

---

## A scope question: the MacBook Neo

Apple's Tahoe 26 compatibility list contains a **MacBook Neo (13-inch, A18 Pro)**, and the macOS 27
list contains **MacBook Neo (2026)**. It is a laptop, it is Apple silicon in the broad sense, and it
is neither a MacBook Air nor a MacBook Pro nor M-series.

The map fixes scope as *"M1–M5 MacBook Air and MacBook Pro"*, so the Neo is **out of scope as
written**. This note does not propose changing that — a 2026 machine is not yet a second-hand
machine, and [#13](https://github.com/mingrath/mbcheck/issues/13) already found that MacBook Neo
figures are a live trap in Apple's own pricing widgets, which is a reason for the guide to keep the
line sharp rather than blur it. Recorded here so the scope line is re-read deliberately rather than
by accident.

---

## Unresolved conflicts and open questions in the sources

1. **Is Apple's macOS 27 preview compatibility list final?** It is a marketing preview page with a
   family-level rule ("2020 and later"), not the enumerated `support.apple.com` article Apple
   publishes at ship. *Consequence if it changes:* essentially none for this note's conclusion, since
   there are no Apple-silicon MacBooks earlier than 2020 to exclude. *To pin:* re-read the enumerated
   list when macOS 27 ships in autumn 2026.
2. **Are the Tahoe-only CVEs genuinely unpatched on Sonoma, or non-applicable?** Some Tahoe-only
   components (Apple Neural Engine, CloudAttestation) may not exist in Sonoma at all, which would be a
   legitimate reason for absence rather than a support gap. Apple's deployment-guide note asserts the
   gap is real in general; this note does not claim a specific CVE count. *To pin:* check whether the
   framework is present in a Sonoma install, or watch for the CVE appearing in a later Sonoma advisory.
3. **The 12 GB / M3 Apple Intelligence tier is secondary-sourced only.** Three outlets report it
   consistently; Apple's own requirements page contradicts none of it but states no such tier.
   *To pin:* Apple's macOS 27 feature-availability page when it publishes at ship, or Apple's
   Apple Intelligence page footnotes.
4. **What macOS Big Sur 11.7.11 (2026-02-02) actually was.** Listed by Apple with no CVEs and no
   advisory, 2⅓ years after Big Sur's last real patch. *To pin:* diff the build against 11.7.10.
5. **Which macOS versions still receive XProtect definitions.** Apple documents the mechanism and
   never its reach. *To pin:* enumerate `softwareupdate -l --include-config-data` against Apple's
   per-version catalog URLs.

---

## Unpinned / could not establish

| # | Missing | Why | What would pin it |
|---|---|---|---|
| 1 | **Any Apple statement of how long a Mac receives macOS upgrades or security updates** | Apple publishes none, for any Mac, ever. The UK PSTI regime that forced the iPhone's five-year figure **excepts laptop computers** by name. | Nothing available. A future EU Cyber Resilience Act obligation might force one; it does not apply yet. |
| 2 | **The exact ship date of macOS 27 Golden Gate** | Apple says only "this fall". Every dated prediction here therefore carries ±1 month. | Apple's autumn 2026 announcement. |
| 3 | **Precise CVE set sizes for Tahoe 26.6 vs Sequoia 15.7.8 vs Sonoma 14.8.8** | Specific present/absent CVEs were verified by direct reading of Apple's advisories; total counts were not computed and are not claimed. | A `CVE-\d{4}-\d{4,7}` set-diff across the three advisories. |
| 4 | **Whether N‑1 is measurably better patched than N‑2** | Apple's wording implies a gradient; only N vs N‑2 was measured here. | The same set-diff including 15.7.8. |
| 5 | **Whether Apple's preview compatibility lists have historically matched the shipped lists** | Asserted nowhere; not verified in this research. The note therefore treats the macOS 27 list as an announcement, not a guarantee. | Diffing archived preview pages against shipped `support.apple.com` lists for macOS 14–26. |
| 6 | **Kaidee listing-level second-hand prices** | Only the category page was reachable, and its "ราคากลาง ฿104,100.30" is a site-wide notebook average, not a MacBook figure. Kaidee's list is client-rendered. | A browser-driven session on `kaidee.com/c82a10945-computer-notebook-macbook-air` with a model filter. |
| 6b | **Shopee / Lazada / Facebook Marketplace prices** | **Confirmed excluded, reproducing [#13](https://github.com/mingrath/mbcheck/issues/13)'s finding exactly.** Shopee returns "We cannot provide a description for this page right now"; Lazada tag pages carry promo boilerplate and no prices. **No figure from these channels appears anywhere in this note.** | A logged-in headless browser, or their internal search APIs. |
| 6c | **Sold prices, as opposed to asking prices** | mac2hand never delists, so every figure above is an ask. | Kaidee "ขายแล้ว" archives, or asking a shop directly. |
| 6d | **A firm Apple TH trade-in figure for an M1 Air** | Apple TH publishes none — `apple.com/th/shop/trade-in` outsources estimation to **Likewize** and requires a serial number. Thai รับซื้อ operators (2hand2cash, 168bnt, mj2h, jumnum888) all route to phone or LINE for a quote; one candidate price list 404s. **The ฿9,000–12,000 a private seller might be offered is inferred from shop margins, not observed, and is not asserted in this note.** | Submitting a real serial to `appletradein-th.likewize.com`. |
| 6e | **Whether the ฿25,500 new M1 Airs at SPVi / Studio7 are actually in stock** | Both are structured product prices; stock was not verified. This materially affects the new-versus-used comparison above. | An add-to-cart check or a phone call. |
| 6f | **Whether Thai shops raise OS support verbally in store** | Written sources are silent; that is not the same as shop-floor silence. | Field-testable only — ask a Bangkok or Chiang Mai shop. |
| 7 | **Apple's App Store "last compatible version" behaviour** — whether the store offers an older build of an app to an unsupported macOS | Undocumented by Apple for macOS *and* iOS. The article usually cited (`HT201377`) 404s and redirects to another 404; App Store Connect Help's availability pages 404. Attested only by users on Apple Discussions / Reddit. **Left unasserted rather than quoted from forums.** | A live Apple-authored URL — App Store Connect Help's JS-rendered nav needs a headless fetch, or the App Store Review Guidelines. |
| 8 | **Docker Desktop's actual minimum macOS version number** | Docker publishes only a rolling policy ("current and two previous major releases"). macOS 14 is arithmetic, not Docker's statement. | `docs.docker.com/desktop/release-notes/` or the enterprise PKG requirements page. |
| 9 | **Whether Firefox has announced an end for macOS 10.15 / 11** | Searched; nothing found. Firefox 153.0.1 still lists macOS 10.15 with no announced sunset — so Firefox's long tail has no published end date at all. | A Mozilla EOL announcement, which does not yet exist. |
| 10 | **Which Xcode 26.x point release raised the floor from macOS 15.6 to 26.2** | Only the endpoints were read. A nine-month, full-major-version jump *inside one release train* is a sharper cliff than the annual cycle suggests, and its exact timing is unpinned. | One scrape each of the Xcode 26.1–26.5 release notes. |
| 11 | **A dated Google notice for the Drive-for-desktop Monterey → Ventura cutover** | The macOS 13.0 floor is vendor-stated but undated; Google's release notes contain no such notice. | `workspaceupdates.googleblog.com` around the change. |
| 12 | **Slack's Mac App Store listing appears to contradict slack.com/help** (12.0 vs 13) | The App Store page was not fetched directly; only a search-index snippet suggested the discrepancy. `slack.com/help` is treated as authoritative here. | Fetching the Mac App Store listing directly. |

---

## Method and tooling

Research was run as one primary investigation against Apple's own compatibility, security and policy
pages, plus three parallel sub-investigations (Apple's security-update tail; browser and third-party
app minimum-OS requirements; the Thai second-hand market), each instructed never to invent a fact and
to stamp every claim with its source URL and observed date.

**Tooling:** the **AgentKey** MCP was the primary tool throughout — `Firecrawl/scrape` for every Apple
support page and for the UK statutory instrument, `Brave/getWebSearch` for locating article IDs.
Built-in WebSearch/WebFetch were **not** used for any fact in this document.

**Primary sources are Apple's own and are preferred throughout.** Where only secondary reporting
exists — the Apple Intelligence 12 GB tier, the WWDC 2025 Rosetta announcement, the iPhone PSTI
filing — the source is named inline and the claim is marked as secondary.

**Two things were deliberately established as absences rather than glossed:** Apple publishes no
macOS support-duration policy, and Apple never states which macOS versions still receive XProtect
definitions. Both absences are load-bearing for this note's conclusion that no honest guide can
promise a buyer a date.
