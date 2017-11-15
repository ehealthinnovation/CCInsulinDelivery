//
//  IDSCommandData.swift
//  CCBluetooth
//
//  Created by Kevin Tallevi on 11/2/17.
//

import Foundation
import CCToolbox

var thisIDSCommandData : IDSCommandData?

public protocol IDSCommandDataProtocol {
    func therapyControlStateUpdated()
    func flightModeStatusUpdated()
    func snoozedAnnunciation(annunciation: UInt16)
    func confirmedAnnunciation(annunciation: UInt16)
    func basalRateProfileTemplate(profile: String)
}

public class IDSCommandData: NSObject {
    public var idsCommandDataDelegate : IDSCommandDataProtocol?
    public var therapyControlState: UInt8?
    public var flightModeStatus: UInt8?
    
    public class BasalRateProfileTemplate: Codable {
        let templateNumber: String
        let firstTimeBlockNumberIndex: String
        let firstDuration: String?
        let firstRate: String?
        let secondDuration: String?
        let secondRate: String?
        let thirdDuration: String?
        let thirdRate: String?
        
        init(templateNumber: String, firstTimeBlockNumberIndex: String, firstDuration: String?, firstRate: String?, secondDuration: String?, secondRate: String?, thirdDuration: String?, thirdRate: String?) {
            self.templateNumber = templateNumber
            self.firstTimeBlockNumberIndex = firstTimeBlockNumberIndex
            self.firstDuration = firstDuration
            self.firstRate = firstRate
            self.secondDuration = secondDuration
            self.secondRate = secondRate
            self.thirdDuration = thirdDuration
            self.thirdRate = thirdRate
        }
    }
    
    public class func sharedInstance() -> IDSCommandData {
        if thisIDSCommandData == nil {
            thisIDSCommandData = IDSCommandData()
        }
        return thisIDSCommandData!
    }
    
    public override init() {
        super.init()
        print("IDSCommandData#init")
    }
    
    func parseIDSCommandDataResponseCodePacket(data: NSData) {
        let opCodeBytes = (data.subdata(with: NSRange(location:2, length: 2)) as NSData!)
        let opCode: UInt16 = (opCodeBytes?.decode())!
        switch opCode {
        case IDSCommandControlPoint.CommandControlOpCodes.set_therapy_control_state.rawValue:
            parseTherapyControlStateResponse(data: data)
        case IDSCommandControlPoint.CommandControlOpCodes.set_flight_mode.rawValue:
            parseFlightModeResponse(data: data)
        default:
            ()
        }
    }
    
    public func parseIDSCommandDataResponse(data: NSData) {
        print("parseIDSCommandDataResponse")
        
        let reponseCodeBytes = (data.subdata(with: NSRange(location:0, length: 2)) as NSData!)
        let responseCode: UInt16 = (reponseCodeBytes?.decode())!
        switch responseCode {
            case IDSCommandControlPoint.CommandControlOpCodes.response_code.rawValue:
                parseIDSCommandDataResponseCodePacket(data: data)
            case IDSCommandControlPoint.CommandControlOpCodes.snooze_annunciation_response.rawValue:
                parseSnoozeAnnunciationResponse(data: data)
            case IDSCommandControlPoint.CommandControlOpCodes.confirm_annunciation_response.rawValue:
                parseConfirmAnnunciationResponse(data: data)
            case IDSCommandControlPoint.CommandControlOpCodes.read_basal_rate_profile_template_response.rawValue:
                parseReadBasalRateProfileTemplateResponse(data: data)
            default:
                ()
        }
    }
    
    func parseTherapyControlStateResponse(data: NSData) {
        print("parseTherapyControlStateResponse")
        
        let valueByte = (data.subdata(with: NSRange(location:4, length: 1)) as NSData!)
        self.therapyControlState = (valueByte?.decode())!
        idsCommandDataDelegate?.therapyControlStateUpdated()
    }
    
    func parseFlightModeResponse(data: NSData) {
        print("parseFlightModeResponse")
        
        let valueByte = (data.subdata(with: NSRange(location:4, length: 1)) as NSData!)
        self.flightModeStatus = (valueByte?.decode())!
        idsCommandDataDelegate?.flightModeStatusUpdated()
    }
    
