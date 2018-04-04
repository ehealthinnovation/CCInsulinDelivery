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
    func commandDataResponseCode(code: UInt16, error: UInt8)
    func basalRateProfileTemplate(template: BasalRateProfileTemplate)
    func isfProfileTemplate(template: ISFProfileTemplate)
    func i2choRatioProfileTemplate(template: I2CHORatioProfileTemplate)
    func targetGlucoseRangeProfileTemplate(template: TargetGlucoseRangeProfileTemplate)
}

public class IDSCommandData: NSObject {
    public var idsCommandDataDelegate : IDSCommandDataProtocol?
    public var templatesStatusAndDetails = [TemplateStatus]()
    
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
    
    public func parseIDSCommandDataResponse(data: NSData) {
        print("parseIDSCommandDataResponse")
        let responseCode: UInt16 = (data.subdata(with: NSRange(location:0, length: 2)) as NSData).decode()
        switch responseCode {
            case IDSOpCodes.OpCodes.readBasalRateProfileTemplateResponse.rawValue:
                parseReadBasalRateProfileTemplateResponse(data: data)
            case IDSOpCodes.OpCodes.getTemplateStatusAndDetailsResponse.rawValue:
                parseGetTemplateStatusAndDetailsResponse(data: data)
            case IDSOpCodes.OpCodes.readISFProfileTemplateResponse.rawValue:
                parseReadISFProfileTemplateResponse(data: data)
            case IDSOpCodes.OpCodes.readI2CHORatioProfileTemplateResponse.rawValue:
                parseReadI2CHORatioProfileTemplateResponse(data: data)
            case IDSOpCodes.OpCodes.readTargetGlucoseRangeProfileTemplateResponse.rawValue:
                parseReadTargetGlucoseRangeProfileTemplateResponse(data: data)
            default:
            ()
        }
    }
    
    func parseReadBasalRateProfileTemplateResponse(data: NSData) {
        print("parseReadBasalRateProfileTemplateResponse")
        
        var secondDuration: UInt16 = 0
        var thirdDuration: UInt16 = 0
        var secondRate: Float = 0
        var thirdRate: Float = 0
        
        let flags: UInt8 = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        let templateNumber: UInt8 = (data.subdata(with: NSRange(location:3, length: 1)) as NSData).decode()
        let firstTimeblockIndexNumber: UInt8 = (data.subdata(with: NSRange(location:4, length: 1)) as NSData).decode()
        let firstDuration: UInt16 = (data.subdata(with: NSRange(location:5, length: 2)) as NSData).decode()
        let firstRate: Float = (data.subdata(with: NSRange(location:7, length: 2)) as NSData).shortFloatToFloat()
        
        if Int(flags).bit(0).toBool()! {
            secondDuration = (data.subdata(with: NSRange(location:9, length: 2)) as NSData).decode()
            secondRate = (data.subdata(with: NSRange(location:11, length: 2)) as NSData).shortFloatToFloat()
        }
        
        if Int(flags).bit(1).toBool()! {
            thirdDuration = (data.subdata(with: NSRange(location:13, length: 2)) as NSData).decode()
            thirdRate = (data.subdata(with: NSRange(location:15, length: 2)) as NSData).shortFloatToFloat()
        }
        
        let basalRateProfileTemplate = BasalRateProfileTemplate(templateNumber: templateNumber,
                                                                firstTimeBlockNumberIndex: firstTimeblockIndexNumber,
                                                                firstDuration: firstDuration,
                                                                firstRate: firstRate,
                                                                secondDuration: secondDuration,
                                                                secondRate: secondRate,
                                                                thirdDuration: thirdDuration,
                                                                thirdRate: thirdRate)
        print(basalRateProfileTemplate)
        
        idsCommandDataDelegate?.basalRateProfileTemplate(template: basalRateProfileTemplate)
    }
    
