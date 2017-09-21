//
//  IDSStatus.swift
//  Pods
//
//  Created by Kevin Tallevi on 9/18/17.
//
//

import CCToolbox

public class IDSStatus : NSObject {
    var status: Int = 0

    private var therapyControlStateBit = 0
    private var operationalStateBit = 1
    private var reservoirStatusBit = 2
    private var flagsBit = 4
    
    // Flags
    private var reservoirAttachedBit = 0
    
    public var therapyControlState:Int = 0
    public var operationalState:Int = 0
    public var reservoirAttached: Bool?
    public var reservoirRemainingAmount: Float = 0
    
    @objc public enum TherapyControlState : Int {
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
    
    @objc public enum OperationalStateField : Int {
        case undetermined = 0x0F,
        off = 0x33,
        standby = 0x3C,
        preparing = 0x55,
        priming = 0x5A,
        waiting = 0x66,
        ready = 0x96
        
        public var description: String {
            switch self {
            case .undetermined:
                return NSLocalizedString("Undetermined", comment:"")
            case .off:
                return NSLocalizedString("Off", comment:"")
            case .standby:
                return NSLocalizedString("Standby", comment:"")
            case .preparing:
                return NSLocalizedString("Preparing", comment:"")
            case .priming:
                return NSLocalizedString("Priming", comment:"")
            case .waiting:
                return NSLocalizedString("Waiting", comment:"")
            case .ready:
                return NSLocalizedString("Ready", comment:"")
            }
        }
    }

    public init(data: NSData?) {
        print("IDSStatus#init - \(String(describing: data))")
        
        let therapyControlStateByte = (data?.subdata(with: NSRange(location: 0, length: 1)) as NSData!)
        therapyControlStateByte?.getBytes(&therapyControlState, length: MemoryLayout<UInt8>.size)
        
        let operationalStateByte = (data?.subdata(with: NSRange(location: 1, length: 1)) as NSData!)
        operationalStateByte?.getBytes(&operationalState, length: MemoryLayout<UInt8>.size)
        
        let reservoirRemainingBytes = (data?.subdata(with: NSRange(location: 2, length: 2)) as NSData!)
        reservoirRemainingAmount = (reservoirRemainingBytes?.shortFloatToFloat())!
        print("Reservoir Remaining Amount: \(reservoirRemainingAmount)")
        
        var reservoirAttachedValue = 0
        let reservoirAttachedByte = (data?.subdata(with: NSRange(location: 4, length: 1)) as NSData!)
        reservoirAttachedByte?.getBytes(&reservoirAttachedValue, length: MemoryLayout<UInt8>.size)
        reservoirAttached = reservoirAttachedValue.bit(reservoirAttachedBit).toBool()
        print("Reservoir Attached: \(String(describing: reservoirAttached))")
    }
}
