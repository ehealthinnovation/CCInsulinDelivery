//
//  IDSStatusReaderControlPoint.swift
//  Pods
//
//  Created by Kevin Tallevi on 9/22/17.
//
//

import Foundation
import CoreBluetooth
import CCToolbox
import CCBluetooth

var thisIDSStatusReaderControlPoint : IDSStatusReaderControlPoint?

public protocol IDSStatusReaderControlPointProtcol {
    func statusReaderResponseCode(code: UInt16, error: UInt8)
    func resetStatusUpdated(responseCode: UInt8)
    func numberOfActiveBolusIDS(count: UInt8)
    func bolusActiveDelivery(bolusDelivery: ActiveBolusDelivery)
    func basalActiveDelivery(basalDelivery: ActiveBasalRateDelivery)
    func totalDailyInsulinDeliveredStatus(status: TotalDailyInsulinDeliveredStatus)
    func counterValues(counter: Counter)
    func deliveredInsulin(insulinAmount: DeliveredInsulin)
    func insulinOnBoard(insulinAmount: InsulinOnBoard)
}

public class IDSStatusReaderControlPoint: NSObject {
    
    public var idsStatusReaderControlPointDelegate : IDSStatusReaderControlPointProtcol?
    public var peripheral: CBPeripheral?
    public var resetResponseCode: UInt8 = 0
    public var activeBolusIDS: Array<UInt16> = Array<UInt16>()
    
    /*
    public var bolusDelayTimePresent:Bool = false
    public var bolusTemplateNumberPresent:Bool = false
    public var bolusActivationTypePresent:Bool = false
    public var bolusDeliveryReasonCorrection:Bool = false
    public var bolusDeliveryReasonMeal:Bool = false
    */
    
    public var activeBolusDeliveries = [ActiveBolusDelivery]()
    
    public var bolusDelayTimePresentBit = 0
    public var bolusTemplateNumberPresentBit = 1
    public var bolusActivationTypePresentBit = 2
    public var bolusDeliveryReasonCorrectionBit = 3
    public var bolusDeliveryReasonMealBit = 4
    
    /*public class TotalDailyInsulinDeliveredStatus: Codable {
        let sumOfBolusDelivered: String
        let sumOfBasalDelivered: String
        let sumOfBolusAndBasalDelivered: String?
        
        init(sumOfBolusDelivered: String, sumOfBasalDelivered: String, sumOfBolusAndBasalDelivered: String?) {
            self.sumOfBolusDelivered = sumOfBolusDelivered
            self.sumOfBasalDelivered = sumOfBasalDelivered
            self.sumOfBolusAndBasalDelivered = sumOfBolusAndBasalDelivered
        }
    }*/
    
    @objc public enum StatusReaderOpCodes: UInt16 {
        case responseCode = 0x0303,
        resetStatus = 0x030C,
        getActiveBolusIds = 0x0330,
        getActiveBolusIdsResponse = 0x033F,
        getActiveBolusDelivery = 0x0356,
        getActiveBolusDeliveryResponse = 0x0359,
        getActiveBasalRateDelivery = 0x0365,
        getActiveBasalRateDeliveryResponse = 0x036A,
        getTotalDailyInsulinStatus = 0x0395,
        getTotalDailyInsulinStatusResponse = 0x039A,
        getCounter = 0x03A6,
        getCounterResponse = 0x03A9,
        getDeliveredInsulin = 0x03C0,
        getDeliveredInsulinResponse = 0x03CF,
        getInsulinOnBoard = 0x03F3,
        getInsulinOnBoardResponse = 0x03FC
    
