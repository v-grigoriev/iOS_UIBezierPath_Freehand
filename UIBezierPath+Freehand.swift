
//  Copyright © 2017 Vladislav Grigoriev

import Foundation
import UIKit

extension UIBezierPath {
    
    public func addFreehandLine(to point: CGPoint, maxOffset: CGFloat = CGFloat(1.0), doubleLine: Bool = true) {
        
        let currentPoint = self.currentPoint
        let freehandLine = FreehandLine(from: currentPoint, to: point, maxOffset: maxOffset)

        addFreehandLine(freehandLine)
        
        if doubleLine {
            move(to: currentPoint)
            addFreehandLine(freehandLine, 0.5)
        }
    }
    
    public func addFreehandRect(rect: CGRect, maxOffset: CGFloat = CGFloat(1.0), doubleLine: Bool = true) {
        move(to: rect.origin)
        
        let freehandLines = [FreehandLine(from: CGPoint(x: rect.minX, y: rect.minY), to: CGPoint(x: rect.maxX, y: rect.minY), maxOffset: maxOffset),
                             FreehandLine(from: CGPoint(x: rect.maxX, y: rect.minY), to: CGPoint(x: rect.maxX, y: rect.maxY), maxOffset: maxOffset),
                             FreehandLine(from: CGPoint(x: rect.maxX, y: rect.maxY), to: CGPoint(x: rect.minX, y: rect.maxY), maxOffset: maxOffset),
                             FreehandLine(from: CGPoint(x: rect.minX, y: rect.maxY), to: CGPoint(x: rect.minX, y: rect.minY), maxOffset: maxOffset)]
        
        for freehandLine in freehandLines {
            addFreehandLine(freehandLine)
        }
        
        if doubleLine {
            for freehandLine in freehandLines {
                addFreehandLine(freehandLine, 0.5)
            }
        }
        
        close()
    }
    
    public func addCatmullRomCurve(with points: [CGPoint]) {
        if points.count < 4 {
            return
        }
        
        let epsilon = CGFloat(1.0e-5)
        let startIndex = 1
        let alpha = CGFloat(0.0)
        
        for index in startIndex..<points.count - 2 {
            let prevIndex = (index - 1 < 0 ? points.count - 1 : index - 1)
            let nextIndex = (index + 1) % points.count
            let nextNextIndex = (nextIndex + 1) % points.count
            
            let p0 = points[prevIndex]
            let p1 = points[index]
            let p2 = points[nextIndex]
            let p3 = points[nextNextIndex]
            
            let d1 = distance(point: difference(between: p1, and: p0))
            let d2 = distance(point: difference(between: p2, and: p1))
            let d3 = distance(point: difference(between: p3, and: p2))
            
            var b1: CGPoint
            if fabs(d1) < epsilon {
                b1 = p1
            }
            else {
                b1 = multiple(point: p2, by: pow(d1, 2.0 * alpha))
                b1 = difference(between: b1, and: multiple(point: p0, by: pow(d2, 2.0 * alpha)))
                b1 = add(point: b1, to: multiple(point: p1, by: (2.0 * pow(d1, 2.0 * alpha) + pow(d2, 2.0 * alpha) + 3.0 * pow(d1, alpha) * pow(d2, alpha))))
                b1 = multiple(point: b1, by: 1.0 / (3.0 * pow(d1, alpha) * (pow(d1, alpha) + pow(d2, alpha))))
            }
            
            var b2: CGPoint
            if fabs(d3) < epsilon {
                b2 = p2
            }
            else {
                b2 = multiple(point: p1, by: pow(d3, 2.0 * alpha))
                b2 = difference(between: b2, and: multiple(point: p3, by: pow(d2, 2.0 * alpha)))
                b2 = add(point: b2, to: multiple(point: p2, by: (2.0 * pow(d3, 2.0 * alpha) + pow(d2, 2.0 * alpha) + 3.0 * pow(d3, alpha) * pow(d2, alpha))))
                b2 = multiple(point: b2, by: 1.0 / (3.0 * pow(d3, alpha) * (pow(d3, alpha) + pow(d2, alpha))))
            }
            
            self.addCurve(to: p2, controlPoint1: b1, controlPoint2: b2)
        }
    }
    
