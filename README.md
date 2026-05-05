# BouncingDVD on Mac

A nostalgic-style **bouncing logo overlay** for macOS. Lives in your menu bar, drifts a logo across your desktop, and gets *very* excited when it hits a perfect corner.

> ⚠️ **No DVD trademark inside.** This app is a generic, reconfigurable bouncing-logo demo inspired by the well-known internet meme. The default on-screen text is `BNC` / `LOGO`, fully customizable from the menu-bar popover. The "DVD VIDEO" logo is a trademark of DVD Format/Logo Licensing Corporation and is **not** included or distributed with this software.

## Features

- 🪟 **Transparent overlay** that floats over every Space and lets clicks pass through to the apps below
- 🎨 **Color cycle** on every wall hit (classic CRT vibe)
- 🎯 **Corner detection** with rainbow glow + confetti + giant flash text + multi-layered system sounds
- 🎚️ **Menu-bar popover** to tune size, speed, logo text, and toggle the celebration on/off
- 🐰 **Hidden mode**: ⌥-click (or right-click) the menu-bar icon to surface a live "wall hits until next corner" predictor
- 🛠️ **Debug**: "Aim at Corner" forces the logo onto a guaranteed corner trajectory; "Force FX" replays the celebration without touching physics

## Install

```sh
brew tap nyanko3141592/tap
brew install --cask bouncingdvd
```

Because the binary is **ad-hoc signed** (no Apple Developer ID), the first launch will be blocked by Gatekeeper. Right-click the app in `/Applications` → **Open** → Open. Subsequent launches work normally.

## Usage

1. Launch from `/Applications/BouncingDVD.app` (or after install via brew).
2. A logo starts drifting on your main display.
3. Click the optical-disc icon in the menu bar to open the settings popover.
4. ⌘Q from the popover (or the app menu) to quit.

### Customizing the logo text

In the popover, the **Logo** row has two text fields. The first replaces the big serif text (max 5 chars), the second replaces the small text inside the bottom ellipse (max 8 chars). You are free to type anything you like — but trademarked text is **your** responsibility.

## Build from source

Requires **Xcode 16+** on **Apple Silicon macOS Sonoma or newer**.

```sh
swift build               # debug build
swift run DVDBouncer       # launch directly
```

To build a redistributable `.app`:

```sh
scripts/build-app.sh 0.1.0     # creates .build/dist/BouncingDVD.app
scripts/build-dmg.sh 0.1.0     # creates .build/dist/BouncingDVDonMac-0.1.0.dmg
```

## Releasing a new version

1. Bump the version (e.g. `0.2.0`):
   ```sh
   scripts/build-app.sh 0.2.0
   scripts/build-dmg.sh 0.2.0
   ```
2. Note the printed `SHA256`.
3. Tag and push:
   ```sh
   git tag v0.2.0
   git push origin v0.2.0
   ```
4. Create a GitHub Release for that tag and upload `BouncingDVDonMac-0.2.0.dmg`.
5. Update the cask in `nyanko3141592/homebrew-tap`:
   ```ruby
   cask "bouncingdvd" do
     version "0.2.0"
     sha256 "<paste sha256>"
     ...
   ```
6. Push the tap repo. Users get the update with `brew upgrade --cask bouncingdvd`.

## Project layout

```
.
├── Package.swift
├── Sources/DVDBouncer/        # Swift source
├── Resources/Info.plist       # bundle template (__VERSION__ replaced at build)
├── scripts/build-app.sh       # assembles the .app and ad-hoc signs
├── scripts/build-dmg.sh       # packages the .app into a UDZO DMG
└── Casks/bouncingdvd.rb       # cask template (copy to homebrew-tap on release)
```

## License

MIT — see [LICENSE](LICENSE).

## Trademark notice

"DVD" and "DVD VIDEO" and the related logos are trademarks of their respective owners (including DVD Format/Logo Licensing Corporation). This project is an independent, non-commercial homage to the *bouncing logo screensaver* meme. The application **does not bundle, reproduce, or distribute** the DVD VIDEO logo, wordmark, or any other protected trade dress. The default on-screen text is intentionally generic, and any customization performed by end users is at their own discretion and responsibility.
