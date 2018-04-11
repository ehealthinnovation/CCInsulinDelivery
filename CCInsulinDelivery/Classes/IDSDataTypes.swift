//
//  IDSDataTypes.swift
//  CCInsulinDelivery
//
//  Created by Kevin Tallevi on 2/21/18.
//

import Foundation

public class IDSDataTypes: NSObject {
    @objc public enum TherapyControlStateValues: UInt8 {
        case undetermined = 0x0F,
        stop = 0x33,
        pause = 0x3C,
        run = 0x55
        public var description: String {
            switch self {
            case .undetermined:
                return NSLocalizedString("Undetermined", comment:"")
            case .stop:
                return NSLocalizedString("Stop", comment:"")
            case .pause:
                return NSLocalizedString("Pause", comment:"")
            case .run:
                return NSLocalizedString("Run", comment:"")
            }
        }
    }
    
    @objc public enum TBRTypeValues: UInt8 {
        case undetermined = 0x0F,
        absolute = 0x33,
        relative = 0x3C
        
        public var description: String {
            switch self {
            case .undetermined:
                return NSLocalizedString("Undetermined", comment:"")
            case .absolute:
                return NSLocalizedString("Absolute", comment:"")
            case .relative:
                return NSLocalizedString("Relative", comment:"")
            }
        }
    }
    
    @objc public enum TBRDeliveryContextValues: UInt8 {
        case undetermined = 0x0F,
        deviceBased = 0x33,
        remoteControl = 0x3C,
        apController = 0x55
        
        public var description: String {
            switch self {
            case .undetermined:
                return NSLocalizedString("Undetermined", comment:"")
            case .deviceBased:
                return NSLocalizedString("Device Based", comment:"")
            case .remoteControl:
                return NSLocalizedString("Remote Control", comment:"")
            case .apController:
                return NSLocalizedString("AP Controller", comment: "")
            }
        }
    }
    
    @objc public enum TemplateType: UInt8 {
        case basalRateProfileTemplate = 0x33,
        tbrTemplate = 0x3C,
        bolusTemplate = 0x55,
        isfProfileTemplate = 0x5A,
        i2choTemplate = 0x66,
        targetGlucoseTemplate = 0x96
        
        public var description: String {
            switch self {
            case .basalRateProfileTemplate:
                return NSLocalizedString("Basal Rate Profile Template", comment:"")
            case .tbrTemplate:
                return NSLocalizedString("TBR Template", comment:"")
            case .bolusTemplate:
                return NSLocalizedString("Bolus Template", comment:"")
            case .isfProfileTemplate:
                return NSLocalizedString("ISF Profile Template", comment:"")
            case .i2choTemplate:
                return NSLocalizedString("I2CHO Profile Template", comment:"")
            case .targetGlucoseTemplate:
                return NSLocalizedString("Target Glucose Template", comment:"")
            }
        }
    }
}