    func parseSnoozeAnnunciationResponse(data: NSData) {
        print("parseSnoozeAnnunciationResponse")
        
        let snoozedAnnunciationBytes = (data.subdata(with: NSRange(location:2, length: 2)) as NSData!)
        let snoozedAnnunciation: UInt16 = (snoozedAnnunciationBytes?.decode())!
        idsCommandDataDelegate?.snoozedAnnunciation(annunciation: snoozedAnnunciation)
    }
    
    func parseConfirmAnnunciationResponse(data: NSData) {
        print("parseConfirmAnnunciationResponse")
        
        let confirmedAnnunciationBytes = (data.subdata(with: NSRange(location:2, length: 2)) as NSData!)
        let confirmedAnnunciation: UInt16 = (confirmedAnnunciationBytes?.decode())!
        idsCommandDataDelegate?.confirmedAnnunciation(annunciation: confirmedAnnunciation)
    }
    
    func parseReadBasalRateProfileTemplateResponse(data: NSData) {
        print("parseReadBasalRateProfileTemplateResponse")
        
        var secondDuration: UInt16?
        var thirdDuration: UInt16?
        var secondRate: Float?
        var thirdRate: Float?
        
        let flags = (data.subdata(with: NSRange(location:2, length: 1)) as NSData!)
        let flagBits: UInt8 = (flags?.decode())!
        
        let templateNumberByte = (data.subdata(with: NSRange(location:3, length: 1)) as NSData!)
        let templateNumber: UInt8 = (templateNumberByte?.decode())!
        
        let firstTimeblockIndexNumberByte = (data.subdata(with: NSRange(location:4, length: 1)) as NSData!)
        let firstTimeblockIndexNumber: UInt8 = (firstTimeblockIndexNumberByte?.decode())!
        
        let firstDurationBytes = (data.subdata(with: NSRange(location:5, length: 2)) as NSData!)
        let firstDuration: UInt8 = (firstDurationBytes?.decode())!
        
        let firstRateBytes = (data.subdata(with: NSRange(location:7, length: 2)) as NSData!)
        let firstRate: Float = (firstRateBytes?.shortFloatToFloat())!
        
        if Int(flagBits).bit(0).toBool()! {
            let secondDurationBytes = (data.subdata(with: NSRange(location:9, length: 2)) as NSData!)
            secondDuration = (secondDurationBytes?.decode())!
            
            let secondRateBytes = (data.subdata(with: NSRange(location:11, length: 2)) as NSData!)
            secondRate = secondRateBytes?.shortFloatToFloat()
        }
        
        if Int(flagBits).bit(1).toBool()! {
            let thirdDurationBytes = (data.subdata(with: NSRange(location:5, length: 2)) as NSData!)
            thirdDuration = (thirdDurationBytes?.decode())!
            
            let thirdRateBytes = (data.subdata(with: NSRange(location:7, length: 2)) as NSData!)
            thirdRate = thirdRateBytes?.shortFloatToFloat()
        }
        
        let basalRateProfileTemplate = BasalRateProfileTemplate(templateNumber: templateNumber.description,
                                         firstTimeBlockNumberIndex: firstTimeblockIndexNumber.description,
                                         firstDuration: firstDuration.description,
                                         firstRate: firstRate.description,
                                         secondDuration: secondDuration?.description,
                                         secondRate: secondRate?.description,
                                         thirdDuration: thirdDuration?.description,
                                         thirdRate: thirdRate?.description)
        print(basalRateProfileTemplate)
        
        // https://medium.com/@ashishkakkad8/use-of-codable-with-jsonencoder-and-jsondecoder-in-swift-4-71c3637a6c65
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(basalRateProfileTemplate)
            let jsonString = String(data: jsonData, encoding: .utf8)
            print("JSON String : " + jsonString!)
            idsCommandDataDelegate?.basalRateProfileTemplate(profile: jsonString!)
        }
        catch {
        }
    }
}
