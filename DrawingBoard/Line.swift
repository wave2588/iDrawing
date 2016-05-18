/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Contains the `Line` and `LinePoint` types used to represent and draw lines derived from touches.
*/

import UIKit

@available(iOS 9.1, *)
class Line: NSObject {
    // MARK: Properties
    
    var points = [LinePoint]()
    
    var pointsWaitingForUpdatesByEstimationIndex = [NSNumber: LinePoint]()

    var committedPoints = [LinePoint]()
    
    var isComplete: Bool {
        return pointsWaitingForUpdatesByEstimationIndex.count == 0
    }
    
    var newLineColor = UIColor();

    func updateWithTouch(touch: UITouch) -> (Bool, CGRect) {
        if  let estimationUpdateIndex = touch.estimationUpdateIndex,
            let point = pointsWaitingForUpdatesByEstimationIndex[estimationUpdateIndex] {
            var rect = updateRectForExistingPoint(point)
            let didUpdate = point.updateWithTouch(touch)
            if didUpdate {
                rect.unionInPlace(updateRectForExistingPoint(point))
            }
//            if point.estimatedPropertiesExpectingUpdates == [] {
//                pointsWaitingForUpdatesByEstimationIndex.removeValueForKey(estimationUpdateIndex)
//            }
            return (didUpdate,rect)
        }
        return (false, CGRect.null)
    }
    
    // MARK: Interface
    
    func addPointOfType(pointType: LinePoint.PointType, forTouch touch: UITouch) -> CGRect {
        let previousPoint = points.last
        let previousSequenceNumber = previousPoint?.sequenceNumber ?? -1
        let point = LinePoint(touch: touch, sequenceNumber: previousSequenceNumber + 1, pointType:pointType)
        
//        if let estimationIndex = point.estimationUpdateIndex {
//            if !point.estimatedPropertiesExpectingUpdates.isEmpty {
//                pointsWaitingForUpdatesByEstimationIndex[estimationIndex] = point
//            }
//        }
        
        points.append(point)
        
        let updateRect = updateRectForLinePoint(point, previousPoint: previousPoint)
        
        return updateRect
    }
    
    func removePointsWithType(type: LinePoint.PointType) -> CGRect {
        var updateRect = CGRect.null
        var priorPoint: LinePoint?
        
        points = points.filter { point in
            let keepPoint = !point.pointType.contains(type)
            
            if !keepPoint {
                var rect = self.updateRectForLinePoint(point)
                
                if let priorPoint = priorPoint {
                    rect.unionInPlace(updateRectForLinePoint(priorPoint))
                }
                
                updateRect.unionInPlace(rect)
            }
            
            priorPoint = point
            
            return keepPoint
        }
        
        return updateRect
    }
    
    func cancel() -> CGRect {
        let updateRect = points.reduce(CGRect.null) { accumulated, point in
            point.pointType.unionInPlace(.Cancelled)
            
            return accumulated.union(updateRectForLinePoint(point))
        }
        
        return updateRect
    }
    
    // MARK: Drawing
    
    func drawInContext(context: CGContext,  usePreciseLocation: Bool) {

        var maybePriorPoint: LinePoint?

        for point in points {

            
            guard let priorPoint = maybePriorPoint else {
                maybePriorPoint = point
                continue
            }

            let location = usePreciseLocation ? point.preciseLocation : point.location
            let priorLocation = usePreciseLocation ? priorPoint.preciseLocation : priorPoint.location
//
            CGContextSetStrokeColorWithColor(context, self.newLineColor.CGColor)
            
            CGContextBeginPath(context)
            
            CGContextMoveToPoint(context, priorLocation.x, priorLocation.y)
            CGContextAddLineToPoint(context, location.x, location.y)
            
//            if BBSettings.defaultSettings().isEraserState{
//            
//                CGContextSetLineWidth(context, 200);
//            }else{
                CGContextSetLineWidth(context, point.magnitude);
//            }
            
            
            CGContextStrokePath(context)
  
            maybePriorPoint = point
        }
    }
    
    func drawFixedPointsInContext(context: CGContext, usePreciseLocation: Bool, commitAll: Bool = false) {
        let allPoints = points
        var committing = [LinePoint]()
        
        if commitAll {
            committing = allPoints
            points.removeAll()
        }
        else {
            for (index, point) in allPoints.enumerate() {
                guard point.pointType.intersect([.NeedsUpdate, .Predicted]).isEmpty && index < allPoints.count - 2 else {
                    committing.append(points.first!)
                    break
                }
                
                guard index > 0 else { continue }
                
                let removed = points.removeFirst()
                committing.append(removed)
            }
        }
        guard committing.count > 1 else { return }
        //
        let committedLine = Line()
        committedLine.newLineColor = self.newLineColor;

        committedLine.points = committing
        committedLine.drawInContext(context,  usePreciseLocation: usePreciseLocation);
        
        
        if committedPoints.count > 0 {
            committedPoints.removeLast()
        }
        
        committedPoints.appendContentsOf(committing)
    }
    
    func drawCommitedPointsInContext(context: CGContext,  usePreciseLocation: Bool) {
        let committedLine = Line()
        //
        committedLine.newLineColor = self.newLineColor;
        committedLine.points = committedPoints
        committedLine.drawInContext(context,  usePreciseLocation: usePreciseLocation);
    }
    
    // MARK: Convenience
    
