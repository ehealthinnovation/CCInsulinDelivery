//
//  IDSHistory.swift
//  CCInsulinDelivery
//
//  Created by Kevin Tallevi on 4/30/18.
//

import Foundation
import CCBluetooth

var thisIDSHistoryEvent : IDSHistoryEvent?

public class IDSHistoryEvent: NSObject {
    var bluetoothDateTime: BluetoothDateTime!
    
    public var event: UInt16 = 0
    public var sequence: UInt32 = 0
    public var offset: UInt32 = 0
    public var historyData: NSData!
    public var eventDescription: String!
    
    init(data: NSData) {
        super.init()
        self.bluetoothDateTime = BluetoothDateTime()
        print("IDSHistory")
        let dataLength: Int = data.length - 11
        event = (data.subdata(with: NSRange(location:0, length: 2)) as NSData).decode()
        sequence = (data.subdata(with: NSRange(location:2, length: 4)) as NSData).decode()
        offset = (data.subdata(with: NSRange(location:6, length: 2)) as NSData).decode()
        historyData = (data.subdata(with: NSRange(location:8, length: dataLength)) as NSData)
        eventDescription = historyEventDescription(event: event, data: historyData)
        print("event: \(String(describing: IDSDataTypes.EventType(rawValue:event)?.description))")
        print("sequence: " + sequence.description)
        print("offset: " + offset.description)
        print("history data: " + historyData.description)
        print("event description: " + eventDescription)
    }
    
