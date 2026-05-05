# BouncingLogo for Mac

A nostalgic-style **bouncing logo overlay** for macOS, inspired by the classic *bouncing screensaver* meme that everyone has stared at while waiting for the corner. Lives in your menu bar, drifts a logo across your desktop, and gets *very* excited when it hits a perfect corner.

> ⚠️ **Trademark-clean by design.**
> This app **does not include, reproduce, or distribute** the "DVD VIDEO" logo, wordmark, or any other protected trade dress. The on-screen logo defaults to the generic placeholder text **`BNC` / `LOGO`** and uses dynamic, ever-changing colors. The `BouncingLogo.app` distributed via this repository contains no trademarked imagery or strings. See the [Trademark notice](#trademark-notice) at the bottom for details.

## Features

- 🪟 **Transparent overlay** that floats over every Space and lets clicks pass through to the apps below
- 🎨 **Color cycle** on every wall hit (classic CRT vibe)
- 🌈 **Rainbow + confetti + flash celebration** on a perfect corner hit, with multi-layered system sounds
- 🎚️ **Menu-bar popover** to tune size, speed, on-screen text, and toggle the celebration on/off
- 🐰 **Hidden mode**: ⌥-click (or right-click) the menu-bar icon to surface a live "wall hits until next corner" predictor
- 🛠️ **Debug helpers**: *Aim at Corner* forces the logo onto a guaranteed corner trajectory; *Force FX* replays the celebration without touching physics

## Install

```sh
brew tap nyanko3141592/tap
brew install --cask bouncinglogo
```

Because the binary is **ad-hoc signed** (no Apple Developer ID), the first launch will be blocked by Gatekeeper. Right-click `BouncingLogo.app` in `/Applications` → **Open** → *Open*. Subsequent launches work normally.

## Usage

1. Launch from `/Applications/BouncingLogo.app` (or after installing via brew).
2. A logo starts drifting on your main display.
3. Click the optical-disc icon in the menu bar to open the settings popover.
4. ⌘Q from the popover (or the app menu) to quit.

### Customizing the on-screen text

In the popover, the **Logo** row has two text fields. The first replaces the big serif text (max 5 chars), the second replaces the small text inside the bottom ellipse (max 8 chars). Type whatever you like — *trademarked text typed in by an end user is the user's responsibility, not the project's*.

## Build from source

Requires **Xcode 16+** on **Apple Silicon macOS Sonoma or newer**.

```sh
swift build               # debug build
swift run DVDBouncer       # launch directly
```

To build a redistributable `.app`:

```sh
scripts/build-app.sh 0.1.0     # creates .build/dist/BouncingLogo.app
scripts/build-dmg.sh 0.1.0     # creates .build/dist/BouncingLogo-0.1.0.dmg
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
4. Create a GitHub Release for that tag and upload `BouncingLogo-0.2.0.dmg`.
5. Update the cask in `nyanko3141592/homebrew-tap`:
   ```ruby
   cask "bouncinglogo" do
     version "0.2.0"
     sha256 "<paste sha256>"
     ...
   ```
6. Push the tap repo. Users get the update with `brew upgrade --cask bouncinglogo`.

## Project layout

```
.
├── Package.swift
├── Sources/DVDBouncer/        # Swift source (internal module name retained)
├── Resources/Info.plist       # bundle template (__VERSION__ replaced at build)
├── scripts/build-app.sh       # assembles BouncingLogo.app and ad-hoc signs it
├── scripts/build-dmg.sh       # packages BouncingLogo.app into a UDZO DMG
└── Casks/bouncinglogo.rb      # cask template (copy to homebrew-tap on release)
```

## License

MIT — see [LICENSE](LICENSE).

## Trademark notice

"DVD" and "DVD VIDEO", along with the associated stylized logo, are trademarks of their respective owners (including DVD Format/Logo Licensing Corporation). This project is an independent, non-commercial homage to the public-domain *bouncing-logo screensaver* meme that inspired the repository name.

The application **does not bundle, reproduce, or distribute** the DVD VIDEO logo, wordmark, or any other protected trade dress:

- The default on-screen text is the generic placeholder `BNC` / `LOGO`.
- The visible app name (`BouncingLogo`), bundle identifier (`com.nyanko.bouncinglogo`), DMG file name, and Cask name contain no trademarked terms.
- The shape (a colored ellipse with text on top of a smaller ellipse) is a generic geometric composition; it is not the registered DVD VIDEO logo.

This software is provided for personal entertainment and educational purposes. The repository name `BouncingDVDonMac` is used solely as a *descriptive* reference to the well-known internet meme and does not assert any rights over, or affiliation with, any trademark holder.
