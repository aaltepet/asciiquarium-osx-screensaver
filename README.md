# Asciiquarium macOS Screensaver

A native macOS screensaver and application that brings the charming and beloved asciiquarium terminal application to your screen saver and desktop.

## Overview

This project ports the popular [asciiquarium](https://github.com/cmatsuoka/asciiquarium) Perl script to native macOS using Swift and the ScreenSaver/AppKit frameworks. Experience the nostalgic charm of ASCII art aquarium animations right on your Mac's screen saver or in a standalone application window.

**License**: GNU General Public License v2 (GPL-2.0) - matching the original asciiquarium

## Features

- 🐠 **Animated ASCII Aquarium**: Watch fish, whales, and sea creatures swim in ASCII art
- 🎨 **Multiple Color Schemes**: Monochrome, colored, and custom themes
- ⚙️ **Configurable Settings**: Animation speed, font size, and visual options
- 🖥️ **Native macOS Integration**: Seamless screensaver experience
- 🚀 **Lightweight**: Minimal resource usage for smooth performance

## Requirements

- macOS 10.15 (Catalina) or later
- asciiquarium Perl script (installed via Homebrew)

## Installation

1. Install asciiquarium via Homebrew:
   ```bash
   brew install asciiquarium
   ```

2. Download the latest `.saver` bundle from the releases page

3. Double-click the `.saver` file to install, or manually copy to:
   ```
   ~/Library/Screen Savers/
   ```

4. Open System Preferences > Desktop & Screen Saver and select "Asciiquarium Screensaver"

## Configuration

The screensaver includes several configuration options:

- **Animation Speed**: Slow, Normal, Fast
- **Color Scheme**: Monochrome, Colored, Custom
- **Font Size**: Auto, Small, Medium, Large
- **Background**: Black, Dark Gray, Custom

## Development

### Prerequisites

- Xcode 12.0 or later
- macOS development environment
- asciiquarium installed locally

### Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/asciiquarium-screensaver.git
   cd asciiquarium-screensaver
   ```

2. Open `AsciiquariumScreensaver.xcodeproj` in Xcode

3. Build the project (⌘+B)

4. The `.saver` bundle will be created in the build directory

### Project Structure

```
AsciiquariumScreensaver/
├── AsciiquariumScreensaver/
│   ├── AsciiquariumScreensaverView.swift    # Main screensaver view
│   ├── AsciiquariumEngine.swift             # Script execution engine
│   ├── ASCIIRenderer.swift                  # Text rendering system
│   └── ConfigurationManager.swift           # Settings management
├── Resources/
│   └── asciiquarium.pl                      # Bundled Perl script
└── AsciiquariumScreensaver.xcodeproj       # Xcode project file
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Guidelines

1. Follow Swift style guidelines
2. Add comments for complex logic
3. Test on multiple macOS versions
4. Ensure performance remains optimal

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Original [asciiquarium](https://github.com/cmatsuoka/asciiquarium) by Kirk Baucom
- [Term::Animation](https://metacpan.org/pod/Term::Animation) Perl module
- macOS ScreenSaver framework

## Roadmap

- [ ] Multiple aquarium themes
- [ ] Sound effects integration
- [ ] Interactive elements
- [ ] Custom ASCII art support
- [ ] Network aquarium (multiple screens)

## Support

If you encounter any issues or have questions, please open an issue on GitHub.

---

*Bring the terminal to your screen saver* 🐠✨
