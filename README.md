# Used MacBook Inspection Checklist

**Total time: ~20 minutes at the shop.**

Built for: MacBook Pro 16" (M1 Pro, 2021), 16GB / 512GB, ฿31,500, listed at 84% battery health / 150 cycles.

Do the steps in order. Each one has a **walk away if** line. If you hit one, stop — don't negotiate around it.

---

## Step 1 — Verify the machine and its owner (8 min)

### 1a. Is it the machine advertised?

Open  → **About This Mac**.

Check every line matches the listing:

| Field | Must say |
|---|---|
| Chip | Apple M1 Pro |
| Memory | 16 GB |
| Model | MacBook Pro (16-inch, 2021) |
| macOS | Sequoia 15 or Tahoe 26 |

Then open **Storage** and confirm total capacity is ~494GB (a "512GB" drive shows as ~494GB — this is normal).

Copy the serial number, then check it at **[checkcoverage.apple.com](https://checkcoverage.apple.com)** on your phone. You want:

- The model to match what you're holding
- No "Invalid serial number" error

**Walk away if:** the serial is invalid, the spec doesn't match, or the seller won't let you see About This Mac.

### 1b. Is it locked or stolen?

This is the check people skip, and it's the one that makes a MacBook worthless.

1.  → **System Settings** → **General** → **Transfer or Reset**
2. Confirm **Erase All Content and Settings** exists and is tappable
3.  → **System Settings** → click the **account name at the top**
4. Confirm you can **sign out of iCloud** — ask the seller to do it in front of you

Then restart the machine and confirm it boots to **Setup Assistant** (the "Hello" screen), not a login screen asking for someone else's Apple ID.

**Walk away if:** an Activation Lock screen appears, the seller "will sign out later," or they can't remember the Apple ID password. A locked Mac is a brick — Apple will not unlock it for you.

---

## Step 2 — Physical inspection (5 min)

### Trackpad — the swollen-battery test

Press **each of the four corners** of the trackpad, one at a time.

- Good: firm, even click on all four
- Bad: any corner sits raised, rocks, or clicks unevenly

A lifted trackpad means the battery underneath is swelling. On a 16" MacBook that's a ~100Wh cell — it will get worse, and it can crack the display.

### Screen

1. Open a full-screen **white** image → look for dead pixels (black dots) and yellow patches
2. Open a full-screen **black** image → look for stuck pixels (bright dots) and check the mini-LED blooming is even, not blotchy
3. Tilt the screen through its full range — no flicker, no lines

### Everything else

- **Keyboard:** open TextEdit, type every key including all F-keys and arrows
- **Ports:** plug the charger into **each of the three Thunderbolt ports** — all three must charge
- **Speakers:** play a bass-heavy track loud — no rattle, no buzz. The 16" has woofers; it should sound genuinely good
- **Camera + mic:** open Photo Booth, record 5 seconds, play it back
- **Chassis:** check for dents at the corners (drop damage) and screws that look chewed (previously opened)

**Walk away if:** the trackpad lifts, or any Thunderbolt port won't charge.

---

## Step 3 — Stress test the fans (6 min)

This is the whole reason you're buying a Pro instead of an Air. Prove the fans work.

Open **Terminal** (`Cmd + Space`, type `terminal`), paste this, hit Enter:

```bash
for i in {1..8}; do yes > /dev/null & done; sleep 300; killall yes
```

It pins all 8 performance cores for 5 minutes, then stops itself.

To stop early, open a new tab (`Cmd + T`) and run:

```bash
killall yes
```

While it runs, open **Activity Monitor** → **CPU** tab. CPU Load should sit near 100%.

**What good looks like:**

- Fans become audible within 30–60 seconds and settle into a steady whoosh
- Chassis gets warm, but you can rest your hand on it
- Runs the full 5 minutes without interruption

**Walk away if:**

- **Total silence.** Dead or unplugged fans — the single most expensive failure mode, and the most common one on a machine that's been opened.
- **Sudden shutdown or reboot** — thermal or battery fault
- **Grinding, rattling, or ticking** — worn fan bearing

---

## Step 4 — Battery and repair history (4 min)

Hold `Option`, click  → **System Information** → **Power**.

Record these three:

| Field | Expected | Concern |
|---|---|---|
| Cycle Count | ~150 | Over 300 = renegotiate |
| Maximum Capacity | ~84% | Under 80% = "Service Recommended" soon |
| Condition | Normal | "Service Recommended" = replace now |

Then check the repair history:

 → **System Settings** → **General** → **About** → **Parts & Service**

| Shows | Meaning |
|---|---|
| *(section absent)* | Never repaired — best case |
| **Genuine** | Repaired with real Apple parts — fine |
| **Used** | Part came from another Mac — acceptable, mention it |
| **Unknown** | **Non-genuine part.** Walk away. |

> Apple's own wording: *"Repairs performed by untrained individuals or using nongenuine parts might affect the functionality, safety, security, and privacy of the device."*

An **Unknown** flag is permanent, kills resale value, and you cannot undo it.

**Walk away if:** Parts & Service shows **Unknown**, or Condition says **Service Recommended**.

---

## Before you hand over money

- [ ] Specs match the listing (16GB / 512GB / M1 Pro / 16-inch 2021)
- [ ] Serial valid on checkcoverage.apple.com
- [ ] Seller signed out of iCloud **in front of you**
- [ ] Machine boots to the Setup Assistant "Hello" screen
- [ ] Trackpad flat and even on all four corners
- [ ] All three Thunderbolt ports charge
- [ ] Fans audible under load, no shutdown
- [ ] Parts & Service is clean or "Genuine"
- [ ] You have the **140W charger** in hand (a replacement is ~฿3,000)
- [ ] You got a **receipt** with the serial number and the seller's phone number

---

## Useful Thai phrases

| English | Thai |
|---|---|
| Can I check the machine first? | ขอเช็คเครื่องก่อนได้ไหมครับ |
| Please sign out of iCloud | รบกวนออกจากระบบ iCloud ให้หน่อยครับ |
| How many battery cycles? | แบตเตอรี่กี่รอบครับ |
| Has it ever been repaired? | เครื่องเคยซ่อมไหมครับ |
| Can I have a receipt? | ขอใบเสร็จด้วยครับ |

---

## After you get it home

Docker fills a 512GB drive fast. Set this up on day one:

```bash
docker system prune -a --volumes    # reclaims 20-50GB
```

Then **Docker Desktop → Settings → Resources** → cap the disk image at ~60GB so it can't quietly eat the drive.

The battery at 84% gives you ~83.7Wh usable — more than a brand-new 15" MacBook Air's 66.5Wh. Don't rush to replace it. Wait until Condition reads "Service Recommended," then get a genuine Apple battery for ฿6,990.
