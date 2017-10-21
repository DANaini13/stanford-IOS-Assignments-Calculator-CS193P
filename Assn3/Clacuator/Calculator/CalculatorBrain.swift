//
//  CalculatorBrain.swift
//  Clacuator
//
//  Created by zeyong shan on 10/4/17.
//  Copyright © 2017 zeyong shan. All rights reserved.
//

import Foundation

/**
 ClaculatorBrain is core of the claculator.
 - public functions:
 1. func setOperand(_ num: Double)
 2. func setOperand(variable named: String)
 3. func perfromOperator(_ symbol: String)
 4. func undo()
 5. func evaluate(using variables: Dictionary<String, Double>? = default) -> (result: Double?, isPending: Bool, description: String)
 - public variables
 1. result
 2. description
 */
public struct ClacualtorBrain {
    
    /**
     The variable that generate the description for calculatorBrain
     */
    private var descriptionGenerator = DescriptionGenerator()
    
    /**
     The abstract data type that stand for different operations:
     constant, generate number functions, unary operations,
     binaryOperations, and equal sign.
     */
    private enum Operation {
        case constant(Double)
        case unaryOperationPrefix((Double) -> Double)
        case unaryOperationPostfix((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equal
    }
    
    /**
     The abstract data type that defien the Operand
     - include:
         1. Ternimal: value, variable
         2. Non-ternimal: resultOfStep
     */
    private enum Operand {
        case value(Double)
        case resultOfStep(Int)
        case variable(String)
    }
    
    /**
     The abstract data type that define the Step.
     */
    private enum Step {
        case constantGrabing(value: Double, description: DescriptionGenerator)
        case unaryOperation(operation: (Double) -> Double, operand: Operand, description: DescriptionGenerator)
        case pendingBinaryOperation(operation: (Double, Double) -> Double, operand: Operand, description: DescriptionGenerator)
        case performBinaryOperation(pedingStep: (Int), secondOperand: Operand, description: DescriptionGenerator)
    }
    
    /**
     the variable that store the current Operand.
     */
    private var currentOperand: Operand?
    
    /**
     the variable that shows if the currentOperand has been reseted.
     */
    private var operandSet = false
    
    /**
     the variable that shows the pending step if there is a step are pending in the steps.
     */
    private var pendingStep: Int?
    
    /**
     an array to store every calculation steps
     */
    private var steps:[Step] = [] {
        didSet {
            guard steps.count != 0 else {
                descriptionGenerator = DescriptionGenerator()
                return
            }
            if case Step.pendingBinaryOperation = steps.last! {
                pendingStep = steps.count - 1
            }
            switch steps.last! {
            case .constantGrabing(_, let context):
                descriptionGenerator = context
            case .unaryOperation(_, _, let context):
                descriptionGenerator = context
            case .pendingBinaryOperation(_, _, let context):
                descriptionGenerator = context
            case .performBinaryOperation(_, _, let context):
                descriptionGenerator = context
            }
        }
    }

    /**
     operators is a dictionary that store the operations that would
     used in this calculator brain with string as keys. the operations
     include,"π", "e", "cos", "sin", "tan", "^2", "^3", "√", "±", "lg",
     "abs", "%", "rand", "+", "-", "×", "÷" and "="
     */
    private var operators: Dictionary<String, Operation> = [
        "π"     : Operation.constant(Double.pi),
        "e"     : Operation.constant(M_E),
        "cos"   : Operation.unaryOperationPrefix(cos),
        "sin"   : Operation.unaryOperationPrefix(sin),
        "tan"   : Operation.unaryOperationPrefix(tan),
        "^2"    : Operation.unaryOperationPostfix({pow($0, 2)}),
        "^3"    : Operation.unaryOperationPostfix({pow($0, 3)}),
        "√"     : Operation.unaryOperationPrefix(sqrt),
        "±"     : Operation.unaryOperationPrefix({-$0}),
        "lg"    : Operation.unaryOperationPrefix({log($0)}),
        "abs"   : Operation.unaryOperationPrefix(abs),
        "%"     : Operation.unaryOperationPostfix({$0/100}),
        "+"     : Operation.binaryOperation(+),
        "-"     : Operation.binaryOperation(-),
        "×"     : Operation.binaryOperation(*),
        "÷"     : Operation.binaryOperation(/),
        "="     : Operation.equal
    ]
    
    /**
     The computed properity that return a bool, which
     shows that if the current result is being pending
     */
    public var resultIsPending: Bool {
        return descriptionGenerator.resultIsPending
    }
    
    
    /**
     The function that set the operand (Double) to the calculatorBrain,
     either the fist or the second.
     
     - parameter num: the number that will replace the accumulator.
     - Author:
     Zeyong Shan
     - Important:
     This function will modify the accumulator
     - Version:
     0.1
     
     */
    public mutating func setOperand(_ num: Double) {
        let formattedValue:String
        let numberFormatter = NumberFormatter()
        if (num < 0 && num > -0.0000001) || (num > 0 && num < 0.0000001) || num > 1000000 || num < -1000000{
            numberFormatter.numberStyle = NumberFormatter.Style.scientific
        }else {
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
        }
        numberFormatter.maximumFractionDigits = 6
        let nsNumber: NSDecimalNumber = NSDecimalNumber(value: num)
        formattedValue = numberFormatter.string(from: nsNumber)!
        descriptionGenerator.addConstant(currentNum: formattedValue)
        currentOperand = Operand.value(num)
        operandSet = true
    }
    
    /**
     The function that set the operand (Double) to the calculatorBrain,
     either the fist or the second.
     
     - parameter num: the number that will replace the accumulator.
     - Author:
     Zeyong Shan
     - Important:
     This function will modify the accumulator
     - Version:
     0.1
     
     */
    public mutating func setOperand(variable named: String) {
        descriptionGenerator.addConstant(currentNum: named)
        currentOperand = Operand.variable(named)
        operandSet = true
    }
    
    /**
     The function will perform the operation that passed in.
     The new result would be replaced to public read-only
     property result.
     
     - parameter symbol: this parameter sotre the symbol of operation that will be done
     for this function.
     - Author:
     Zeyong Shan
     - Important:
     This function will modify the internel steps
     - Version:
     0.1
     */
    public mutating func perfromOperator(_ symbol: String) {
        guard let myOperator = operators[symbol] else {
            return
        }
        switch myOperator {
            
        case .constant(let value):
            descriptionGenerator.addConstant(currentNum: symbol)
            steps.append(Step.constantGrabing(value: value, description: descriptionGenerator))
            operandSet = true
        case .unaryOperationPrefix(let function):
            descriptionGenerator.addUnaryOperationToCurrentDescription(operation: symbol, prefix: true)
            if operandSet {
                steps.append(Step.unaryOperation(operation: function, operand: currentOperand!, description: descriptionGenerator))
            } else {
                guard steps.count != 0 else {
                    return
                }
                steps.append(Step.unaryOperation(operation: function, operand: Operand.resultOfStep(steps.count-1), description: descriptionGenerator))
            }
        case .unaryOperationPostfix(let function):
            descriptionGenerator.addUnaryOperationToCurrentDescription(operation: symbol, prefix: false)
            if operandSet {
                steps.append(Step.unaryOperation(operation: function, operand: currentOperand!, description: descriptionGenerator))
            } else {
                guard steps.count != 0 else {
                    return
                }
                steps.append(Step.unaryOperation(operation: function, operand: Operand.resultOfStep(steps.count-1), description: descriptionGenerator))
            }
        case .binaryOperation(let function):
            if pendingStep != nil {
                perfromOperator("=")
            }
            descriptionGenerator.addBinaryOperation(operation: symbol)
            if operandSet {
                steps.append(Step.pendingBinaryOperation(operation: function, operand: currentOperand!, description: descriptionGenerator))
            } else {
                guard steps.count != 0 else {
                    return
                }
                steps.append(Step.pendingBinaryOperation(operation: function, operand: Operand.resultOfStep(steps.count-1), description: descriptionGenerator))
            }
            pendingStep = steps.count - 1
        case .equal:
            guard pendingStep != nil && steps.count != 0 else {
                switch(currentOperand) {
                case .value(let value)? :
                    descriptionGenerator.addConstant(currentNum: String(value))
                    steps.append(Step.constantGrabing(value: value, description: descriptionGenerator))
                case .variable? :
                    descriptionGenerator.addUnaryOperationToCurrentDescription(operation: "", prefix: true)
                    steps.append(Step.unaryOperation(operation: {$0}, operand: currentOperand!, description: descriptionGenerator))
                default:
                    break
                }
                return
            }
            descriptionGenerator.performBinaryOperation()
            if operandSet {
                steps.append(Step.performBinaryOperation(pedingStep: pendingStep!, secondOperand: currentOperand!, description: descriptionGenerator))
            } else {
                steps.append(Step.performBinaryOperation(pedingStep: pendingStep!, secondOperand: Operand.resultOfStep(steps.count - 1), description: descriptionGenerator))
            }
            pendingStep = nil
        }
        operandSet = false
    }
    
    /**
     The function will perform the undo operation and update all the current information
     include: Description, Result, ResultIsPending
     
     - Author:
     Zeyong Shan
     - Important:
     This function will modify the internal steps.
     - Version:
     0.1
     */
    public mutating func undo() {
        guard steps.count != 0 else {
            return
        }
        steps.removeLast()
    }
    
    /**
     The public read-only property that return the current value of the calculator brain.
     */
    public var result: Double {
        return calculateResult(stepNum: steps.count - 1) ?? 0
    }
    
    /**
     The public read-only property that return the current description of the calculator brain.
     */
    public var description: String {
        return descriptionGenerator.description
    }
    
    /**
     The function get the result through all the stored operations.
     Start from the last step until hit terminals.
     
     - parameter variables: this is a dictionary that stores all the variables. For example ["x":5, "m":-1]
     This function will evaluate the result accroding to the dictionary that provided. If it didn't find
     the needed variables in the dictionary, then the value of those variabes will be set to zero.
     
     - returns:
         it will return a tuple that contains the result, isPending and the newest description.
     - Author:
     Zeyong Shan
     - Version:
     0.1
     */
    public func evaluate(using variables: Dictionary<String, Double>? = nil) ->
    (result: Double?, isPending: Bool, description: String) {
        let result = calculateResult(using: variables, stepNum: steps.count - 1)
        let isPending = pendingStep != nil
        return (result, isPending, description)
    }
    
    /**
     The function get the result through all the stored operations.
     Start from the last step until hit terminals.
     
     - parameter variables: this is a dictionary that stores all the variables. For example ["x":5, "m":-1]
     This function will evaluate the result accroding to the dictionary that provided. If it didn't find
     the needed variables in the dictionary, then the value of those variabes will be set to zero.
     - returns:
     it will return an Optional that store the calculated result.
     - Author:
     Zeyong Shan
     - Version:
     0.1
     */
    private func calculateResult(using variables: Dictionary<String, Double>? = nil, stepNum: Int) -> Double? {
        if stepNum >= steps.count || stepNum < 0 {
            return nil
        }
        switch steps[stepNum] {
        case .constantGrabing(let value, _):
            return value
        case .unaryOperation(let function, let operand, _):
            return function(calculateOperand(using: variables, operand: operand)!)
        case .pendingBinaryOperation:
            return calculateOperand(using: variables, operand: currentOperand ?? Operand.value(0))
        case .performBinaryOperation(let pendingStepNum, let operandSecond, _):
            if case let .pendingBinaryOperation(function, operandFirst, _) = steps[pendingStepNum] {
                let first  = calculateOperand(using: variables, operand: operandFirst)
                let second = calculateOperand(using: variables, operand: operandSecond)
                return function(first ?? 0, second ?? 0)
            }
            return 0
        }
    }
    
    /**
     The function is the helper function for calculateResult(...) This function will see if the operand is
     
     - parameters:
         - variables:
             this is a dictionary that stores all the variables. For example ["x":5, "m":-1]
             This function will evaluate the result accroding to the dictionary that provided. If it didn't find
             the needed variables in the dictionary, then the value of those variabes will be set to zero.
         - operand:
             to store the operand that will be calclated.
     - returns:
     it will return an Optional that store the calculated result.
     - Author:
     Zeyong Shan
     - Version:
     0.1
     */
    private func calculateOperand(using variables: Dictionary<String, Double>? = nil, operand: Operand) -> Double? {
        switch operand {
        case .value(let value):
            return value
        case .resultOfStep(let stepNum):
            return calculateResult(using: variables, stepNum: stepNum)
        case .variable(let name):
            let value = variables?[name] ?? 0
            return value
        }
    }
    
}










