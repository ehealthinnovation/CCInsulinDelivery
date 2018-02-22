//
//  IDSRecordAccessControlPoint.swift
//  CCBluetooth
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
        case response_code = 0x0F,
        report_stored_records = 0x33,
        delete_stored_records = 0x3C,
        abort_operation = 0x55,
        report_number_of_stored_records = 0x5A,
        number_of_stored_records_response = 0x66
    }
    
    @objc public enum RecordAccessControlPointOperators: UInt8 {
        case null = 0x0F,
        all_records = 0x33,
        less_than_or_equal_to = 0x3C,
        greater_than_or_equal_to = 0x55,
        within_range_of = 0x5A,
        first_record = 0x66,
        last_record = 0x69
    }
    
    @objc public enum RecordAccessControlPointOperandFilters: UInt8 {
        case sequence_number = 0x0F,
        sequence_number_filtered_by_reference_time_event = 0x33,
        sequence_number_filtered_by_nonreference_time_event = 0x3C
    }
    
    @objc public enum RecordAccessControlPointResponseCodes: UInt8 {
        case procedure_not_applicable = 0x0A,
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
        let opCode: UInt8 = RecordAccessControlPointOpCodes.report_stored_records.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.all_records.rawValue,
                                           RecordAccessControlPointOperandFilters.sequence_number.rawValue,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func reportRecordsLessThanOrEqualTo(recordNumber: Int) {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.report_stored_records.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.less_than_or_equal_to.rawValue,
                                           RecordAccessControlPointOperandFilters.sequence_number.rawValue,
                                           UInt8(recordNumber),
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func reportRecordsGreaterThanOrEqualTo(recordNumber: Int) {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.report_stored_records.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.greater_than_or_equal_to.rawValue,
                                           RecordAccessControlPointOperandFilters.sequence_number.rawValue,
                                           UInt8(recordNumber),
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func reportRecordsWithinRange(from: Int , to: Int) {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.report_stored_records.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.within_range_of.rawValue,
                                           RecordAccessControlPointOperandFilters.sequence_number.rawValue,
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
        let opCode: UInt8 = RecordAccessControlPointOpCodes.report_stored_records.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.first_record.rawValue,
                                           RecordAccessControlPointOperandFilters.sequence_number.rawValue,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func reportLastRecord() {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.report_stored_records.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.last_record.rawValue,
                                           RecordAccessControlPointOperandFilters.sequence_number.rawValue,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func deleteAllRecords() {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.delete_stored_records.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.all_records.rawValue,
                                           RecordAccessControlPointOperandFilters.sequence_number.rawValue,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func deleteRecordsLessThanOrEqualTo(recordNumber: Int) {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.delete_stored_records.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.less_than_or_equal_to.rawValue,
                                           RecordAccessControlPointOperandFilters.sequence_number.rawValue,
                                           UInt8(recordNumber),
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func deleteRecordsGreaterThanOrEqualTo(recordNumber: Int) {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.delete_stored_records.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.greater_than_or_equal_to.rawValue,
                                           RecordAccessControlPointOperandFilters.sequence_number.rawValue,
                                           UInt8(recordNumber),
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func deleteRecordsWithinRange(from: Int , to: Int) {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.delete_stored_records.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.within_range_of.rawValue,
                                           RecordAccessControlPointOperandFilters.sequence_number.rawValue,
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
        let opCode: UInt8 = RecordAccessControlPointOpCodes.delete_stored_records.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.first_record.rawValue,
                                           RecordAccessControlPointOperandFilters.sequence_number.rawValue,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func deleteLastRecord() {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.delete_stored_records.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.last_record.rawValue,
                                           RecordAccessControlPointOperandFilters.sequence_number.rawValue,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func abortOperation() {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.abort_operation.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           UInt8(RecordAccessControlPointOperators.null.rawValue),
                                           RecordAccessControlPointOperandFilters.sequence_number.rawValue,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func reportNumberOfAllStoredRecords() {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.report_number_of_stored_records.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.all_records.rawValue,
                                           RecordAccessControlPointOperandFilters.sequence_number.rawValue,
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func reportNumberOfStoredRecordsLessThanOrEqualTo(recordNumber: Int) {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.report_number_of_stored_records.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.less_than_or_equal_to.rawValue,
                                           RecordAccessControlPointOperandFilters.sequence_number.rawValue,
                                           UInt8(recordNumber),
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func reportNumberOfStoredRecordsGreaterThanOrEqualTo(recordNumber: Int) {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.report_number_of_stored_records.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.greater_than_or_equal_to.rawValue,
                                           RecordAccessControlPointOperandFilters.sequence_number.rawValue,
                                           UInt8(recordNumber),
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(recordAccessControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func reportNumberOfStoredRecordsWithinRange(from: Int , to: Int) {
        let opCode: UInt8 = RecordAccessControlPointOpCodes.report_number_of_stored_records.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode),
                                           RecordAccessControlPointOperators.within_range_of.rawValue,
                                           RecordAccessControlPointOperandFilters.sequence_number.rawValue,
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
