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
 1. func readyToReplaceTheDescription()
 2. func setOperand(_ num: Double)
 3. func performOperation(_ symbol: String)
 - public variables
 1. result
 2. description
 */
public struct ClacualtorBrain {
    
    /**
     The variable to store the current accummulate value.
     */
    private var accummulator: Double?
    
    /**
     The computed property for accummulator that return the string version that
     formatted by numberFormatter. return "0" if the accummulator is nil
     */
    private var stringForAccummulator: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.alwaysShowsDecimalSeparator = false
        numberFormatter.maximumFractionDigits = 6
        let nsNumber: NSDecimalNumber = NSDecimalNumber(value: accummulator ?? 0)
        numberFormatter.string(from: nsNumber)
        return numberFormatter.string(from: nsNumber)!
    }
    
    /**
     The variable that store the information of the first half binary operation.
     */
    private var pendingBinaryOperator: PendingBinaryOperation?
    
    /**
     The variable that generate the description for calculator
     */
    private var descriptionGenerator: DescriptionGenerator = DescriptionGenerator()
    
    /**
     The abstract data type that stand for different operations:
     constant, generate number functions, unary operations,
     binaryOperations, and equal sign.
     */
    private enum Operation {
        case constant(Double)
        case generateNumberFunction(() -> Double)
        case unaryOperationPrefix((Double) -> Double)
        case unaryOperationPostfix((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equal
    }
    /**
     The data type that store the fist half the a binary operation
     - public functions:
     1. performOperation(_ numerb2: Double) -> Double
     */
    private struct PendingBinaryOperation {
        
        let number: Double
        let function: ((Double, Double) -> Double)
        
        public func performOperation(_ number2: Double) -> Double {
            return function(number, number2)
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
        "rand"  : Operation.generateNumberFunction({Double(arc4random()) / Double(UINT32_MAX)}),
        "+"     : Operation.binaryOperation(+),
        "-"     : Operation.binaryOperation(-),
        "×"     : Operation.binaryOperation(*),
        "÷"     : Operation.binaryOperation(/),
        "="     : Operation.equal
    ]
    
    /**
     The variable that shows that if the bianary operation should replace the first
     number as the current accumulaor
     */
    private var replaceDescription = false
    
    /**
     The computed properity that return a bool, which
     shows that if the current result is being pending
     */
    public var resultIsPending: Bool {
        return pendingBinaryOperator != nil
    }
    
    /**
     The function that set the operand to the calculatorBrain,
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
        accummulator = num
    }
    
    /**
     The function that make calculator brain ready to
     replace the current decsription with the new operation and
     operand.
     
     - Author:
     Zeyong Shan
     - Version:
     0.1
     
     */
    public mutating func readyToReplaceDescription() {
        replaceDescription = true
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
     This function will modify the accumulator.
     - Version:
     0.1
     */
    public mutating func perfromOperator(_ symbol: String) {
        guard let myOperator = operators[symbol] else {
            return
        }
        if accummulator == nil {
            accummulator = 0
        }
        
        switch myOperator {
        case Operation.constant(let value):
            descriptionGenerator.addConstant(currentNum: symbol)
            accummulator = value
            
        case Operation.unaryOperationPostfix(let function):
            descriptionGenerator.addUnaryOperationToCurrentDescription(operation: symbol, prefix: false, currentNum: stringForAccummulator)
            accummulator = function(accummulator!)
            
        case Operation.unaryOperationPrefix(let function):
            descriptionGenerator.addUnaryOperationToCurrentDescription(operation: symbol, prefix: true, currentNum: stringForAccummulator)
            accummulator = function(accummulator!)
            
        case Operation.binaryOperation(let function):
            if pendingBinaryOperator != nil {
                perfromOperator("=")
            }
            descriptionGenerator.addBinaryOperation(operation: symbol, firstNum: stringForAccummulator, replace: replaceDescription)
            pendingBinaryOperator = PendingBinaryOperation(number: accummulator!, function: function)
            
        case Operation.equal :
            guard pendingBinaryOperator != nil else {
                descriptionGenerator.addConstant(currentNum: stringForAccummulator)
                return
            }
            descriptionGenerator.performBinaryOperation(secondNum: stringForAccummulator)
            accummulator = pendingBinaryOperator!.performOperation(accummulator!)
            pendingBinaryOperator = nil
            
        case Operation.generateNumberFunction(let function):
            accummulator = function()
            descriptionGenerator.addConstant(currentNum: stringForAccummulator)
        }
        
        replaceDescription = false
    }
    
    /**
     The public read-only property that return the current value of the calculator brain.
     */
    public var result: Double {
        return accummulator == nil ? 0 : accummulator!
    }
    
    /**
     The public read-only property that return the current description of the calculator brain.
     */
    public var description: String {
        return descriptionGenerator.description
    }
}



