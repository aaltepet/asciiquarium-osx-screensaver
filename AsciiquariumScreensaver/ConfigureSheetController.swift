//
//  ConfigureSheetController.swift
//  AsciiquariumScreensaver
//
//  Created by Andy Altepeter on 12/21/25.
//

import AppKit
import ScreenSaver

class ConfigureSheetController: NSWindowController {
  private var fishCountSlider: NSSlider!
  private var fishCountLabel: NSTextField!
  private var fishCountTextField: NSTextField!
  private var okButton: NSButton!
  private var cancelButton: NSButton!

  private let defaults = ScreenSaverDefaults(
    forModuleWithName: "com.andyaltepeter.AsciiquariumScreensaver")!

  // UserDefaults key for fish count
  private let fishCountKey = "FishCount"

  // Default fish count (0 means use automatic calculation)
  private let defaultFishCount = 0

  convenience init() {
    // Create window programmatically
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
      styleMask: [.titled, .closable],
      backing: .buffered,
      defer: false
    )
    window.title = "Asciiquarium Configuration"
    window.center()
    window.isReleasedWhenClosed = false

    self.init(window: window)
    setupUI()
    loadConfiguration()
  }

  override func windowDidLoad() {
    super.windowDidLoad()
    // Configuration is already loaded in init, but ensure UI is updated
    loadConfiguration()
  }

  private func loadConfiguration() {
    // Load saved fish count or use default
    let savedCount = defaults.integer(forKey: fishCountKey)
    let fishCount = savedCount == 0 ? defaultFishCount : savedCount

    // Set up slider (0-100, where 0 = automatic) if UI is ready
    if fishCountSlider != nil {
      fishCountSlider.minValue = 0
      fishCountSlider.maxValue = 100
      fishCountSlider.intValue = Int32(fishCount)
    }

    // Set up text field if UI is ready
    if fishCountTextField != nil {
      fishCountTextField.intValue = Int32(fishCount)
    }

    updateLabel()
  }

  private func setupUI() {
    guard let contentView = window?.contentView else { return }

    // Create main container
    let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 200))

    // Fish count label (title)
    let titleLabel = NSTextField(labelWithString: "Number of Fish:")
    titleLabel.frame = NSRect(x: 20, y: 130, width: 120, height: 17)
    titleLabel.alignment = .right
    containerView.addSubview(titleLabel)

    // Fish count slider
    fishCountSlider = NSSlider(frame: NSRect(x: 150, y: 130, width: 150, height: 20))
    fishCountSlider.target = self
    fishCountSlider.action = #selector(fishCountChanged)
    containerView.addSubview(fishCountSlider)

    // Fish count text field
    fishCountTextField = NSTextField(frame: NSRect(x: 310, y: 127, width: 60, height: 22))
    fishCountTextField.target = self
    fishCountTextField.action = #selector(fishCountTextFieldChanged)
    fishCountTextField.alignment = .center
    containerView.addSubview(fishCountTextField)

    // Description label
    fishCountLabel = NSTextField(labelWithString: "")
    fishCountLabel.frame = NSRect(x: 20, y: 100, width: 360, height: 17)
    fishCountLabel.alignment = .center
    fishCountLabel.textColor = .secondaryLabelColor
    containerView.addSubview(fishCountLabel)

    // Info text
    let infoLabel = NSTextField(
      wrappingLabelWithString:
        "Set to 0 for automatic calculation based on screen size. Otherwise, specify the number of fish (1-100)."
    )
    infoLabel.frame = NSRect(x: 20, y: 50, width: 360, height: 40)
    infoLabel.alignment = .center
    infoLabel.textColor = .secondaryLabelColor
    infoLabel.font = NSFont.systemFont(ofSize: 11)
    containerView.addSubview(infoLabel)

    // OK button
    okButton = NSButton(title: "OK", target: self, action: #selector(ok(_:)))
    okButton.frame = NSRect(x: 240, y: 10, width: 80, height: 32)
    okButton.keyEquivalent = "\r"
    containerView.addSubview(okButton)

    // Cancel button
    cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancel(_:)))
    cancelButton.frame = NSRect(x: 330, y: 10, width: 80, height: 32)
    cancelButton.keyEquivalent = "\u{1b}"  // Escape key
    containerView.addSubview(cancelButton)

    window?.contentView = containerView
  }

  @objc private func fishCountChanged() {
    let value = Int(fishCountSlider.intValue)
    fishCountTextField.intValue = Int32(value)
    updateLabel()
  }

  @objc private func fishCountTextFieldChanged() {
    var value = Int(fishCountTextField.intValue)
    // Clamp to valid range
    if value < 0 {
      value = 0
    } else if value > 100 {
      value = 100
    }
    fishCountSlider.intValue = Int32(value)
    fishCountTextField.intValue = Int32(value)
    updateLabel()
  }

  private func updateLabel() {
    let value = Int(fishCountSlider.intValue)
    if value == 0 {
      fishCountLabel.stringValue = "Automatic (based on screen size)"
    } else {
      fishCountLabel.stringValue = "\(value) fish"
    }
  }

  @objc private func ok(_ sender: Any) {
    // Save the fish count
    let fishCount = Int(fishCountSlider.intValue)
    defaults.set(fishCount, forKey: fishCountKey)
    defaults.synchronize()

    // Close the sheet
    window?.sheetParent?.endSheet(window!, returnCode: .OK)
  }

  @objc private func cancel(_ sender: Any) {
    // Close the sheet without saving
    window?.sheetParent?.endSheet(window!, returnCode: .cancel)
  }
}

// Helper extension to access fish count from UserDefaults
extension ScreenSaverDefaults {
  static func fishCount() -> Int {
    let defaults = ScreenSaverDefaults(
      forModuleWithName: "com.andyaltepeter.AsciiquariumScreensaver")!
    return defaults.integer(forKey: "FishCount")
  }
}
