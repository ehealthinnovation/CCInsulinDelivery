//
//  ActiveBolusDelivery.swift
//  CCInsulinDelivery
//
//  Created by Kevin Tallevi on 3/14/18.
//

import Foundation

public class ActiveBolusDelivery: NSObject {
    public var bolusID: String
    public var bolusType: String
    public var bolusFastAmount: String?
    public var bolusExtendedAmount: String?
    public var bolusDuration: String?
    public var bolusDelayTime: String?
    public var bolusTemplateNumber: String?
    public var bolusActivationType: String?
    
    public init(bolusID: String, bolusType: String, bolusFastAmount: String?, bolusExtendedAmount: String?, bolusDuration: String?, bolusDelayTime: String?, bolusTemplateNumber: String?, bolusActivationType: String?) {
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
