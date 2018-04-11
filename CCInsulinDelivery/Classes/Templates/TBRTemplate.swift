//
//  TBRTemplate.swift
//  CCInsulinDelivery
//
//  Created by Kevin Tallevi on 2/19/18.
//

import Foundation

public class TBRTemplate : NSObject {
    public var templateNumber: UInt8!
    public var type: UInt8!
    public var adjustmentValue: Float!
    public var duration: UInt16!
    
    public init(templateNumber: UInt8, type: UInt8, adjustmentValue: Float, duration: UInt16) {
        self.templateNumber = templateNumber
        self.type = type
        self.adjustmentValue = adjustmentValue
        self.duration = duration
    }
}
