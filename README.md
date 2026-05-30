# Sentinel

An Android background location tracking app. Sentinel runs as a foreground service, reads the device GPS at a configurable interval, and delivers the position to a prioritised list of recipients via SMS and Telegram. If the primary group fails, it falls back to the next one automatically.

[![Release](https://github.com/marco-zanella/sentinel/actions/workflows/release.yml/badge.svg)](https://github.com/marco-zanella/sentinel/actions/workflows/release.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

---

## Features

- **Background tracking** — stays alive with a foreground service; survives screen off and app switching
- **SMS delivery** — sends location via SMS directly from the device
- **Telegram delivery** — posts to any Telegram chat, group, or channel via a bot
- **Priority groups** — recipients are organised in groups; if one group fails, the next is tried
- **Delivery policy** — each group uses either *any* (succeed if at least one recipient works) or *all* (succeed only if every recipient works)
- **Send now** — manual one-off delivery for testing or on-demand use
- **Delivery log** — history of every attempt with timestamp, coordinates, and result
- **Device name** — customisable name included in every message so the recipient knows which device sent it
- **Configurable interval** — 1, 2, 5, 10, 15, 30, or 60 minutes

---

## How it works

Every interval, Sentinel:

1. Reads the current GPS position
2. Iterates recipient groups in priority order
3. For each group, attempts delivery to every recipient according to the group's policy
4. Stops at the first group that reports success

The location message includes coordinates, accuracy, and a Google Maps link.

---

## Permissions

| Permission | Reason |
|---|---|
| `ACCESS_FINE_LOCATION` | Read precise GPS coordinates |
| `ACCESS_BACKGROUND_LOCATION` | Continue reading GPS while the app is in the background |
| `SEND_SMS` | Deliver location via SMS |
| `INTERNET` | Deliver location via Telegram |
| `FOREGROUND_SERVICE` / `FOREGROUND_SERVICE_LOCATION` | Keep the tracking service alive |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Ask the user to exempt Sentinel from battery saver, which would otherwise kill the service |

Background location requires a separate grant: after allowing location, Android will prompt you to choose **"Allow all the time"** in the system settings.

---

## Setting up recipients

### SMS

Add a recipient, choose **SMS**, enter a label and the destination phone number (international format recommended, e.g. `+391234567890`).

### Telegram

Telegram requires a bot to send messages on your behalf.

1. Open Telegram and start a chat with **@BotFather**
2. Send `/newbot` and follow the prompts to create a bot — copy the **token** (looks like `7123456789:AAFxxx...`)
3. Open a chat with your new bot and send it any message (e.g. `/start`)
4. In a browser, open `https://api.telegram.org/bot<TOKEN>/getUpdates` — find the `"chat":{"id": ...}` field in the response; that is your **chat ID**
   - For a group: add the bot to the group, send a message there, then call `getUpdates` — the chat ID will be a negative number like `-100123456789`
5. In Sentinel, add a recipient, choose **Telegram**, and paste the token and chat ID

---

## Building from source

**Requirements:** Flutter 3.44+, Android SDK, JDK 21+

```bash
git clone https://github.com/marco-zanella/sentinel.git
cd sentinel
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Signing for release

Create `android/key.properties` (this file is gitignored — never commit it):

```
storePassword=<your keystore password>
keyPassword=<your key password>
keyAlias=<your key alias>
storeFile=<absolute path to your .jks file>
```

Then:

```bash
flutter build appbundle --release
```

---

## CI/CD

GitHub Actions builds and signs a release `.aab` on every push of a `v*` tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The signed bundle is uploaded as a workflow artifact. The first upload to Google Play must be done manually; subsequent releases can be promoted directly.

Required repository secrets:

| Secret | Description |
|---|---|
| `KEYSTORE_BASE64` | Base64-encoded `.jks` keystore |
| `KEY_ALIAS` | Key alias inside the keystore |
| `KEY_PASSWORD` | Key password |
| `STORE_PASSWORD` | Keystore password |

---

## License

Sentinel is free software released under the [GNU General Public License v3.0](LICENSE).
