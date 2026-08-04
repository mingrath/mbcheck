# Reading fan speed on Apple silicon, and whether a dead fan is detectable

Resolves [#32](https://github.com/mingrath/mbcheck/issues/32).

**Constraint that decides everything:** `check.sh` runs on a stranger's machine, in one
paste, with no `sudo`, no installs, no downloads. Only preinstalled macOS binaries qualify.

---

## Headline

**Fan RPM is readable on Apple silicon without root — but not by anything macOS ships.**

The `check.sh:999` claim, *"Fan speed needs sudo, and this script does not ask for a
password"*, reaches the right conclusion by the wrong reason. SMC **reads** do not require
root. What they require is a **compiled IOKit binary**, and macOS preinstalls none.

The honest sentence is *"macOS ships no tool that reads fan speed"* — not *"fan speed needs
sudo"*.

---

## 1. Every surface, tested or sourced

| Surface | Preinstalled | Needs root | Reports fan RPM | Evidence |
|---|---|---|---|---|
| `powermetrics` | yes | **yes** | n/a — refuses first | first-hand |
| `powermetrics --samplers smc` | yes | — | **sampler does not exist** on Apple silicon | first-hand |
| `system_profiler SPPowerDataType` | yes | no | **no** — battery/charger only | first-hand + [1] |
| `sysctl -a` | yes | no | **no** — no fan keys | first-hand |
| `ioreg` | yes | no | **no** — SMC keys are not registry properties | first-hand + [2] |
| `smctemp` | **no** | no | temps (fan-capable SMC layer) | [3] |
| `iStats` / SMCKit | **no** | no | yes | [4] |
| `smcFanControl` | **no** | no to read, yes to write | yes | [2] |
| Macs Fan Control | **no** | no | yes | [5] |

### First-hand results

Run on the dev's **MacBook Air M4** (`Mac16,13`, macOS 26.5.2) — **fanless**:

```
powermetrics --samplers cpu_power -n1  →  "powermetrics must be invoked as the superuser"
powermetrics --samplers smc            →  "unrecognized sampler: smc"
system_profiler SPPowerDataType        →  no fan/rpm lines
sysctl -a | grep -i fan                →  nothing
ioreg -c AppleSMC -r -l | grep -i fan  →  nothing
ioreg -l | grep -ic fan                →  0
```

**These zeros came from a machine with no fans.** They prove the commands *degrade
gracefully on an Air* rather than erroring — worth knowing, since any command shipped must
survive half the supported line-up. They prove **nothing** about a fan-cooled Pro: a zero
from "surface doesn't expose fans" is indistinguishable from a zero from "machine has no
fans." Only the `powermetrics` rows are machine-independent, because they fail before ever
touching hardware.

### The read/write privilege split

This is the correction that matters. Three independent implementations agree:

> smcFanControl … **The main application runs without elevated permissions and can directly
> read SMC sensor data.** However, writing fan speed settings to the SMC requires root
> access. [2]

> SMC reads (command `5`) succeed from unprivileged user processes without code signing or
> root privileges … **SMCKit documents that reading temperatures and fan speeds requires no
> elevation, while writes require root**; smc-fuzzer demonstrates read operations without
> `sudo`. [4]

So the barrier is not privilege. It is that reading SMC means `IOServiceOpen` on the
`AppleSMC` service followed by `IOConnectCallStructMethod` — a compiled IOKit call. `ioreg`
cannot reach it, because SMC keys live behind a **user client**, not as registry
properties. There is no preinstalled binary that opens that user client.

### Apple-silicon caveat on the classic keys

> Prior work established the basic SMC key schema from the Linux kernel `applesmc` driver:
> `F0Md` for fan mode, `F0Tg` for target RPM, and `Ftst` … These keys were accessible via
> standard `IOKit` calls on earlier hardware but **failed on Apple Silicon**. [4]

That quote covers fan **control** keys. Whether the RPM-read key (`F0Ac`) survives on
Apple silicon is **unverified here** — third-party monitors do report live RPM on Apple
silicon Macs [5], so some read path clearly works, but this research did not pin down which
key. It does not change the conclusion: no preinstalled tool reaches any of them.

---

## 2. Can a dead fan be told from a quiet one?

**No — not by any preinstalled, no-sudo surface. Clean negative.**

This is the gap that matters, because `check.sh` currently asks only:

> `Any grinding, rattling or ticking from the fans?`

A fan that is disconnected, seized, or never commanded to spin produces **no grinding, no
rattle, no ticking**. The buyer answers "no" and the machine grades clean on a real fault.
The current prompt cannot catch the failure mode it most needs to catch.

Nothing in the preinstalled toolchain closes that. An RPM reading would close it trivially
— `0 RPM` late in a saturating load is unambiguous — and that reading is exactly what is out
of reach.

---

## 3. What is left, if RPM is unreachable

Ranked. **All are indirect** — none measures the fan.

1. **Thermal-pressure trajectory (already in `check.sh`).** The load test samples
   `com.apple.system.thermalpressurelevel` every 10 s. A Pro with a dead fan cannot hold a
   low plateau under sustained load — it should climb and stay climbing. This is the
   strongest available proxy and it costs nothing new: the sampler already runs. It detects
   *cooling failure*, which is the thing the buyer actually cares about, rather than fan
   rotation.
2. **Airflow at the vent.** A hand at the rear exhaust late in the load window. Crude,
   free, and unlike listening it distinguishes "not spinning" from "spinning quietly."
3. **Audible spin-up as a positive signal.** Reframing the existing prompt from "do you
   hear something bad" to "do you hear it start at all" converts silence from a pass into a
   flag.

Options 2 and 3 are prompt changes, not readings. **Designing the replacement prompt is out
of scope for this ticket** — see [#32](https://github.com/mingrath/mbcheck/issues/32).

---

## Consequences for the map

- `check.sh:999`'s stated reason is wrong and should be reworded. The conclusion (no RPM
  read) stands.
- The Pro fan check passes a dead fan. That is a live defect in a shipped deliverable.
- [#26](https://github.com/mingrath/mbcheck/issues/26) — the borrowed-Pro sitting — should
  **not** budget time for an RPM trace. There is nothing to capture without installing a
  tool on a machine that is not the dev's. It should instead record whether the fans are
  *audible* at spin-up and how far into the window that happens.

---

## Sources

1. Apple Developer Forums, thread 835131 — `system_profiler SPPowerDataType` reports only
   AC/battery data "regardless of adapter or load, even during active benchmarking with
   fans at full speed".
   <https://developer.apple.com/forums/thread/835131>
2. DeepWiki, *Security and Privileges*, `hholtmann/smcFanControl` — read/write privilege
   split. <https://deepwiki.com/hholtmann/smcFanControl/7-security-and-privileges>
3. `narugit/smctemp` README — Apple silicon M1–M5, installed via brew or `sudo make
   install`. <https://github.com/narugit/smctemp>
4. `Wenshuishi0528/MacFanControl`, `docs/research.md` — unprivileged SMC reads corroborated
   across SMCKit, smc-fuzzer; Apple-silicon key failures.
   <https://github.com/Wenshuishi0528/MacFanControl/blob/main/docs/research.md>
5. Macs Fan Control — real-time fan monitoring, "Works on all Macs, both Intel & Apple
   Silicon". <https://crystalidea.com/macs-fan-control>

<sub>Researched inline after three subagent attempts died on API 500s. Every "first-hand"
row above was run in this session on the dev's own machine; every other row is sourced and
labelled.</sub>
