//
//  ViewController.swift
//  Clacuator
//
//  Created by zeyong shan on 10/4/17.
//  Copyright © 2017 zeyong shan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak private var descriptionDisplay: UILabel!
    @IBOutlet weak private var display: UILabel!
    private var userInTheMiddleOfInput = false
    private var userInTheDot           = false
    private var brain = ClacualtorBrain()
    private var displayValue:Double {
        set {
            let numberFormatter = NumberFormatter()
            numberFormatter.alwaysShowsDecimalSeparator = false
            numberFormatter.maximumFractionDigits = 6
            let nsNumber: NSDecimalNumber = NSDecimalNumber(value: newValue)
            numberFormatter.string(from: nsNumber)
            display.text = numberFormatter.string(from: nsNumber)
        }
        get {
            return Double(display.text ?? "0")!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        if userInTheMiddleOfInput {
            display.text = display.text! + sender.currentTitle!
        } else {
            display.text = sender.currentTitle!
            userInTheMiddleOfInput = true
        }
        brain.readyToReplaceDescription()
    }
    
    @IBAction private func touchOperand(_ sender: UIButton) {
        if userInTheMiddleOfInput {
            brain.setOperand(displayValue)
            userInTheMiddleOfInput = false
        }
        brain.perfromOperator(sender.currentTitle!)
        displayValue = brain.result
        if brain.resultIsPending {
            descriptionDisplay.text = brain.description
        } else {
            descriptionDisplay.text = brain.description + "="
        }
        userInTheDot = false
    }
    
    @IBAction private func allClear(_ sender: UIButton) {
        brain = ClacualtorBrain()
        display.text = "0"
        userInTheMiddleOfInput = false
        userInTheDot = false
        descriptionDisplay.text = "Description"
    }
    
    @IBAction private func touchDot(_ sender: UIButton) {
        if userInTheDot {
            return
        }
        if !userInTheMiddleOfInput {
            display.text = "."
            userInTheMiddleOfInput = true
            return
        }
        display.text = display.text! + "."
        userInTheDot = true
    }
    
    @IBAction private func touchBackspace(_ sender: UIButton) {
        brain.readyToReplaceDescription()
        display.text?.removeLast()
        userInTheMiddleOfInput = true
        if display.text! == "" {
            display.text = "0"
        }
    }
    
}


