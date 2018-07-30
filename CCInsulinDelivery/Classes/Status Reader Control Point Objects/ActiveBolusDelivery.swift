//
//  ActiveBolusDelivery.swift
//  CCInsulinDelivery
//
//  Created by Kevin Tallevi on 3/14/18.
//

import Foundation

public class ActiveBolusDelivery: NSObject {
    public var flags: UInt8!
    public var bolusID: UInt16!
    public var bolusType: String!
    public var bolusFastAmount: Float!
    public var bolusExtendedAmount: Float!
    public var bolusDuration: UInt16!
    public var bolusDelayTime: UInt16?
    public var bolusTemplateNumber: UInt8?
    public var bolusActivationType: String?
    
    public init(flags: UInt8!, bolusID: UInt16!, bolusType: String!, bolusFastAmount: Float!, bolusExtendedAmount: Float!, bolusDuration: UInt16!, bolusDelayTime: UInt16?, bolusTemplateNumber: UInt8?, bolusActivationType: String?) {
        self.flags = flags
        self.bolusID = bolusID
        self.bolusType = bolusType
        self.bolusFastAmount = bolusFastAmount
        self.bolusExtendedAmount = bolusExtendedAmount
        self.bolusDuration = bolusDuration
        self.bolusDelayTime = bolusDelayTime
        self.bolusTemplateNumber = bolusTemplateNumber
        self.bolusActivationType = bolusActivationType
    }
}
