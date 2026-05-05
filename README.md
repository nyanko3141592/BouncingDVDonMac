# BouncingLogo for Mac

[![Latest release](https://img.shields.io/github/v/release/nyanko3141592/BouncingDVDonMac?label=release)](https://github.com/nyanko3141592/BouncingDVDonMac/releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-Sonoma%2B-black?logo=apple)](https://www.apple.com/macos/)
[![arch](https://img.shields.io/badge/arch-arm64-green)](#)

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

After install, launch `BouncingLogo` from Spotlight or `/Applications`. An optical-disc icon appears in the menu bar — click it to open the settings popover.

### First-launch Gatekeeper note

The binary is **ad-hoc signed** (no Apple Developer ID). On first launch macOS will block it with *"can't be opened because Apple cannot check it for malicious software"*.

The easiest workaround is one of:

- **Right-click** `/Applications/BouncingLogo.app` → **Open** → confirm *Open* in the dialog.
- Or strip the quarantine attribute manually:
  ```sh
  xattr -dr com.apple.quarantine /Applications/BouncingLogo.app
  ```

After the first allow, subsequent launches work normally.

### Updating

```sh
brew upgrade --cask bouncinglogo
```

### Uninstall

```sh
brew uninstall --cask bouncinglogo
brew uninstall --cask --zap bouncinglogo   # also remove preferences/caches
```

## Usage

| Action | How |
|---|---|
| Open settings popover | Click the menu-bar disc icon |
| Toggle hidden predictor (wall hits to next corner) | ⌥-click or right-click the menu-bar disc icon |
| Trigger a guaranteed corner hit (debug) | popover → **Aim at Corner** |
| Replay celebration FX without touching physics | popover → **Force FX** |
| Disable corner-hit celebration | popover → **Corner hit celebration** toggle |
| Quit | popover → **Quit**, or ⌘Q from the app menu |

### Customizing the on-screen text

In the popover, the **Logo** row has two text fields. The first replaces the big serif text (max 5 chars), the second replaces the small text inside the bottom ellipse (max 8 chars). Type whatever you like — *trademarked text typed in by an end user is the user's responsibility, not the project's*.

## Build from source

Requires **Xcode 16+** on **Apple Silicon macOS Sonoma or newer**.

```sh
swift build               # debug build
swift run DVDBouncer      # launch directly (debug, no menu-bar icon)
```

To build a redistributable `.app`:

```sh
scripts/build-app.sh 0.1.0     # creates .build/dist/BouncingLogo.app
scripts/build-dmg.sh 0.1.0     # creates .build/dist/BouncingLogo-0.1.0.dmg
```

`build-app.sh` runs `swift build -c release --arch arm64`, assembles the bundle from [`Resources/Info.plist`](Resources/Info.plist) (substituting `__VERSION__`), then ad-hoc signs the result with `codesign --force --deep --sign -`.

## Releasing a new version

1. Build the release artifact:
   ```sh
   scripts/build-app.sh 0.2.0
   scripts/build-dmg.sh 0.2.0       # prints the DMG path and SHA256
   ```
2. Tag and push:
   ```sh
   git tag v0.2.0
   git push origin v0.2.0
   ```
3. Create a GitHub Release with the DMG attached:
   ```sh
   gh release create v0.2.0 \
     --title "BouncingLogo v0.2.0" \
     --notes "..." \
     .build/dist/BouncingLogo-0.2.0.dmg
   ```
4. Update the cask in [`nyanko3141592/homebrew-tap`](https://github.com/nyanko3141592/homebrew-tap) with the new `version` + `sha256`. Lint and audit before pushing:
   ```sh
   TAP="$(brew --repository)/Library/Taps/nyanko3141592/homebrew-tap"
   $EDITOR "$TAP/Casks/bouncinglogo.rb"
   brew style --cask "$TAP/Casks/bouncinglogo.rb"
   brew audit --cask nyanko3141592/tap/bouncinglogo
   git -C "$TAP" commit -am "Update bouncinglogo to 0.2.0" && git -C "$TAP" push
   ```
5. Verify end-to-end:
   ```sh
   brew update
   brew upgrade --cask bouncinglogo
   ```

The local cask template at [`Casks/bouncinglogo.rb`](Casks/bouncinglogo.rb) in this repository tracks the same content for reference.

## Project layout

```
.
├── Package.swift
├── Sources/DVDBouncer/        # Swift source (internal module name retained)
├── Resources/Info.plist       # bundle template (__VERSION__ replaced at build)
├── scripts/build-app.sh       # assembles BouncingLogo.app and ad-hoc signs it
├── scripts/build-dmg.sh       # packages BouncingLogo.app into a UDZO DMG
└── Casks/bouncinglogo.rb      # cask reference (real one lives in homebrew-tap)
```

## License

MIT — see [LICENSE](LICENSE).

## Trademark notice

"DVD" and "DVD VIDEO", along with the associated stylized logo, are trademarks of their respective owners (including DVD Format/Logo Licensing Corporation). This project is an independent, non-commercial homage to the *bouncing-logo screensaver* meme that inspired the repository name.

The application **does not bundle, reproduce, or distribute** the DVD VIDEO logo, wordmark, or any other protected trade dress:

- The default on-screen text is the generic placeholder `BNC` / `LOGO`.
- The visible app name (`BouncingLogo`), bundle identifier (`com.nyanko.bouncinglogo`), DMG file name, and Cask name contain no trademarked terms.
- The shape (a colored ellipse with text on top of a smaller ellipse) is a generic geometric composition; it is not the registered DVD VIDEO logo.

This software is provided for personal entertainment and educational purposes. The repository name `BouncingDVDonMac` is used solely as a *descriptive* reference to the well-known internet meme and does not assert any rights over, or affiliation with, any trademark holder.