    func parseGetTemplateStatusAndDetailsResponse(data: NSData) {
        print("parseGetTemplateStatusAndDetailsResponse")
        
        let templateType: UInt8 = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        let startingTemplateNumber: UInt8 = (data.subdata(with: NSRange(location:3, length: 1)) as NSData).decode()
        let numberOfTemplates: UInt8 = (data.subdata(with: NSRange(location:4, length: 1)) as NSData).decode()
        let maxNumberOfSupportedTimeBlocks: UInt8 = (data.subdata(with: NSRange(location:5, length: 1)) as NSData).decode()
        let configurableAndConfiguredFlags: Int = (data.subdata(with: NSRange(location:6, length: 1)) as NSData).decode()
        
        print("template type: \(templateType)")
        print("starting template number: \(startingTemplateNumber)")
        print("number of templates: \(numberOfTemplates)")
        print("maxNumber of supported time blocks: \(maxNumberOfSupportedTimeBlocks)")
        print("configurable and configured flags: \(configurableAndConfiguredFlags)")
        
        var y: Int = 0
        for x in 0...numberOfTemplates {
            let configurable = configurableAndConfiguredFlags.bit(y).toBool()
            let configured = configurableAndConfiguredFlags.bit(y+1).toBool()
            let template = TemplateStatus(templateType: templateType,
                                          templateNumber: startingTemplateNumber + x,
                                          maxNumberOfSupportedTimeBlocks: maxNumberOfSupportedTimeBlocks,
                                          configurable: configurable!,
                                          configured: configured!)
            
            templatesStatusAndDetails.append(template)
            y+=2
        }
    }
    
    func parseReadISFProfileTemplateResponse(data: NSData) {
        print("parseReadISFProfileTemplateResponse")
        var secondDuration: UInt16 = 0
        var thirdDuration: UInt16 = 0
        var secondISF: Float = 0
        var thirdISF: Float = 0
        
        let flags: UInt8 = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        let templateNumber: UInt8 = (data.subdata(with: NSRange(location:3, length: 1)) as NSData).decode()
        let firstTimeBlockNumberIndex: UInt8 = (data.subdata(with: NSRange(location:4, length: 1)) as NSData).decode()
        let firstDuration: UInt16 = (data.subdata(with: NSRange(location:5, length: 2)) as NSData).decode()
        let firstISF = (data.subdata(with: NSRange(location:7, length: 2)) as NSData).shortFloatToFloat()
        
        if Int(flags).bit(0).toBool()! {
            secondDuration = (data.subdata(with: NSRange(location:9, length: 2)) as NSData).decode()
            secondISF = (data.subdata(with: NSRange(location:11, length: 2)) as NSData).shortFloatToFloat()
        }
        
        if Int(flags).bit(1).toBool()! {
            thirdDuration = (data.subdata(with: NSRange(location:13, length: 2)) as NSData).decode()
            thirdISF = (data.subdata(with: NSRange(location:15, length: 2)) as NSData).shortFloatToFloat()
        }
        
        let isfTemplate = ISFProfileTemplate(templateNumber: templateNumber,
                                         firstTimeBlockNumberIndex: firstTimeBlockNumberIndex,
                                         firstDuration: firstDuration,
                                         firstISF: firstISF,
                                         secondDuration: secondDuration,
                                         secondISF: secondISF,
                                         thirdDuration: thirdDuration,
                                         thirdISF: thirdISF)
        
        idsCommandDataDelegate?.isfProfileTemplate(template: isfTemplate)
    }
    
