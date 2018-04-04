//
//  ISFProfileTemplate.swift
//  CCInsulinDelivery
//
//  Created by Kevin Tallevi on 2/19/18.
//

import Foundation

public class ISFProfileTemplate : NSObject {
    public var templateNumber: UInt8!
    public var firstTimeBlockNumberIndex: UInt8!
    public var firstDuration: UInt16!
    public var firstISF: Float!
    public var secondDuration: UInt16?
    public var secondISF: Float?
    public var thirdDuration: UInt16?
    public var thirdISF: Float?
    
    public init(templateNumber: UInt8, firstTimeBlockNumberIndex: UInt8, firstDuration: UInt16, firstISF: Float, secondDuration: UInt16, secondISF: Float, thirdDuration: UInt16, thirdISF: Float) {
        self.templateNumber = templateNumber
        self.firstTimeBlockNumberIndex = firstTimeBlockNumberIndex
        self.firstDuration = firstDuration
        self.firstISF = firstISF
        self.secondDuration = secondDuration
        self.secondISF = secondISF
        self.thirdDuration = thirdDuration
        self.thirdISF = thirdISF
    }
}
