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
    
    @objc public enum EventType: UInt16 {
        case referenceTime = 0x000F,
        referenceTimeBaseOffset = 0x0033,
        bolusCalculated1of2 = 0x003C,
        bolusCalculated2of2 = 0x0055,
        bolusProgrammed1of2 = 0x005A,
        bolusProgrammed2of2 = 0x0066,
        bolusDelivered1of2 = 0x0069,
        bolusDelivered2of2 = 0x0096,
        deliveredBasalRateChanged = 0x0099,
        tbrAdjustmentStarted = 0x00A5,
        tbrAdjustmentEnded = 0x00AA,
        tbrAdjustmentChanged = 0x00C3,
        profileTemplateActivated = 0x00CC,
        basalRateProfileTemplateTimeBlockChanged = 0x00F0,
        totalDailyInsulinDelivery = 0x00FF,
        therapyControlStateChanged = 0x0303,
        operationalStateChanged = 0x030C,
        reservoirRemainingAmountChanged = 0x0330,
        annunciationStatusChanged1of2 = 0x033F,
        annunciationStatusChanged2of2 = 0x0356,
        isfProfileTemplateTimeBlockChanged = 0x0359,
        i2choRatioProfileTemplateTimeBlockChanged = 0x0365,
        targetGlucoseRangeProfileTemplateTimeBlockChanged = 0x036A,
        primingStarted = 0x0395,
        primingDone = 0x39A,
        dataCorruption = 0x03A6,
        pointerEvent = 0x03A9,
        bolusTemplateChanged1of2 = 0x03C0,
        bolusTemplateChanged2of2 = 0x03CF,
        tbrTemplateChanged = 0x03F3,
        maxBolusAmountChanged = 0x03FC
        
        public var description: String {
            switch self {
            case .referenceTime:
                return NSLocalizedString("Reference Time", comment:"")
            case .referenceTimeBaseOffset:
                return NSLocalizedString("Reference Time Base Offset", comment:"")
            case .bolusCalculated1of2:
                return NSLocalizedString("Bolus Calculated 1 of 2", comment:"")
            case .bolusCalculated2of2:
                return NSLocalizedString("Bolus Calculated 2 of 2", comment:"")
            case .bolusProgrammed1of2:
                return NSLocalizedString("Bolus Programmed 1 of 2", comment:"")
            case .bolusProgrammed2of2:
                return NSLocalizedString("Bolus Programmed 2 of 2", comment:"")
            case .bolusDelivered1of2:
                return NSLocalizedString("Bolus Delivered 1 of 2", comment:"")
            case .bolusDelivered2of2:
                return NSLocalizedString("Bolus Delivered 2 of 2", comment:"")
            case .deliveredBasalRateChanged:
                return NSLocalizedString("Delivered Basal Rate Changed", comment:"")
            case .tbrAdjustmentStarted:
                return NSLocalizedString("TBR Adjustment Started", comment:"")
            case .tbrAdjustmentEnded:
                return NSLocalizedString("TBR Adjustment Ended", comment:"")
            case .tbrAdjustmentChanged:
                return NSLocalizedString("TBR Adjustment Changed", comment:"")
            case .profileTemplateActivated:
                return NSLocalizedString("Profile Template Activated", comment:"")
            case .basalRateProfileTemplateTimeBlockChanged:
                return NSLocalizedString("Basal Rate Profile Template Time Block Changed", comment:"")
            case .totalDailyInsulinDelivery:
                return NSLocalizedString("Total Daily Insulin Delivery", comment:"")
            case .therapyControlStateChanged:
                return NSLocalizedString("Therapy Control State Changed", comment:"")
            case .operationalStateChanged:
                return NSLocalizedString("Operational State Changed", comment:"")
            case .reservoirRemainingAmountChanged:
                return NSLocalizedString("Reservoir Remaining Amount Changed", comment:"")
            case .annunciationStatusChanged1of2:
                return NSLocalizedString("Annunciation Status Changed 1 of 2", comment:"")
            case .annunciationStatusChanged2of2:
                return NSLocalizedString("Annunciation Status Changed 2 of 2", comment:"")
            case .isfProfileTemplateTimeBlockChanged:
                return NSLocalizedString("ISF Profile Template Time Block Changed", comment:"")
            case .i2choRatioProfileTemplateTimeBlockChanged:
                return NSLocalizedString("I2CHO Ratio Profile Template Time Block Changed", comment:"")
            case .targetGlucoseRangeProfileTemplateTimeBlockChanged:
                return NSLocalizedString("Target Glucose Range Profile Template Time Block Changed", comment:"")
            case .primingStarted:
                return NSLocalizedString("Priming Started", comment:"")
            case .primingDone:
                return NSLocalizedString("Priming Done", comment:"")
            case .dataCorruption:
                return NSLocalizedString("Data Corruption", comment:"")
            case .pointerEvent:
                return NSLocalizedString("Pointer Event", comment:"")
            case .bolusTemplateChanged1of2:
                return NSLocalizedString("Bolus Template Changed 1 of 2", comment:"")
            case .bolusTemplateChanged2of2:
                return NSLocalizedString("Bolus Template Changed 2 of 2", comment:"")
            case .tbrTemplateChanged:
                return NSLocalizedString("TBR Template Changed", comment:"")
            case .maxBolusAmountChanged:
                return NSLocalizedString("Max Bolus Amount Changed", comment:"")
            }
        }
    }
}

