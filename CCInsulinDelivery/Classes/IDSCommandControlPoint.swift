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
    func commandControlPointResponseCode(code: UInt16, error: UInt8)
    func snoozedAnnunciation(annunciation: UInt16)
    func confirmedAnnunciation(annunciation: UInt16)
    func writeBasalRateProfileTemplateResponse()
    func getTBRTemplateResponse(template: TBRTemplate)
    func setTBRTemplateResponse(templateNumber: UInt8)
    func setBolusResponse(bolusID: UInt16)
    func cancelBolusResponse(bolusID: UInt16)
    func getAvailableBolusResponse(availableBoluses: UInt8)
    func getBolusTemplateResponse(template: BolusTemplate)
    func setBolusTemplateResponse(template: UInt8)
    func templateStatusAndDetails(templateStatuses: [TemplateStatus])
    func resetProfileTemplates(templates: [UInt8])
    func activatedProfileTemplates(templates: [UInt8])
    func activateProfileTemplates(templates: [UInt8])
    func writeISFProfileTemplateResponse(templateNumber: UInt8)
    func writeI2CHOProfileTemplateResponse(templateNumber: UInt8)
    func writeTargetGlucoseRangeProfileTemplateResponse(templateNumber: UInt8)
    func getMaxBolusAmountResponse(bolusAmount: Float)
}

