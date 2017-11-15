//
//  IDSCommandControlPoint.swift
//  CCInsulinDelivery
//
//  Created by Kevin Tallevi on 10/26/17.
//

import Foundation
import CoreBluetooth
import CCToolbox
import CCBluetooth

var thisIDSCommandControlPoint : IDSCommandControlPoint?

public protocol IDSCommandControlPointProtcol {
    
}

public class IDSCommandControlPoint: NSObject {
    public var peripheral: CBPeripheral?
    
    @objc public enum CommandControlOpCodes: UInt16 {
        case response_code = 0x0F55,
        set_therapy_control_state = 0x0F5A,
        set_flight_mode = 0x0F66,
        snooze_annunciation = 0x0F69,
        snooze_annunciation_response = 0x0F96,
        confirm_annunciation = 0x0F99,
        confirm_annunciation_response = 0x0FA5,
        read_basal_rate_profile_template = 0x0FAA,
        read_basal_rate_profile_template_response = 0x0FC3,
        write_basal_rate_profile_template = 0x0FCC,
        write_basal_rate_profile_template_response = 0x0FF0,
        set_tbr_adjustment = 0x0FFF,
        cancel_tbr_adjustment = 0x1111,
        get_tbr_template = 0x111E,
        get_tbr_template_response = 0x1122,
        set_tbr_template = 0x112D,
        set_tbr_template_response = 0x1144,
        set_bolus = 0x114B,
        set_bolus_response = 0x1177,
        cancel_bolus = 0x1178,
        cancel_bolus_response = 0x1187,
        get_available_boluses = 0x1188,
        get_available_boluses_response = 0x11B4,
        get_bolus_template = 0x11BB,
        get_bolus_template_response = 0x11D2,
        set_bolus_template = 0x11DD,
        set_bolus_template_response = 0x11E1,
        get_template_status_and_details = 0x11EE,
        get_template_status_and_details_response = 0x1212,
        reset_template_status = 0x121D,
        reset_template_status_response = 0x1221,
        activate_profile_templates = 0x122E,
        activate_profile_templates_response = 0x1247,
        get_activated_profile_templates = 0x1248,
        get_activated_profile_templates_response = 0x1274,
        start_priming = 0x127B,
        stop_priming = 0x1284,
        set_initial_reservoir_fill_level = 0x128B,
        reset_reservoir_insulin_operation_time = 0x12B7,
        read_isf_profile_template = 0x12B8,
        read_isf_profile_template_response = 0x12D1,
        write_isf_profile_template = 0x12DE,
        write_isf_profile_template_response = 0x12E2,
        read_i2cho_ratio_profile_template = 0x12ED,
        read_i2cho_ratio_profile_template_response = 0x1414,
        write_i2cho_ratio_profile_template = 0x141B,
        write_i2cho_ratio_profile_template_response = 0x1427,
        read_target_glucose_range_profile_template = 0x1428,
        read_target_glucose_range_profile_template_response = 0x1441,
        write_target_glucose_range_profile_template = 0x144E,
        write_target_glucose_range_profile_template_response = 0x1472,
        get_max_bolus_amount = 0x147D,
        get_max_bolus_amount_response = 0x1482,
        set_max_bolus_amount = 0x148D
    }
    
    @objc public enum ResponseCodes: UInt8 {
        case success = 0x0F,
        op_code_not_supported = 0x70,
        invalid_operand = 0x71,
        procedure_not_completed = 0x72,
        parameter_out_of_range = 0x73,
        procedure_not_applicable = 0x74,
        plausibility_check_failed = 0x75,
        maximum_bolus_number_reached = 0x76
        
        public var description: String {
            switch self {
            case .success:
                return NSLocalizedString("Success", comment:"")
            case .op_code_not_supported:
                return NSLocalizedString("Op code not supported", comment:"")
            case .invalid_operand:
                return NSLocalizedString("Invalid operand", comment:"")
            case .procedure_not_completed:
                return NSLocalizedString("Procedure not completed", comment:"")
            case .parameter_out_of_range:
                return NSLocalizedString("Parameter out of range", comment:"")
            case .procedure_not_applicable:
                return NSLocalizedString("Procedure not applicable", comment:"")
            case .plausibility_check_failed:
                return NSLocalizedString("Plausibility Check Failed", comment:"")
            case .maximum_bolus_number_reached:
                return NSLocalizedString("Maximum Bolus Number Reached", comment:"")
            }
        }
    }
    
