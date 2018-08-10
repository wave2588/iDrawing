/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The `CanvasView` tracks `UITouch`es and represents them as a series of `Line`s.
*/

import UIKit

var eraserState = true;

@available(iOS 9.1, *)
@objc class CanvasView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
     
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Properties
    
    public let isPredictionEnabled = UIDevice.current.userInterfaceIdiom == .pad

    public let isTouchUpdatingEnabled = true

    @objc var lineColor: UIColor = UIColor()
    
    public var usePreciseLocations = false {
        didSet {
            needsFullRedraw = true
            setNeedsDisplay()
        }
    }

    
    public var needsFullRedraw = true
    
    public var lines = [Line]()
    
    public var finishedLines = [Line]()
    
    public let activeLines = NSMapTable<AnyObject, AnyObject>.strongToStrongObjects()
    public let pendingLines = NSMapTable<AnyObject, AnyObject>.strongToStrongObjects()
    
    public lazy var frozenContext: CGContext = {
        
        let scale = self.window!.screen.scale
        var size = self.bounds.size
        
        size.width *= scale
        size.height *= scale
        let colorSpace = CGColorSpaceCreateDeviceRGB()
    
        
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)

        context!.setLineCap(.round)
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        context!.concatenate(transform)
        
        return context!
    }()
    

    public var frozenImage: CGImage?
    
    // MARK: Drawing
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        
        context.setLineCap(.round)
        context.setLineWidth(2.0)
//
        context.setStrokeColor(self.lineColor.cgColor);
        
        if (needsFullRedraw) {
            setFrozenImageNeedsUpdate()
            
            frozenContext.clear(bounds)
            
            for array in [finishedLines,lines] {
                for line in array {
                    line.drawCommitedPointsInContext(context: frozenContext, usePreciseLocation: usePreciseLocations)
                }
            }
            needsFullRedraw = false
        }

        frozenImage = frozenImage ?? frozenContext.makeImage()
        
        if let frozenImage = frozenImage {
            context.draw(frozenImage, in: bounds)
        }
        
        for line in lines {
            line.drawInContext(context: context,  usePreciseLocation: usePreciseLocations)
            
        }
    }
    
    func setFrozenImageNeedsUpdate() {
        frozenImage = nil
    }
    
    // MARK: Actions
    
     @objc func clear() {
        activeLines.removeAllObjects()
        pendingLines.removeAllObjects()
        lines.removeAll()
        finishedLines.removeAll()
        needsFullRedraw = true
        setNeedsDisplay()
    }
    
    // MARK: Convenience
    
    @objc func drawTouches(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        var updateRect = CGRect.null
        
        for touch in touches {

            let line = activeLines.object(forKey: touch) as? Line ?? addActiveLineForTouch(touch: touch)
            
            updateRect = updateRect.union(line.removePointsWithType(type: .Predicted))
            
            let coalescedTouches = event?.coalescedTouches(for: touch) ?? []
            
            let coalescedRect = addPointsOfType(type: .Coalesced, forTouches: coalescedTouches, toLine: line, currentUpdateRect: updateRect)
            updateRect = updateRect.union(coalescedRect)
            
//            if isPredictionEnabled {
            let predictedTouches = event?.predictedTouches(for: touch) ?? []
            let predictedRect = addPointsOfType(type: .Predicted, forTouches: predictedTouches, toLine: line, currentUpdateRect: updateRect)
            updateRect = updateRect.union(predictedRect)
//            }
        }
        
        setNeedsDisplay(updateRect)
    }

    func addActiveLineForTouch(touch: UITouch) -> Line {
        let newLine = Line()
        newLine.newLineColor = self.lineColor;
        activeLines.setObject(newLine, forKey: touch)
        lines.append(newLine)
        
        return newLine
    }
    
    func addPointsOfType(type: LinePoint.PointType, forTouches touches: [UITouch], toLine line: Line, currentUpdateRect updateRect: CGRect) -> CGRect {
        
        var type = type
        
        var accumulatedRect = CGRect.null
    
        for (idx, touch) in touches.enumerated() {
            let isStylus = touch.type == .stylus
            

            if !isStylus {
                type = type.union(.Finger)
            }
        

            if isTouchUpdatingEnabled && !touch.estimatedProperties.isEmpty {
                type = type.union(.NeedsUpdate)
            }
            

            if type.contains(.Coalesced) && idx == touches.count - 1 {
                
               type.subtract(.Coalesced)
               type = type.union(.Standard)
            }
            
            let touchRect = line.addPointOfType(pointType: type, forTouch: touch)
            accumulatedRect = accumulatedRect.union(touchRect)
            
            commitLine(line: line)
        }
        
        return updateRect.union(accumulatedRect)
    }

    @objc func endTouches(touches: Set<UITouch>, cancel: Bool) {
        var updateRect = CGRect.null
        
        for touch in touches {

            guard let line = activeLines.object(forKey: touch) as? Line else { continue }
            
            if cancel {
                updateRect = updateRect.union(line.cancel())
                
            }
            

            if line.isComplete || !isTouchUpdatingEnabled {
                finishLine(line: line)
            }

            else {
                pendingLines.setObject(line, forKey: touch)
            }
            
            activeLines.removeObject(forKey: touch)
        }
        setNeedsDisplay(updateRect)
    }
    
    func updateEstimatedPropertiesForTouches(touches: Set<NSObject>) {
        guard isTouchUpdatingEnabled, let touches = touches as? Set<UITouch> else { return }
        
        for touch in touches {
            var isPending = false
            
            let possibleLine: Line? = activeLines.object(forKey: touch) as? Line ?? {
                let pendingLine = pendingLines.object(forKey: touch) as? Line
                isPending = pendingLine != nil
                return pendingLine
            }()
            

            guard let line = possibleLine else { return }
            
            switch line.updateWithTouch(touch: touch) {
                case (true, let updateRect):
                    setNeedsDisplay(updateRect)
                default:
                    ()
            }
            

            if isPending && line.isComplete {
                finishLine(line: line)
                pendingLines.removeObject(forKey: touch)
            }

            else {
                commitLine(line: line)
            }
            
        }
    }
    
    func commitLine(line: Line) {
        
        line.drawFixedPointsInContext(context: frozenContext,  usePreciseLocation: usePreciseLocations)
        
        setFrozenImageNeedsUpdate()
    }
    
    func finishLine(line: Line) {
        
        line.drawFixedPointsInContext(context: frozenContext,  usePreciseLocation: usePreciseLocations, commitAll: true)
        
        setFrozenImageNeedsUpdate()
        if let index = lines.index(of: line) {
            lines.remove(at: index)
        }
//        line.dslineColor = self.viewColor;

        finishedLines.append(line)
    }
}