    func updateRectForLinePoint(point: LinePoint) -> CGRect {
        var rect = CGRect(origin: point.location, size: CGSize.zero)
        
        let magnitude = -3 * point.magnitude - 2
        rect.insetInPlace(dx: magnitude, dy: magnitude)
        
        return rect
    }

    func updateRectForLinePoint(point: LinePoint, previousPoint optionalPreviousPoint: LinePoint? = nil) -> CGRect {
        var rect = CGRect(origin: point.location, size: CGSize.zero)
        
        var pointMagnitude = point.magnitude

        if let previousPoint = optionalPreviousPoint {
            pointMagnitude = max(pointMagnitude, previousPoint.magnitude)
            rect = CGRectUnion(rect, CGRect(origin:previousPoint.location, size: CGSize.zero))
        }
        
        let magnitude = -3.0 * pointMagnitude - 2.0
        rect.insetInPlace(dx: magnitude, dy: magnitude)
        
        return rect
    }
    
    func updateRectForExistingPoint(point: LinePoint) -> CGRect {
        var rect = updateRectForLinePoint(point)
        
        let arrayIndex = point.sequenceNumber - points.first!.sequenceNumber

        if arrayIndex > 0 {
            rect = CGRectUnion(rect,updateRectForLinePoint(point, previousPoint: points[arrayIndex-1]))
        }
        if arrayIndex + 1 < points.count {
            rect = CGRectUnion(rect,updateRectForLinePoint(point, previousPoint: points[arrayIndex+1]))
        }
        return rect
    }

}

@available(iOS 9.1, *)
class LinePoint: NSObject  {
    // MARK: Types
    
    struct PointType: OptionSetType {
        // MARK: Properties
        
        let rawValue: Int
        
        // MARK: Options
        
        static var Standard: PointType    { return self.init(rawValue: 0) }
        static var Coalesced: PointType   { return self.init(rawValue: 1 << 0) }
        static var Predicted: PointType   { return self.init(rawValue: 1 << 1) }
        static var NeedsUpdate: PointType { return self.init(rawValue: 1 << 2) }
        static var Updated: PointType     { return self.init(rawValue: 1 << 3) }
        static var Cancelled: PointType   { return self.init(rawValue: 1 << 4) }
        static var Finger: PointType      { return self.init(rawValue: 1 << 5) }
        static var RedPenColor : PointType{ return self.init(rawValue: 1 << 6) }
    }
    
    // MARK: Properties
    
    var sequenceNumber: Int
    let timestamp: NSTimeInterval
    var force: CGFloat
    var location: CGPoint
    var preciseLocation: CGPoint
//    var estimatedPropertiesExpectingUpdates: UITouchProperties
    var estimatedProperties: UITouchProperties
    let type: UITouchType
    var altitudeAngle: CGFloat
    var azimuthAngle: CGFloat
    let estimationUpdateIndex: NSNumber?
    
    var pointType: PointType
    
    var magnitude: CGFloat {
        
//        return max(force, 0.025)
        
        if BBSettings.defaultSettings().isEraserState{
            return 25;
        }else{
            return max(force, 0.025)
        }
    }
    
    // MARK: Initialization
    
    init(touch: UITouch, sequenceNumber: Int, pointType: PointType) {
        self.sequenceNumber = sequenceNumber
        self.type = touch.type
        self.pointType = pointType
        
        timestamp = touch.timestamp
        let view = touch.view
        location = touch.locationInView(view)
        preciseLocation = touch.preciseLocationInView(view)
        azimuthAngle = touch.azimuthAngleInView(view)
        estimatedProperties = touch.estimatedProperties
//        estimatedPropertiesExpectingUpdates = touch.estimatedPropertiesExpectingUpdates
        altitudeAngle = touch.altitudeAngle
        
        force = (type == .Stylus || touch.force > 0) ? touch.force : 1.0
 
        
//        if !estimatedPropertiesExpectingUpdates.isEmpty {
//            self.pointType.unionInPlace(.NeedsUpdate)
//        }
        
        estimationUpdateIndex = touch.estimationUpdateIndex
    }

    func updateWithTouch(touch: UITouch) -> Bool {
        guard let estimationUpdateIndex = touch.estimationUpdateIndex
            where estimationUpdateIndex == estimationUpdateIndex else { return false }
        
        let touchProperties: [UITouchProperties] = [.Altitude, .Azimuth, .Force, .Location]
        
        for expectedProperty in touchProperties {
//            guard !estimatedPropertiesExpectingUpdates.contains(expectedProperty) else { continue }
            
            switch expectedProperty {
                case UITouchProperties.Force:
                    force = touch.force
                case UITouchProperties.Azimuth:
                    azimuthAngle = touch.azimuthAngleInView(touch.view)
                case UITouchProperties.Altitude:
                    altitudeAngle = touch.altitudeAngle
                case UITouchProperties.Location:
                    location = touch.locationInView(touch.view)
                    preciseLocation = touch.preciseLocationInView(touch.view)
                default:
                    ()
            }

            if !touch.estimatedProperties.contains(expectedProperty) {
                estimatedProperties.subtractInPlace(expectedProperty)
            }
            
//            if !touch.estimatedPropertiesExpectingUpdates.contains(expectedProperty) {
//                estimatedPropertiesExpectingUpdates.subtractInPlace(expectedProperty)
//                
//                if estimatedPropertiesExpectingUpdates.isEmpty {
//                    pointType.subtractInPlace(.NeedsUpdate)
//                    pointType.unionInPlace(.Updated)
//                }
//            }
        }
        
        return true
    }
}
