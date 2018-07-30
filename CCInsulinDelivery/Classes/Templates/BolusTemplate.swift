//
//  BolusTemplate.swift
//  CCInsulinDelivery
//
//  Created by Kevin Tallevi on 2/19/18.
//

import Foundation

public class BolusTemplate : NSObject {
    public var templateNumber: UInt8!
    public var bolusType: UInt8
    public var bolusFastAmount: Float
    public var bolusExtendedAmount: Float
    public var bolusDuration: UInt16
    public var bolusDelayTime: UInt16
    
    public init(templateNumber: UInt8, bolusType: UInt8, bolusFastAmount: Float, bolusExtendedAmount: Float, bolusDuration: UInt16, bolusDelayTime: UInt16) {
        self.templateNumber = templateNumber
        self.bolusType = bolusType
        self.bolusFastAmount = bolusFastAmount
        self.bolusExtendedAmount = bolusExtendedAmount
        self.bolusDuration = bolusDuration
        self.bolusDelayTime = bolusDelayTime
    }
}

