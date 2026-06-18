# Nova Heronix NFC Tag — User Guide

This guide explains how Nova Heronix WiFi NFC tags work for factory staff, property owners, and guests.

## Tag states

| State | Who writes it | What's on the tag (Android) | Guest without app |
|-------|---------------|----------------------------|-------------------|
| **Blank** | — | Empty or non-Nova data | Nothing useful |
| **Provisioned** | Factory (Nova) | App link + tag ID (no WiFi yet) | No join WiFi |
| **Configured** | Owner (Nova on Android) | WiFi join record + app link + tag ID | **Tap to join WiFi** |

**iPhone guests:** Use the **QR sticker** (Camera app). iOS does not support generic NFC WiFi join like Android.

---

## Reading without the Nova app

### Android guest — configured tag (current format)

1. Tap phone on the sticker.
2. Phone shows **Connect to network** / join WiFi.
3. Tap Connect — device joins the guest network.

No app required.

### Android guest — old tags

Older tags may show readable text instead of join WiFi. The owner should **re-write the tag** from Nova (Network details → Write to NFC).

### Provisioned-only tag (not set up yet)

No WiFi join until the owner completes setup in Nova.

---

## Reading with the Nova app

### Scan tab

1. Open Nova → **Scan**.
2. Hold phone on tag.
3. App routes to:
   - **Setup** — tag needs SSID and password.
   - **Network details** — tag is configured (PIN required for credentials).
4. Legacy tags show a reminder to re-write for guest tap-to-join.

### Tag launches the app

If Nova is installed, tapping a tag can open the app and run the same flow as Scan.

---

## Writing with the Nova app

### Factory: initialize blank tag

1. Open factory tools (service code required).
2. **Initialize tag** → hold on blank writable NFC tag.
3. Tag gets a unique ID and is ready to ship.

### Owner: set up WiFi

1. Scan provisioned tag → **Setup**.
2. Enter PIN, label, SSID, password (8+ characters).
3. **Save and write to tag** (Android recommended).

### Owner: update or re-write

1. **Networks** → network → edit credentials or **Write to NFC**.
2. Replace QR sticker if the password changed.
3. Use **Download PDF** or **Print QR** for iPhone guests and signage.

### Lock tag

**Lock tag** makes the chip read-only (no further writes).

### Factory: wipe tag

Clears Nova data from writable Nova or blank tags (service code required).

---

## Writing with another app (not Nova)

Third-party NFC tools can overwrite tags. That may:

- Break Nova setup flow (missing app link / tag ID).
- Still allow guest WiFi join if only a standard WiFi record is written.
- Show plain text to guests if old Text-record formats are used.

**Recovery:** Re-initialize (factory) or scan and set up again in Nova.

---

## Security notes

- Guest WiFi tags are for **convenience**, not high security. Use a **guest-only** network.
- The Nova **user PIN** protects viewing/editing in the app, not the physical tag.
- Change the factory **service code** before production deployment.

---

## Build note (developers)

On external drives (macOS `/Volumes/...`), build APK with:

```bash
./scripts/build_apk.sh
```

Do not run `flutter build apk` directly on the external volume (AppleDouble `._*` files break builds).
