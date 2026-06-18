# iOS App Clip — WiFi Tap-to-Join Setup Guide

## What This Does

When a guest iPhone taps an NFC tag written by this app, iOS shows a native card at
the bottom of the screen — no app install required. The guest taps **Join**, iOS shows
its own confirmation dialog, and the phone connects to WiFi.

```
Guest taps tag
  → iOS shows App Clip card ("Nova WiFi — Open")
    → Guest taps Open
      → App Clip loads instantly
        → Guest taps "Join [SSID]"
          → iOS native "Join [SSID]?" prompt
            → Phone connects to WiFi
```

---

## What Was Already Done in Code

These changes are already committed to the codebase. No code changes are needed.

### New files created

| File | Purpose |
|---|---|
| `ios/NovaClip/NovaClipApp.swift` | App Clip entry point |
| `ios/NovaClip/WifiConnectView.swift` | Full App Clip UI + WiFi connection logic |
| `ios/NovaClip/Info.plist` | App Clip bundle configuration |
| `ios/NovaClip/NovaClip.entitlements` | Associated domains + Hotspot capability |
| `.well-known/apple-app-site-association` | Domain association file (needs hosting) |

### Files modified

| File | What changed |
|---|---|
| `ios/Runner/Runner.entitlements` | Added Associated Domains and Hotspot capability |
| `lib/services/nfc_constants.dart` | Added `appClipBaseUrl` constant |
| `lib/services/nfc_service.dart` | iOS configured tags now write a URL record first |
| `lib/models/wifi_network.dart` | Added `toIosTagJson()` (v2 format with credentials) |

### How the NFC tag changes work

**Before (iOS tag):**
```
Record 1: NFC External — novaheronix.com:wifi (Nova JSON, no v field)
```

**After (iOS configured tag):**
```
Record 1: Well-Known URI — https://appclip.novaheronix.com/wifi#d=<base64json>
Record 2: NFC External  — novaheronix.com:wifi (Nova JSON v2, with v field)
```

The URL fragment `#d=` carries credentials base64-encoded. Fragments are never
sent to any server — they exist only in the browser/App Clip.

**Provisioned-only tags** (factory-initialized, no credentials yet) keep just Record 2.
These still fit on NTAG213 chips.

---

## Step 1 — Add the App Clip target in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode (not the `.xcodeproj`)
2. Go to **File → New → Target**
3. Select **App Clip** under the iOS section
4. Fill in the fields:
   - Product Name: `NovaClip`
   - Bundle Identifier: `com.novaheronix.wifimanager.Clip`
   - Language: **Swift**
   - Interface: **SwiftUI**
5. Click **Finish**
6. When Xcode asks *"Activate NovaClip scheme?"* — click **Activate**

---

## Step 2 — Add the source files to the target

1. In Xcode's project navigator, right-click the `NovaClip` group → **Add Files to "Runner"**
2. Navigate to `ios/NovaClip/` and select:
   - `NovaClipApp.swift`
   - `WifiConnectView.swift`
3. In the file-add dialog:
   - **Uncheck** Runner under "Add to targets"
   - **Check** NovaClip under "Add to targets"
4. Click **Add**
5. Delete the placeholder Swift files Xcode auto-generated for the NovaClip target
   (usually named `NovaClip.swift` or similar) — the files above replace them

---

## Step 3 — Set the entitlements file

1. Select the **NovaClip** target in Xcode
2. Go to the **Build Settings** tab
3. Search for `CODE_SIGN_ENTITLEMENTS`
4. Set the value to: `NovaClip/NovaClip.entitlements`
5. Go to the **Signing & Capabilities** tab
6. Click **+ Capability** and add:
   - **Associated Domains**
   - **Hotspot Configuration**
7. In the Associated Domains section, verify this entry is present:
   ```
   appclips:appclip.novaheronix.com
   ```

Do the same for the **Runner** (main app) target:

1. Select the **Runner** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability** and add:
   - **Associated Domains** (if not already present)
   - **Hotspot Configuration**
4. In Associated Domains, add:
   ```
   appclips:appclip.novaheronix.com
   ```

---

## Step 4 — Replace your Team ID in the AASA file

1. Open `.well-known/apple-app-site-association` in the project root
2. Find both occurrences of `XXXXXXXXXX`
3. Replace each with your 10-character Apple Developer Team ID