    func parseReadI2CHORatioProfileTemplateResponse(data: NSData) {
        print("parseReadI2CHORatioProfileTemplateResponse")
        
        var secondDuration: UInt16 = 0
        var thirdDuration: UInt16 = 0
        var secondRatio: Float = 0
        var thirdRatio: Float = 0
        
        let flags: UInt8 = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        let templateNumber: UInt8 = (data.subdata(with: NSRange(location:3, length: 1)) as NSData).decode()
        let firstTimeBlockNumberIndex: UInt8 = (data.subdata(with: NSRange(location:4, length: 1)) as NSData).decode()
        let firstDuration: UInt16 = (data.subdata(with: NSRange(location:5, length: 2)) as NSData).decode()
        let firstRatio = (data.subdata(with: NSRange(location:7, length: 2)) as NSData).shortFloatToFloat()
        
        if Int(flags).bit(0).toBool()! {
            secondDuration = (data.subdata(with: NSRange(location:9, length: 2)) as NSData).decode()
            secondRatio = (data.subdata(with: NSRange(location:11, length: 2)) as NSData).shortFloatToFloat()
        }
        
        if Int(flags).bit(1).toBool()! {
            thirdDuration = (data.subdata(with: NSRange(location:13, length: 2)) as NSData).decode()
            thirdRatio = (data.subdata(with: NSRange(location:15, length: 2)) as NSData).shortFloatToFloat()
        }
        
        let i2choTemplate = I2CHORatioProfileTemplate(templateNumber: templateNumber,
                                                      firstTimeBlockNumberIndex: firstTimeBlockNumberIndex,
                                                      firstDuration: firstDuration,
                                                      firstI2CHORatio: firstRatio,
                                                      secondDuration: secondDuration,
                                                      secondI2CHORatio: secondRatio,
                                                      thirdDuration: thirdDuration,
                                                      thirdI2CHORatio: thirdRatio)
        
        idsCommandDataDelegate?.i2choRatioProfileTemplate(template: i2choTemplate)
    }
    
    func parseReadTargetGlucoseRangeProfileTemplateResponse(data: NSData) {
        print("parseReadTargetGlucoseRangeProfileTemplateResponse")
        
        var secondDuration: UInt16 = 0
        var secondLowerTargetGlucoseLimit: Float = 0
        var secondUpperTargetGlucoseLimit: Float = 0
        
        let flags: UInt8 = (data.subdata(with: NSRange(location:2, length: 1)) as NSData).decode()
        let templateNumber: UInt8 = (data.subdata(with: NSRange(location:3, length: 1)) as NSData).decode()
        let firstTimeBlockNumberIndex: UInt8 = (data.subdata(with: NSRange(location:4, length: 1)) as NSData).decode()
        let firstDuration: UInt16 = (data.subdata(with: NSRange(location:5, length: 2)) as NSData).decode()
        let firstLowerTargetGlucoseLimit = (data.subdata(with: NSRange(location:7, length: 2)) as NSData).shortFloatToFloat()
        let firstUpperTargetGlucoseLimit = (data.subdata(with: NSRange(location:9, length: 2)) as NSData).shortFloatToFloat()
        
        if Int(flags).bit(1).toBool()! {
            secondDuration = (data.subdata(with: NSRange(location:11, length: 2)) as NSData).decode()
            secondLowerTargetGlucoseLimit = (data.subdata(with: NSRange(location:13, length: 2)) as NSData).shortFloatToFloat()
            secondUpperTargetGlucoseLimit = (data.subdata(with: NSRange(location:15, length: 2)) as NSData).shortFloatToFloat()
        }
        
        let targetGlucoseRangeProfileTemplate = TargetGlucoseRangeProfileTemplate(templateNumber: templateNumber,
                                                         firstTimeBlockNumberIndex: firstTimeBlockNumberIndex,
                                                         firstDuration: firstDuration,
                                                         firstLowerTargetGlucoseLimit: firstLowerTargetGlucoseLimit,
                                                         firstUpperTargetGlucoseLimit: firstUpperTargetGlucoseLimit,
                                                         secondDuration: secondDuration,
                                                         secondLowerTargetGlucoseLimit: secondLowerTargetGlucoseLimit,
                                                         secondUpperTargetGlucoseLimit: secondUpperTargetGlucoseLimit)
        
        idsCommandDataDelegate?.targetGlucoseRangeProfileTemplate(template: targetGlucoseRangeProfileTemplate)
    }
}
