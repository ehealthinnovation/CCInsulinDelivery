//
//  I2CHORatioProfileTemplate.swift
//  CCInsulinDelivery
//
//  Created by Kevin Tallevi on 2/19/18.
//

import Foundation

public class I2CHORatioProfileTemplate : NSObject {
    public var templateNumber: UInt8!
    public var firstTimeBlockNumberIndex: UInt8!
    public var firstDuration: UInt16!
    public var firstI2CHORatio: Float!
    public var secondDuration: UInt16?
    public var secondI2CHORatio: Float?
    public var thirdDuration: UInt16?
    public var thirdI2CHORatio: Float?
    
    public init(templateNumber: UInt8, firstTimeBlockNumberIndex: UInt8, firstDuration: UInt16, firstI2CHORatio: Float, secondDuration: UInt16, secondI2CHORatio: Float, thirdDuration: UInt16, thirdI2CHORatio: Float) {
        self.templateNumber = templateNumber
        self.firstTimeBlockNumberIndex = firstTimeBlockNumberIndex
        self.firstDuration = firstDuration
        self.firstI2CHORatio = firstI2CHORatio
        self.secondDuration = secondDuration
        self.secondI2CHORatio = secondI2CHORatio
        self.thirdDuration = thirdDuration
        self.thirdI2CHORatio = thirdI2CHORatio
    }
}
