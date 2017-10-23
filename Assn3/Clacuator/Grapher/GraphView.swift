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
    
    /**
     The variable that store the scale of the whole graph view
     */
    @IBInspectable
    var scale:CGFloat                     = 0.05        { didSet { setNeedsDisplay() } }
    
    /**
     The next origin point
     */
    var moveOriginPointTo:CGPoint? { didSet { setNeedsDisplay() } }
    
    /**
     The points number that will be generate on the view
     The quality of the graph
     */
    private var generatedPointsNumber:Int = 999
    
    /**
     The read-only calculated variable. return the origin's poistion on the view
     */
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
    
    /**
     The variable that store the position type of the origin point of the axis.
     include: center, leftDown, rightDown, rightUp and leftUp
     */
    var originPosition:originPositionType = .center
    
    /**
     The enum of the origin position
     */
    enum originPositionType {
        case center
        case leftDown
        case rightDown
        case rightUp
        case leftUp
    }
    
    /**
     The color of the axes.
     */
    @IBInspectable
    var axesColor:UIColor               = UIColor.white
   
    /**
     The color of the function graph
     */
    @IBInspectable
    var lineColor:UIColor               = UIColor.orange
    
    /**
     The Points that will be generated on the graph view
     */
    var curvePoints:[CGPoint]           = []       { didSet { setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        drawAxes()
        drawFunction(rect)
    }
    
    /**
     The function that generate the x coordinate of the points
     on the screen

     - returns:
         This function will return a array of CGFloat that store the x coordinates of the graph picture
     - Author:
     Zeyong Shan
     - Version:
     0.1
     
     */
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
    
    /**
     The function will draw the graph of the Axes.
     
     - Author:
     Zeyong Shan
     - Version:
     0.1
     
     */
    private func drawAxes() {
        let rect = self.bounds
        var axesDrawer = AxesDrawer()
        axesDrawer.color = axesColor
        axesDrawer.drawAxes(in: rect, origin: origin, pointsPerUnit: scale * 17)
    }
    
    /**
     This function will draw the graph of function.
     It would make the lineWidth become thinner if the slope
     of the line is larger than 999 or less than -999, to hide the line of unexist points.
     - parameter rect: the CGRect that will be draw into.

     - Author:
         Zeyong Shan
     - Version:
         0.1
     */
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
    
    /**
     This function will calculate the distance between two points.
     - parameters:
         - from: the first point that used to calculate the distance
         - to: the second point to calculate the distance
     - returns:
         this function return a CGFloat to store the calculate result.
     - Author:
     Zeyong Shan
     - Version:
     0.1
     */
    private func distance(from a:CGPoint, to b:CGPoint) -> CGFloat {
        return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    }
    
    /**
     This function will calculate the slope a straight line that cross the
     two points that passed in.
     - parameters:
         - from: the first point that used to calculate the slope
         - to: the second point to calculate the slope
     - returns:
     this function return a CGFloat to store the calculate result.
     - Author:
     Zeyong Shan
     - Version:
     0.1
     */
    private func slope(from a:CGPoint, to b:CGPoint) -> CGFloat {
        return (a.y - b.y)/(a.x - b.x)
    }
    
    /**
     This function will translate the position of point in the math axies to the
     position on the view.
     - parameter target: the parameter that will be translated
     - returns:
     this function return a CGPoint to store the calculate result.
     - Author:
     Zeyong Shan
     - Version:
     0.1
     */
    private func translateToGraph(target: CGPoint) -> CGPoint {
        let originPoint = origin
        let x = target.x
        let y = target.y
        return CGPoint(x: (originPoint.x) + 17 * scale * x, y: (originPoint.y) - 17 * scale * y)
    }
    
    /**
     This function will translate the position of point in the view to the
     position in the math axies.
     - parameter target: the parameter that will be translated
     - returns:
     this function return a CGPoint to store the calculate result.
     - Author:
     Zeyong Shan
     - Version:
     0.1
     */
    private func translateToMath(target: CGPoint) -> CGPoint {
        let originPoint = origin
        let x = target.x
        let y = target.y
        return CGPoint(x: (x - originPoint.x) / (17 * scale), y: -(y - originPoint.y) / (17 * scale))
    }
    
    /**
     This function will translate the length in the view to the
     length in the math axies.
     - parameter target: the parameter that will be translated
     - returns:
     this function return a CGFloat to store the calculate result.
     - Author:
     Zeyong Shan
     - Version:
     0.1
     */
    private func translateLengthToMath(target: CGFloat) -> CGFloat {
        return target / (17 * scale)
    }

}








