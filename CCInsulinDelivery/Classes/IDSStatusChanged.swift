//
//  IDSStatusChanged.swift
//  Pods
//
//  Created by Kevin Tallevi on 9/18/17.
//
//

import CCToolbox

public class IDSStatusChanged : NSObject {
    var status: Int = 0
    
    private var therapyControlStateChangedBit = 0
    private var operationalStateChangedBit = 1
    private var reservoirStatusChangedBit = 2
    private var annunciationStatusChangedBit = 3
    private var totalDailyInsulinStatusChangedBit = 4
    private var activeBasalRateStatusChangedBit = 5
    private var activeBolusStatusChangedBit = 6
    private var historyEventRecordedBit = 7
    
    public var therapyControlStateChanged: Bool?
    public var operationalStateChanged: Bool?
    public var reservoirStatusChanged: Bool?
    public var annunciationStatusChanged: Bool?
    public var totalDailyInsulinStatusChanged: Bool?
    public var activeBasalRateStatusChanged: Bool?
    public var activeBolusStatusChanged: Bool?
    public var historyEventRecorded: Bool?

    public init(data: NSData?) {
        print("IDSStatusChanged#init - \(String(describing: data))")
        
        let statusChangedBytes = (data?.subdata(with: NSRange(location:0, length: 2)) as NSData?)
        var statusChangedBits:Int = 0
        statusChangedBytes?.getBytes(&statusChangedBits, length: MemoryLayout<UInt16>.size)
        
        therapyControlStateChanged = statusChangedBits.bit(therapyControlStateChangedBit).toBool()
        operationalStateChanged = statusChangedBits.bit(operationalStateChangedBit).toBool()
        reservoirStatusChanged = statusChangedBits.bit(reservoirStatusChangedBit).toBool()
        annunciationStatusChanged = statusChangedBits.bit(annunciationStatusChangedBit).toBool()
        totalDailyInsulinStatusChanged = statusChangedBits.bit(totalDailyInsulinStatusChangedBit).toBool()
        activeBasalRateStatusChanged = statusChangedBits.bit(activeBasalRateStatusChangedBit).toBool()
        activeBolusStatusChanged = statusChangedBits.bit(activeBolusStatusChangedBit).toBool()
        historyEventRecorded = statusChangedBits.bit(historyEventRecordedBit).toBool()
    }
}