    func historyEventDescription(event: UInt16, data: NSData) -> String {
        let eventData = data.reverseData()
        switch event {
            case IDSDataTypes.EventType.referenceTime.rawValue:
                let subData: NSData = (eventData.subdata(with: NSRange(location:1, length: data.length - 1)) as NSData)
                let date: Date = bluetoothDateTime.dateFromData(data: subData)
                let timeStr: String = bluetoothDateTime.stringFromDate(date: date)
                return timeStr
            case IDSDataTypes.EventType.therapyControlStateChanged.rawValue:
                let previousState: UInt8 = (eventData.subdata(with: NSRange(location:0, length: 1)) as NSData).decode()
                let newState: UInt8 = (eventData.subdata(with: NSRange(location:1, length: 1)) as NSData).decode()
                return ("\(String(describing: IDSDataTypes.TherapyControlStateValues(rawValue:previousState)!.description)) -> \(String(describing: IDSDataTypes.TherapyControlStateValues(rawValue:newState)!.description))")
            case IDSDataTypes.EventType.primingStarted.rawValue:
                return ("Amount: \(data.shortFloatToFloat())")
            case IDSDataTypes.EventType.primingDone.rawValue:
                let primedAmount: NSData = (eventData.subdata(with: NSRange(location:1, length: 2)) as NSData)
                return ("Amount: \(primedAmount.shortFloatToFloat())")
            case IDSDataTypes.EventType.maxBolusAmountChanged.rawValue:
                let oldMaxBolusAmount: NSData = (eventData.subdata(with: NSRange(location:0, length: 2)) as NSData)
                let newMaxBolusAmount: NSData = (eventData.subdata(with: NSRange(location:2, length: 2)) as NSData)
                return "Old amount: \(oldMaxBolusAmount.shortFloatToFloat()) New amount: \(newMaxBolusAmount.shortFloatToFloat())"
            case IDSDataTypes.EventType.basalRateProfileTemplateTimeBlockChanged.rawValue:
                let basalRateProfileTemplateNumber: UInt8 = (eventData.subdata(with: NSRange(location:0, length: 1)) as NSData).decode()
                let timeBlockNumber: UInt8 = (eventData.subdata(with: NSRange(location:1, length: 1)) as NSData).decode()
                let firstDuration: UInt16 = (eventData.subdata(with: NSRange(location:2, length: 2)) as NSData).decode()
                let rate: Float = (eventData.subdata(with: NSRange(location:4, length: 2)) as NSData).shortFloatToFloat()
                return "Template number: \(basalRateProfileTemplateNumber)\nTime block number: \(timeBlockNumber)\nFirst duration: \(firstDuration)\nRate: \(rate)"
            case IDSDataTypes.EventType.tbrTemplateChanged.rawValue:
                let tbrTemplateNumber: UInt8 = (eventData.subdata(with: NSRange(location:0, length: 1)) as NSData).decode()
                let tbrType: UInt8 = (eventData.subdata(with: NSRange(location:1, length: 1)) as NSData).decode()
                let tbrAdjustmentValue: Float = (eventData.subdata(with: NSRange(location:2, length: 2)) as NSData).shortFloatToFloat()
                let tbrDuration: UInt16 = (eventData.subdata(with: NSRange(location:4, length: 2)) as NSData).decode()
                return "TBR template number: \(tbrTemplateNumber)\nTBR type: \(String(describing: IDSDataTypes.TBRTypeValues(rawValue: tbrType)!.description))\nTBR adjustment value: \(tbrAdjustmentValue)\nTBR duration: \(tbrDuration)"
            case IDSDataTypes.EventType.isfProfileTemplateTimeBlockChanged.rawValue:
                let isfProfileTemplateNumber: UInt8 = (eventData.subdata(with: NSRange(location:0, length: 1)) as NSData).decode()
                let timeBlockNumber: UInt8 = (eventData.subdata(with: NSRange(location:1, length: 1)) as NSData).decode()
                let duration: UInt16 = (eventData.subdata(with: NSRange(location:2, length: 2)) as NSData).decode()
                let isf: Float = (eventData.subdata(with: NSRange(location:4, length: 2)) as NSData).shortFloatToFloat()
                return "ISF profile template number: \(isfProfileTemplateNumber)\nTime block number: \(timeBlockNumber)\nDuration: \(duration)\nISF: \(isf)"
            case IDSDataTypes.EventType.i2choRatioProfileTemplateTimeBlockChanged.rawValue:
                let i2choProfileTemplateNumber: UInt8 = (eventData.subdata(with: NSRange(location:0, length: 1)) as NSData).decode()
                let timeBlockNumber: UInt8 = (eventData.subdata(with: NSRange(location:1, length: 1)) as NSData).decode()
                let duration: UInt16 = (eventData.subdata(with: NSRange(location:2, length: 2)) as NSData).decode()
                let ratio: Float = (eventData.subdata(with: NSRange(location:4, length: 2)) as NSData).shortFloatToFloat()
                return "I2CHO profile template number: \(i2choProfileTemplateNumber)\nTime block number: \(timeBlockNumber)\nDuration: \(duration)\nRatio: \(ratio)"
            case IDSDataTypes.EventType.targetGlucoseRangeProfileTemplateTimeBlockChanged.rawValue:
                let targetGlucoseRangeTemplateNumber: UInt8 = (eventData.subdata(with: NSRange(location:0, length: 1)) as NSData).decode()
                let timeBlockNumber: UInt8 = (eventData.subdata(with: NSRange(location:1, length: 1)) as NSData).decode()
                let duration: UInt16 = (eventData.subdata(with: NSRange(location:2, length: 2)) as NSData).decode()
                let lowerTargetGlucoseLimit: Float = (eventData.subdata(with: NSRange(location:4, length: 2)) as NSData).shortFloatToFloat()
                let upperTargetGlucoseLimit: Float = (eventData.subdata(with: NSRange(location:6, length: 2)) as NSData).shortFloatToFloat()
                return "Target glucose range template number: \(targetGlucoseRangeTemplateNumber)\nTime block number: \(timeBlockNumber)\nDuration: \(duration)\nLower target glucose limit: \(lowerTargetGlucoseLimit)\nUpper target glucose limit: \(upperTargetGlucoseLimit)"
            default:
                return ""
        }
    }
}
