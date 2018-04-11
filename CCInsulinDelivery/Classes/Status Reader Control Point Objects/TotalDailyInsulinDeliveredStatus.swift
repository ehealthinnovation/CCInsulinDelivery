//
//  TotalDailyInsulinDeliveredStatus.swift
//  CCBluetooth
//
//  Created by Kevin Tallevi on 3/27/18.
//

import Foundation

public class TotalDailyInsulinDeliveredStatus: NSObject {
    public var totalDailyInsulinSumOfBolusDelivered: Float!
    public var totalDailyInsulinSumOfBasalDelivered: Float!
    public var totalDailyInsulinSumOfBolusAndBasalDelivered: Float!
    
    public init(totalDailyInsulinSumOfBolusDelivered: Float!, totalDailyInsulinSumOfBasalDelivered: Float!) {
        self.totalDailyInsulinSumOfBolusDelivered = totalDailyInsulinSumOfBolusDelivered
        self.totalDailyInsulinSumOfBasalDelivered = totalDailyInsulinSumOfBasalDelivered
        self.totalDailyInsulinSumOfBolusAndBasalDelivered = totalDailyInsulinSumOfBolusDelivered + totalDailyInsulinSumOfBasalDelivered
    }
}
