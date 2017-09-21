//
//  IDSFeatures.swift
//  Pods
//
//  Created by Kevin Tallevi on 9/13/17.
//
//

import CCToolbox

public class IDSFeatures : NSObject {
    var features: Int = 0
    
    private var e2eProtectionSupportedBit = 0
    private var basalRateSupportedBit = 1
    private var tbrAbsoluteSupportedBit = 2
    private var tbrRelativeSupportedBit = 3
    private var tbrTemplateSupportedBit = 4
    private var fastBolusSupportedBit = 5
    private var extendedBolusSupportedBit = 6
    private var multiwaveBolusSupportedBit = 7
    private var bolusDelayTimeSupportedBit = 8
    private var bolusTemplateSupportedBit = 9
    private var bolusActivationTypeSupportedBit = 10
    private var multipleBondSupportedBit = 11
    private var isfProfileTemplateSupportedBit = 12
    private var i2choRatioProfileTemplateSupportedBit = 13
    private var targetGlucoseRangeProfileTemplateSupportedBit = 14
    private var insulinOnBoardSupportedBit = 15
    private var featureExtensionBit = 16
    private var glucoseConcentrationBit = 17

    
    public var e2eProtectionSupported: Bool?
    public var basalRateSupported: Bool?
    public var tbrAbsoluteSupported: Bool?
    public var tbrRelativeSupported: Bool?
    public var tbrTemplateSupported: Bool?
    public var fastBolusSupported: Bool?
    public var extendedBolusSupported: Bool?
    public var multiwaveBolusSupported: Bool?
    public var bolusDelayTimeSupported: Bool?
    public var bolusTemplateSupported: Bool?
    public var bolusActivationTypeSupported: Bool?
    public var multipleBondSupported: Bool?
    public var isfProfileTemplateSupported: Bool?
    public var i2choRatioProfileTemplateSupported: Bool?
    public var targetGlucoseRangeProfileTemplateSupported: Bool?
    public var insulinOnBoardSupported: Bool?
    public var featureExtension: Bool?
    public var glucoseConcentration: Float?
    
    
    public init(data: NSData?) {
        print("IDSFeatures#init - \(String(describing: data))")
        
        let featureBytes = (data?.subdata(with: NSRange(location:1, length: 2)) as NSData!)
        var featureBits:Int = 0
        featureBytes?.getBytes(&featureBits, length: MemoryLayout<UInt32>.size)
        
        let glucoseConcentrationBytes = (data?.subdata(with: NSRange(location:3, length: 2)) as NSData!)
        glucoseConcentration = glucoseConcentrationBytes!.shortFloatToFloat()
        
        e2eProtectionSupported = featureBits.bit(e2eProtectionSupportedBit).toBool()
        basalRateSupported = featureBits.bit(basalRateSupportedBit).toBool()
        tbrAbsoluteSupported = featureBits.bit(tbrAbsoluteSupportedBit).toBool()
        tbrRelativeSupported = featureBits.bit(tbrRelativeSupportedBit).toBool()
        tbrTemplateSupported = featureBits.bit(tbrTemplateSupportedBit).toBool()
        fastBolusSupported = featureBits.bit(fastBolusSupportedBit).toBool()
        extendedBolusSupported = featureBits.bit(extendedBolusSupportedBit).toBool()
        multiwaveBolusSupported = featureBits.bit(multiwaveBolusSupportedBit).toBool()
        bolusDelayTimeSupported = featureBits.bit(bolusDelayTimeSupportedBit).toBool()
        bolusTemplateSupported = featureBits.bit(bolusTemplateSupportedBit).toBool()
        bolusActivationTypeSupported = featureBits.bit(bolusActivationTypeSupportedBit).toBool()
        multipleBondSupported = featureBits.bit(multipleBondSupportedBit).toBool()
        isfProfileTemplateSupported = featureBits.bit(isfProfileTemplateSupportedBit).toBool()
        i2choRatioProfileTemplateSupported = featureBits.bit(i2choRatioProfileTemplateSupportedBit).toBool()
        targetGlucoseRangeProfileTemplateSupported = featureBits.bit(targetGlucoseRangeProfileTemplateSupportedBit).toBool()
        insulinOnBoardSupported = featureBits.bit(insulinOnBoardSupportedBit).toBool()
        featureExtension = featureBits.bit(featureExtensionBit).toBool()
    }
}
