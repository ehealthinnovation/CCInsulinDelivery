//
//  IDSOpCodes.swift
//  CCBluetooth
//
//  Created by Kevin Tallevi on 2/15/18.
//

import Foundation

public class IDSOpCodes : NSObject {
    @objc public enum OpCodes: UInt16 {
        case responseCode = 0x0F55,
        setTherapyControlState = 0x0F5A,
        setFlightMode = 0x0F66,
        snoozeAnnunciation = 0x0F69,
        snoozeAnnunciationResponse = 0x0F96,
        confirmAnnunciation = 0x0F99,
        confirmAnnunciationResponse = 0x0FA5,
        readBasalRateProfileTemplate = 0x0FAA,
        readBasalRateProfileTemplateResponse = 0x0FC3,
        writeBasalRateProfileTemplate = 0x0FCC,
        writeBasalRateProfileTemplateResponse = 0x0FF0,
        setTBRAdjustment = 0x0FFF,
        cancelTBRAdjustment = 0x1111,
        getTBRTemplate = 0x111E,
        getTBRTemplateResponse = 0x1122,
        setTBRTemplate = 0x112D,
        setTBRTemplateResponse = 0x1144,
        setBolus = 0x114B,
        setBolusResponse = 0x1177,
        cancelBolus = 0x1178,
        cancelBolusResponse = 0x1187,
        getAvailableBoluses = 0x1188,
        getAvailableBolusesResponse = 0x11B4,
        getBolusTemplate = 0x11BB,
        getBolusTemplateResponse = 0x11D2,
        setBolusTemplate = 0x11DD,
        setBolusTemplateResponse = 0x11E1,
        getTemplateStatusAndDetails = 0x11EE,
        getTemplateStatusAndDetailsResponse = 0x1212,
        resetTemplateStatus = 0x121D,
        resetTemplateStatusResponse = 0x1221,
        activateProfileTemplates = 0x122E,
        activateProfileTemplatesResponse = 0x1247,
        getActivatedProfileTemplates = 0x1248,
        getActivatedProfileTemplatesResponse = 0x1274,
        startPriming = 0x127B,
        stopPriming = 0x1284,
        setInitialReservoirFillLevel = 0x128B,
        resetReservoirInsulinOperationTime = 0x12B7,
        readISFProfileTemplate = 0x12B8,
        readISFProfileTemplateResponse = 0x12D1,
        writeISFProfileTemplate = 0x12DE,
        writeISFProfileTemplateResponse = 0x12E2,
        readI2CHORatioProfileTemplate = 0x12ED,
        readI2CHORatioProfileTemplateResponse = 0x1414,
        writeI2CHORatioProfileTemplate = 0x141B,
        writeI2CHORatioProfileTemplateResponse = 0x1427,
        readTargetGlucoseRangeProfileTemplate = 0x1428,
        readTargetGlucoseRangeProfileTemplateResponse = 0x1441,
        writeTargetGlucoseRangeProfileTemplate = 0x144E,
        writeTargetGlucoseRangeProfileTemplateResponse = 0x1472,
        getMaxBolusAmount = 0x147D,
        getMaxBolusAmountResponse = 0x1482,
        setMaxBolusAmount = 0x148D
        
