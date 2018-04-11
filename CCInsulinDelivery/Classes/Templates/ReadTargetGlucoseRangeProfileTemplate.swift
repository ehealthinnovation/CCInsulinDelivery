//
//  ReadTargetGlucoseRangeProfileTemplate.swift
//  CCInsulinDelivery
//
//  Created by Kevin Tallevi on 2/19/18.
//

import Foundation

public class TargetGlucoseRangeProfileTemplate : NSObject {
    public var templateNumber: UInt8!
    public var firstTimeBlockNumberIndex: UInt8!
    public var firstDuration: UInt16!
    public var firstLowerTargetGlucoseLimit: Float!
    public var firstUpperTargetGlucoseLimit: Float!
    public var secondDuration: UInt16?
    public var secondLowerTargetGlucoseLimit: Float!
    public var secondUpperTargetGlucoseLimit: Float!
    
    public init(templateNumber: UInt8, firstTimeBlockNumberIndex: UInt8, firstDuration: UInt16, firstLowerTargetGlucoseLimit: Float, firstUpperTargetGlucoseLimit: Float, secondDuration: UInt16, secondLowerTargetGlucoseLimit: Float, secondUpperTargetGlucoseLimit: Float) {
        self.templateNumber = templateNumber
        self.firstTimeBlockNumberIndex = firstTimeBlockNumberIndex
        self.firstDuration = firstDuration
        self.firstLowerTargetGlucoseLimit = firstLowerTargetGlucoseLimit
        self.firstUpperTargetGlucoseLimit = firstUpperTargetGlucoseLimit
        self.secondDuration = secondDuration
        self.secondLowerTargetGlucoseLimit = secondLowerTargetGlucoseLimit
        self.secondUpperTargetGlucoseLimit = secondUpperTargetGlucoseLimit
    }
}
