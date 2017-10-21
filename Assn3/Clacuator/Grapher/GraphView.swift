//
//  GraphView.swift
//  Clacuator
//
//  Created by zeyong shan on 10/17/17.
//  Copyright © 2017 zeyong shan. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    @IBInspectable
    var scale:CGFloat                   = 0.05        { didSet { setNeedsDisplay() } }
    
    var moveOriginPointTo:CGPoint? { didSet { setNeedsDisplay() } }
    
    private var generatedPointsNumber:Int = 999
    
    var origin: CGPoint {
        if moveOriginPointTo != nil {
            return moveOriginPointTo!
        }
        let centerInView = convert(center, from: superview)
        let offset:CGFloat = 20
        switch originPosition {
        case .center:
            return centerInView
        case .leftDown:
            return CGPoint(x: centerInView.x - self.bounds.midX, y: centerInView.y + self.bounds.midY - offset)
        case .leftUp:
            let centerInView = convert(center, from: superview)
            return CGPoint(x: centerInView.x - self.bounds.midX, y: centerInView.y - self.bounds.midY)
        case .rightDown:
            let centerInView = convert(center, from: superview)
            return CGPoint(x: centerInView.x + self.bounds.midX - offset, y: centerInView.y + self.bounds.midY - offset)
        case .rightUp:
            let centerInView = convert(center, from: superview)
            return CGPoint(x: centerInView.x + self.bounds.midX - offset, y: centerInView.y - self.bounds.midY)
        }
    }
    
    var originPosition:originPositionType = .center
    
    enum originPositionType {
        case center
        case leftDown
        case rightDown
        case rightUp
        case leftUp
    }
    
    @IBInspectable
    var axesColor:UIColor               = UIColor.white
    
    @IBInspectable
    var lineColor:UIColor               = UIColor.orange
    
    var curvePoints:[CGPoint]           = []       { didSet { setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        drawAxes()
        drawFunction(rect)
    }
    
    
    @objc
    func getDestributionPoints() -> [CGFloat] {
        var x = self.bounds.minX
        let width = (self.bounds.maxX - self.bounds.minX) / CGFloat(generatedPointsNumber)
        var result:[CGFloat] = []
        var i = 0
        while x < self.bounds.maxX {
            if i >= generatedPointsNumber {
                break
            }
            let mathPoint = translateToMath(target: CGPoint(x: x, y: 0))
            result.append(mathPoint.x)
            x += width
            i += 1
        }
        return result
    }
    
    private func drawAxes() {
        let rect = self.bounds
        axesDrawer.color = axesColor
        axesDrawer.drawAxes(in: rect, origin: origin, pointsPerUnit: scale * 17)
    }
    
    private var axesDrawer = AxesDrawer()
    
    private func drawFunction(_ rect: CGRect) {
        guard curvePoints.count == generatedPointsNumber else {
            return
        }
        var index: Int = 0
        while index < generatedPointsNumber - 3 {
            let start = translateToGraph(target: curvePoints[index])
            let end   = translateToGraph(target: curvePoints[index + 3])
            let cp1   = translateToGraph(target: curvePoints[index + 1])
            let cp2   = translateToGraph(target: curvePoints[index + 2])
            
            if start.y == CGFloat.nan || end.y == CGFloat.nan
                || cp1.y == CGFloat.nan || cp2.y == CGFloat.nan{
                    index += 3
                    continue
            }
            let path  = UIBezierPath()
            if abs(slope(from: start, to: end)) > 999 {
                path.lineWidth = 0.1
            }else {
                path.lineWidth = 1
            }
            path.move(to: start)
            path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
            lineColor.set()
            path.stroke()
            index += 3
        }

    }
    
    private func distance(from a:CGPoint, to b:CGPoint) -> CGFloat {
        return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    }
    
    private func slope(from a:CGPoint, to b:CGPoint) -> CGFloat {
        return (a.y - b.y)/(a.x - b.x)
    }
    
    private func translateToGraph(target: CGPoint) -> CGPoint {
        let originPoint = origin
        let x = target.x
        let y = target.y
        return CGPoint(x: (originPoint.x) + 17 * scale * x, y: (originPoint.y) - 17 * scale * y)
    }
    
    private func translateToMath(target: CGPoint) -> CGPoint {
        let originPoint = origin
        let x = target.x
        let y = target.y
        return CGPoint(x: (x - originPoint.x) / (17 * scale), y: -(y - originPoint.y) / (17 * scale))
    }
    
    private func translateLengthToMath(target: CGFloat) -> CGFloat {
        return target / (17 * scale)
    }

}








