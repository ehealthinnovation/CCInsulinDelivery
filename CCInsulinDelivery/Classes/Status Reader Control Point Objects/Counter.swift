//
//  Counter.swift
//  CCBluetooth
//
//  Created by Kevin Tallevi on 3/27/18.
//

import Foundation

public class Counter: NSObject {
    public var counterType: String!
    public var  counterValueSelection: String!
    public var counterValue: Int32!
    
    public init(counterType: String!, counterValueSelection: String!, counterValue: Int32!) {
        self.counterType = counterType
        self.counterValueSelection = counterValueSelection
        self.counterValue = counterValue
    }
}