public class IDSCommandControlPoint: NSObject {
    public var peripheral: CBPeripheral?
    public var idsCommandControlPointDelegate : IDSCommandControlPointProtcol?
    
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
        let opCode: UInt16 = IDSOpCodes.OpCodes.setTherapyControlState.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           IDSDataTypes.TherapyControlStateValues.run.rawValue,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func setFlightMode() {
        let opCode: UInt16 = IDSOpCodes.OpCodes.setFlightMode.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func snoozeAnnunciation(annunciation: UInt16) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.snoozeAnnunciation.rawValue
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           UInt8(annunciation & 0xff),
                                           UInt8(annunciation >> 8),
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func confirmAnnunciation(annunciation: UInt16) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.confirmAnnunciation.rawValue
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           UInt8(annunciation & 0xff),
                                           UInt8(annunciation >> 8),
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func readBasalRateProfileTemplate(templateNumber: UInt8) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.readBasalRateProfileTemplate.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           templateNumber,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func writeBasalRateProfileTemplate(templateNumber: UInt8) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.writeBasalRateProfileTemplate.rawValue
        let flags: UInt8 = 0x01 //end transaction: true, second present: false, third present: false
        let firstDuration: UInt16 = 1440 //1440 = 24 hours (total duration must be 24 hours)
        let firstRateValue: Float = 2.4
        let firstRateValueShort: Float = firstRateValue.floatToShortFloat()
        let firstRate = Int(firstRateValueShort)
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           flags,
                                           templateNumber, //Basal Rate Profile Template Number
                                           0x01, //First Time Block Number Index
                                           UInt8(firstDuration & 0xff),
                                           UInt8(firstDuration >> 8),
                                           UInt8(firstRate & 0xff),
                                           UInt8(firstRate >> 8),
                                           0x00] as [UInt8], length: 10)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func setTBRAdjustment() {
        let opCode: UInt16 = IDSOpCodes.OpCodes.setTBRAdjustment.rawValue
        let flags: UInt8 = 0x00
        /*
         bit 0 = tbr template number present
         bit 1 = tbr delivery context present
         bit 2 = change tbr
         */
        let tbrAdjustment: Float = 2.1
        let tbrAdjustmentValue: Int = Int(tbrAdjustment.floatToShortFloat())
        let tbrDuration: UInt16 = 2
        let tbrTemplateNumber: UInt8 = 1
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           flags,
                                           UInt8(IDSDataTypes.TBRTypeValues.absolute.rawValue),
                                           UInt8(tbrAdjustmentValue & 0xff),
                                           UInt8(tbrAdjustmentValue >> 8),
                                           UInt8(tbrDuration & 0xff),
                                           UInt8(tbrDuration >> 8),
                                           tbrTemplateNumber,
                                           IDSDataTypes.TBRDeliveryContextValues.deviceBased.rawValue,
                                           0x00] as [UInt8], length: 11)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func cancelTBRAdjustment() {
        let opCode: UInt16 = IDSOpCodes.OpCodes.cancelTBRAdjustment.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func getTBRTemplate(templateNumber: UInt8) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.getTBRTemplate.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           templateNumber,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func setTBRTemplate(templateNumber: UInt8) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.setTBRTemplate.rawValue
        let tbrAdjustment: Float = 2.1
        let tbrAdjustmentValue: Int = Int(tbrAdjustment.floatToShortFloat())
        let tbrDuration: UInt16 = 2
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           templateNumber, // TBR Template Number
                                           UInt8(IDSDataTypes.TBRTypeValues.absolute.rawValue),
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
    
    public func setBolus(fastAmount: Float, extendedAmount: Float, duration: UInt16, delayTime: UInt16, templateNumber: UInt8, activationType: UInt8, bolusDeliveryReasonCorrection: Bool, bolusDeliveryReasonMeal: Bool) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.setBolus.rawValue
        let bolusFastAmountValue: Int = Int(fastAmount.floatToShortFloat())
        let bolusExtendedAmountValue: Int = Int(extendedAmount.floatToShortFloat())
        
        var flags: UInt8 = 0
        var type: UInt8!
        
        if fastAmount > 0 {
            type = IDSStatusReaderControlPoint.BolusType.fast.rawValue
        } else {
            type = IDSStatusReaderControlPoint.BolusType.extended.rawValue
        }
        
        /*
         bit 0 = Bolus Delay Time Present
         bit 1 = Bolus Template Number Present
         bit 2 = Bolus Activation Type Present
         bit 3 = Bolus Delivery Reason Correction
         bit 4 = Bolus Delivery Reason Meal
         */
        if delayTime > 0 {
            flags = flags | (1 << 0)
        }
        if templateNumber > 0 {
            flags = flags | (1 << 1)
        }
        if activationType > 0 {
            flags = flags | (1 << 2)
        }
        if bolusDeliveryReasonCorrection == true {
            flags = flags | (1 << 3)
        }
        if bolusDeliveryReasonMeal == true {
            flags = flags | (1 << 4)
        }
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           flags, // all flags cleared
                                           type,
                                           UInt8(bolusFastAmountValue & 0xff),
                                           UInt8(bolusFastAmountValue >> 8),
                                           UInt8(bolusExtendedAmountValue & 0xff),
                                           UInt8(bolusExtendedAmountValue >> 8),
                                           UInt8(duration & 0xff),
                                           UInt8(duration >> 8),
                                           0x00] as [UInt8], length: 11)
        
        if delayTime > 0 {
            let bolusDelayTime = NSMutableData(bytes: [ UInt8(delayTime & 0xff), UInt8(delayTime >> 8) ] as [UInt8], length: 2)
            packet.append(bolusDelayTime as Data)
        }
        
        if templateNumber > 0 {
            let bolusTemplateNumber = NSMutableData(bytes: [ UInt8(templateNumber) ] as [UInt8], length: 1)
            packet.append(bolusTemplateNumber as Data)
        }
        
        if activationType > 0 {
            let bolusActivationType = NSMutableData(bytes: [ UInt8(activationType) ] as [UInt8], length: 1)
            packet.append(bolusActivationType as Data)
        }
        
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func cancelBolus(bolusID: UInt16) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.cancelBolus.rawValue
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
        let opCode: UInt16 = IDSOpCodes.OpCodes.getAvailableBoluses.rawValue
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func getBolusTemplate(templateNumber: UInt8) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.getBolusTemplate.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           UInt8(templateNumber),
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func setBolusTemplate(templateNumber: UInt8) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.setBolusTemplate.rawValue
        let flags: UInt8 = 0
        /*
        bit 0 = Bolus Delay Time Present
        bit 1 = Bolus Delivery Reason Correction
        bit 2 = Bolus Delivery Reason Meal
        */
        let bolusFastAmount: Float = 2.1
        let bolusFastAmountValue: Int = Int(bolusFastAmount.floatToShortFloat())
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           UInt8(templateNumber),
                                           flags, // all flags cleared
                                           IDSStatusReaderControlPoint.BolusType.fast.rawValue,
                                           UInt8(bolusFastAmountValue & 0xff),
                                           UInt8(bolusFastAmountValue >> 8),
                                           0x00, //Bolus Extended Amount
                                           0x00, //Bolus Extended Amount
                                           0x00, //Bolus Duration
                                           0x00, //Bolus Duration
                                           0x00, //Delay time
                                           0x00] as [UInt8], length: 12)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func getTemplateStatusAndDetails() {
        IDSCommandData.sharedInstance().templatesStatusAndDetails.removeAll()
        
        let opCode: UInt16 = IDSOpCodes.OpCodes.getTemplateStatusAndDetails.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func resetTemplateStatus(templatesNumbers: [UInt8]) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.resetTemplateStatus.rawValue
        let numberOfTemplatesToReset: Int = templatesNumbers.count
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           UInt8(numberOfTemplatesToReset),
                                          ] as [UInt8], length: 3)
        
        for i in 0...(numberOfTemplatesToReset-1) {
            let templateNumber = NSMutableData(bytes: [ UInt8(templatesNumbers[i]) ] as [UInt8], length: 1)
            
            packet.append(templateNumber as Data)
        }
        
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func activateProfileTemplates(templatesNumbers: [UInt8]) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.activateProfileTemplates.rawValue
        let numberOfTemplatesToActivate: Int = templatesNumbers.count
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           UInt8(numberOfTemplatesToActivate),
                                           ] as [UInt8], length: 3)
        
        for i in 0...(numberOfTemplatesToActivate-1) {
            let templateNumber = NSMutableData(bytes: [ UInt8(templatesNumbers[i]) ] as [UInt8], length: 1)
            
            packet.append(templateNumber as Data)
        }
        
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func getActivatedProfileTemplates() {
        let opCode: UInt16 = IDSOpCodes.OpCodes.getActivatedProfileTemplates.rawValue
        
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
        let opCode: UInt16 = IDSOpCodes.OpCodes.startPriming.rawValue
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
        let opCode: UInt16 = IDSOpCodes.OpCodes.stopPriming.rawValue
        
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
        let opCode: UInt16 = IDSOpCodes.OpCodes.setInitialReservoirFillLevel.rawValue
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
        let opCode: UInt16 = IDSOpCodes.OpCodes.resetReservoirInsulinOperationTime.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func readISFProfileTemplate(templateNumber: UInt8) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.readISFProfileTemplate.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           templateNumber,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func writeISFProfileTemplate(templateNumber: UInt8) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.writeISFProfileTemplate.rawValue
        let firstDuration: UInt16 = 5
        let firstISF: Float = 2.1
        let firstISFValue: Int = Int(firstISF.floatToShortFloat())
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x01, // flags [end transaction: true]
                                           templateNumber,
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
    
    public func readI2CHORatioProfileTemplate(templateNumber: UInt8) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.readI2CHORatioProfileTemplate.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           templateNumber, //I2CHO Ratio Profile Template Number
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    //TO-DO
    public func writeI2CHORatioProfileTemplate(templateNumber: UInt8) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.writeI2CHORatioProfileTemplate.rawValue
        let firstDuration: UInt16 = 5
        let firstI2CHO: Float = 2.1
        let firstI2CHOValue: Int = Int(firstI2CHO.floatToShortFloat())
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x01, // flags [end transaction: true], second and third time blocks not present
                                           templateNumber, // I2CHO Ratio Profile Template Number
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
    
    public func readTargetGlucoseRangeProfileTemplate(templateNumber: UInt8) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.readTargetGlucoseRangeProfileTemplate.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           templateNumber,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func writeTargetGlucoseRangeProfileTemplate(templateNumber: UInt8) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.writeTargetGlucoseRangeProfileTemplate.rawValue
        let firstDuration: UInt16 = 5
        let firstLowerTargetGlucoseLimit: Float = 2.9
        let firstLowerTargetGlucoseLimitValue: Int = Int(firstLowerTargetGlucoseLimit.floatToShortFloat())
        let firstUpperTargetGlucoseLimit: Float = 8.5
        let firstUpperTargetGlucoseLimitValue: Int = Int(firstUpperTargetGlucoseLimit.floatToShortFloat())
        
        let packet = NSMutableData(bytes: [ UInt8(opCode & 0xff),
                                            UInt8(opCode >> 8),
                                            0x01, // flags [end transactiom: true, second time block present: false]
                                            templateNumber, // target Glucose Range Profile Template Number
                                            0x01, // first Time Block Number Index
                                            UInt8(firstDuration & 0xff),
                                            UInt8(firstDuration >> 8),
                                            UInt8(firstLowerTargetGlucoseLimitValue & 0xff),
                                            UInt8(firstLowerTargetGlucoseLimitValue >> 8),
                                            //UInt8(firstUpperTargetGlucoseLimitValue & 0xff),
                                            //UInt8(firstUpperTargetGlucoseLimitValue >> 8),
                                            //0x00] as [UInt8], length: 10)
                                            ] as [UInt8], length: 9)
        // this block of code is needed as the packet declaration with length of 12 throws error:
        // 'Expression was too complex to be solved in reasonable time; consider breaking up the expression into distinct sub-expressions'
        let upperTarget = NSMutableData(bytes: [ UInt8(firstUpperTargetGlucoseLimitValue & 0xff),
                                            UInt8(firstUpperTargetGlucoseLimitValue >> 8),
                                            0x00] as [UInt8], length: 3)
        packet.append(upperTarget as Data)
        
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func getMaxBolusAmount() {
        let opCode: UInt16 = IDSOpCodes.OpCodes.getMaxBolusAmount.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsCommandControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func setMaxBolusAmount(maxBolusAmount: Float) {
        let opCode: UInt16 = IDSOpCodes.OpCodes.setMaxBolusAmount.rawValue
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
    
    //
    public func parseIDSCommandControlPointResponse(data: NSData) {
        print("parseIDSCommandControlPointResponse")
        
        let responseCode: UInt16 = (data.subdata(with: NSRange(location:0, length: 2)) as NSData).decode()
        switch responseCode {
        case IDSOpCodes.OpCodes.responseCode.rawValue:
            parseIDSCommandControlPointResponseCodePacket(data: data)
        case IDSOpCodes.OpCodes.snoozeAnnunciationResponse.rawValue:
            parseSnoozeAnnunciationResponse(data: data)
        case IDSOpCodes.OpCodes.confirmAnnunciationResponse.rawValue:
            parseConfirmAnnunciationResponse(data: data)
        case IDSOpCodes.OpCodes.writeBasalRateProfileTemplateResponse.rawValue:
            parseWriteBasalRateProfileTemplateResponse(data: data)
        case IDSOpCodes.OpCodes.setBolusResponse.rawValue:
            parseSetBolusResponse(data: data)
        case IDSOpCodes.OpCodes.cancelBolusResponse.rawValue:
            parseCancelBolusResponse(data: data)
        case IDSOpCodes.OpCodes.getAvailableBolusesResponse.rawValue:
            parseGetAvailableBoluses(data: data)
        case IDSOpCodes.OpCodes.getBolusTemplateResponse.rawValue:
            parseGetBolusTemplateResponse(data: data)
        case IDSOpCodes.OpCodes.setBolusTemplateResponse.rawValue:
            parseSetBolusTemplateResponse(data: data)
        case IDSOpCodes.OpCodes.getTBRTemplateResponse.rawValue:
            parseGetTBRTemplateResponse(data: data)
        case IDSOpCodes.OpCodes.setTBRTemplateResponse.rawValue:
            parseSetTBRTemplateResponse(data: data)
        case IDSOpCodes.OpCodes.resetTemplateStatusResponse.rawValue:
            parseResetTemplateStatus(data: data)
        case IDSOpCodes.OpCodes.activateProfileTemplatesResponse.rawValue:
            parseActivateProfileTemplatesResonse(data: data)
        case IDSOpCodes.OpCodes.getActivatedProfileTemplatesResponse.rawValue:
            parseGetActivateProfileTemplatesResonse(data: data)
        case IDSOpCodes.OpCodes.writeISFProfileTemplateResponse.rawValue:
            parseWriteISFProfileTemplateResponse(data: data)
        case IDSOpCodes.OpCodes.writeI2CHORatioProfileTemplateResponse.rawValue:
            parseWriteI2CHOProfileTemplateResponse(data: data)
        case IDSOpCodes.OpCodes.writeTargetGlucoseRangeProfileTemplateResponse.rawValue:
            parseWriteTargetGlucoseTemplateResponse(data: data)
        case IDSOpCodes.OpCodes.getMaxBolusAmountResponse.rawValue:
            parseGetMaxBolusAmountResponse(data: data)
        default:
            ()
        }
    }
    
    func parseIDSCommandControlPointResponseCodePacket(data: NSData) {
        print("parseIDSCommandDataResponseCodePacket")
        let opCode: UInt16 = (data.subdata(with: NSRange(location:2, length: 2)) as NSData).decode()
        let response: UInt8 = (data.subdata(with: NSRange(location:4, length: 1)) as NSData).decode()
        idsCommandControlPointDelegate?.commandControlPointResponseCode(code: opCode, error: response)
    }
    
    func parseSnoozeAnnunciationResponse(data: NSData) {
        print("parseSnoozeAnnunciationResponse")
        
        let snoozedAnnunciation: UInt16 = (data.subdata(with: NSRange(location:2, length: 2)) as NSData).decode()
        idsCommandControlPointDelegate?.snoozedAnnunciation(annunciation: snoozedAnnunciation)
    }
    
    func parseConfirmAnnunciationResponse(data: NSData) {
        print("parseConfirmAnnunciationResponse")
        
        let confirmedAnnunciation: UInt16 = (data.subdata(with: NSRange(location:2, length: 2)) as NSData).decode()
        idsCommandControlPointDelegate?.confirmedAnnunciation(annunciation: confirmedAnnunciation)
    }
    
    func parseWriteBasalRateProfileTemplateResponse(data: NSData) {
        print("parseWriteBasalRateProfileTemplateResponse")
        let flags: Int = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        if flags.bit(0) == 1 {
            idsCommandControlPointDelegate?.writeBasalRateProfileTemplateResponse()
        }
    }
    
    func parseSetBolusResponse(data: NSData) {
        print("parseSetBolusResponse")
        let bolusID: UInt16 = (data.subdata(with: NSRange(location:2, length: 2)) as NSData).decode()
        idsCommandControlPointDelegate?.setBolusResponse(bolusID: bolusID)
    }
    
    func parseCancelBolusResponse(data: NSData) {
        print("parseCancelBolusResponse")
        let bolusID: UInt16 = (data.subdata(with: NSRange(location:2, length: 2)) as NSData).decode()
        idsCommandControlPointDelegate?.cancelBolusResponse(bolusID: bolusID)
    }
    
    func parseGetAvailableBoluses(data: NSData) {
        print("parseGetAvailableBoluses")
        let availableBoluses: UInt8 = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        idsCommandControlPointDelegate?.getAvailableBolusResponse(availableBoluses: availableBoluses)
    }
    
    public func parseGetBolusTemplateResponse(data: NSData) {
        print("parseGetBolusTemplateResponse")
        let templateNumber: UInt8 = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        let flags: UInt8 = (data.subdata(with: NSRange(location:3, length: 1)) as NSData).decode()
        let bolusType: UInt8 = (data.subdata(with: NSRange(location:4, length: 1)) as NSData).decode()
        let bolusFastAmount: Float = (data.subdata(with: NSRange(location:5, length: 2)) as NSData).shortFloatToFloat()
        let bolusExtendedAmount: Float = (data.subdata(with: NSRange(location:7, length: 2)) as NSData).shortFloatToFloat()
        let bolusDurationAmount: UInt16 = (data.subdata(with: NSRange(location:9, length: 2)) as NSData).decode()
        var bolusDelayTime: UInt16 = 0
        
        if Int(flags).bit(0).toBool()! {
            bolusDelayTime = (data.subdata(with: NSRange(location:11, length: 2)) as NSData).decode()
        }
        
        let bolusTemplate = BolusTemplate(templateNumber: templateNumber,
                                          bolusType: bolusType,
                                          bolusFastAmount: bolusFastAmount,
                                          bolusExtendedAmount: bolusExtendedAmount,
                                          bolusDuration: bolusDurationAmount,
                                          bolusDelayTime: bolusDelayTime)
        
        print(bolusTemplate)
        
        idsCommandControlPointDelegate?.getBolusTemplateResponse(template: bolusTemplate)
    }
    
    public func parseSetBolusTemplateResponse(data: NSData) {
        print("parseSetBolusTemplateResponse")
        let templateNumber: UInt8 = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        print("template number: \(templateNumber)")
        idsCommandControlPointDelegate?.setBolusTemplateResponse(template: templateNumber)
    }
    
    public func parseGetTBRTemplateResponse(data: NSData) {
        print("parseGetTBRTemplateResponse")
        
        let templateNumber: UInt8 = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        let type: UInt8 = (data.subdata(with: NSRange(location:3, length: 1)) as NSData).decode()
        let adjustmentValue = (data.subdata(with: NSRange(location:4, length: 2)) as NSData).shortFloatToFloat()
        let duration: UInt16 = (data.subdata(with: NSRange(location:6, length: 2)) as NSData).decode()
        
        let tbrTemplate = TBRTemplate(templateNumber: templateNumber,
                                      type: type,
                                      adjustmentValue: adjustmentValue,
                                      duration: duration)
        
        print(tbrTemplate)
        
        idsCommandControlPointDelegate?.getTBRTemplateResponse(template: tbrTemplate)
    }
    
    public func parseSetTBRTemplateResponse(data: NSData) {
        print("parseSetTBRTemplateResponse")
        let templateNumber: UInt8 = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        
        print("template number: \(templateNumber)")
        idsCommandControlPointDelegate?.setTBRTemplateResponse(templateNumber: templateNumber)
    }
    
    public func parseResetTemplateStatus(data: NSData) {
        print("parseResetTemplateStatus")
        
        var resetTemplates = [UInt8]()
        
        let numberOfResetTemplates: UInt8 = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        for x in 0...(numberOfResetTemplates-1) {
            let templateNumber: UInt8 = (data.subdata(with: NSRange(location:(Int(x) + 3), length: 1)) as NSData).decode()
            resetTemplates.append(templateNumber)
        }
        idsCommandControlPointDelegate?.resetProfileTemplates(templates: resetTemplates)
    }
    
    public func parseActivateProfileTemplatesResonse(data: NSData) {
        print("parseActivateProfileTemplatesResonse")
        
        var activatedTemplates = [UInt8]()
        
        let numberOfActivatedTemplates: UInt8 = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        for x in 0...(numberOfActivatedTemplates-1) {
            let templateNumber: UInt8 = (data.subdata(with: NSRange(location:(Int(x) + 3), length: 1)) as NSData).decode()
            activatedTemplates.append(templateNumber)
        }
        idsCommandControlPointDelegate?.activateProfileTemplates(templates: activatedTemplates)
    }
    
    public func parseGetActivateProfileTemplatesResonse(data: NSData) {
        print("parseGetActivateProfileTemplatesResonse")
        
        var activatedTemplates = [UInt8]()
        
        let numberOfActivatedTemplates: UInt8 = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        if numberOfActivatedTemplates > 0 {
            for x in 0...(numberOfActivatedTemplates-1) {
                let templateNumber: UInt8 = (data.subdata(with: NSRange(location:(Int(x) + 3), length: 1)) as NSData).decode()
                activatedTemplates.append(templateNumber)
            }
        }
        idsCommandControlPointDelegate?.activatedProfileTemplates(templates: activatedTemplates)
    }
    
    public func parseWriteISFProfileTemplateResponse(data: NSData) {
        print("parseWriteISFProfileTemplateResponse")
        let templateNumber: UInt8 = (data.subdata(with: NSRange(location:3, length: 1)) as NSData).decode()
        idsCommandControlPointDelegate?.writeISFProfileTemplateResponse(templateNumber: templateNumber)
    }
    
    public func parseWriteI2CHOProfileTemplateResponse(data: NSData) {
        print("parseWriteI2CHOProfileTemplateResponse")
        let templateNumber: UInt8 = (data.subdata(with: NSRange(location:3, length: 1)) as NSData).decode()
        idsCommandControlPointDelegate?.writeI2CHOProfileTemplateResponse(templateNumber: templateNumber)
    }

    public func parseWriteTargetGlucoseTemplateResponse(data: NSData) {
        print("parseWriteTargetGlucoseTemplateResponse")
        let templateNumber: UInt8 = (data.subdata(with: NSRange(location:3, length: 1)) as NSData).decode()
        idsCommandControlPointDelegate?.writeTargetGlucoseRangeProfileTemplateResponse(templateNumber: templateNumber)
    }
    
    public func parseGetMaxBolusAmountResponse(data: NSData) {
        print("parseGetMaxBolusAmountResponse")
        let maxBolusAmount = (data.subdata(with: NSRange(location:2, length: 2)) as NSData).shortFloatToFloat()
        idsCommandControlPointDelegate?.getMaxBolusAmountResponse(bolusAmount: maxBolusAmount)
    }
}