        public var description: String {
            switch self {
            case .responseCode:
                return NSLocalizedString("Response Code", comment:"")
            case .setTherapyControlState:
                return NSLocalizedString("Set Therapy Control State", comment:"")
            case .setFlightMode:
                return NSLocalizedString("Set Flight Mode", comment:"")
            case .snoozeAnnunciation:
                return NSLocalizedString("Snooze Annunciation", comment:"")
            case .snoozeAnnunciationResponse:
                return NSLocalizedString("Snooze Annunciation Response", comment:"")
            case .confirmAnnunciation:
                return NSLocalizedString("Confirm Annunciation", comment:"")
            case .confirmAnnunciationResponse:
                return NSLocalizedString("Confirm Annunciation Response", comment:"")
            case .readBasalRateProfileTemplate:
                return NSLocalizedString("Read Basal Rate Profile Template", comment:"")
            case .readBasalRateProfileTemplateResponse:
                return NSLocalizedString("Read Basal Rate Profile Template Response", comment:"")
            case .writeBasalRateProfileTemplate:
                return NSLocalizedString("Write Basal Rate Profile Template", comment:"")
            case .writeBasalRateProfileTemplateResponse:
                return NSLocalizedString("Write Basal Rate Profile Template Response", comment:"")
            case .setTBRAdjustment:
                return NSLocalizedString("Set TBR Adjustment", comment:"")
            case .cancelTBRAdjustment:
                return NSLocalizedString("Cancel TBR Adjustment", comment:"")
            case .getTBRTemplate:
                return NSLocalizedString("Get TBR Template", comment:"")
            case .getTBRTemplateResponse:
                return NSLocalizedString("Get TBR Template Response", comment:"")
            case .setTBRTemplate:
                return NSLocalizedString("Set TBR Template", comment:"")
            case .setTBRTemplateResponse:
                return NSLocalizedString("Set TBR Template Response", comment:"")
            case .setBolus:
                return NSLocalizedString("Set Bolus", comment:"")
            case .setBolusResponse:
                return NSLocalizedString("Set Bolus Response", comment:"")
            case .cancelBolus:
                return NSLocalizedString("Cancel Bolus", comment:"")
            case .cancelBolusResponse:
                return NSLocalizedString("Cancel Bolus Response", comment:"")
            case .getAvailableBoluses:
                return NSLocalizedString("Get Available Boluses", comment:"")
            case .getAvailableBolusesResponse:
                return NSLocalizedString("Get Available Boluses Response", comment:"")
            case .getBolusTemplate:
                return NSLocalizedString("Get Bolus Template", comment:"")
            case .getBolusTemplateResponse:
                return NSLocalizedString("Get Bolus Template Response", comment:"")
            case .setBolusTemplate:
                return NSLocalizedString("Set Bolus Template", comment:"")
            case .setBolusTemplateResponse:
                return NSLocalizedString("Set Bolus Template Response", comment:"")
            case .getTemplateStatusAndDetails:
                return NSLocalizedString("Get Template Status and Details", comment:"")
            case .getTemplateStatusAndDetailsResponse:
                return NSLocalizedString("Get Template Status and Details Response", comment:"")
            case .resetTemplateStatus:
                return NSLocalizedString("Reset Template Status", comment:"")
            case .resetTemplateStatusResponse:
                return NSLocalizedString("Reset Template Status Response", comment:"")
            case .activateProfileTemplates:
                return NSLocalizedString("Activate Profile Templates", comment:"")
            case .activateProfileTemplatesResponse:
                return NSLocalizedString("Activate Profile Templates Response", comment:"")
            case .getActivatedProfileTemplates:
                return NSLocalizedString("Get Activated Profile Templates", comment:"")
            case .getActivatedProfileTemplatesResponse:
                return NSLocalizedString("Get Activated Profile Templates Response", comment:"")
            case .startPriming:
                return NSLocalizedString("Start Priming", comment:"")
            case .stopPriming:
                return NSLocalizedString("Stop Priming", comment:"")
            case .setInitialReservoirFillLevel:
                return NSLocalizedString("Set Initial Reservoir Fill Level", comment:"")
            case .resetReservoirInsulinOperationTime:
                return NSLocalizedString("Reset Reservoir Insulin Operation Time", comment:"")
            case .readISFProfileTemplate:
                return NSLocalizedString("Read ISF Profile Template", comment:"")
            case .readISFProfileTemplateResponse:
                return NSLocalizedString("Read ISF Profile Template Response", comment:"")
            case .writeISFProfileTemplate:
                return NSLocalizedString("Write ISF Profile Template", comment:"")
            case .writeISFProfileTemplateResponse:
                return NSLocalizedString("Write ISF Profile Template Response", comment:"")
            case .readI2CHORatioProfileTemplate:
                return NSLocalizedString("Read I2CHO Ratio Profile Template", comment:"")
            case .readI2CHORatioProfileTemplateResponse:
                return NSLocalizedString("Read I2CHO Ratio Profile Template Response", comment:"")
            case .writeI2CHORatioProfileTemplate:
                return NSLocalizedString("Write I2CHO Ratio Profile Template", comment:"")
            case .writeI2CHORatioProfileTemplateResponse:
                return NSLocalizedString("Write I2CHO Ratio Profile Template Response", comment:"")
            case .readTargetGlucoseRangeProfileTemplate:
                return NSLocalizedString("Read Target Glucose Range Profile Template", comment:"")
            case .readTargetGlucoseRangeProfileTemplateResponse:
                return NSLocalizedString("Read Target Glucose Range Profile Template Response", comment:"")
            case .writeTargetGlucoseRangeProfileTemplate:
                return NSLocalizedString("Write Target Glucose Range Profile Template", comment:"")
            case .writeTargetGlucoseRangeProfileTemplateResponse:
                return NSLocalizedString("Write Target Glucose Range Profile Template Response", comment:"")
            case .getMaxBolusAmount:
                return NSLocalizedString("Get Max Bolus Amount", comment:"")
            case .getMaxBolusAmountResponse:
                return NSLocalizedString("Get Max Bolus Amount Response", comment:"")
            case .setMaxBolusAmount:
                return NSLocalizedString("Set Max Bolus Amount", comment:"")
            }
        }
    }
    
    @objc public enum ResponseCodes: UInt8 {
        case success = 0x0F,
        opCodeNotSupported = 0x70,
        invalidOperand = 0x71,
        procedureNotCompleted = 0x72,
        parameterOutOfRange = 0x73,
        procedureNotApplicable = 0x74,
        plausibilityCheckFailed = 0x75,
        maximumBolusNumberReached = 0x76
        
        public var description: String {
            switch self {
            case .success:
                return NSLocalizedString("Success", comment:"")
            case .opCodeNotSupported:
                return NSLocalizedString("Op code not supported", comment:"")
            case .invalidOperand:
                return NSLocalizedString("Invalid operand", comment:"")
            case .procedureNotCompleted:
                return NSLocalizedString("Procedure not completed", comment:"")
            case .parameterOutOfRange:
                return NSLocalizedString("Parameter out of range", comment:"")
            case .procedureNotApplicable:
                return NSLocalizedString("Procedure not applicable", comment:"")
            case .plausibilityCheckFailed:
                return NSLocalizedString("Plausibility Check Failed", comment:"")
            case .maximumBolusNumberReached:
                return NSLocalizedString("Maximum Bolus Number Reached", comment:"")
            }
        }
    }
}