        public var description: String {
            switch self {
            case .responseCode:
                return NSLocalizedString("Response Code", comment:"")
            case .resetStatus:
                return NSLocalizedString("Reset Status", comment:"")
            case .getActiveBolusIds:
                return NSLocalizedString("Get Active Bolus ID's", comment:"")
            case .getActiveBolusIdsResponse:
                return NSLocalizedString("Get Active Bolus ID's Response", comment:"")
            case .getActiveBolusDelivery:
                return NSLocalizedString("Get Active Bolus Delivery", comment:"")
            case .getActiveBolusDeliveryResponse:
                return NSLocalizedString("Get Active Bolus Delivery Response", comment:"")
            case .getActiveBasalRateDelivery:
                return NSLocalizedString("Get Active Basal Tate Delivery", comment:"")
            case .getActiveBasalRateDeliveryResponse:
                return NSLocalizedString("Get Active Basal Rate Delivery Response", comment:"")
            case .getTotalDailyInsulinStatus:
                return NSLocalizedString("Get Total Daily Insulin Status", comment:"")
            case .getTotalDailyInsulinStatusResponse:
                return NSLocalizedString("Get Total Daily Insulin Status Response", comment:"")
            case .getCounter:
                return NSLocalizedString("Get Counter", comment:"")
            case .getCounterResponse:
                return NSLocalizedString("Get Counter Response", comment:"")
            case .getDeliveredInsulin:
                return NSLocalizedString("Get Delivered Insulin", comment:"")
            case .getDeliveredInsulinResponse:
                return NSLocalizedString("Get Delivered Insulin Response", comment:"")
            case .getInsulinOnBoard:
                return NSLocalizedString("Get Insulin on Board", comment:"")
            case .getInsulinOnBoardResponse:
                return NSLocalizedString("Get Insulin on Board Response", comment:"")
            }
        }
    }
    
