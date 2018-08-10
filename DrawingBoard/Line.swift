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
            
            var rect = updateRectForExistingPoint(point: point)
            let didUpdate = point.updateWithTouch(touch: touch)
            if didUpdate {
                rect = rect.union(updateRectForExistingPoint(point: point))
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
        
        let updateRect = updateRectForLinePoint(point: point, previousPoint: previousPoint)
        
        return updateRect
    }
    
    func removePointsWithType(type: LinePoint.PointType) -> CGRect {
        var updateRect = CGRect.null
        
        var priorPoint: LinePoint?
        
        points = points.filter { point in
            let keepPoint = !point.pointType.contains(type)
            
            if !keepPoint {
                var rect = self.updateRectForLinePoint(point: point)
                
                if let priorPoint = priorPoint {
                    rect = rect.union(updateRectForLinePoint(point: priorPoint))
                }
                
                updateRect = updateRect.union(rect)
            }
            
            priorPoint = point
            
            return keepPoint
        }
        
        return updateRect
    }
    
    func cancel() -> CGRect {
        let updateRect = points.reduce(CGRect.null) { accumulated, point in
            _ = point.pointType.union(.Cancelled)
            
            return accumulated.union(updateRectForLinePoint(point: point))
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
            context.setStrokeColor(self.newLineColor.cgColor)
            
            context.beginPath()
            
            context.move(to: CGPoint(x: priorLocation.x, y: priorLocation.y))
            context.addLine(to: CGPoint(x: location.x, y: location.y))
            
            
//            if BBSettings.defaultSettings().isEraserState{
//            
//                CGContextSetLineWidth(context, 200);
//            }else{
            context.setLineWidth( point.magnitude)
//            }
            
            
            context.strokePath()
  
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
            for (index, point) in allPoints.enumerated() {
                guard point.pointType.intersection([.NeedsUpdate, .Predicted]).isEmpty,  index < allPoints.count - 2 else {
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
        committedLine.drawInContext(context: context,  usePreciseLocation: usePreciseLocation);
        
        
        if committedPoints.count > 0 {
            committedPoints.removeLast()
        }
        committedPoints.append(contentsOf: committing)
    }
    
    func drawCommitedPointsInContext(context: CGContext,  usePreciseLocation: Bool) {
        let committedLine = Line()
        //
        committedLine.newLineColor = self.newLineColor;
        committedLine.points = committedPoints
        committedLine.drawInContext(context: context, usePreciseLocation: usePreciseLocation)
    }
    
    // MARK: Convenience
    
    func updateRectForLinePoint(point: LinePoint) -> CGRect {
        var rect = CGRect(origin: point.location, size: CGSize.zero)
        
        let magnitude = -3 * point.magnitude - 2
        rect = rect.insetBy(dx: magnitude, dy: magnitude)
        
        return rect
    }

    func updateRectForLinePoint(point: LinePoint, previousPoint optionalPreviousPoint: LinePoint? = nil) -> CGRect {
        var rect = CGRect(origin: point.location, size: CGSize.zero)
        
        var pointMagnitude = point.magnitude

        if let previousPoint = optionalPreviousPoint {
            pointMagnitude = max(pointMagnitude, previousPoint.magnitude)
            rect = rect.union(CGRect(origin:previousPoint.location, size: CGSize.zero))
        }
        
        let magnitude = -3.0 * pointMagnitude - 2.0
        
        rect.insetBy(dx: magnitude, dy: magnitude)
        
        return rect
    }
    
    func updateRectForExistingPoint(point: LinePoint) -> CGRect {
        var rect = updateRectForLinePoint(point: point)
        
        let arrayIndex = point.sequenceNumber - points.first!.sequenceNumber

        if arrayIndex > 0 {
            rect = rect.union(updateRectForLinePoint(point: point, previousPoint: points[arrayIndex-1]))
        }
        if arrayIndex + 1 < points.count {
            rect = rect.union(updateRectForLinePoint(point: point, previousPoint: points[arrayIndex+1]))
        }
        return rect
    }

}

@available(iOS 9.1, *)
class LinePoint: NSObject  {
    // MARK: Types
    
    struct PointType: OptionSet {
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
    let timestamp: TimeInterval
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
        
        if BBSettings.default().isEraserState{
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
        location = touch.location(in: view)
        preciseLocation = touch.preciseLocation(in: view)
        azimuthAngle = touch.azimuthAngle(in: view)
        estimatedProperties = touch.estimatedProperties
//        estimatedPropertiesExpectingUpdates = touch.estimatedPropertiesExpectingUpdates
        altitudeAngle = touch.altitudeAngle
        
        force = (type == .stylus || touch.force > 0) ? touch.force : 1.0
 
        
//        if !estimatedPropertiesExpectingUpdates.isEmpty {
//            self.pointType.unionInPlace(.NeedsUpdate)
//        }
        
        estimationUpdateIndex = touch.estimationUpdateIndex
    }

    func updateWithTouch(touch: UITouch) -> Bool {
        guard let estimationUpdateIndex = touch.estimationUpdateIndex, estimationUpdateIndex == estimationUpdateIndex else { return false }
        
        let touchProperties: [UITouchProperties] = [.altitude, .azimuth, .force, .location]
        
        for expectedProperty in touchProperties {
//            guard !estimatedPropertiesExpectingUpdates.contains(expectedProperty) else { continue }
            
            switch expectedProperty {
            case UITouchProperties.force:
                    force = touch.force
            case UITouchProperties.azimuth:
                    azimuthAngle = touch.azimuthAngle(in: touch.view)
            case UITouchProperties.altitude:
                    altitudeAngle = touch.altitudeAngle
            case UITouchProperties.location:
                    location = touch.location(in: touch.view)
                    preciseLocation = touch.preciseLocation(in: touch.view)
                default:
                    ()
            }

            if !touch.estimatedProperties.contains(expectedProperty) {
                estimatedProperties.subtract(expectedProperty)
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
