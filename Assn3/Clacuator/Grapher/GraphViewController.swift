//
//  GraphViewController.swift
//  Clacuator
//
//  Created by zeyong shan on 10/17/17.
//  Copyright © 2017 zeyong shan. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        updateUI()
    }
    
    @IBOutlet private weak var graphView: GraphView! {
        didSet {
            let pinchHandler = #selector(changeScale(byReactingTo:))
            let pinchRecongnizer = UIPinchGestureRecognizer(target: self, action: pinchHandler)
            graphView.addGestureRecognizer(pinchRecongnizer)
            
            let panHandler = #selector(self.changePosition(byReactingTo:))
            let panRecongnizer = UIPanGestureRecognizer(target: self, action: panHandler)
            graphView.addGestureRecognizer(panRecongnizer)
            updateUI()
        }
    }
    
    var calculatorViewController: CalculatorViewController?
    
    private func updateUI() {
        if let calculator = calculatorViewController,
            let xForPoints = graphView?.getDestributionPoints(){
            var curvePoints: [CGPoint] = []
            for x in xForPoints {
                let result = calculator.getYFromX(getValueThrough: Double(x));
                curvePoints.append(CGPoint(x: x, y: CGFloat(result ?? Double(CGFloat.nan))))
            }
            graphView.curvePoints = curvePoints
        }
    }
    
    @objc
    private func changePosition(byReactingTo panGestureRecongnizer: UIPanGestureRecognizer) {
        guard graphView != nil else {
            return
        }
        switch panGestureRecongnizer.state {
        case .began:
            pendingMovement.firstTouchedLocation = panGestureRecongnizer.location(in: graphView)
        case .changed:
            let changedLocation = panGestureRecongnizer.location(in: graphView)
            let finalLocation = pendingMovement.performPendingMovement(endTouchedLocation: changedLocation, originalPoint: graphView!.origin)
            graphView.moveOriginPointTo = finalLocation
            pendingMovement.firstTouchedLocation = changedLocation
        case .ended:
            let changedLocation = panGestureRecongnizer.location(in: graphView)
            let finalLocation = pendingMovement.performPendingMovement(endTouchedLocation: changedLocation, originalPoint: graphView!.origin)
            graphView.moveOriginPointTo = finalLocation
            pendingMovement.firstTouchedLocation = nil
        default:
            return
        }
        updateUI()
    }
    
    @objc
    private func changeScale(byReactingTo pinchReconginzer: UIPinchGestureRecognizer) {
        switch pinchReconginzer.state {
        case .changed, .ended:
            graphView.scale *= pinchReconginzer.scale
            pinchReconginzer.scale = 1
        default:
            break
        }
        updateUI()
    }
    
    private var pendingMovement = PendingMovement()
    
    private struct PendingMovement {
        var firstTouchedLocation:CGPoint?
        func performPendingMovement(endTouchedLocation: CGPoint, originalPoint: CGPoint) -> CGPoint? {
            if let first = firstTouchedLocation{
                let movedX = endTouchedLocation.x - first.x
                let movedY = endTouchedLocation.y - first.y
                return CGPoint(x: originalPoint.x + movedX, y: originalPoint.y + movedY)
            }
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