    @objc public enum StatusReaderResponseCodes: UInt8 {
        case success = 0x0F,
        op_code_not_supported = 0x70,
        invalid_operand = 0x71,
        procedure_not_completed = 0x72,
        parameter_out_of_range = 0x73,
        procedure_not_applicable = 0x74
    
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
            }
        }
    }
    
    @objc public enum BolusValueSelection: UInt8 {
        case programmed = 0x0F,
        remaining = 0x33,
        delivered = 0x3C
        
        public var description: String {
            switch self {
            case .programmed:
                return NSLocalizedString("Programmed", comment:"")
            case .remaining:
                return NSLocalizedString("Remaining", comment:"")
            case .delivered:
                return NSLocalizedString("Delivered", comment:"")
            }
        }
    }
    
    @objc public enum BolusType: UInt8 {
        case undetermined = 0x0F,
        fast = 0x33,
        extended = 0x3C,
        multiwave = 0x55
        
        public var description: String {
            switch self {
            case .undetermined:
                return NSLocalizedString("Undetermined", comment:"")
            case .fast:
                return NSLocalizedString("Fast", comment:"")
            case .extended:
                return NSLocalizedString("Extended", comment:"")
            case .multiwave:
                return NSLocalizedString("Multiwave", comment:"")
            }
        }
    }
    
    @objc public enum BolusActivationType: UInt8 {
        case undetermined = 0x0F,
        manual_bolus = 0x33,
        recommended_bolus = 0x3C,
        manually_changed_recommended_bolus = 0x55,
        commanded_bolus = 0x5A
        
        public var description: String {
            switch self {
            case .undetermined:
                return NSLocalizedString("Undetermined", comment:"")
            case .manual_bolus:
                return NSLocalizedString("Manual Bolus", comment:"")
            case .recommended_bolus:
                return NSLocalizedString("Recommended Bolus", comment:"")
            case .manually_changed_recommended_bolus:
                return NSLocalizedString("Manually Changed Recommended Bolus", comment:"")
            case .commanded_bolus:
                return NSLocalizedString("Commanded Bolus", comment:"")
            }
        }
    }
    
    @objc public enum TBRType: UInt8 {
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
    
    @objc public enum CounterTypes: UInt8 {
        case iddLifetime = 0x0F,
        iddWarrantyTime = 0x33,
        iddLoanerTime = 0x3C,
        reservoirInsulinOperationTime = 0x55
        
        public var description: String {
            switch self {
            case .iddLifetime:
                return NSLocalizedString("IDD Lifetime", comment:"")
            case .iddWarrantyTime:
                return NSLocalizedString("IDD Warranty Time", comment:"")
            case .iddLoanerTime:
                return NSLocalizedString("IDD Loaner Time", comment:"")
            case .reservoirInsulinOperationTime:
                return NSLocalizedString("Reservoir Insulin Operation Time", comment:"")
            }
        }
        
        public static let allValues = [iddLifetime, iddWarrantyTime, iddLoanerTime, reservoirInsulinOperationTime]
    }
    
    @objc public enum CounterValues: UInt8 {
        case remaining = 0x0F,
        elapsed = 0x33
        
        public var description: String {
            switch self {
            case .remaining:
                return NSLocalizedString("Remaining", comment:"")
            case .elapsed:
                return NSLocalizedString("Elapsed", comment:"")
            }
        }
    }
    
    public class func sharedInstance() -> IDSStatusReaderControlPoint {
        if thisIDSStatusReaderControlPoint == nil {
            thisIDSStatusReaderControlPoint = IDSStatusReaderControlPoint()
        }
        return thisIDSStatusReaderControlPoint!
    }
    
    public override init() {
        super.init()
        print("IDSStatusReaderControlPoint#init")
    }
    
    public init(peripheral: CBPeripheral?) {
        super.init()
        print("IDSStatusReaderControlPoint#init with peripheral")
        
        self.peripheral = peripheral
    }
    
    public func parseIDSStatusReaderControlPointResponse(data: NSData) {
        print("parseIDSStatusReaderControlPointResponse")
        
        let opCode: UInt16 = (data.subdata(with: NSRange(location:0, length: 2)) as NSData).decode()
        //let opCode: UInt16 = (opCodeBytes?.decode())!
            switch opCode {
            case StatusReaderOpCodes.responseCode.rawValue:
                self.parseResponseCodeOpCode(data: data)
            case StatusReaderOpCodes.getActiveBolusIdsResponse.rawValue:
                self.parseGetActiveBolusIDSResponse(data: data)
            case StatusReaderOpCodes.getActiveBolusDeliveryResponse.rawValue:
                self.parseGetActiveBolusDeliveryResponse(data: data)
            case StatusReaderOpCodes.getActiveBasalRateDeliveryResponse.rawValue:
                self.parseGetActiveBasalRateDeliveryResponse(data: data)
            case StatusReaderOpCodes.getTotalDailyInsulinStatusResponse.rawValue:
                self.parseGetTotalDailyInsulinStatus(data: data)
            case StatusReaderOpCodes.getCounterResponse.rawValue:
                self.parseGetCounter(data: data)
            case StatusReaderOpCodes.getDeliveredInsulinResponse.rawValue:
                self.parseDeliveredInsulinResponse(data: data)
            case StatusReaderOpCodes.getInsulinOnBoardResponse.rawValue:
                self.parseInsulinOnBoardResponse(data: data)
            default:
                print("op code not recognized")
            }
    }
    
    public func parseResponseCodeOpCode(data: NSData) {
        let opCode: Int = (data.subdata(with: NSRange(location:2, length: 2)) as NSData).decode()
        let operand: UInt8 = (data.subdata(with: NSRange(location:4, length: 1)) as NSData).decode()
        
        switch(opCode) {
            case Int(StatusReaderOpCodes.resetStatus.rawValue):
                let response: UInt8 = (data.subdata(with: NSRange(location:4, length: 1)) as NSData).decode()
                idsStatusReaderControlPointDelegate?.resetStatusUpdated(responseCode: response)
            case Int(StatusReaderOpCodes.getActiveBolusIds.rawValue):
                //print("get_active_bolus_ids error")
                idsStatusReaderControlPointDelegate?.statusReaderResponseCode(code: UInt16(opCode), error: operand)
            case Int(StatusReaderOpCodes.getActiveBolusDelivery.rawValue):
                print("get_active_bolus_delivery error")
            default:
                ()
         }
    }
    
    func parseGetActiveBolusIDSResponse(data: NSData) {
        let numberOfActiveBolusIDS: UInt8 = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        var j: Int = 0
        
        activeBolusIDS.removeAll()
        for i in 0 ..< Int(numberOfActiveBolusIDS) {
            let bolusID: UInt16 = (data.subdata(with: NSRange(location:i + j + 3, length: 2)) as NSData).decode()
            activeBolusIDS.append(bolusID)
            j += 1
        }
        idsStatusReaderControlPointDelegate?.numberOfActiveBolusIDS(count: numberOfActiveBolusIDS)
    }
    
    func parseGetActiveBolusDeliveryResponse(data: NSData) {
        let flags: UInt8 = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        let bolusID: UInt16 = (data.subdata(with: NSRange(location:3, length: 2)) as NSData).decode()
        let bolusType: UInt8 = (data.subdata(with: NSRange(location:5, length: 1)) as NSData).decode()
        let fastAmount = (data.subdata(with: NSRange(location:6, length: 2)) as NSData).shortFloatToFloat()
        let extendedAmount = (data.subdata(with: NSRange(location:8, length: 2)) as NSData).shortFloatToFloat()
        let duration: UInt16 = (data.subdata(with: NSRange(location:10, length: 2)) as NSData).decode()
        
        var delay: UInt16 = 0
        if Int(flags).bit(IDSStatusReaderControlPoint.sharedInstance().bolusDelayTimePresentBit).toBool()! {
            delay = (data.subdata(with: NSRange(location:12, length: 2)) as NSData).decode()
        }
        
        var templateNumber: UInt8 = 0
        if Int(flags).bit(IDSStatusReaderControlPoint.sharedInstance().bolusTemplateNumberPresentBit).toBool()! {
            templateNumber = (data.subdata(with: NSRange(location:14, length: 1)) as NSData).decode()
        }
        
        var activation: UInt8 = 0x0F
        if Int(flags).bit(IDSStatusReaderControlPoint.sharedInstance().bolusActivationTypePresentBit).toBool()! {
            activation = (data.subdata(with: NSRange(location:15, length: 1)) as NSData).decode()
        }
        
        let bolusDeliveryDetails = ActiveBolusDelivery(flags: flags,
                                           bolusID: bolusID,
                                           bolusType: BolusType(rawValue: bolusType)!.description,
                                           bolusFastAmount: fastAmount,
                                           bolusExtendedAmount: extendedAmount,
                                           bolusDuration: duration,
                                           bolusDelayTime: delay,
                                           bolusTemplateNumber: templateNumber,
                                           bolusActivationType: BolusActivationType(rawValue: activation)!.description)
        
        print(bolusDeliveryDetails)
        
        //addActiveBolusDelivery(delivery: bolusDeliveryDetails)
        idsStatusReaderControlPointDelegate?.bolusActiveDelivery(bolusDelivery: bolusDeliveryDetails)
    }
    
    // add for now, need to support updating later
    func addActiveBolusDelivery(delivery: ActiveBolusDelivery) {
        for bolusDelivery in activeBolusDeliveries {
            if bolusDelivery.bolusID == delivery.bolusID {
                return
            }
        }
        
        //if the bolus id is not in the array, add it
        activeBolusDeliveries.append(delivery)
    }
    
    func getActiveBolusDelivery(bolusID: UInt8) -> ActiveBolusDelivery? {
        for bolusDelivery in activeBolusDeliveries {
            if UInt8(bolusDelivery.bolusID) == bolusID {
                return bolusDelivery
            }
        }
        return nil
    }
    
    func parseGetActiveBasalRateDeliveryResponse(data: NSData) {
        let flags: UInt8 = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        //let flagBits: UInt8 = self.decode(data: flags!)
        
        let activeBasalRateProfileTemplateNumber: UInt8 = (data.subdata(with: NSRange(location:3, length: 1)) as NSData).decode()
        let currentConfigValue: Float  = (data.subdata(with: NSRange(location:4, length: 2)) as NSData).shortFloatToFloat()
        let tbrType: UInt8 = (data.subdata(with: NSRange(location:6, length: 1)) as NSData).decode()
        let tbrAdjustmentValue: Float = (data.subdata(with: NSRange(location:7, length: 2)) as NSData).shortFloatToFloat()
        let tbrDurationProgrammed: UInt16 = (data.subdata(with: NSRange(location:9, length: 2)) as NSData).swapUInt16Data().decode()
        let tbrDurationRemaining: UInt16 = (data.subdata(with: NSRange(location:11, length: 2)) as NSData).swapUInt16Data().decode()
        let tbrTemplateNumber: UInt8 = (data.subdata(with: NSRange(location:13, length: 1)) as NSData).decode()
        let context: UInt8 = (data.subdata(with: NSRange(location:14, length: 1)) as NSData).decode()
        
        let activeBasalRateDelivery = ActiveBasalRateDelivery(flags: flags,
                                                              profileTemplateNumber: activeBasalRateProfileTemplateNumber,
                                                              currentConfigValue: currentConfigValue,
                                                              tbrType: tbrType.description,
                                                              tbrAdjustmentValue: tbrAdjustmentValue,
                                                              tbrDurationProgrammed: tbrDurationProgrammed,
                                                              tbrDurationRemaining: tbrDurationRemaining,
                                                              tbrTemplateNumber: tbrTemplateNumber,
                                                              context: context.description)
        
        print(activeBasalRateDelivery)
        idsStatusReaderControlPointDelegate?.basalActiveDelivery(basalDelivery: activeBasalRateDelivery)
    }
    
    func parseGetTotalDailyInsulinStatus(data: NSData) {
        print("IDSStatusReaderControlPoint#parseGetTotalDailyInsulinStatus")
        
        let sumOfBolusDelivered: Float = (data.subdata(with: NSRange(location:2, length: 2)) as NSData).shortFloatToFloat()
        //let sumOfBolusDelivered: Float = (sumOfBolusDeliveredBytes?.shortFloatToFloat())!
        
        let sumOfBasalDelivered: Float = (data.subdata(with: NSRange(location:4, length: 2)) as NSData).shortFloatToFloat()
        //let sumOfBasalDelivered: Float = (sumOfBasalDeliveredBytes?.shortFloatToFloat())!
        
        let totalDailyDelivery = TotalDailyInsulinDeliveredStatus(totalDailyInsulinSumOfBolusDelivered: sumOfBolusDelivered,
                                                                  totalDailyInsulinSumOfBasalDelivered: sumOfBasalDelivered)
    
        print(totalDailyDelivery)
        
        idsStatusReaderControlPointDelegate?.totalDailyInsulinDeliveredStatus(status: totalDailyDelivery)
    }
    
    func parseGetCounter(data: NSData) {
        print("parseGetCounter")
        
        let counterType: UInt8 = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        //let counterType: UInt8 = (counterTypeByte?.decode())!
        
        let counterValueSelection: UInt8 = (data.subdata(with: NSRange(location:3, length: 1)) as NSData).decode()
        //let counterValueSelection: UInt8 = (counterValueSelectionByte?.decode())!
        
        let counterValueBytes = (data.subdata(with: NSRange(location:4, length: 4)) as NSData).swapUInt32Data()
        let counterValue: Int32 = counterValueBytes.decode()
        
        let counter = Counter(counterType: counterType.description,
                              counterValueSelection: counterValueSelection.description,
                              counterValue: counterValue)
    
        idsStatusReaderControlPointDelegate?.counterValues(counter: counter)
    }
    
    func parseDeliveredInsulinResponse(data: NSData) {
        print("parseDeliveredInsulinResponse")
        
        let bolusAmountDelivered: Float32 = (data.subdata(with: NSRange(location:2, length: 4)) as NSData).toFloat()
        let basalAmountDelivered: Float32 = (data.subdata(with: NSRange(location:6, length: 4)) as NSData).toFloat()
        
        let deliveredInsulin = DeliveredInsulin(bolusAmountDelivered: bolusAmountDelivered, basalAmountDelivered: basalAmountDelivered)
        idsStatusReaderControlPointDelegate?.deliveredInsulin(insulinAmount: deliveredInsulin)
    }
    
    func parseInsulinOnBoardResponse(data: NSData) {
        print("parseInsulinOnBoardResponse")
        
        let flags: UInt8 = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        let insulinOnBoard: Float = (data.subdata(with: NSRange(location:3, length: 2)) as NSData).shortFloatToFloat()
        let remainingDuration: UInt16 = (data.subdata(with: NSRange(location:5, length: 2)) as NSData).decode()
        
        let insulin = InsulinOnBoard(flags: flags, insulinOnBoard: insulinOnBoard, remainingDuration: remainingDuration)
        idsStatusReaderControlPointDelegate?.insulinOnBoard(insulinAmount: insulin)
    }
    
    //pg 108
    public func resetSensorStatus() {
        print("IDSStatusReaderControlPoint#resetStatus")
        
        let opCode: UInt16 = StatusReaderOpCodes.resetStatus.rawValue
        
        //op code, reset all bits (0xFF) , crc counter (0x00)
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0xFF, //reset all status bits
                                           0x00, //RFU
                                           0x00] as [UInt8], length: 4)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsStatusReaderControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func getActiveBolusIDs() {
        activeBolusIDS.removeAll()
        let opCode: UInt16 = StatusReaderOpCodes.getActiveBolusIds.rawValue
        
        //op code, no operand , crc counter (0x00)
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsStatusReaderControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func getActiveBolusDelivery(bolusID: UInt16) {
        let opCode: UInt16 = StatusReaderOpCodes.getActiveBolusDelivery.rawValue
        
        //op code (2 bytes), bolus id (2 bytes), value [programmed] (1 byte), crc counter (1 byte), crc (2 bytes)
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           UInt8(bolusID & 0xff),
                                           UInt8(bolusID >> 8),
                                           0x0F,
                                           0x00] as [UInt8], length: 6)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsStatusReaderControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func getActiveBasalRateDelivery() {
        let opCode: UInt16 = StatusReaderOpCodes.getActiveBasalRateDelivery.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsStatusReaderControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func getTotalDailyInsulinStatus() {
        let opCode: UInt16 = StatusReaderOpCodes.getTotalDailyInsulinStatus.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsStatusReaderControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func getCounter(counterType: UInt8) {
        let opCode: UInt16 = StatusReaderOpCodes.getCounter.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           counterType,
                                           CounterValues.remaining.rawValue,
                                           0x00] as [UInt8], length: 5)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsStatusReaderControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func getDeliveredInsulin() {
        let opCode: UInt16 = StatusReaderOpCodes.getDeliveredInsulin.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsStatusReaderControlPointCharacteristic)!), data: packet as Data)
        }
    }
    
    public func getInsulinOnBoard() {
        let opCode: UInt16 = StatusReaderOpCodes.getInsulinOnBoard.rawValue
        
        let packet = NSMutableData(bytes: [UInt8(opCode & 0xff),
                                           UInt8(opCode >> 8),
                                           0x00] as [UInt8], length: 3)
        let crc: NSData = (packet.crcMCRF4XX)
        packet.append(crc as Data)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(idsStatusReaderControlPointCharacteristic)!), data: packet as Data)
        }
    }
}
