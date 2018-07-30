//
//  Template.swift
//  CCBluetooth
//
//  Created by Kevin Tallevi on 2/13/18.
//

import Foundation

public class TemplateStatus : NSObject {
    public var templateType: UInt8!
    public var templateNumber: UInt8!
    public var maxNumberOfSupportedTimeBlocks: UInt8!
    public var configurable: Bool!
    public var configured: Bool!
    
    public init(templateType: UInt8, templateNumber: UInt8, maxNumberOfSupportedTimeBlocks: UInt8, configurable: Bool, configured: Bool) {
        self.templateType = templateType
        self.templateNumber = templateNumber
        self.maxNumberOfSupportedTimeBlocks = maxNumberOfSupportedTimeBlocks
        self.configurable = configurable
        self.configured = configured
    }
}
