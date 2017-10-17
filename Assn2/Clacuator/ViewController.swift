//
//  ViewController.swift
//  Clacuator
//
//  Created by zeyong shan on 10/4/17.
//  Copyright © 2017 zeyong shan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    /**
     The property that control the descrition display screen in the top of the view
     */
    @IBOutlet weak private var descriptionDisplay: UILabel!
    /**
     The property that control the display screen in the top of the view
     */
    @IBOutlet weak private var display: UILabel!
    /**
     The private variable that show that if the user is in the middle of the input.
     */
    private var userInTheMiddleOfInput = false
    /**
     The private variable that show that if there are already dot in the scree.
     */
    private var userInTheDot           = false
    /**
     The calculator brain that store all the calculation operations for the calculator.
     */
    
    
    @IBOutlet weak var mDisplay: UILabel!
    
    
    private var brain = ClacualtorBrain()
    /**
     The camputed value to display on the display screen
     to the Double.
     - get:
     returns a double that converted from display.text, return 0.0 if the display.text is nil
     - set:
     use number formatter to store the double into the display screen.
     */
    private var displayValue:Double {
        set {
            let numberFormatter = NumberFormatter()
            if (newValue < 0 && newValue > -0.0000001) || (newValue > 0 && newValue < 0.0000001) || newValue > 1000000 || newValue < -1000000{
                numberFormatter.numberStyle = NumberFormatter.Style.scientific
            }else {
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
            }
            numberFormatter.maximumFractionDigits = 6
            let nsNumber: NSDecimalNumber = NSDecimalNumber(value: newValue)
            numberFormatter.string(from: nsNumber)
            if newValue >= Double.infinity || newValue <= -.infinity{
                display.text = "Error"
                return
            }
            display.text = numberFormatter.string(from: nsNumber)
        }
        get {
            return Double(display.text ?? "Error")!
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
    
    /**
     The function that response the 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 buttons
     on the view.
     
     - parameter sender: the UIButton that call this function.
     - Author:
     Zeyong Shan
     - Version:
     0.1
     
     */
    @IBAction private func touchDigit(_ sender: UIButton) {
        if userInTheMiddleOfInput {
            display.text = display.text! + sender.currentTitle!
        } else {
            display.text = sender.currentTitle!
            userInTheMiddleOfInput = true
        }
        if !brain.resultIsPending {
     //       brain = ClacualtorBrain()
        }
    }
    
    /**
     The function that response the buttons that contains the operators.
     on the view.
     
     - parameter sender: the UIButton that call this function.
     - Author:
     Zeyong Shan
     - Version:
     0.1
     
     */
    @IBAction private func touchOperand(_ sender: UIButton) {
        if userInTheMiddleOfInput {
            brain.setOperand(displayValue)
            userInTheMiddleOfInput = false
        }
        brain.perfromOperator(sender.currentTitle!)
        let (result, _, description) = brain.evaluate(using: variables)
        displayValue = result ?? 0
        descriptionDisplay.text = description
        userInTheDot = false
    }
    
    /**
     The function that response to the "AC" button. it will clean all
     the display constext and refresh the status of the calculator.
     
     - parameter sender: the UIButton that call this function.
     - Author:
     Zeyong Shan
     - Important:
     This function will never use the sender parameter.
     - Version:
     0.1
     
     */
    @IBAction private func allClear(_ sender: UIButton) {
        brain = ClacualtorBrain()
        display.text = "0"
        userInTheMiddleOfInput = false
        userInTheDot = false
        descriptionDisplay.text = " "
        variables = Dictionary()
    }
    
    /**
     The function that response the "." button. it will set a
     dot in the display screen if there is no dot on the screen.
     
     - parameter sender: the UIButton that call this function.
     - Author:
     Zeyong Shan
     - Important:
     This function will never use the sender parameter.
     - Version:
     0.1
     
     */
    @IBAction private func touchDot(_ sender: UIButton) {
        if userInTheDot {
            return
        }
        if !userInTheMiddleOfInput {
            display.text = "0."
            userInTheMiddleOfInput = true
            userInTheDot = true
            return
        }else {
            display.text = display.text! + "."
        }
        userInTheDot = true
    }
    
    /**
     The function that response the backspace buttons. it will delete
     a character form the display.text and if would left a "0" if
     the string is empty
     
     - parameter sender: the UIButton that call this function.
     - Author:
     Zeyong Shan
     - Important:
     This function will never use the sender parameter.
     - Version:
     0.1
     
     */
    @IBAction private func touchBackspace(_ sender: UIButton) {
        display.text?.removeLast()
        userInTheMiddleOfInput = true
        if display.text! == "" {
            brain.undo()
            let (result, _, description) = brain.evaluate(using: variables)
            displayValue = result ?? 0
            descriptionDisplay.text = description
            userInTheMiddleOfInput = false
        }
    }
    
    private var variables: Dictionary<String, Double> = Dictionary() {
        didSet {
            if let value = variables["M"] {
                mDisplay.text = "M: " + String(value)
            }else {
                mDisplay.text = "M: "
            }
        }
    }

    @IBAction func setNewMValue(_ sender: UIButton) {
        let variableName = sender.currentTitle!.last!
        variables[String(variableName)] = displayValue
        let (result, _, description) = brain.evaluate(using: variables)
        displayValue = result ?? 0
        descriptionDisplay.text = description
        userInTheMiddleOfInput = false
    }
    
    @IBAction func setValue(_ sender: UIButton) {
        brain.setOperand(variable: sender.currentTitle!)
        display.text = sender.currentTitle
        userInTheMiddleOfInput = false
    }
    
    @IBAction func generateRandomNumber(_ sender: UIButton) {
        displayValue = Double(arc4random()) / Double(UINT32_MAX)
    }
    
}