**Where to find your Team ID:**
- Go to [developer.apple.com](https://developer.apple.com) → Account → Membership
- It looks like: `AB12CD34EF`

The file should look like this after editing:

```json
{
  "appclips": {
    "apps": [
      "AB12CD34EF.com.novaheronix.wifimanager.Clip"
    ]
  },
  "applinks": {
    "details": [
      {
        "appIDs": [
          "AB12CD34EF.com.novaheronix.wifimanager"
        ],
        "components": [
          {
            "/": "/wifi",
            "comment": "App Clip and main app both handle /wifi paths"
          }
        ]
      }
    ]
  }
}
```

---

## Step 5 — Host the AASA file

The file must be reachable at this exact URL:

```
https://appclip.novaheronix.com/.well-known/apple-app-site-association
```

Requirements (Apple enforces all of these):

- Served over **HTTPS** — no HTTP
- **No redirects** — the URL must respond directly, not via a 301/302
- `Content-Type` header must be `application/json`
- No authentication — publicly accessible

### Hosting with Netlify (free, 5 minutes)

1. Create a folder called `public/`
2. Inside it create `.well-known/apple-app-site-association` with the edited content
3. Create a `netlify.toml` file:
   ```toml
   [[headers]]
     for = "/.well-known/apple-app-site-association"
     [headers.values]
       Content-Type = "application/json"
   ```
4. Drop the `public/` folder onto [app.netlify.com/drop](https://app.netlify.com/drop)
5. Set a custom domain in Netlify's domain settings pointing to `appclip.novaheronix.com`

### Hosting with Cloudflare Pages (free)

1. Push the `.well-known/` folder to a GitHub repo
2. Connect it in Cloudflare Pages with build output `/`
3. Add a custom domain: `appclip.novaheronix.com`
4. Add a Transform Rule to set `Content-Type: application/json` for the path

### Verify hosting is correct

After deploying, run this in your terminal:

```bash
curl -I https://appclip.novaheronix.com/.well-known/apple-app-site-association
```

You should see `HTTP/2 200` and `content-type: application/json`.

---

## Step 6 — Enable the App Clip in App Store Connect

This is required for TestFlight and production. Not needed for direct device installs.

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Select your app → **App Clips** tab
3. Click **+** to add a new App Clip
4. Set the **App Clip URL** to: `https://appclip.novaheronix.com/wifi`
5. Add a title and subtitle for the App Clip card:
   - Title: `Nova Heronix WiFi`
   - Subtitle: `Tap to join this network`
6. Upload a header image (min 3000×2000px)

---

## Step 7 — Test the App Clip

### On a physical device (before App Store)

1. Build and run the **NovaClip** scheme on a real iPhone (not simulator)
2. In Xcode go to **Debug → Simulate App Clip Experience**
3. Enter the URL: `https://appclip.novaheronix.com/wifi#d=eyJzIjoiVGVzdFdpRmkiLCJwIjoicGFzc3dvcmQxMiIsImwiOiJUZXN0In0=`
   (this decodes to `{"s":"TestWiFi","p":"password12","l":"Test"}`)
4. The App Clip card should appear at the bottom of the screen
5. Tap Open — the connect UI should show with SSID "TestWiFi"

### With a real NFC tag

1. Open the main Nova app on an iPhone
2. Create a network with a real SSID and password
3. Write it to an NTAG215 or larger tag
4. Lock the iPhone screen
5. Hold the NFC tag to the top of the iPhone
6. The App Clip card should appear automatically

---

## NFC Tag Size Requirements

| Tag type | Usable storage | Supported |
|---|---|---|
| NTAG213 | 137 bytes | Provisioned-only tags only |
| NTAG215 | 492 bytes | Full configured tags ✓ |
| NTAG216 | 872 bytes | Full configured tags ✓ |
| MIFARE Ultralight C | 142 bytes | Provisioned-only only |

**Configured tags** (with SSID + password) write two NDEF records totalling
approximately 250–350 bytes depending on credential length. Use **NTAG215 or
NTAG216** for all tags that will hold WiFi credentials.

---

## How the Credential Encoding Works

When the app writes a configured iOS tag, it encodes credentials like this:

```dart
// In nfc_service.dart — buildMessageForNetwork (iOS path)
final payload = base64Encode(
  utf8.encode(jsonEncode({'s': ssid, 'p': password, 'l': label})),
);
final url = 'https://appclip.novaheronix.com/wifi#d=$payload';
```

The App Clip decodes it like this:

```swift
// In WifiConnectView.swift — WifiCredentials.init(url:)
guard
    let fragment = url.fragment,             // "d=eyJzIjo..."
    fragment.hasPrefix("d="),
    let encoded = fragment.dropFirst(2).removingPercentEncoding,
    let data = Data(base64Encoded: encoded),
    let json = try? JSONSerialization.jsonObject(with: data) as? [String: String]
else { return nil }
```

The `#fragment` part of a URL is **never sent to any server**. It lives only in
the URL string itself and is read entirely client-side by the App Clip. The WiFi
password never touches any network request.

---

## Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| App Clip card doesn't appear | AASA file not reachable or wrong Team ID | Run `curl -I` check from Step 5 |
| "Cannot connect" error | Wrong SSID or password in the tag | Re-write the tag with correct credentials |
| App Clip shows but can't connect | Hotspot entitlement missing | Check Step 3 — both targets need it |
| "Already connected" shows | Phone is already on that network | This is correct behaviour |
| Xcode build fails | Source files added to wrong target | Ensure files are in NovaClip target only |
| Tag read fails in full app | Two-record format change | Full app handles multi-record iOS tags correctly |
