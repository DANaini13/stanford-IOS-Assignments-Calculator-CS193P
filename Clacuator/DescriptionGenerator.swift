//
//  DescriptionGenerator.swift
//  Clacuator
//
//  Created by zeyong shan on 10/6/17.
//  Copyright © 2017 zeyong shan. All rights reserved.


import Foundation
/**
 struct name: DescriptionGenerator
 the descriptionGenerator is used to add, modify the descriptioons for calculator brain.
 **/
public struct DescriptionGenerator {


    public mutating func addConstant(currentNum: String) {
        context = currentNum
    }
    
    public mutating func addUnaryOperationToCurrentDescription(operation: String, prefix: Bool, currentNum: String) {
        if context == nil {
            context = currentNum
        }
        if prefix {
            context =  operation + "(" + context! + ")"
        }else {
            context =  "(" + context! + ")" + operation
        }
    }
    
    public mutating func addBinaryOperation(operation: String, firstNum: String, replace: Bool) {
        guard pendingBinaryOperation == nil else {
            return
        }
        if replace || context == nil{
            context = firstNum
        }
        pendingBinaryOperation = PendingBinaryOperation(operatorName: operation, firstOperand: context!)
        context = nil
    }
    
    public mutating func performBinaryOperation(secondNum: String) {
        guard pendingBinaryOperation != nil else {
            return
        }
        if context == nil {
            context = secondNum
        }
        context = pendingBinaryOperation!.generationString(secondOperand: context!)
        pendingBinaryOperation = nil
    }
    
    var description: String {
        let returnValue:String
        if let pending = pendingBinaryOperation {
            if context != nil {
                returnValue = pending.contextBeforeGenerating + context! + "..."
            } else {
                returnValue =  pending.contextBeforeGenerating + "..."
            }
        }else {
            if context != nil {
                returnValue =  context!
            } else {
                returnValue =  ""
            }
        }
        return returnValue
    }
    
    private var context: String?
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let operatorName: String
        let firstOperand: String
        
        var contextBeforeGenerating: String {
            return firstOperand + operatorName
        }
        
        public func generationString(secondOperand: String) -> String {
            return firstOperand + operatorName + secondOperand
        }
    }
}


