//
//  AsciiquariumScreensaverView.swift
//  AsciiquariumScreensaver
//
//  Created by Andy Altepeter on 12/21/25.
//

import AppKit
import AsciiquariumCore
import ScreenSaver

@objc(AsciiquariumScreensaverView)
class AsciiquariumScreensaverView: ScreenSaverView {
  private var engine: AsciiquariumEngine
  private var renderer: ASCIIRenderer
  private var lastRenderedString: NSAttributedString?
  private var lastTickTime: CFTimeInterval = 0

  override init?(frame: NSRect, isPreview: Bool) {
    self.engine = AsciiquariumEngine()
    self.renderer = ASCIIRenderer()

    super.init(frame: frame, isPreview: isPreview)

    // Screensavers typically run at 30 FPS
    self.animationTimeInterval = 1.0 / 30.0

    setupEngine()
  }

  required init?(coder: NSCoder) {
    self.engine = AsciiquariumEngine()
    self.renderer = ASCIIRenderer()

    super.init(coder: coder)

    self.animationTimeInterval = 1.0 / 30.0

    setupEngine()
  }

  private func setupEngine() {
    // Load fish count from UserDefaults and set on engine
    let fishCount = ScreenSaverDefaults.fishCount()
    engine.customFishCount = fishCount
    updateDimensions()
  }

  override func startAnimation() {
    super.startAnimation()
    lastTickTime = CACurrentMediaTime()

    // Reload configuration in case it changed while screensaver was stopped
    let fishCount = ScreenSaverDefaults.fishCount()
    if engine.customFishCount != fishCount {
      engine.customFishCount = fishCount
      engine.respawnFish()
    }
  }

  override func stopAnimation() {
    super.stopAnimation()
  }

  override func draw(_ rect: NSRect) {
    // Draw background (black)
    NSColor.black.set()
    rect.fill()

    let entities = engine.entities
    let gridWidth = engine.gridWidth
    let gridHeight = engine.gridHeight

    let attributedString = renderer.renderScene(
      entities: entities,
      gridWidth: gridWidth,
      gridHeight: gridHeight
    )

    // Draw the attributed string
    attributedString.draw(in: rect)
  }

  override func animateOneFrame() {
    let currentTime = CACurrentMediaTime()
    let deltaTime = currentTime - lastTickTime
    lastTickTime = currentTime

    engine.tick(deltaTime: deltaTime)
    setNeedsDisplay(bounds)
  }

  override func setFrameSize(_ newSize: NSSize) {
    super.setFrameSize(newSize)
    updateDimensions()
  }

  private func updateDimensions() {
    let bounds = self.bounds
    let font = FontMetrics.shared.createDefaultFont()
    let dimensions = FontMetrics.shared.calculateGridDimensions(for: bounds, font: font)

    // Reload fish count from UserDefaults in case it changed
    let fishCount = ScreenSaverDefaults.fishCount()
    let oldFishCount = engine.customFishCount
    engine.customFishCount = fishCount

    engine.updateGridDimensions(width: dimensions.width, height: dimensions.height)

    // If fish count changed, respawn fish
    if oldFishCount != fishCount {
      engine.respawnFish()
    }

    // Ensure renderer is using the same font/size
    renderer.updateFont(size: FontMetrics.shared.getDefaultFontSize())
  }

  override var hasConfigureSheet: Bool {
    return true
  }

  override var configureSheet: NSWindow? {
    let controller = ConfigureSheetController()
    return controller.window
  }
}
