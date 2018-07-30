//
//  IDSAnnunciationStatus.swift
//  Pods
//
//  Created by Kevin Tallevi on 9/21/17.
//
//

import Foundation

public class IDSAnnunciationStatus : NSObject {
    
    private var flagsBit = 0
    private var annunciationInstanceIDBit = 1
    private var annunciationTypeBit = 3
    private var annunciationStatusBit = 5
    
    // Flags
    private var annunciationPresentBit = 0
    private var auxInfo1PresentBit = 1
    private var auxInfo2PresentBit = 2
    private var auxInfo3PresentBit = 3
    private var auxInfo4PresentBit = 4
    private var auxInfo5PresentBit = 5
    
    public var annunciationType: UInt16 = 0
    public var annunciationStatus: UInt8 = 0
    
    public var flags:Int = 0
    public var annunciationPresent: Bool?
    public var auxInfo1Present: Bool?
    public var auxInfo2Present: Bool?
    public var auxInfo3Present: Bool?
    public var auxInfo4Present: Bool?
    public var auxInfo5Present: Bool?
    public var annunciationInstanceID: UInt16 = 0
    
    @objc public enum AnnunciationStatusValues: UInt8 {
        case undetermined = 0x0F,
        pending = 0x33,
        snoozed = 0x3C,
        confirmed = 0x55
        
        public var description: String {
            switch self {
            case .undetermined:
                return NSLocalizedString("Undetermined", comment:"")
            case .pending:
                return NSLocalizedString("Pending", comment:"")
            case .snoozed:
                return NSLocalizedString("Snoozed", comment:"")
            case .confirmed:
                return NSLocalizedString("Confirmed", comment:"")
            }
        }
    }
    
    @objc public enum AnnunciationTypeValues: UInt16 {
        case systemIssue = 0x000F,
        mechanicalIssue = 0x0033,
        occlusionDetected = 0x003C,
        reservoirIssue	= 0x0055,
        reservoirEmpty	= 0x005A,
        reservoirLow = 0x0066,
        primingIssue = 0x0069,
        infusionSetIncomplete = 0x0096,
        infusionSetDetached = 0x0099,
        powerSourceInsufficient = 0x00A5,
        batteryEmpty = 0x00AA,
        batteryLow = 0x00C3,
        batteryMedium = 0x00CC,
        batteryFull = 0x00F0,
        temperatureOutOfRange = 0x00FF,
        airPressureOutOfRange = 0x0303,
        bolusCancelled = 0x030C,
        tbrOver = 0x0330,
        tbrCancelled = 0x033F,
        maxDelivery = 0x0356,
        dateTimeIssue = 0x0359,
        temperature = 0x0365
        
        public var description: String {
            switch self {
            case .systemIssue:
                return NSLocalizedString("System issue", comment:"")
            case .mechanicalIssue:
                return NSLocalizedString("Mechanical issue", comment:"")
            case .occlusionDetected:
                return NSLocalizedString("Occlusion detected", comment:"")
            case .reservoirIssue:
                return NSLocalizedString("Reservoir issue", comment:"")
            case .reservoirEmpty:
                return NSLocalizedString("Reservoir empty", comment:"")
            case .reservoirLow:
                return NSLocalizedString("Reservoir low", comment:"")
            case .primingIssue:
                return NSLocalizedString("Priming issue", comment:"")
            case .infusionSetIncomplete:
                return NSLocalizedString("Infusion set incomplete", comment:"")
            case .infusionSetDetached:
                return NSLocalizedString("Infusion set detached", comment:"")
            case .powerSourceInsufficient:
                return NSLocalizedString("Power source insufficient", comment:"")
            case .batteryEmpty:
                return NSLocalizedString("Battery empty", comment:"")
            case .batteryLow:
                return NSLocalizedString("Battery low", comment:"")
            case .batteryMedium:
                return NSLocalizedString("Battery medium", comment:"")
            case .batteryFull:
                return NSLocalizedString("Battery full", comment:"")
            case .temperatureOutOfRange:
                return NSLocalizedString("Temperature out of range", comment:"")
            case .airPressureOutOfRange:
                return NSLocalizedString("Air pressure out of range", comment:"")
            case .bolusCancelled:
                return NSLocalizedString("Bolus cancelled", comment:"")
            case .tbrOver:
                return NSLocalizedString("TBR over", comment:"")
            case .tbrCancelled:
                return NSLocalizedString("TBR cancelled", comment:"")
            case .maxDelivery:
                return NSLocalizedString("Max delivery", comment:"")
            case .dateTimeIssue:
                return NSLocalizedString("Date time issue", comment:"")
            case .temperature:
                return NSLocalizedString("Temperature", comment:"")
            }
        }
    }
    
    
    public init(data: NSData?) {
        print("IDSAnnunciationStatus#init - \(String(describing: data))")
        
        let flagsByte = (data?.subdata(with: NSRange(location: 0, length: 1)) as NSData?)
        flagsByte?.getBytes(&flags, length: MemoryLayout<UInt8>.size)
        
        annunciationPresent = flags.bit(annunciationPresentBit).toBool()
        auxInfo1Present = flags.bit(auxInfo1PresentBit).toBool()
        auxInfo2Present = flags.bit(auxInfo2PresentBit).toBool()
        auxInfo3Present = flags.bit(auxInfo3PresentBit).toBool()
        auxInfo4Present = flags.bit(auxInfo4PresentBit).toBool()
        auxInfo5Present = flags.bit(auxInfo5PresentBit).toBool()
        
        if annunciationPresent! {
            let annunciationInstanceIDBytes = (data?.subdata(with: NSRange(location: annunciationInstanceIDBit, length: 2)) as NSData?)
            annunciationInstanceIDBytes?.getBytes(&annunciationInstanceID, length: MemoryLayout<UInt16>.size)
            
            let annunciationTypeBytes = (data?.subdata(with: NSRange(location: annunciationTypeBit, length: 2)) as NSData?)
            annunciationTypeBytes?.getBytes(&annunciationType, length: MemoryLayout<UInt16>.size)
            
            let annunciationStatusByte = (data?.subdata(with: NSRange(location: annunciationStatusBit, length: 1)) as NSData?)
            annunciationStatusByte?.getBytes(&annunciationStatus, length: MemoryLayout<UInt8>.size)
        }
    }
}
