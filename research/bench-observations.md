# Bench observations — Apple Diagnostics and Activation Lock

Resolves [#22](https://github.com/mingrath/mbcheck/issues/22).

Every observation records the machine and macOS it was taken on. Anything not observed
first-hand is marked **NOT OBSERVED** and stays open — nothing here is inferred and
presented as measured.

## Bench machine

| | |
|---|---|
| Model | MacBook Air, `Mac16,13` (M4) |
| Memory | 16 GB |
| macOS | 26.5.2 (build 25F84) |
| Serial | G5GQL2690L |
| FileVault | Off |
| MDM / DEP | `Enrolled via DEP: No` · `MDM enrollment: No` |
| iCloud | signed in (`mingrath@gmail.com`) |
| Find My Mac | on (`com.apple.Dataclass.DeviceLocator` present in `MobileMeAccounts`) |

Date: 2026-08-04.

---

## D. The output traps `check.sh` must avoid

**Status: resolved.** All three confirmed first-hand on the bench machine. One of them
is new — [#3](https://github.com/mingrath/mbcheck/issues/3) did not record it.

### D1. `-detailLevel mini` deletes `Activation Lock Status` — confirmed

`SPHardwareDataType`, same machine, same moment:

| invocation | `Activation Lock Status` |
|---|---|
| `system_profiler SPHardwareDataType` (default) | `Enabled` |
| `-detailLevel mini` | **absent — the line does not exist** |
| `-detailLevel basic` | `Enabled` |
| `-detailLevel full` | `Enabled` |
| `-json` | present, as `activation_lock_status` |

`mini` is the only level that drops it. **`basic` keeps it**, which matters below.

### D2. Text and JSON disagree on the battery condition string — confirmed

`SPPowerDataType`, same machine, same moment:

| output | field | value |
|---|---|---|
| text | `Condition:` | `Normal` |
| JSON | `sppower_battery_health` | **`Good`** |

Two different words for one battery state. A script that greps text for `Good`, or JSON
for `Normal`, silently finds nothing and reports no battery finding at all — the worst
possible failure mode, because absence of a finding reads as a healthy battery.

Cycle count and maximum capacity agree across both (`61`, `100%`), and unlike the
Activation Lock field they survive `-detailLevel mini` intact.

### D3. Text and JSON also disagree on the Activation Lock value — NEW

Not recorded by [#3](https://github.com/mingrath/mbcheck/issues/3). Same trap shape as D2,
on the field the guide leans on hardest:

| output | key | value |
|---|---|---|
| text | `Activation Lock Status` | `Enabled` |
| JSON | `activation_lock_status` | **`activation_lock_enabled`** |

The JSON value is not `Enabled`. A script matching the string it saw in text output finds
nothing in JSON.

### D4. The invocation `check.sh` must use

```sh
system_profiler -detailLevel basic SPHardwareDataType SPPowerDataType
```

Parse the **text** output, not JSON.

Why each part:

- **`basic`, not `mini`** — `mini` deletes `Activation Lock Status` (D1). `basic` keeps
  every field the guide needs.
- **`basic`, not the default** — no cost, and it is an explicit statement of intent rather
  than a reliance on whatever Apple makes the default next release.
- **text, not `-json`** — the JSON value strings differ from the documented/observed text
  ones on both fields that matter (D2, D3). Text is what every source, including this
  repo's own README, is written against.
- **Both data types in one call** — one process, not two.

Measured cost, three runs each, warm:

| invocation | real |
|---|---|
| default, both types | 0.27 · 0.17 · 0.16 s |
| `-detailLevel basic`, both types | 0.21 · 0.14 · 0.20 s |

Indistinguishable. `basic` is free.

---

## A. What Apple Diagnostics actually costs, in minutes

**Status: NOT OBSERVED.** Needs a restart — see the bench sheet in the ticket.

To record: wall-clock from restart to result; per test in the macOS Tahoe 26 menu;
whether it can be left running unattended; what a clean pass displays; whether any
reference code appears without a fault.

## B. Whether Apple Diagnostics runs in the states a second-hand Mac is in

**Status: NOT OBSERVED.**

Three states: Activation Lock engaged · Setup Assistant, before any account exists ·
FileVault locked.

## C. What `Activation Lock Status` reads across states

**Status: one cell observed, the rest NOT OBSERVED.**

| iCloud | Find My Mac | `Activation Lock Status` | observed? |
|---|---|---|---|
| signed in | on | `Enabled` | **yes** — bench machine, 2026-08-04 |
| signed in | off | ? | no |
| signed out | n/a | ? | no |

The observed cell reconfirms [#2](https://github.com/mingrath/mbcheck/issues/2)'s central
correction: `Enabled` is the **normal** reading on a healthy, honestly-owned machine.
