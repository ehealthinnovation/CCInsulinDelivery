//
//  BasalRateProfileTemplate.swift
//  CCBluetooth
//
//  Created by Kevin Tallevi on 2/15/18.
//

import Foundation

public class BasalRateProfileTemplate : NSObject {
    public var templateNumber: UInt8!
    public var firstTimeBlockNumberIndex: UInt8!
    public var firstDuration: UInt16!
    public var firstRate: Float!
    public var secondDuration: UInt16?
    public var secondRate: Float?
    public var thirdDuration: UInt16?
    public var thirdRate: Float?
    
    public init(templateNumber: UInt8, firstTimeBlockNumberIndex: UInt8, firstDuration: UInt16, firstRate: Float, secondDuration: UInt16, secondRate: Float, thirdDuration: UInt16, thirdRate: Float) {
        self.templateNumber = templateNumber
        self.firstTimeBlockNumberIndex = firstTimeBlockNumberIndex
        self.firstDuration = firstDuration
        self.firstRate = firstRate
        self.secondDuration = secondDuration
        self.secondRate = secondRate
        self.thirdDuration = thirdDuration
        self.thirdRate = thirdRate
    }
}
