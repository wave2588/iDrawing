/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The `CanvasView` tracks `UITouch`es and represents them as a series of `Line`s.
*/

import UIKit

var eraserState = true;

@available(iOS 9.1, *)
class CanvasView: UIView {
    

    override init(frame: CGRect) {
        super.init(frame: frame)
     
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Properties
    
    let isPredictionEnabled = UIDevice.currentDevice().userInterfaceIdiom == .Pad
    let isTouchUpdatingEnabled = true

    var lineColor = UIColor();
    
    var usePreciseLocations = false {
        didSet {
            needsFullRedraw = true
            setNeedsDisplay()
        }
    }

    
    var needsFullRedraw = true
    
    var lines = [Line]()
    
    var finishedLines = [Line]()

    let activeLines = NSMapTable.strongToStrongObjectsMapTable()
    
    let pendingLines = NSMapTable.strongToStrongObjectsMapTable()

    lazy var frozenContext: CGContext = {
        let scale = self.window!.screen.scale
        var size = self.bounds.size
        
        size.width *= scale
        size.height *= scale
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), 8, 0, colorSpace, CGImageAlphaInfo.PremultipliedLast.rawValue)

        CGContextSetLineCap(context!, .Round)
        let transform = CGAffineTransformMakeScale(scale, scale)
        CGContextConcatCTM(context!, transform)
        
        return context!
    }()
    

    var frozenImage: CGImage?
    
    // MARK: Drawing
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        
        CGContextSetLineCap(context, .Round)
//
        CGContextSetStrokeColorWithColor(context,self.lineColor.CGColor);
        
        if (needsFullRedraw) {
            setFrozenImageNeedsUpdate()
            CGContextClearRect(frozenContext, bounds)
            for array in [finishedLines,lines] {
                for line in array {
                    line.drawCommitedPointsInContext(frozenContext,  usePreciseLocation: usePreciseLocations)
                }
            }
            needsFullRedraw = false
        }

        frozenImage = frozenImage ?? CGBitmapContextCreateImage(frozenContext)
        
        if let frozenImage = frozenImage {
            CGContextDrawImage(context, bounds, frozenImage)
        }
        
        for line in lines {
//            line.newLineColor = self.lineColor;
//            line.selestColorIndex = self.selestColorIndex;
            line.drawInContext(context,  usePreciseLocation: usePreciseLocations)
            
        }
    }
    
    func setFrozenImageNeedsUpdate() {
        frozenImage = nil
    }
    
    // MARK: Actions
    
    func clear() {
        activeLines.removeAllObjects()
        pendingLines.removeAllObjects()
        lines.removeAll()
        finishedLines.removeAll()
        needsFullRedraw = true
        setNeedsDisplay()
    }
    
    // MARK: Convenience
    
    func drawTouches(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var updateRect = CGRect.null
        
        for touch in touches {

            let line = activeLines.objectForKey(touch) as? Line ?? addActiveLineForTouch(touch)
            
            updateRect.unionInPlace(line.removePointsWithType(.Predicted))
            
            let coalescedTouches = event?.coalescedTouchesForTouch(touch) ?? []
            let coalescedRect = addPointsOfType(.Coalesced, forTouches: coalescedTouches, toLine: line, currentUpdateRect: updateRect)
            updateRect.unionInPlace(coalescedRect)
            
//            if isPredictionEnabled {
                let predictedTouches = event?.predictedTouchesForTouch(touch) ?? []
                let predictedRect = addPointsOfType(.Predicted, forTouches: predictedTouches, toLine: line, currentUpdateRect: updateRect)
                updateRect.unionInPlace(predictedRect)
//            }
        }
        
        setNeedsDisplayInRect(updateRect)
    }

    func addActiveLineForTouch(touch: UITouch) -> Line {
        let newLine = Line()
        newLine.newLineColor = self.lineColor;
        activeLines.setObject(newLine, forKey: touch)
        lines.append(newLine)
        
        return newLine
    }
    
    func addPointsOfType(var type: LinePoint.PointType, forTouches touches: [UITouch], toLine line: Line, currentUpdateRect updateRect: CGRect) -> CGRect {
        var accumulatedRect = CGRect.null
        
        for (idx, touch) in touches.enumerate() {
            let isStylus = touch.type == .Stylus
            

            if !isStylus {
                type.unionInPlace(.Finger)
            }
        

            if isTouchUpdatingEnabled && !touch.estimatedProperties.isEmpty {
                type.unionInPlace(.NeedsUpdate)
            }
            

            if type.contains(.Coalesced) && idx == touches.count - 1 {
                type.subtractInPlace(.Coalesced)
                type.unionInPlace(.Standard)
            }
            
            let touchRect = line.addPointOfType(type, forTouch: touch)
            accumulatedRect.unionInPlace(touchRect)
            
            commitLine(line)
        }
        
        return updateRect.union(accumulatedRect)
    }

    func endTouches(touches: Set<UITouch>, cancel: Bool) {
        var updateRect = CGRect.null
        
        for touch in touches {

            guard let line = activeLines.objectForKey(touch) as? Line else { continue }
            

            if cancel { updateRect.unionInPlace(line.cancel()) }
            

            if line.isComplete || !isTouchUpdatingEnabled {
                finishLine(line)
            }

            else {
                pendingLines.setObject(line, forKey: touch)
            }
            
            activeLines.removeObjectForKey(touch)
        }

        setNeedsDisplayInRect(updateRect)
    }
    
    func updateEstimatedPropertiesForTouches(touches: Set<NSObject>) {
        guard isTouchUpdatingEnabled, let touches = touches as? Set<UITouch> else { return }
        
        for touch in touches {
            var isPending = false
            
            let possibleLine: Line? = activeLines.objectForKey(touch) as? Line ?? {
                let pendingLine = pendingLines.objectForKey(touch) as? Line
                isPending = pendingLine != nil
                return pendingLine
            }()
            

            guard let line = possibleLine else { return }
            
            switch line.updateWithTouch(touch) {
                case (true, let updateRect):
                    setNeedsDisplayInRect(updateRect)
                default:
                    ()
            }
            

            if isPending && line.isComplete {
                finishLine(line)
                pendingLines.removeObjectForKey(touch)
            }

            else {
                commitLine(line)
            }
            
        }
    }
    
    func commitLine(line: Line) {
        
        line.drawFixedPointsInContext(frozenContext,  usePreciseLocation: usePreciseLocations)
        
        setFrozenImageNeedsUpdate()
    }
    
    func finishLine(line: Line) {
        
        line.drawFixedPointsInContext(frozenContext,  usePreciseLocation: usePreciseLocations, commitAll: true)
        
        setFrozenImageNeedsUpdate()

        lines.removeAtIndex(lines.indexOf(line)!)
//        line.dslineColor = self.viewColor;

        finishedLines.append(line)
    }
}