    private func addFreehandLine(_ freehandLine: FreehandLine, _ offsetMultiplier: CGFloat = CGFloat(1.0)) {
        let x1 = freehandLine.fromPoint.x
        let y1 = freehandLine.fromPoint.y
        
        let x2 = freehandLine.toPoint.x
        let y2 = freehandLine.toPoint.y
        
        let divergePoint = freehandLine.divergePoint
        let midDisp = freehandLine.midpointDisplacement
        let offset = freehandLine.offset * offsetMultiplier

        let point1 = CGPoint(x: x1 + FreehandLine.offset(-offset, offset), y: y1 + FreehandLine.offset(-offset, offset))
        let point2 = CGPoint(x: x1 + FreehandLine.offset(-offset, offset), y: y1 + FreehandLine.offset(-offset, offset))
        let point3 = CGPoint(x: midDisp.x + x1 + (x2 - x1) * divergePoint + FreehandLine.offset(-offset, offset), y: midDisp.y + y1 + (y2 - y1) * divergePoint + FreehandLine.offset(-offset, offset))
        let point4 = CGPoint(x: midDisp.y + x1 + 2 * (x2 - x1) * divergePoint + FreehandLine.offset(-offset, offset), y: midDisp.y + y1 + 2.0 * (y2 - y1) * divergePoint + FreehandLine.offset(-offset, offset))
        let point5 = CGPoint(x: x2 + FreehandLine.offset(-offset, offset), y: y2 + FreehandLine.offset(-offset, offset))
        let point6 = CGPoint(x: x2 + FreehandLine.offset(-offset, offset), y: y2 + FreehandLine.offset(-offset, offset))
        
        addCatmullRomCurve(with: [point1, point2, point3, point4, point5, point6])
    }
    
    private func difference(between point: CGPoint, and otherPoint: CGPoint) -> CGPoint {
        return CGPoint(x: point.x - otherPoint.x, y: point.y - otherPoint.y)
    }
    
    private func distance(point: CGPoint) -> CGFloat {
        return CGFloat(sqrt(pow(point.x, 2.0) + pow(point.y, 2.0)))
    }
    
    private func multiple(point: CGPoint, by multiplier: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * multiplier, y: point.y * multiplier)
    }
    
    private func add(point: CGPoint, to otherPoint: CGPoint) -> CGPoint {
        return CGPoint(x: point.x + otherPoint.x, y: point.y + otherPoint.y)
    }
    
    internal class FreehandLine {
        
        let fromPoint: CGPoint
        let toPoint: CGPoint
        
        let divergePoint: CGFloat
        let midpointDisplacement: CGPoint
        
        let offset: CGFloat
        
        init(from fromPoint: CGPoint, to toPoint: CGPoint, maxOffset: CGFloat) {
            
            self.fromPoint = fromPoint
            self.toPoint = toPoint
            
            let lenSq = pow(fromPoint.x - toPoint.x, 2.0) + pow(fromPoint.y - toPoint.y, 2.0)
            var offset = maxOffset
            
            if pow(offset, 2.0) * 100.0 > lenSq {
                offset = sqrt(lenSq) / 10.0
            }
            self.offset = offset
            
            divergePoint = CGFloat(0.2 + FreehandLine.rand() * 0.2)
            
            
            let midpointDisplacement = CGPoint(x: CGFloat(maxOffset * (toPoint.y - fromPoint.y) / 200.0),
                                               y: CGFloat(maxOffset * (fromPoint.x - toPoint.x) / 200.0))
            
            self.midpointDisplacement = CGPoint(x: FreehandLine.offset(-midpointDisplacement.x, midpointDisplacement.x),
                                                y: FreehandLine.offset(-midpointDisplacement.y, midpointDisplacement.y))
        }
        
        public class func rand() -> CGFloat {
            return CGFloat(CGFloat(arc4random()) / CGFloat(UInt32.max))
        }
        
        public class func offset(_ min: CGFloat, _ max: CGFloat) -> CGFloat {
            return rand() * (max - min) + min
        }
    }
}
