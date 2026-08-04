# Can `check.sh` trust what it reads?

Research note resolving [issue #21](https://github.com/mingrath/mbcheck/issues/21).

**Research date: 2026-08-04.** Every experiment below was run first-hand on the dev's
**MacBook Air `Mac16,13` (M4), 16 GB, macOS 26.5.2 (25F84)**, as an ordinary admin user,
**no sudo**. Where something is reasoned rather than observed, it says so.

---

## The answer in three sentences

**Spoofing the readings *through the machine* is impractical without the admin password, and
the script can prove that cheaply.** The system volume is cryptographically sealed, the tools
are root-owned on it, an unprivileged overwrite is refused outright, and `DYLD_INSERT_LIBRARIES`
is stripped from platform binaries.

**Spoofing the readings *around the tools* is trivial, needs no privileges whatsoever, and
nobody had considered it.** A three-line shell script placed earlier on `PATH` — or an exported
shell function — fakes the entire hardware sheet.

**It costs nothing to defeat: call every binary by absolute path.** That is now a hard
construction rule for `check.sh`, and it is the single most load-bearing thing in this note.

---

## 1. The attack that works — demonstrated

`check.sh` is fetched and run by the *buyer*, but it runs **in the seller's shell, on the
seller's machine, under the seller's environment**. That environment is entirely the seller's
to arrange, in advance, with no privileges at all.

### 1.1 A `PATH` shim

```sh
$ cat "$D/bin/system_profiler"
#!/bin/sh
echo "Hardware:"
echo "      Model Name: MacBook Pro"
echo "      Chip: Apple M4 Max"
echo "      Memory: 128 GB"
echo "      Serial Number (system): TOTALLYLEGIT"
echo "      Activation Lock Status: Disabled"
```

Observed, unprivileged:

```console
$ PATH="$D/bin:$PATH" system_profiler SPHardwareDataType
Hardware:
      Model Name: MacBook Pro
      Chip: Apple M4 Max
      Memory: 128 GB
      Serial Number (system): TOTALLYLEGIT
      Activation Lock Status: Disabled
```

Every fact the guide leans on, wrong, in six lines of shell. Note the last one especially:
`Activation Lock Status: Disabled` is what the guide wants to see **after** a sign-out.

### 1.2 An exported shell function

Same result, without even a file on disk:

```console
$ bash -c 'system_profiler() { echo "      Serial Number (system): FAKE-VIA-FUNCTION"; }; \
           export -f system_profiler; system_profiler SPHardwareDataType'
      Serial Number (system): FAKE-VIA-FUNCTION
```

A shell function takes precedence over `PATH` entirely, so a `PATH` reset alone does not close
this.

### 1.3 Why this is the realistic threat and the kernel one is not

It requires **no privileges, no reboot, no SIP change, and leaves nothing anomalous** for the
buyer to notice: `csrutil status` still reads enabled, Secure Boot still reads Full Security,
because none of that has been touched. It is preparable in advance by a seller who knows a
buyer might run a script, and — unlike everything in §2 — it is **not** something Apple's
platform security is designed to prevent, because it is not an attack on the OS at all.

---

## 2. The defence — also demonstrated

### 2.1 Absolute paths defeat both attacks

Same poisoned environment, absolute path:

```console
$ PATH="$D/bin:$PATH" /usr/sbin/system_profiler -detailLevel basic SPHardwareDataType
      Model Name: MacBook Air
      Chip: Apple M4
      Memory: 16 GB
      Serial Number (system): G5GQL2690L
      Activation Lock Status: Enabled
```

And against the exported function:

```console
$ ... export -f system_profiler; /usr/sbin/system_profiler ... | grep Serial
      Serial Number (system): G5GQL2690L
```

Both defeated. A path beginning with `/` is not looked up in `PATH`, and a shell function name
cannot contain `/`, so neither interception mechanism can reach it.

### 2.2 Why the absolute path is trustworthy — the chain, verified

The defence only holds if the binary *at* that path is Apple's. Four observations, all
first-hand:

| Check | Observed |
|---|---|
| System volume sealed? | `diskutil apfs list` → `Sealed: Yes`, `Snapshot Sealed: Yes` |
| Binary ownership | `/usr/sbin/system_profiler` → `-rwxr-xr-x root` (also `ioreg`, `csrutil`, `profiles`, `notifyutil`, `sysctl`, `pmset`) |
| Can an unprivileged admin replace it? | `cp /bin/echo /usr/sbin/system_profiler` → **`Operation not permitted`** |
| Code signature | `codesign -dv` → `Identifier=com.apple.system_profiler`, `Platform identifier=26`, `TeamIdentifier=not set` — a platform binary |

So: **SSV `Sealed: Yes` ⇒ the binary at `/usr/sbin/system_profiler` is the one Apple shipped.**
That is a genuine chain, and it is why the script reports Signed System Volume state.

### 2.3 `DYLD_INSERT_LIBRARIES` is not a route

The obvious third interception — injecting a dylib into the real binary — is closed by SIP,
which strips `DYLD_*` from restricted/platform binaries:

```console
$ DYLD_INSERT_LIBRARIES=/nonexistent.dylib /usr/sbin/system_profiler ... | grep Serial
      Serial Number (system): G5GQL2690L
```

Note the shape of the evidence: a *nonexistent* library was named and the process neither
failed nor complained — the variable was discarded before `dyld` ever looked at it. Had it been
honoured, the process would have died with a load error.

---

## 3. With SIP **on**, what about the values themselves?

`system_profiler` and `ioreg` do not invent their output: they read the **IORegistry**, which
the kernel populates from data provided by iBoot at boot. Changing those values in place
therefore requires kernel code execution.

On Apple silicon that is defended by more than SIP alone. Apple's own description:

> "macOS utilizes kernel permissions to limit writability of critical system files with a
> feature called System Integrity Protection (SIP). **This feature is separate and in addition
> to the hardware-based Kernel Integrity Protection (KIP) available on a Mac with Apple
> silicon, which protects modification of the kernel in memory.**"
> — <https://support.apple.com/guide/security/system-integrity-protection-secb7ea06b49/web>

So with **Full Security + SIP on + SSV sealed**, altering an IORegistry value means defeating a
signed kernel, hardware kernel-memory protection, and a sealed system volume simultaneously.

**Stated honestly: no demonstration of this was found, and none is claimed here.** What was
found is one relevant negative from Apple's own developer community — on Apple silicon, even
Apple's *Virtualization framework* does not offer serial-number spoofing that Intel Macs
allowed (<https://discussions.apple.com/thread/255669818>). That is a weak signal, and it is
reported as one.

**Verdict: `check.sh` should treat SIP-on readings as sound, and say plainly that it is doing
so.** It is not an unconditional guarantee; it is a stated precondition.

---

## 4. With SIP **off**, what becomes forgeable?

Everything, eventually — but the question that matters for the guide is narrower and has a
clean answer.

Turning SIP off on Apple silicon **requires** dropping the boot policy to **Permissive
Security**, which per Apple *"can be accessed only from command-line tools"* and cannot be
reached from Startup Security Utility. So it is:

- **always deliberate** — nobody does this by accident;
- **always visible** — `csrutil status` and `SPiBridgeDataType` both report it unprivileged;
- **never innocent in this context**, because of what it does *besides* weakening the readings:
  Activation Lock stops applying below Full Security ([#2](https://github.com/mingrath/mbcheck/issues/2)),
  and the Parts & Service pane is hidden entirely
  ([#3](https://github.com/mingrath/mbcheck/issues/3) §13b).

### Can a machine report `enabled` while it is not?

**Not reachable by the interception routes above**, because `csrutil` is read by absolute path
from the sealed volume like everything else. Beyond that it is the same question as §3 — it
needs kernel code execution — and the same honest answer: **not demonstrated either way.**

There is one Apple-documented caveat worth carrying, and it is Apple arguing against itself.
From `man bputil`: it is possible for an OS to report Full Security *"despite not being the
latest software version. Full Security only indicates the state as of the latest install or
upgrade."* **A Full Security readout is a claim about the past, not a live attestation.**

---

## 5. Does `ioreg` differ from `system_profiler`?

**No, in the way that matters.** Both read the same IORegistry, both are root-owned platform
binaries on the sealed volume, and both are interceptable by exactly the same `PATH`/function
routes and immune by exactly the same absolute-path fix. The fields
[#4](https://github.com/mingrath/mbcheck/issues/4) leans on — `region-info`,
`regulatory-model-number` — inherit the same trust level as `Serial Number (system)`.

One asymmetry worth recording: `ioreg` is *lower level*, so it is marginally harder to fake by
accident and no easier to fake on purpose. There is no reason to prefer one over the other on
integrity grounds.

---

## 6. Observed in the wild?

**No evidence found, in either direction, and this note will not invent a rate.** Searches for
spoofed Apple-silicon spec sheets returned Intel-era material, VM-serial questions, and
unrelated `system_profiler` output-format complaints. [#7](https://github.com/mingrath/mbcheck/issues/7)
reached the same dead end independently and recorded it as UNPINNED.

The relevant structural point is that the Intel-era techniques do not port: RAM and storage are
on-package and soldered on M1–M5, so the *physical* misrepresentation this would be used to
cover up has largely disappeared from the Mac market.

---

## 7. What the guide does about it

**A cheap integrity check exists, it is already in the script, and it costs about 200 ms.**

1. **Reset `PATH`** to the system directories, and `unset -f` every tool name — closes the
   casual case and the exported-function case.
2. **Call every evidence-bearing binary by absolute path** — the actual defence. Non-negotiable.
3. **Read and report `csrutil status` plus `SPiBridgeDataType` Boot Policy first**, before
   anything that depends on them.
4. **State the precondition in the report**: with SIP off, every software-read fact is
   downgraded and the script says so in words.

### Grading

- **SIP on, Full Security, SSV enabled** → readings stand. The question closes.
- **SIP off, or Secure Boot below Full Security** → **🛑**, and not primarily because of
  spoofing: it hides the repair-history pane and silently voids Activation Lock. The report
  says all three consequences.
- **Boot policy unreadable while SIP reads enabled** → `?? could not look`. **An unreadable
  field is not a bad field**, and grading it as one would fire on older machines that lack
  `SPiBridgeDataType`.

---

## Unpinned / could not establish

| # | Question | Why it stayed open |
|---|---|---|
| 1 | Whether IORegistry values can be altered with SIP on and Full Security | No demonstration found either way. Requires kernel code execution against a signed kernel + KIP + SSV. Reported as undemonstrated rather than assumed safe. |
| 2 | Whether `csrutil` can be made to lie about itself | Same class as #1, same answer. |
| 3 | Real-world prevalence of any of this on second-hand Macs | No source, in any language. |
| 4 | Whether a seller could tamper with the **report file** after it is written | Out of scope: the buyer watches the run and is told to AirDrop the report immediately. |

**Nothing in the unpinned list changes the guide's construction**, because the fix for the
demonstrated attack also happens to be the fix for the undemonstrated ones: read from the
sealed volume by absolute path, and state SIP as a precondition.
