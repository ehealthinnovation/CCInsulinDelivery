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
        case system_issue = 0x000F,
        mechanical_issue = 0x0033,
        occlusion_detected = 0x003C,
        reservoir_issue	= 0x0055,
        reservoir_empty	= 0x005A,
        reservoir_low = 0x0066,
        priming_issue = 0x0069,
        infusion_set_incomplete = 0x0096,
        infusion_set_detached = 0x0099,
        power_source_insufficient = 0x00A5,
        battery_empty = 0x00AA,
        battery_low = 0x00C3,
        battery_medium = 0x00CC,
        battery_full = 0x00F0,
        temperature_out_of_range = 0x00FF,
        air_pressure_out_of_range = 0x0303,
        bolus_cancelled = 0x030C,
        tbr_over = 0x0330,
        tbr_cancelled = 0x033F,
        max_delivery = 0x0356,
        date_time_issue = 0x0359,
        temperature = 0x0365
        
        public var description: String {
            switch self {
            case .system_issue:
                return NSLocalizedString("System issue", comment:"")
            case .mechanical_issue:
                return NSLocalizedString("Mechanical issue", comment:"")
            case .occlusion_detected:
                return NSLocalizedString("Occlusion detected", comment:"")
            case .reservoir_issue:
                return NSLocalizedString("Reservoir issue", comment:"")
            case .reservoir_empty:
                return NSLocalizedString("Reservoir empty", comment:"")
            case .reservoir_low:
                return NSLocalizedString("Reservoir low", comment:"")
            case .priming_issue:
                return NSLocalizedString("Priming issue", comment:"")
            case .infusion_set_incomplete:
                return NSLocalizedString("Infusion set incomplete", comment:"")
            case .infusion_set_detached:
                return NSLocalizedString("Infusion set detached", comment:"")
            case .power_source_insufficient:
                return NSLocalizedString("Power source insufficient", comment:"")
            case .battery_empty:
                return NSLocalizedString("Battery empty", comment:"")
            case .battery_low:
                return NSLocalizedString("Battery low", comment:"")
            case .battery_medium:
                return NSLocalizedString("Battery medium", comment:"")
            case .battery_full:
                return NSLocalizedString("Battery full", comment:"")
            case .temperature_out_of_range:
                return NSLocalizedString("Temperature out of range", comment:"")
            case .air_pressure_out_of_range:
                return NSLocalizedString("Air pressure out of range", comment:"")
            case .bolus_cancelled:
                return NSLocalizedString("Bolus cancelled", comment:"")
            case .tbr_over:
                return NSLocalizedString("TBR over", comment:"")
            case .tbr_cancelled:
                return NSLocalizedString("TBR cancelled", comment:"")
            case .max_delivery:
                return NSLocalizedString("Max delivery", comment:"")
            case .date_time_issue:
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
