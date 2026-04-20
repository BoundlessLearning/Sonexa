<img src="docs/images/logo-full.png" alt="Sonexa logo" width="180">

# Sonexa

Sonexa is an open music client for people who host their own music library.
It focuses on **Navidrome** and other **Subsonic-compatible** servers, and tries to make self-hosted music feel polished instead of patched together.

> Your music. Anywhere.

[简体中文](README.md)

* * *

## 📱 Preview

| Home | Now Playing |
| --- | --- |
| ![](docs/images/home.png) | ![](docs/images/now-playing.png) |

| Library | Settings |
| --- | --- |
| ![](docs/images/library.png) | ![](docs/images/settings.png) |

* * *

## ✨ Features

- Full library browsing with home recommendations
- Persistent playback with queue and progress restoration
- Usable synced lyrics with replacement and calibration tools
- Downloads, caching, offline playback, and basic cleanup tools
- Exportable diagnostics for troubleshooting

* * *

## ⚡ Quick Start

### 1. Get dependencies

```bash
flutter pub get
```

### 2. Run in development

```bash
flutter run
```

### 3. Common commands

```bash
flutter analyze
flutter test
flutter build apk --release
flutter build windows
flutter build linux
```

* * *

## 🧱 Project Structure

```text
lib/
├── core/         shared infrastructure: audio, routing, storage, theme, diagnostics
├── features/     auth, home, library, lyrics, player, download, search, settings
│
assets/
├── branding/     branding and splash assets
│
android/
ios/
linux/
windows/          platform runners
│
scripts/          helper scripts
test/             tests
```

* * *

## 🛠 Stack

- Flutter
- Riverpod
- Drift
- Dio
- just_audio
- audio_service

* * *

## 📌 Current State

Sonexa is still a personal project, but the core flow is already in place:

- login
- library browsing
- playback
- lyrics
- downloads
- cache management
- diagnostics

It is already usable, and still being actively refined.

* * *

## 🤖 About How This Project Is Built

Sonexa is the first application I have built almost entirely through **vibe coding / AI-assisted development**.

That comes with two practical implications:

- I am not a deeply experienced engineer in every part of this stack, so some implementation details, architectural decisions, and platform-specific issues are still things I am learning through the project itself
- I do read bugs, issues, and pull requests seriously, but response time may sometimes be slower than in a more mature project

At the same time, this also means the project is intentionally open to AI-assisted contribution styles.
If your workflow, patches, or collaboration style clearly involve AI, that is absolutely welcome here.

* * *

## 🗺 Roadmap

- Improve platform consistency across Android, Windows, and Linux
- Continue polishing the lyrics workflow
- Expand server compatibility beyond the current focus
- Keep improving diagnostics and recovery behavior

* * *

## 📎 Notes

- Sonexa is a client, not a music server
- Some lyrics features may fall back to public lyrics sources when server-local lyrics are unavailable
- This repository includes multiple Flutter platform folders, though day-to-day verification may vary by platform

* * *

## 📄 License

This project is licensed under **GNU GPL-3.0**.

That means:

- personal use is allowed
- modification is allowed
- commercial use is allowed
- but if you distribute a modified version, you must also provide the corresponding source code under GPL-3.0

See [LICENSE](LICENSE) for the full license text.

* * *

## ⭐ Support

If this project feels interesting, a star helps a lot.
