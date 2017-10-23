//
//  GraphViewController.swift
//  Clacuator
//
//  Created by zeyong shan on 10/17/17.
//  Copyright © 2017 zeyong shan. All rights reserved.
//

import UIKit


/**
 The viewController for the graphView
 */
class GraphViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        updateUI()
    }
    
    /**
     This is the graph view that display the function graph and Axies.
     It contains two gestureRecongizer: pinchGestureRecongizer and panGestureRecongizer.
     It will auto update UI after initialize.
     */
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
    
    /**
     The reference of the calculatorViewController that will be set from the segue.
     */
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
    
    /**
     The handler that will response to the PanGestureRecongnizer. it will keep the graph movement sync with the finger movement
     - parameter byReactingTo: store the panGestureRecongnizer.
     - Author: Zeyong Shan
     - Version: 0.1
     - Important: this function will modified the state of the graph view.
     */
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
    
    /**
     The handler that will response to the pinchRecongnizer. It will modify the scale of the graphView to follow the finger movement.
     - parameter byReactingTo: store the pinchGestureRecongnizer.
     - Author: Zeyong Shan
     - Version: 0.1
     - Important: this function will modified the state of the graph view.
     */
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
    
    /**
     The variable that store the first touch point of the panGestureRecongnizer and perform later.
     */
    private var pendingMovement = PendingMovement()
    
    /**
     The stuct that used to help perform the pan gesture movement.
     */
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
