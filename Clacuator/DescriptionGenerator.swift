//
//  DescriptionGenerator.swift
//  Clacuator
//
//  Created by zeyong shan on 10/6/17.
//  Copyright © 2017 zeyong shan. All rights reserved.


import Foundation
/**
 DescriptionGenerator
 the descriptionGenerator is used to add, modify the descriptioons for calculator brain.
 */
public struct DescriptionGenerator {
    
    /**
     This function is used to replace the current Description with the argument
     that passed in. Workd with the case Operation.constant and case Operation.generateNumberFunction
     
     - parameter currentNum: store the constant that will replace the current Description. Ex. pi, 790
     - Author:
     Zeyong Shan
     - Important:
     This function might modify the context of the description.
     - Version:
     0.1
     */
    
    public mutating func addConstant(currentNum: String) {
        context = currentNum
    }
    
    
    /**
     This function is used to add a unary operation to description.
     It will sotre the first number that will take part in the
     operation to the data structure first then waiting for the second
     number to finish the operation.
     
     - parameters:
     - operation:
     The variable that store the function name as a string.
     - prefix:
     To declare that the function should be prefixed or postfixed.
     - currentNum:
     The number that used to take part into the operation.
     - Author:
     Zeyong Shan
     - Important:
     This function might modify the context of the description.
     - Version:
     0.1
     
     */
    
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
    
    /**
     This function is used to add a binary operation to description.
     It will sotre the first number that will take part in the
     operation to the data structure first then waiting for the second
     number to finish the operation.
     
     - parameters:
     - operation:
     The variable that store the function name as a string.
     - firstNum:
     The first numebr that will take part in the oepration.
     - replace:
     To declare that if the firstNum will replace the current description. true or false
     - Author:
     Zeyong Shan
     - Important:
     This function might modify the context of the description.
     - Version:
     0.1
     
     */
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
    
    /**
     This function is used to perform the binary operation that already stored by the
     function func addBinaryOperation(operation: Stirng, firstNum: String, replace: Bool)
     
     - parameter secondNum: The second number that will take part into the bianry operation.
     
     - Author:
     Zeyong Shan
     - Important:
     This function might modify the context of the description.
     - Version:
     0.1
     
     */
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
    
    /**
     The computed read-only variable that return the current description.
     the return value depends on the situation of pendingBinaryOperation and
     the current context. It would return the context with "..." in the end
     if there is binary operation are pending, return "" if no description.
     - Author:
     Zeyong Shan
     - Version:
     0.1
     
     */
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
    
    /**
     The variable that store the main context the the description.
     */
    private var context: String?
    /**
     The variable that store the information of the first half binary operation.
     */
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    /**
     TypeName: PendingBinaryOperation
     The data type that store the fist half the a binary operation
     */
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


