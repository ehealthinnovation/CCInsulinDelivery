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
    func bolusActiveDelivery(bolusDelivery: String)
    func basalActiveDelivery(basalDelivery: String)
    func totalDailyInsulinDeliveredStatus(status: String)
    func counterValues(counter: String)
    func deliveredInsulin(insulinAmount: String)
    func insulinOnBoard(insulinAmount: String)
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
    
    public class ActiveBolusDelivery: Codable {
        let bolusID: String
        let bolusType: String
        let bolusFastAmount: String?
        let bolusExtendedAmount: String?
        let bolusDuration: String?
        let bolusDelayTime: String?
        let bolusTemplateNumber: String?
        let bolusActivationType: String?
    
        init(bolusID: String, bolusType: String, bolusFastAmount: String?, bolusExtendedAmount: String?, bolusDuration: String?, bolusDelayTime: String?, bolusTemplateNumber: String?, bolusActivationType: String?) {
            self.bolusID = bolusID
            self.bolusType = bolusType
            self.bolusFastAmount = bolusFastAmount
            self.bolusExtendedAmount = bolusExtendedAmount
            self.bolusDuration = bolusDuration
            self.bolusDelayTime = bolusDelayTime
            self.bolusTemplateNumber = bolusTemplateNumber
            self.bolusActivationType = bolusActivationType
        }
    }
    
    public class ActiveBasalRateDelivery: Codable {
        let profileTemplateNumber: String
        let currentConfigValue: String
        let tbrType: String?
        let tbrAdjustmentValue: String?
        let tbrDurationProgrammed: String?
        let tbrDurationRemaining: String?
        let tbrTemplateNumber: String?
        let context: String?
        
        init(profileTemplateNumber: String, currentConfigValue: String, tbrType: String?, tbrAdjustmentValue: String?, tbrDurationProgrammed: String?, tbrDurationRemaining: String?, tbrTemplateNumber: String?, context: String?) {
                self.profileTemplateNumber = profileTemplateNumber
                self.currentConfigValue = currentConfigValue
                self.tbrType = tbrType
                self.tbrAdjustmentValue = tbrAdjustmentValue
                self.tbrDurationProgrammed = tbrDurationProgrammed
                self.tbrDurationRemaining = tbrDurationRemaining
                self.tbrTemplateNumber = tbrTemplateNumber
                self.context = context
        }
    }
    
    public class TotalDailyInsulinDeliveredStatus: Codable {
        let sumOfBolusDelivered: String
        let sumOfBasalDelivered: String
        let sumOfBolusAndBasalDelivered: String?
        
        init(sumOfBolusDelivered: String, sumOfBasalDelivered: String, sumOfBolusAndBasalDelivered: String?) {
            self.sumOfBolusDelivered = sumOfBolusDelivered
            self.sumOfBasalDelivered = sumOfBasalDelivered
            self.sumOfBolusAndBasalDelivered = sumOfBolusAndBasalDelivered
        }
    }
    
    private var bolusDelayTimePresentBit = 0
    private var bolusTemplateNumberPresentBit = 1
    private var bolusActivationTypePresentBit = 2
    private var bolusDeliveryReasonCorrectionBit = 3
    private var bolusDeliveryReasonMealBit = 4
    
    
    @objc public enum StatusReaderOpCodes: UInt16 {
        case response_code = 0x0303,
        reset_status = 0x030C,
        get_active_bolus_ids = 0x0330,
        get_active_bolus_ids_response = 0x033F,
        get_active_bolus_delivery = 0x0356,
        get_active_bolus_delivery_response = 0x0359,
        get_active_basal_rate_delivery = 0x0365,
        get_active_basal_rate_delivery_response = 0x036A,
        get_total_daily_insulin_status = 0x0395,
        get_total_daily_insulin_status_response = 0x039A,
        get_counter = 0x03A6,
        get_counter_response = 0x03A9,
        get_delivered_insulin = 0x03C0,
        get_delivered_insulin_response = 0x03CF,
        get_insulin_on_board = 0x03F3,
        get_insulin_on_board_response = 0x03FC
    
        public var description: String {
            switch self {
            case .response_code:
                return NSLocalizedString("Response Code", comment:"")
            case .reset_status:
                return NSLocalizedString("Reset Status", comment:"")
            case .get_active_bolus_ids:
                return NSLocalizedString("Get Active Bolus ID's", comment:"")
            case .get_active_bolus_ids_response:
                return NSLocalizedString("Get Active Bolus ID's Response", comment:"")
            case .get_active_bolus_delivery:
                return NSLocalizedString("Get Active Bolus Delivery", comment:"")
            case .get_active_bolus_delivery_response:
                return NSLocalizedString("Get Active Bolus Delivery Response", comment:"")
            case .get_active_basal_rate_delivery:
                return NSLocalizedString("Get Active Basal Tate Delivery", comment:"")
            case .get_active_basal_rate_delivery_response:
                return NSLocalizedString("Get Active Basal Rate Delivery Response", comment:"")
            case .get_total_daily_insulin_status:
                return NSLocalizedString("Get Total Daily Insulin Status", comment:"")
            case .get_total_daily_insulin_status_response:
                return NSLocalizedString("Get Total Daily Insulin Status Response", comment:"")
            case .get_counter:
                return NSLocalizedString("Get Counter", comment:"")
            case .get_counter_response:
                return NSLocalizedString("Get Counter Response", comment:"")
            case .get_delivered_insulin:
                return NSLocalizedString("Get Delivered Insulin", comment:"")
            case .get_delivered_insulin_response:
                return NSLocalizedString("Get Delivered Insulin Response", comment:"")
            case .get_insulin_on_board:
                return NSLocalizedString("Get Insulin on Board", comment:"")
            case .get_insulin_on_board_response:
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
    
    public class Counter: Codable {
        let counterType: String
        let counterValueSelection: String
        let counterValue: String?
        
        init(counterType: String, counterValueSelection: String, counterValue: String?) {
            self.counterType = counterType
            self.counterValueSelection = counterValueSelection
            self.counterValue = counterValue
        }
    }
    
    public class DeliveredInsulin: Codable {
        let bolusAmountDelivered: String
        let basalAmountDelivered: String
        
        init(bolusAmountDelivered: String, basalAmountDelivered: String) {
            self.bolusAmountDelivered = bolusAmountDelivered
            self.basalAmountDelivered = basalAmountDelivered
        }
    }
    
    public class InsulinOnBoard: Codable {
        let insulinOnBoard: String
        let remainingDuration: String
        
        init(insulinOnBoard: String, remainingDuration: String) {
            self.insulinOnBoard = insulinOnBoard
            self.remainingDuration = remainingDuration
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
        
        let opCodeBytes = (data.subdata(with: NSRange(location:0, length: 2)) as NSData!)
        let opCode: UInt16 = (opCodeBytes?.decode())!
            switch opCode {
            case StatusReaderOpCodes.response_code.rawValue:
                print("response code")
                self.parseResponseCodeOpCode(data: data)
            case StatusReaderOpCodes.get_active_bolus_ids_response.rawValue:
                self.parseGetActiveBolusIDSResponse(data: data)
            case StatusReaderOpCodes.get_active_bolus_delivery_response.rawValue:
                self.parseGetActiveBolusDeliveryResponse(data: data)
            case StatusReaderOpCodes.get_active_basal_rate_delivery_response.rawValue:
                self.parseGetActiveBasalRateDeliveryResponse(data: data)
            case StatusReaderOpCodes.get_total_daily_insulin_status_response.rawValue:
                self.parseGetTotalDailyInsulinStatus(data: data)
            case StatusReaderOpCodes.get_counter_response.rawValue:
                self.parseGetCounter(data: data)
            case StatusReaderOpCodes.get_delivered_insulin_response.rawValue:
                self.parseDeliveredInsulinResponse(data: data)
            case StatusReaderOpCodes.get_insulin_on_board_response.rawValue:
                self.parseInsulinOnBoardResponse(data: data)
            default:
                print("op code not recognized")
            }
    }
    
    public func parseResponseCodeOpCode(data: NSData) {
        let opCode: Int = (data.subdata(with: NSRange(location:2, length: 2)) as NSData!).decode()
        let operand: UInt8 = (data.subdata(with: NSRange(location:4, length: 1)) as NSData!).decode()
        
        switch(opCode) {
            case Int(StatusReaderOpCodes.reset_status.rawValue):
                let response: UInt8 = (data.subdata(with: NSRange(location:4, length: 1)) as NSData!).decode()
                idsStatusReaderControlPointDelegate?.resetStatusUpdated(responseCode: response)
            case Int(StatusReaderOpCodes.get_active_bolus_ids.rawValue):
                //print("get_active_bolus_ids error")
                idsStatusReaderControlPointDelegate?.statusReaderResponseCode(code: UInt16(opCode), error: operand)
            case Int(StatusReaderOpCodes.get_active_bolus_delivery.rawValue):
                print("get_active_bolus_delivery error")
            default:
                ()
         }
    }
    
    func parseGetActiveBolusIDSResponse(data: NSData) {
        let number = (data.subdata(with: NSRange(location:2, length: 1)) as NSData!)
        let numberOfActiveBolusIDS: UInt8 = number!.decode()
        var j: Int = 0
        
        activeBolusIDS.removeAll()
        for i in 0 ..< Int(numberOfActiveBolusIDS) {
            let bolusID: UInt16 = (data.subdata(with: NSRange(location:i + j + 3, length: 2)) as NSData!).decode()
            activeBolusIDS.append(bolusID)
            j += 1
        }
        idsStatusReaderControlPointDelegate?.numberOfActiveBolusIDS(count: numberOfActiveBolusIDS)
    }
    
    func parseGetActiveBolusDeliveryResponse(data: NSData) {
        var fastRemainingAmount: Float = 0
        
        let bolusIDBytes  = (data.subdata(with: NSRange(location:3, length: 2)) as NSData!).swapUInt16Data()
        let bolusID: UInt16 = bolusIDBytes.decode()
        let bolusTypeByte  = (data.subdata(with: NSRange(location:5, length: 1)) as NSData!)
        let bolusType: UInt8 = (bolusTypeByte?.decode())!
 
        switch(BolusType(rawValue: bolusType)!.description) {
            case "Undetermined":
                print("Undetermined")
            case "Fast":
                print("Fast")
                let fastRemainingAmountBytes  = (data.subdata(with: NSRange(location:6, length: 2)) as NSData!)
                fastRemainingAmount = (fastRemainingAmountBytes?.shortFloatToFloat())!
            case "Extended":
                print("Extended")
            case "Multiwave":
                print("Multiwave")
            default:
                ()
        }
        
        let bolusDelayBytes  = (data.subdata(with: NSRange(location:12, length: 2)) as NSData!).swapUInt16Data()
        let bolusDelay: UInt16 = bolusDelayBytes.decode()
        
        let bolusTemplateNumberBytes  = (data.subdata(with: NSRange(location:14, length: 1)) as NSData!)
        let bolusTemplateNumber: UInt8 = (bolusTemplateNumberBytes?.decode())!
        
        let bolusActivationBytes  = (data.subdata(with: NSRange(location:15, length: 1)) as NSData!)
        let bolusActivation: UInt8 = (bolusActivationBytes?.decode())!
        
        let bolusDeliveryDetails = ActiveBolusDelivery(bolusID: bolusID.description,
                                           bolusType: BolusType(rawValue: bolusType)!.description,
                                           bolusFastAmount: fastRemainingAmount.description,
                                           bolusExtendedAmount: "",
                                           bolusDuration: "",
                                           bolusDelayTime: bolusDelay.description,
                                           bolusTemplateNumber: bolusTemplateNumber.description,
                                           bolusActivationType: BolusActivationType(rawValue: bolusActivation)!.description)
        
        print(bolusDeliveryDetails)
        
        addActiveBolusDelivery(delivery: bolusDeliveryDetails)
        
        // https://medium.com/@ashishkakkad8/use-of-codable-with-jsonencoder-and-jsondecoder-in-swift-4-71c3637a6c65
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(bolusDeliveryDetails)
            let jsonString = String(data: jsonData, encoding: .utf8)
            print("JSON String : " + jsonString!)
            idsStatusReaderControlPointDelegate?.bolusActiveDelivery(bolusDelivery: jsonString!)
        }
        catch {
        }
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
        //let flags = (data.subdata(with: NSRange(location:2, length: 1)) as NSData!)
        //let flagBits: UInt8 = self.decode(data: flags!)
        
        let profileTemplateNumberByte = (data.subdata(with: NSRange(location:3, length: 1)) as NSData!)
        let profileTemplateNumber: UInt8 = (profileTemplateNumberByte?.decode())!
        
        let currentConfigValueBytes = (data.subdata(with: NSRange(location:4, length: 2)) as NSData!)
        let currentConfigValue: Float = (currentConfigValueBytes?.shortFloatToFloat())!
        
        let tbrTypeByte = (data.subdata(with: NSRange(location:6, length: 1)) as NSData!)
        let tbrType: UInt8 = (tbrTypeByte?.decode())!
        
        let tbrAdjustmentValueBytes = (data.subdata(with: NSRange(location:7, length: 2)) as NSData!)
        let tbrAdjustmentValue: Float = (tbrAdjustmentValueBytes?.shortFloatToFloat())!
    
        let tbrDurationProgrammedBytes = (data.subdata(with: NSRange(location:9, length: 2)) as NSData!).swapUInt16Data()
        let tbrDurationProgrammed: UInt16 = tbrDurationProgrammedBytes.decode()
    
        let tbrDurationRemainingBytes = (data.subdata(with: NSRange(location:11, length: 2)) as NSData!).swapUInt16Data()
        let tbrDurationRemaining: UInt16 = tbrDurationRemainingBytes.decode()
    
        let tbrTemplateNumberByte = (data.subdata(with: NSRange(location:13, length: 1)) as NSData!)
        let tbrTemplateNumber: UInt8 = (tbrTemplateNumberByte?.decode())!
    
        let contextByte = (data.subdata(with: NSRange(location:14, length: 1)) as NSData!)
        let context: UInt8 = (contextByte?.decode())!
    
        let activeBasalRateDelivery = ActiveBasalRateDelivery(profileTemplateNumber: profileTemplateNumber.description,
                                                              currentConfigValue: currentConfigValue.description,
                                                              tbrType: tbrType.description,
                                                              tbrAdjustmentValue: tbrAdjustmentValue.description,
                                                              tbrDurationProgrammed: tbrDurationProgrammed.description,
                                                              tbrDurationRemaining: tbrDurationRemaining.description,
                                                              tbrTemplateNumber: tbrTemplateNumber.description,
                                                              context: context.description)
        
        print(activeBasalRateDelivery)
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(activeBasalRateDelivery)
            let jsonString = String(data: jsonData, encoding: .utf8)
            print("JSON String : " + jsonString!)
            idsStatusReaderControlPointDelegate?.basalActiveDelivery(basalDelivery: jsonString!)
        }
        catch {
        }
    }
    
    func parseGetTotalDailyInsulinStatus(data: NSData) {
        print("IDSStatusReaderControlPoint#parseGetTotalDailyInsulinStatus")
        
        let sumOfBolusDeliveredBytes = (data.subdata(with: NSRange(location:2, length: 2)) as NSData!)
        let sumOfBolusDelivered: Float = (sumOfBolusDeliveredBytes?.shortFloatToFloat())!
        
        let sumOfBasalDeliveredBytes = (data.subdata(with: NSRange(location:4, length: 2)) as NSData!)
        let sumOfBasalDelivered: Float = (sumOfBasalDeliveredBytes?.shortFloatToFloat())!
        
        let sumOfBolusAndBasalDeliveredBytes = (data.subdata(with: NSRange(location:6, length: 2)) as NSData!)
        let sumOfBolusAndBasalDelivered: Float = (sumOfBolusAndBasalDeliveredBytes?.shortFloatToFloat())!
   
        let totalDailyDelivery = TotalDailyInsulinDeliveredStatus(sumOfBolusDelivered: sumOfBolusDelivered.description,
                                                                  sumOfBasalDelivered: sumOfBasalDelivered.description,
                                                                  sumOfBolusAndBasalDelivered: sumOfBolusAndBasalDelivered.description)
    
        print(totalDailyDelivery)
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(totalDailyDelivery)
            let jsonString = String(data: jsonData, encoding: .utf8)
            print("JSON String : " + jsonString!)
            idsStatusReaderControlPointDelegate?.totalDailyInsulinDeliveredStatus(status: jsonString!)
        }
        catch {
        }
    }
    
    func parseGetCounter(data: NSData) {
        print("parseGetCounter")
        
        let counterTypeByte = (data.subdata(with: NSRange(location:2, length: 1)) as NSData!)
        let counterType: UInt8 = (counterTypeByte?.decode())!
        
        let counterValueSelectionByte = (data.subdata(with: NSRange(location:3, length: 1)) as NSData!)
        let counterValueSelection: UInt8 = (counterValueSelectionByte?.decode())!
        
        let counterValueBytes = (data.subdata(with: NSRange(location:4, length: 4)) as NSData!).swapUInt32Data()
        let counterValue: UInt32 = counterValueBytes.decode()
        
        let counter = Counter(counterType: counterType.description,
                              counterValueSelection: counterValueSelection.description,
                              counterValue: counterValue.description)
    
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(counter)
            let jsonString = String(data: jsonData, encoding: .utf8)
            print("JSON String : " + jsonString!)
            idsStatusReaderControlPointDelegate?.counterValues(counter: jsonString!)
        }
        catch {
        }
    }
    
    func parseDeliveredInsulinResponse(data: NSData) {
        print("parseDeliveredInsulinResponse")
        
        let bolusAmountDeliveredBytes = (data.subdata(with: NSRange(location:2, length: 4)) as NSData!).swapUInt32Data()
        let bolusAmountDelivered: Float32 = bolusAmountDeliveredBytes.toFloat()
        
        let basalAmountDeliveredBytes = (data.subdata(with: NSRange(location:6, length: 4)) as NSData!).swapUInt32Data()
        let basalAmountDelivered: Float32 = basalAmountDeliveredBytes.toFloat()
        
        let deliveredInsulin = DeliveredInsulin(bolusAmountDelivered: bolusAmountDelivered.description, basalAmountDelivered: basalAmountDelivered.description)
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(deliveredInsulin)
            let jsonString = String(data: jsonData, encoding: .utf8)
            print("JSON String : " + jsonString!)
            idsStatusReaderControlPointDelegate?.deliveredInsulin(insulinAmount: jsonString!)
        }
        catch {
        }
    }
    
    func parseInsulinOnBoardResponse(data: NSData) {
        print("parseInsulinOnBoardResponse")
        
        let insulinOnBoardBytes = (data.subdata(with: NSRange(location:3, length: 2)) as NSData!)
        let insulinOnBoard: Float = (insulinOnBoardBytes?.shortFloatToFloat())!
    
        let remainingDurationBytes = (data.subdata(with: NSRange(location:5, length: 2)) as NSData!).swapUInt16Data()
        let remainingDuration: UInt16 = remainingDurationBytes.decode()
    
        let insulin = InsulinOnBoard(insulinOnBoard: insulinOnBoard.description, remainingDuration: remainingDuration.description)
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(insulin)
            let jsonString = String(data: jsonData, encoding: .utf8)
            print("JSON String : " + jsonString!)
            idsStatusReaderControlPointDelegate?.insulinOnBoard(insulinAmount: jsonString!)
        }
        catch {
        }
    }
    
    //pg 108
    public func resetSensorStatus() {
        print("IDSStatusReaderControlPoint#resetStatus")
        
        let opCode: UInt16 = StatusReaderOpCodes.reset_status.rawValue
        
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
        let opCode: UInt16 = StatusReaderOpCodes.get_active_bolus_ids.rawValue
        
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
        let opCode: UInt16 = StatusReaderOpCodes.get_active_bolus_delivery.rawValue
        
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
        let opCode: UInt16 = StatusReaderOpCodes.get_active_basal_rate_delivery.rawValue
        
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
        let opCode: UInt16 = StatusReaderOpCodes.get_total_daily_insulin_status.rawValue
        
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
        let opCode: UInt16 = StatusReaderOpCodes.get_counter.rawValue
        
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
        let opCode: UInt16 = StatusReaderOpCodes.get_delivered_insulin.rawValue
        
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
        let opCode: UInt16 = StatusReaderOpCodes.get_insulin_on_board.rawValue
        
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
