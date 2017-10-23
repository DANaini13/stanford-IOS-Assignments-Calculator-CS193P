//
//  ViewController.swift
//  Clacuator
//
//  Created by zeyong shan on 10/4/17.
//  Copyright © 2017 zeyong shan. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, UISplitViewControllerDelegate {
    
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
    
    
    @IBOutlet private weak var mDisplay: UILabel!
    
    
    private var brain = ClacualtorBrain()
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var destinationViewController = segue.destination
        if let negivationController = destinationViewController as? UINavigationController {
            destinationViewController = negivationController.visibleViewController ?? destinationViewController
        }
        if let graphViewController = destinationViewController as? GraphViewController {
            graphViewController.calculatorViewController = self
        }
    }
    
    
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
            if let number = Double(display.text!) {
                return number
            }
            return Double.nan
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        splitViewController!.delegate = self
        splitViewController!.view.isOpaque = false
        splitViewController!.view.backgroundColor = UIColor.clear
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
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
        displayValue = result ?? displayValue
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
        if !userInTheMiddleOfInput {
            display.text = "0."
            userInTheMiddleOfInput = true
            userInTheDot = true
            return
        }else {
            if userInTheDot {
                return
            }
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
        userInTheMiddleOfInput = true
        if display.text! == "" {
            brain.undo()
            let (result, _, description) = brain.evaluate(using: variables)
            displayValue = result ?? 0
            descriptionDisplay.text = description
            userInTheMiddleOfInput = false
            userInTheDot = false
            return
        }
        display.text?.removeLast()
    }
    
    /**
     the dictionary that store the variable names and their value.
     */
    private var variables: Dictionary<String, Double> = Dictionary() {
        didSet {
            if let value = variables["M"] {
                mDisplay.text = "M: " + String(value)
            }else {
                mDisplay.text = "M: "
            }
        }
    }

    /**
     The function to set a new variable into the dictionary.
     - parameter sender: the button that will response to.
     - Author: Zeyong Shan.
     - Version: 0.1
     */
    @IBAction private func setNewMValue(_ sender: UIButton) {
        let variableName = "M"
        variables[String(variableName)] = displayValue
        let (result, _, description) = brain.evaluate(using: variables)
        displayValue = result ?? 0
        descriptionDisplay.text = description
        userInTheMiddleOfInput = false
        userInTheDot = false
    }
    
    /**
     The function to set a new variable into the dictionary.
     - parameter sender: the button that will response to.
     - Author: Zeyong Shan.
     - Version: 0.1
     */
    @IBAction private func setValue(_ sender: UIButton) {
        brain.setOperand(variable: sender.currentTitle!)
        display.text = sender.currentTitle
        userInTheMiddleOfInput = false
        userInTheDot = false
    }
    
    /**
     the function that generateRandomNumber
     - parameter sender: the button that touched
     - Author: Zeyong Shan
     - Version: 0.1
     */
    @IBAction private func generateRandomNumber(_ sender: UIButton) {
        displayValue = Double(arc4random()) / Double(UINT32_MAX)
        userInTheMiddleOfInput = true
        userInTheDot = true
    }
    
    /**
     The function that used to request result by code.
     
     - parameter getVauleThrough: the variable value that used to get the result
     of the whole expression.
     - returns:
         return the result of the expression form the variable.
     - Author: Zeyong Shan
     - Version: 0.1
     */
    func getYFromX(getValueThrough x:Double) -> Double? {
        variables["M"] = x
        let (result, _, _) = brain.evaluate(using: variables)
        return result
    }
    
}


