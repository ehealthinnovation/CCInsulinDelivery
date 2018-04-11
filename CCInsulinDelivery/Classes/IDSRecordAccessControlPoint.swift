//
//  IDSRecordAccessControlPoint.swift
//  CCInsulinDelivery
//
//  Created by Kevin Tallevi on 11/16/17.
//

import Foundation
import CoreBluetooth
import CCToolbox
import CCBluetooth

var thisIDSRecordAccessControlPoint : IDSRecordAccessControlPoint?

public class IDSRecordAccessControlPoint: NSObject {
    public var peripheral: CBPeripheral?
    
    @objc public enum RecordAccessControlPointOpCodes: UInt8 {
        case responseCode = 0x0F,
        reportStoredRecords = 0x33,
        deleteStoredRecords = 0x3C,
        abortOperation = 0x55,
        reportNumberOfStoredRecords = 0x5A,
        numberOfStoredRecordsResponse = 0x66
    }
    
    @objc public enum RecordAccessControlPointOperators: UInt8 {
        case null = 0x0F,
        allRecords = 0x33,
        lessThanOrEqualTo = 0x3C,
        greaterThanOrEqualTo = 0x55,
        withinRangeOf = 0x5A,
        firstRecord = 0x66,
        lastRecord = 0x69
    }
    
    @objc public enum RecordAccessControlPointOperandFilters: UInt8 {
        case sequenceNumber = 0x0F,
        sequenceNumberFilteredByReferenceTimeEvent = 0x33,
        sequenceNumberFilteredByNonreferenceTimeEvent = 0x3C
    }
    
    @objc public enum RecordAccessControlPointResponseCodes: UInt8 {
        case procedureNotApplicable = 0x0A,
        success = 0xF0
    }
    
    public class func sharedInstance() -> IDSRecordAccessControlPoint {
        if thisIDSRecordAccessControlPoint == nil {
            thisIDSRecordAccessControlPoint = IDSRecordAccessControlPoint()
        }
        return thisIDSRecordAccessControlPoint!
    }
    
    func parseRACPReponse(data:NSData) {
        print("parsing RACP response: \(data)")
    }
    
    func parseRecord(data:NSData) {
    }
    
    public func reportAllRecords() {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.reportStoredRecords.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.allRecords.rawValue,
                                           RecordAccessControlPointOperandFilters.sequenceNumber.rawValue,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func reportRecordsLessThanOrEqualTo(recordNumber: Int) {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.reportStoredRecords.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.lessThanOrEqualTo.rawValue,
                                           RecordAccessControlPointOperandFilters.sequenceNumber.rawValue,
                                           UInt8(recordNumber),
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func reportRecordsGreaterThanOrEqualTo(recordNumber: Int) {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.reportStoredRecords.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.greaterThanOrEqualTo.rawValue,
                                           RecordAccessControlPointOperandFilters.sequenceNumber.rawValue,
                                           UInt8(recordNumber),
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func reportRecordsWithinRange(from: Int , to: Int) {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.reportStoredRecords.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.withinRangeOf.rawValue,
                                           RecordAccessControlPointOperandFilters.sequenceNumber.rawValue,
                                           UInt8(from),
                                           UInt8(to),
                                           0x00] as [UInt8], length: 6)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func reportFirstRecord() {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.reportStoredRecords.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.firstRecord.rawValue,
                                           RecordAccessControlPointOperandFilters.sequenceNumber.rawValue,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func reportLastRecord() {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.reportStoredRecords.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.lastRecord.rawValue,
                                           RecordAccessControlPointOperandFilters.sequenceNumber.rawValue,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func deleteAllRecords() {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.deleteStoredRecords.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.allRecords.rawValue,
                                           RecordAccessControlPointOperandFilters.sequenceNumber.rawValue,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func deleteRecordsLessThanOrEqualTo(recordNumber: Int) {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.deleteStoredRecords.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.lessThanOrEqualTo.rawValue,
                                           RecordAccessControlPointOperandFilters.sequenceNumber.rawValue,
                                           UInt8(recordNumber),
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func deleteRecordsGreaterThanOrEqualTo(recordNumber: Int) {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.deleteStoredRecords.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.greaterThanOrEqualTo.rawValue,
                                           RecordAccessControlPointOperandFilters.sequenceNumber.rawValue,
                                           UInt8(recordNumber),
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func deleteRecordsWithinRange(from: Int , to: Int) {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.deleteStoredRecords.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.withinRangeOf.rawValue,
                                           RecordAccessControlPointOperandFilters.sequenceNumber.rawValue,
                                           UInt8(from),
                                           UInt8(to),
                                           0x00] as [UInt8], length: 6)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func deleteFirstRecord() {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.deleteStoredRecords.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.firstRecord.rawValue,
                                           RecordAccessControlPointOperandFilters.sequenceNumber.rawValue,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func deleteLastRecord() {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.deleteStoredRecords.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.lastRecord.rawValue,
                                           RecordAccessControlPointOperandFilters.sequenceNumber.rawValue,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func abortOperation() {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.abortOperation.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           UInt8(RecordAccessControlPointOperators.null.rawValue),
                                           RecordAccessControlPointOperandFilters.sequenceNumber.rawValue,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func reportNumberOfAllStoredRecords() {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.reportNumberOfStoredRecords.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.allRecords.rawValue,
                                           RecordAccessControlPointOperandFilters.sequenceNumber.rawValue,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func reportNumberOfStoredRecordsLessThanOrEqualTo(recordNumber: Int) {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.reportNumberOfStoredRecords.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.lessThanOrEqualTo.rawValue,
                                           RecordAccessControlPointOperandFilters.sequenceNumber.rawValue,
                                           UInt8(recordNumber),
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func reportNumberOfStoredRecordsGreaterThanOrEqualTo(recordNumber: Int) {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.reportNumberOfStoredRecords.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.greaterThanOrEqualTo.rawValue,
                                           RecordAccessControlPointOperandFilters.sequenceNumber.rawValue,
                                           UInt8(recordNumber),
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func reportNumberOfStoredRecordsWithinRange(from: Int , to: Int) {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.reportNumberOfStoredRecords.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.withinRangeOf.rawValue,
                                           RecordAccessControlPointOperandFilters.sequenceNumber.rawValue,
                                           UInt8(from),
                                           UInt8(to),
                                           0x00] as [UInt8], length: 6)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
}
