# Sentinel — Claude Code Context

## Project Overview

Sentinel is an Android background tracking app. It runs a foreground service that periodically reads the device's GPS position and delivers it to a prioritized list of recipients. If the first recipient fails, it falls back to the next, and so on.

**Platform:** Android only (no iOS, no web, no desktop)  
**Language:** Dart / Flutter 3.44.0  
**Package ID:** `io.github.marco_zanella.sentinel`  
**License:** GPLv3  
**Repository:** https://github.com/marco-zanella/sentinel

---

## Developer Background

The developer has no prior Flutter or Android experience. Explanations should be clear and not assume Flutter/Android familiarity. When making non-obvious choices, briefly explain why.

---

## Architecture

### Data Model

Recipients are organized in **priority-ordered groups**. Each group has a delivery policy:
- `any` — delivery succeeds if at least one recipient in the group succeeds
- `all` — delivery succeeds only if every recipient in the group succeeds

The app tries groups in order and stops at the first successful one.


#### Recipient types (MVP)
- **SMS** — sends a text message to a phone number
- **Telegram** — posts to a Telegram chat/group/channel via Bot API

More recipient types will be added in the future. Use an abstract/interface pattern so new types can be added without touching existing logic.

#### Planned future recipient types (do not implement yet, but do not make impossible)
- Email
- Webhook (generic HTTP POST)
- WhatsApp

### Core Logic

```
every X minutes:
  read GPS position
  for each group in priority order:
    attempt delivery to group according to its policy
    if group delivery succeeds: stop
  if all groups fail: log failure, do nothing
```

### Background Execution

The app must keep running when the screen is off and the app is not in the foreground. This requires a **foreground service** on Android, which mandates a persistent notification. This is not optional — Android will kill background processes without it.

---

## Key Technical Decisions

- **Foreground service:** `flutter_foreground_task` package
- **Location:** `geolocator` package
- **SMS:** `telephony` package
- **Telegram:** plain HTTP POST to `https://api.telegram.org/bot<token>/sendMessage` — no special library needed
- **Local persistence:** `hive` for configuration storage
- **HTTP:** `http` or `dio` package for Telegram API calls

These are starting points. Reconsider if a package is unmaintained or a better alternative exists.

---

## Android Permissions

Declared in `AndroidManifest.xml`, requested at runtime:
- `ACCESS_FINE_LOCATION`
- `ACCESS_BACKGROUND_LOCATION` (requires separate user grant — "allow all the time")
- `SEND_SMS`
- `INTERNET`
- `FOREGROUND_SERVICE`
- `FOREGROUND_SERVICE_LOCATION`

Background location is the most sensitive — Google Play requires a clear justification during review.

---

## Signing & CI/CD

Signing is configured in `android/app/build.gradle.kts`. It reads credentials from:
1. `android/key.properties` (local development — gitignored)
2. Environment variables `KEYSTORE_BASE64`, `KEY_ALIAS`, `KEY_PASSWORD`, `STORE_PASSWORD`, `STORE_FILE` (CI)

CI runs on GitHub Actions and triggers on tags matching `v*`. It builds a signed `.aab` file, uploaded as a GitHub Actions artifact. Play Store upload is manual for now.

**Never commit `android/key.properties` or any keystore file.**

---

## Project Structure

```
sentinel/
├── lib/
│   ├── main.dart               # Entry point
│   ├── models/                 # Data classes (Recipient, RecipientGroup, Config)
│   ├── services/               # Background service, location, delivery logic
│   ├── recipients/             # One file per recipient type (SMS, Telegram, ...)
│   └── ui/                     # Screens and widgets
├── android/
│   ├── app/
│   │   └── build.gradle.kts    # Signing config — do not break this
│   └── key.properties          # Gitignored — local signing credentials
├── fastlane/
│   └── Fastfile                # CI build lane
├── .github/
│   └── workflows/
│       └── release.yml         # GitHub Actions pipeline
├── Gemfile                     # Fastlane dependency
└── CLAUDE.md                   # This file
```

---

## Development Sequence

Suggested order:
1. Add Flutter package dependencies
2. Implement data model (Recipient, RecipientGroup, AppConfig)
3. Local persistence (save/load config)
4. Configuration UI (add/edit/reorder recipients, set frequency)
5. Foreground service skeleton
6. Scheduling loop
7. Location reading
8. SMS delivery
9. Telegram delivery
10. Priority fallback logic
11. Runtime permission handling
12. Delivery attempt log (visible in UI)
13. Physical device testing

---

## Coding Conventions

- Dart standard style (`dart format`)
- Prefer explicit types over `var` where it aids readability
- Each recipient type in its own file under `lib/recipients/`
- Services (location, background, delivery) in `lib/services/`
- No business logic in UI files
- Write at least a basic test for the priority fallback logic

---

## Known Constraints & Gotchas

- **Android battery optimization** will kill the foreground service on some devices unless the user exempts the app. Consider prompting the user to disable battery optimization for Sentinel.
- **Background location** requires a two-step permission grant. The user must first grant location, then separately grant "allow all the time." Handle this flow explicitly.
- **Telegram bot setup** requires the user to create a bot via @BotFather and add it to their group. Plan for clear in-app setup instructions.
- **SMS on some devices** may require the app to be set as the default SMS app, depending on Android version. Test this early.
- **The first Play Store upload** must be done manually. CI takes over from the second release onward.
