# Klakk Homebrew tap

Publisher-maintained installation metadata for [Klakk](https://tryklakk.com/en/), a keyboard sound app for Mac. This is a third-party tap maintained by the Klakk developer. It is not part of the official `homebrew/cask` catalog and does not imply Homebrew endorsement.

## Install with Homebrew

The cask passed [installation validation on Apple silicon and Intel Macs](https://github.com/levindong2026/homebrew-klakk/actions/runs/37712787486). If you prefer a browser download, use the [official download page](https://tryklakk.com/en/download/?utm_source=github&utm_medium=referral&utm_campaign=homebrew_tap).

If you already use Homebrew:

```sh
brew install --cask levindong2026/klakk/klakk
```

Requirements: macOS 14 or later, Apple silicon or Intel. The cask installs the official, signed and notarized Klakk 1.4.1 build 23 DMG. It verifies SHA-256 before installation. The app then requests Input Monitoring when you open it; review the [privacy policy](https://tryklakk.com/en/privacy/) before granting permission.

The full-featured trial lasts 3 days. Continued use costs US$4.49 once for the Mac edition, with applicable taxes at checkout. Windows and the Mac App Store are separate purchase channels. This tap downloads the Mac website edition.

The public checks ran on an Apple silicon Mac with macOS 26 and an Intel Mac with macOS 15. They verified installation, bundle version and build, both executable architectures, code signature, stapled notarization ticket, Gatekeeper acceptance and uninstall. They did not open the app, grant keyboard permissions or test physical audio latency. QA operations are not customer downloads or installations.

## Maintenance

Updates are made only after the publisher's versioned installer and checksum have been verified. The cask does not disable Gatekeeper, alter Input Monitoring permissions, launch the app or accept product agreements for you.

To remove a Homebrew installation:

```sh
brew uninstall --cask levindong2026/klakk/klakk
```

Do not delete your app settings or license files to uninstall the app. This tap intentionally contains no `zap` directive.

## Repository contents

Only public cask metadata, documentation and validation workflows are stored here. The application source remains private. Klakk remains governed by its [product terms](https://tryklakk.com/en/terms/); this repository does not grant an open-source license to the application.
