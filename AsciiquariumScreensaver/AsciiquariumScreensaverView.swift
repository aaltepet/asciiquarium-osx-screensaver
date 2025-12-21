//
//  AsciiquariumScreensaverView.swift
//  AsciiquariumScreensaver
//
//  Created by Andy Altepeter on 12/21/25.
//

import ScreenSaver
import AsciiquariumCore
import AppKit

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
        updateDimensions()
    }
    
    override func startAnimation() {
        super.startAnimation()
        lastTickTime = CACurrentMediaTime()
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
        
        engine.updateGridDimensions(width: dimensions.width, height: dimensions.height)
        // Ensure renderer is using the same font/size
        renderer.updateFont(size: FontMetrics.shared.getDefaultFontSize())
    }
    
    override var hasConfigureSheet: Bool {
        return false
    }
    
    override var configureSheet: NSWindow? {
        return nil
    }
}

