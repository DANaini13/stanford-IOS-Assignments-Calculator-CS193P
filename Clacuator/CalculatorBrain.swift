//
//  CalculatorBrain.swift
//  Clacuator
//
//  Created by zeyong shan on 10/4/17.
//  Copyright © 2017 zeyong shan. All rights reserved.
//

import Foundation

public struct ClacualtorBrain {
    
    private var accummulator: Double?
    private var strAccummulator: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.alwaysShowsDecimalSeparator = false
        numberFormatter.maximumFractionDigits = 6
        let nsNumber: NSDecimalNumber = NSDecimalNumber(value: accummulator ?? 0)
        numberFormatter.string(from: nsNumber)
        return numberFormatter.string(from: nsNumber)!
    }
    private var pendingBinaryOperator: PendingBinaryOperation?
    private var descriptionGenerator: DescriptionGenerator = DescriptionGenerator()
    
    private enum Operation {
        case constant(Double)
        case generateNumberFunction(() -> Double)
        case unaryOperationPrefix((Double) -> Double)
        case unaryOperationPostfix((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equal
    }
    
    private struct PendingBinaryOperation {
        
        let number: Double
        let function: ((Double, Double) -> Double)
        
        public func performOperation(_ number2: Double) -> Double {
            return function(number, number2)
        }
        
    }
    
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
    
    private var replaceDescription = false
    
    var resultIsPending: Bool {
        return pendingBinaryOperator != nil
    }
    
    public mutating func setOperand(_ num: Double) {
        accummulator = num
    }
    
    public mutating func readyToReplaceDescription() {
        replaceDescription = true
    }
    
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
            descriptionGenerator.addUnaryOperationToCurrentDescription(operation: symbol, prefix: false, currentNum: strAccummulator)
            accummulator = function(accummulator!)
            
        case Operation.unaryOperationPrefix(let function):
            descriptionGenerator.addUnaryOperationToCurrentDescription(operation: symbol, prefix: true, currentNum: strAccummulator)
            accummulator = function(accummulator!)
            
        case Operation.binaryOperation(let function):
            if pendingBinaryOperator != nil {
                perfromOperator("=")
            }
            descriptionGenerator.addBinaryOperation(operation: symbol, firstNum: strAccummulator, replace: replaceDescription)
            pendingBinaryOperator = PendingBinaryOperation(number: accummulator!, function: function)
            
        case Operation.equal :
            guard pendingBinaryOperator != nil else {
                descriptionGenerator.addConstant(currentNum: strAccummulator)
                return
            }
            descriptionGenerator.performBinaryOperation(secondNum: strAccummulator)
            accummulator = pendingBinaryOperator!.performOperation(accummulator!)
            pendingBinaryOperator = nil
            
        case Operation.generateNumberFunction(let function):
            accummulator = function()
            descriptionGenerator.addConstant(currentNum: strAccummulator)
        }
        
        replaceDescription = false
    }
    
    public var result: Double {
        return accummulator == nil ? 0 : accummulator!
    }
    
    public var description: String {
        return descriptionGenerator.description
    }
}



