# Asciiquarium macOS Screensaver

A native macOS screensaver and application that brings the charming and beloved asciiquarium terminal application to your screen saver and desktop.

## Overview

This project ports the popular [asciiquarium](https://github.com/cmatsuoka/asciiquarium) Perl script to native macOS using Swift and the ScreenSaver/AppKit frameworks. Experience the nostalgic charm of ASCII art aquarium animations right on your Mac's screen saver or in a standalone application window.

**License**: GNU General Public License v2 (GPL-2.0) - matching the original asciiquarium

## Features

- 🐠 **Animated ASCII Aquarium**: Watch fish, whales, and sea creatures swim in ASCII art
- 🎨 **Pixel-Perfect Collisions**: Shark eats fish with blood splat animations
- 🎣 **Fishing Logic**: Random fishing hooks and lines
- ⚙️ **Native Performance**: 100% Swift implementation (no Perl/external dependencies)
- 🖥️ **macOS Integration**: Works as both a `.saver` and a standalone `.app`

## Requirements

- macOS 10.15 (Catalina) or later
- Xcode 15+ (for building from source)

## Installation (Pre-built)

1. Download the latest `AsciiquariumScreensaver.saver` bundle from the releases page.
2. Double-click the `.saver` file to install.
3. If macOS blocks the installation (Unidentified Developer):
   - Go to **System Settings > Privacy & Security**.
   - Scroll down and click **Open Anyway**.
4. Open **System Settings > Screen Saver** and select "Asciiquarium Screensaver".

## Building from Source

### 1. Build using Xcode
1. Open `Asciiquarium.xcodeproj` in Xcode.
2. Select the **AsciiquariumScreensaver** scheme in the top toolbar.
3. Press **Cmd + Option + B** (or hold Option and go to **Product > Build for Profiling**) to create a **Release** build.
4. To find the file:
   - Go to the **Report Navigator** (Cmd + 9).
   - Select the latest Build log.
   - Click the folder icon next to the build result to "Show in Finder".

### 2. Build using Terminal
Run this command from the project root to build a universal binary (arm64 + x86_64) and place the output in a local `build` folder:
```bash
xcodebuild -project Asciiquarium.xcodeproj \
           -scheme AsciiquariumScreensaver \
           -configuration Release \
           clean build \
           ARCHS="arm64 x86_64" \
           ONLY_ACTIVE_ARCH=NO \
           SYMROOT=$(PWD)/build
```
The screensaver will be located at: `./build/Release/AsciiquariumScreensaver.saver`

**Note**: The `ARCHS="arm64 x86_64"` and `ONLY_ACTIVE_ARCH=NO` flags ensure a universal binary that works on both Apple Silicon and Intel Macs.

### 3. Install via Terminal
After building with the command above, you can install it immediately:
```bash
mkdir -p ~/Library/Screen\ Savers/
cp -R ./build/Release/AsciiquariumScreensaver.saver ~/Library/Screen\ Savers/
```

## Project Structure

- `Sources/AsciiquariumCore`: Shared Swift logic for the aquarium engine and ASCII rendering.
- `AsciiquariumApp`: Native macOS application wrapper.
- `AsciiquariumScreensaver`: macOS Screensaver bundle implementation.
- `Asciiquarium.xcodeproj`: Main Xcode project with shared schemes.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the GNU General Public License v2 (GPL-2.0) - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Original [asciiquarium](https://github.com/cmatsuoka/asciiquarium) by Kirk Baucom
- [Term::Animation](https://metacpan.org/pod/Term::Animation) Perl module
- macOS ScreenSaver framework

---

*Bring the terminal to your screen saver* 🐠✨