    @objc public enum TherapyControlStateValues: UInt8 {
        case undetermined = 0x0F,
        stop = 0x70,
        pause = 0x71,
        run = 0x72
        
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
    
    public class func sharedInstance() -> IDSCommandControlPoint {
        if thisIDSCommandControlPoint == nil {
            thisIDSCommandControlPoint = IDSCommandControlPoint()
        }
        return thisIDSCommandControlPoint!
    }
    
    public override init() {
        super.init()
        print("IDSCommandControlPoint#init")
    }
    
    public init(peripheral: CBPeripheral?) {
        super.init()
        print("IDSCommandControlPoint#init with peripheral")
        
        self.peripheral = peripheral
    }
    
    public func setTherapyControlState() {
        let opCode: UInt16 = CommandControlOpCodes.set_therapy_control_state.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           TherapyControlStateValues.run.rawValue,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func setFlightMode() {
        let opCode: UInt16 = CommandControlOpCodes.set_flight_mode.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func snoozeAnnunciation() {
        let opCode: UInt16 = CommandControlOpCodes.snooze_annunciation.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00,
                                           0x01,
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func confirmAnnunciation() {
        let opCode: UInt16 = CommandControlOpCodes.confirm_annunciation.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00,
                                           0x01,
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func readBasalRateProfileTemplate() {
        let opCode: UInt16 = CommandControlOpCodes.read_basal_rate_profile_template.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x01,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func writeBasalRateProfileTemplate() {
        let opCode: UInt16 = CommandControlOpCodes.write_basal_rate_profile_template.rawValue
        let flags: UInt8 = 0x01 //end transaction: true, second present: false, third present: false
        let firstDuration: UInt16 = 1440 //1440 = 24 hours (total duration must be 24 hours)
        let a: Float = 1.0
        let b: Float = a.floatToShortFloat()
        let c = Int(b)
        //let c: [UInt8] = self.toByteArray(b).reversed()
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           flags,
                                           0x01, //Basal Rate Profile Template Number
                                           0x01, //First Time Block Number Index
                                           UInt8(firstDuration & 0xff),
                                           UInt8(firstDuration >> 8),
                                           UInt8(c & 0xff),
                                           UInt8(c >> 8),
                                           //c[1],
                                           //c[0],
                                           0x00 //crc counter
                                           ] as [UInt8], length: 10) //look into why as! is necessary
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func setTBRAdjustment() {
        let opCode: UInt16 = CommandControlOpCodes.set_tbr_adjustment.rawValue
        let flags: UInt8 = 0x07 //TBR Template Number Present: true, TBR Delivery Context Present: true, Change TBR: true
        
        let tbrAdjustment: Float = 2.1
        let tbrAdjustmentValue: Int = Int(tbrAdjustment.floatToShortFloat())
        let tbrDuration: UInt16 = 2
        let tbrTemplateNumber: UInt8 = 1
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           flags,
                                           UInt8(TBRTypeValues.absolute.rawValue),
                                           UInt8(tbrAdjustmentValue & 0xff),
                                           UInt8(tbrAdjustmentValue >> 8),
                                           UInt8(tbrDuration & 0xff),
                                           UInt8(tbrDuration >> 8),
                                           tbrTemplateNumber,
                                           TBRDeliveryContextValues.deviceBased.rawValue,
                                           0x00] as [UInt8], length: 11)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func cancelTBRAdjustment() {
        let opCode: UInt16 = CommandControlOpCodes.cancel_tbr_adjustment.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func getTBRTemplate() {
        let opCode: UInt16 = CommandControlOpCodes.get_tbr_template.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x01,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func setTBRTemplate() {
        let opCode: UInt16 = CommandControlOpCodes.set_tbr_template.rawValue
        let tbrAdjustment: Float = 2.1
        let tbrAdjustmentValue: Int = Int(tbrAdjustment.floatToShortFloat())
        let tbrDuration: UInt16 = 2
        let tbrTemplateNumber: UInt8 = 1
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           tbrTemplateNumber, // TBR Template Number
                                           UInt8(TBRTypeValues.absolute.rawValue),
                                           UInt8(tbrAdjustmentValue & 0xff),
                                           UInt8(tbrAdjustmentValue >> 8),
                                           UInt8(tbrDuration & 0xff),
                                           UInt8(tbrDuration >> 8),
                                           0x00] as [UInt8], length: 9)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func setBolus() {
        let opCode: UInt16 = CommandControlOpCodes.set_bolus.rawValue
        let bolusFastAmount: Float = 2.1
        let bolusFastAmountValue: Int = Int(bolusFastAmount.floatToShortFloat())
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00, // all flags cleared
                                           IDSStatusReaderControlPoint.BolusType.fast.rawValue,
                                           UInt8(bolusFastAmountValue & 0xff),
                                           UInt8(bolusFastAmountValue >> 8),
                                           0x00, //Bolus Extended Amount
                                           0x00, //Bolus Extended Amount
                                           0x00, //Bolus Duration
                                           0x00, //Bolus Duration
                                           0x00] as [UInt8], length: 11)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func cancelBolus() {
        let opCode: UInt16 = CommandControlOpCodes.cancel_bolus.rawValue
        let bolusID: UInt16 = 2
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           UInt8(bolusID & 0xff),
                                           UInt8(bolusID >> 8),
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func getAvailableBoluses() {
        let opCode: UInt16 = CommandControlOpCodes.get_available_boluses.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func getBolusTemplate() {
        let opCode: UInt16 = CommandControlOpCodes.get_bolus_template.rawValue
        let bolusTemplateNumber: UInt8 = 1
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           UInt8(bolusTemplateNumber),
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func setBolusTemplate() {
        let opCode: UInt16 = CommandControlOpCodes.set_bolus_template.rawValue
        let bolusTemplateNumber: UInt8 = 1
        let flags: UInt8 = 0
        let bolusFastAmount: Float = 2.1
        let bolusFastAmountValue: Int = Int(bolusFastAmount.floatToShortFloat())
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           UInt8(bolusTemplateNumber),
                                           flags, // all flags cleared
                                           IDSStatusReaderControlPoint.BolusType.fast.rawValue,
                                           UInt8(bolusFastAmountValue & 0xff),
                                           UInt8(bolusFastAmountValue >> 8),
                                           0x00, //Bolus Extended Amount
                                           0x00, //Bolus Extended Amount
                                           0x00, //Bolus Duration
                                           0x00, //Bolus Duration
                                           0x00] as [UInt8], length: 12)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func getTemplateStatusAndDetails() {
        let opCode: UInt16 = CommandControlOpCodes.get_template_status_and_details.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func resetTemplateStatus() {
        let opCode: UInt16 = CommandControlOpCodes.reset_template_status.rawValue
        let numberOfTemplatesToReset: UInt8 = 2
        let templatesToReset: [UInt8] = [1,2]
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           UInt8(numberOfTemplatesToReset),
                                           UInt8(templatesToReset[0]),
                                           UInt8(templatesToReset[1]),
                                           0x00] as [UInt8], length: 6)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func activateProfileTemplates() {
        let opCode: UInt16 = CommandControlOpCodes.activate_profile_templates.rawValue
        let numberOfProfileTemplatesToActivate: UInt8 = 2
        let profileTemplatesToActivate: [UInt8] = [1,2]
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           UInt8(numberOfProfileTemplatesToActivate),
                                           UInt8(profileTemplatesToActivate[0]),
                                           UInt8(profileTemplatesToActivate[1]),
                                           0x00] as [UInt8], length: 6)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func getActivatedProfileTemplates() {
        let opCode: UInt16 = CommandControlOpCodes.get_activated_profile_templates.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func startPriming() {
        let opCode: UInt16 = CommandControlOpCodes.start_priming.rawValue
        let primingAmount: Float = 3.5
        let primingAmountValue: Int = Int(primingAmount.floatToShortFloat())
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           UInt8(primingAmountValue & 0xff),
                                           UInt8(primingAmountValue >> 8),
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func stopPriming() {
        let opCode: UInt16 = CommandControlOpCodes.stop_priming.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func setInitialReservoirFillLevel() {
        let opCode: UInt16 = CommandControlOpCodes.set_initial_reservoir_fill_level.rawValue
        let initialReservoirFillLevel: Float = 5.0
        let initialReservoirFillLevelValue: Int = Int(initialReservoirFillLevel.floatToShortFloat())
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           UInt8(initialReservoirFillLevelValue & 0xff),
                                           UInt8(initialReservoirFillLevelValue >> 8),
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func resetReservoirInsulinOperationTime() {
        let opCode: UInt16 = CommandControlOpCodes.reset_reservoir_insulin_operation_time.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    //pg 141
    public func readISFProfileTemplate() {
        let opCode: UInt16 = CommandControlOpCodes.read_isf_profile_template.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x01, // template number
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func writeISFProfileTemplate() {
        let opCode: UInt16 = CommandControlOpCodes.write_isf_profile_template.rawValue
        let firstDuration: UInt16 = 5
        let firstISF: Float = 2.1
        let firstISFValue: Int = Int(firstISF.floatToShortFloat())
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x01, // flags [end transaction: true]
                                           0x01, // ISF Profile Template Number
                                           0x01, // First Time Block Number Index
                                           UInt8(firstDuration & 0xff),
                                           UInt8(firstDuration >> 8),
                                           UInt8(firstISFValue & 0xff),
                                           UInt8(firstISFValue >> 8),
                                           0x00] as [UInt8], length: 10)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func readI2CHORatioProfileTemplate() {
        let opCode: UInt16 = CommandControlOpCodes.read_i2cho_ratio_profile_template.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x01, //I2CHO Ratio Profile Template Number
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    //TO-DO
    public func writeI2CHORatioProfileTemplate() {
        let opCode: UInt16 = CommandControlOpCodes.write_i2cho_ratio_profile_template.rawValue
        let firstDuration: UInt16 = 5
        let firstI2CHO: Float = 2.1
        let firstI2CHOValue: Int = Int(firstI2CHO.floatToShortFloat())
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x01, // flags [end transaction: true]
                                           0x01, // I2CHO Ratio Profile Template Number
                                           0x01, // First Time Block Number Index
                                           UInt8(firstDuration & 0xff),
                                           UInt8(firstDuration >> 8),
                                           UInt8(firstI2CHOValue & 0xff),
                                           UInt8(firstI2CHOValue >> 8),
                                           0x00] as [UInt8], length: 10)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func readTargetGlucoseRangeProfileTemplate() {
        let opCode: UInt16 = CommandControlOpCodes.read_target_glucose_range_profile_template.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x01, // Target Glucose Range Profile Template Number
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func writeTargetGlucoseRangeProfileTemplate() {
        let opCode: UInt16 = CommandControlOpCodes.write_target_glucose_range_profile_template.rawValue
        let firstDuration: UInt16 = 5
        let firstLowerTargetGlucoseLimit: Float = 2.9
        let firstLowerTargetGlucoseLimitValue: Int = Int(firstLowerTargetGlucoseLimit.floatToShortFloat())
        let firstUpperTargetGlucoseLimit: Float = 8.5
        let firstUpperTargetGlucoseLimitValue: Int = Int(firstUpperTargetGlucoseLimit.floatToShortFloat())
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x01, // flags [end transactiom: true, second time block present: false]
                                           0x01, // target Glucose Range Profile Template Number
                                           0x01, // first Time Block Number Index
                                           UInt8(firstDuration & 0xff),
                                           UInt8(firstDuration >> 8),
                                           UInt8(firstLowerTargetGlucoseLimitValue & 0xff),
                                           UInt8(firstLowerTargetGlucoseLimitValue >> 8),
                                           UInt8(firstUpperTargetGlucoseLimitValue & 0xff),
                                           UInt8(firstUpperTargetGlucoseLimitValue >> 8),
                                           0x00] as [UInt8], length: 12)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func getMaxBolusAmount() {
        let opCode: UInt16 = CommandControlOpCodes.get_max_bolus_amount.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func setMaxBolusAmount() {
        let opCode: UInt16 = CommandControlOpCodes.set_max_bolus_amount.rawValue
        let maxBolusAmount: Float = 9.0
        let maxBolusAmountValue: Int = Int(maxBolusAmount.floatToShortFloat())
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           UInt8(maxBolusAmountValue & 0xff),
                                           UInt8(maxBolusAmountValue >> 8),
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
}
