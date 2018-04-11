//
//  ActiveBasalRateDelivery.swift
//  CCBluetooth
//
//  Created by Kevin Tallevi on 3/27/18.
//

import Foundation

public class ActiveBasalRateDelivery: NSObject {
    public var flags: UInt8!
    public var profileTemplateNumber: UInt8!
    public var currentConfigValue: Float!
    public var tbrType: String?
    public var tbrAdjustmentValue: Float?
    public var tbrDurationProgrammed: UInt16?
    public var tbrDurationRemaining: UInt16?
    public var tbrTemplateNumber: UInt8?
    public var context: String?
    
    public init(flags: UInt8!, profileTemplateNumber: UInt8!, currentConfigValue: Float!, tbrType: String?, tbrAdjustmentValue: Float?, tbrDurationProgrammed: UInt16?, tbrDurationRemaining: UInt16?, tbrTemplateNumber: UInt8?, context: String?) {
        self.flags = flags
        self.profileTemplateNumber = profileTemplateNumber
        self.currentConfigValue = currentConfigValue
        self.tbrType = tbrType
        self.tbrAdjustmentValue = tbrAdjustmentValue
        self.tbrDurationProgrammed = tbrDurationProgrammed
        self.tbrDurationRemaining = tbrDurationRemaining
        self.tbrTemplateNumber = tbrTemplateNumber
        self.context = context
    }
}
