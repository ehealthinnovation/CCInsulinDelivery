//
//  SessionViewController.swift
//  CCInsulinDelivery_Example
//
//  Created by Kevin Tallevi on 3/5/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

//TO-DO: fix deviceCoding type on BGM,CGM
//       dialog to enter IU and duration on the session screen
//       PRIVATE THE REPOS!

import Foundation
import UIKit
import CCInsulinDelivery
import SMART
import UICircularProgressRing

class SessionViewController: UIViewController, UICircularProgressRingDelegate {
    @IBOutlet weak var fastBolusButton: UIButton!
    @IBOutlet weak var extendedBolusButton: UIButton!
    @IBOutlet weak var batteryLevelLabel: UILabel!
    @IBOutlet weak var insulinRemainingLabel: UILabel!
    @IBOutlet weak var insulinRemainingRing: UICircularProgressRingView!
    @IBOutlet weak var patientFirstName: UILabel!
    @IBOutlet weak var patientLastName: UILabel!
    @IBOutlet weak var patientFHIRID: UILabel!
    @IBOutlet weak var manufacturerName: UILabel!
    @IBOutlet weak var modelNumber: UILabel!
    @IBOutlet weak var deviceFHIRID: UILabel!
    
    var insulinRemaining: Float = 180
    var medicationRequest: MedicationRequest?
    var medicationAdministration: MedicationAdministration?
    var bolusDeliveryInProgress: Bool?
    
    struct activeBolusDelivery: Codable {
        var bolusID: UInt16?
        var inProgress: Bool?
        var isFinished: Bool?
        var administrationAmount: Float
        var deliveredAmount: Float
        var duration: Float
        var medicationRequestID: Int?
        
        init(bolusID: UInt16?, inProgress: Bool?, isFinished: Bool?, administrationAmount: Float, deliveredAmount: Float, duration: Float, medicationRequestID: Int?) {
            self.bolusID = bolusID
            self.inProgress = inProgress
            self.isFinished = isFinished
            self.administrationAmount = Float(Double(administrationAmount).rounded(toPlaces: 2))  //roundf(administrationAmount * 100) / 100
            self.deliveredAmount = deliveredAmount
            self.duration = duration
            self.medicationRequestID = medicationRequestID
        }
    }
    var bolusDelivery: activeBolusDelivery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        insulinRemainingRing.animationStyle = kCAMediaTimingFunctionLinear
        
        IDS.sharedInstance().readStatus()
        IDS.sharedInstance().idsBatteryDelete = self
        IDS.sharedInstance().idsDelegate = self
        IDSCommandControlPoint.sharedInstance().idsCommandControlPointDelegate = self
        IDSStatusReaderControlPoint.sharedInstance().idsStatusReaderControlPointDelegate = self
        IDS.sharedInstance().readBatteryLevel()
        IDS.sharedInstance().readStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //patientFirstName.text = IDSFhir.IDSFhirInstance.patient?.name?.first?.given?.first?.description
        //patientLastName.text = IDSFhir.IDSFhirInstance.patient?.name?.last?.family?.description
        patientFirstName.text = IDSFhir.IDSFhirInstance.givenName.description
        patientLastName.text = IDSFhir.IDSFhirInstance.familyName.description
        patientFHIRID.text = IDSFhir.IDSFhirInstance.patient?.id?.description
        manufacturerName.text = IDS.sharedInstance().manufacturerName?.description
        modelNumber.text = IDS.sharedInstance().modelNumber?.description
        deviceFHIRID.text = IDSFhir.IDSFhirInstance.device?.id?.description
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
            action.isEnabled = true
        })
        self.present(alert, animated: true)
    }
    
    @IBAction func fastBolusButtonAction(_ sender: Any) {
        if insulinRemaining <= 2.1 {
            showAlert(title: "Insufficient insulin for delivery", message: "")
            return
        }
        
        buttonsEnabled(enabled: false)
        
        self.bolusDelivery = activeBolusDelivery(bolusID: nil, inProgress: false, isFinished: false, administrationAmount:2.1, deliveredAmount:0, duration: 0, medicationRequestID: nil)
        let date = Date()
        if IDSFhir.IDSFhirInstance.patient != nil {
            IDSFhir.IDSFhirInstance.createMedicationRequest(amount: 2.1, duration: 0, onDate: date) { (medicationRequest, error) -> Void in
                if let error = error {
                    print("error creating medication request: \(error)")
                    self.showAlert(title: "FHIR Error", message: "error creating medication request")
                }
                
                if error == nil {
                    print("medication request created with id: \(medicationRequest.id!)")
                    self.bolusDelivery?.medicationRequestID = Int((medicationRequest.id?.description)!)
                }
            }
        }
        
        IDSCommandControlPoint.sharedInstance().setBolus(fastAmount: 2.1,
                                                         extendedAmount: 0,
                                                         duration: 0,
                                                         delayTime: 0,
                                                         templateNumber: 0,
                                                         activationType: 0,
                                                         bolusDeliveryReasonCorrection: false,
                                                         bolusDeliveryReasonMeal: false)
    }
    
    @IBAction func extendedBolusButtonAction(_ sender: Any) {
        if insulinRemaining <= 5.0 {
            showAlert(title: "Insufficient insulin for delivery", message: "")
            return
        }
        
        buttonsEnabled(enabled: false)
        
        self.bolusDelivery = activeBolusDelivery(bolusID: nil, inProgress: false, isFinished: false, administrationAmount:5.0, deliveredAmount:0, duration: 5, medicationRequestID: nil)
        let date = Date()
        if IDSFhir.IDSFhirInstance.patient != nil {
            IDSFhir.IDSFhirInstance.createMedicationRequest(amount: 5.0, duration: 30, onDate: date) { (medicationRequest, error) -> Void in
                if let error = error {
                    print("error creating medication request: \(error)")
                    self.showAlert(title: "FHIR Error", message: "error creating medication request")
                }
                
                if error == nil {
                    print("medication request created with id: \(medicationRequest.id!)")
                    self.bolusDelivery?.medicationRequestID = Int((medicationRequest.id?.description)!)
                }
            }
        }
        IDSCommandControlPoint.sharedInstance().setBolus(fastAmount: 0,
                                                         extendedAmount: 5.0,
                                                         duration: 5,
                                                         delayTime: 0,
                                                         templateNumber: 0,
                                                         activationType: 0,
                                                         bolusDeliveryReasonCorrection: false,
                                                         bolusDeliveryReasonMeal: false)
    }

    func buttonsEnabled(enabled: Bool) {
        if enabled {
            fastBolusButton.isEnabled = true
            fastBolusButton.alpha = 1.0
            extendedBolusButton.isEnabled = true
            extendedBolusButton.alpha = 1.0
        } else {
            fastBolusButton.isEnabled = false
            fastBolusButton.alpha = 0.5
            extendedBolusButton.isEnabled = false
            extendedBolusButton.alpha = 0.5
        }
    }
}

extension SessionViewController: IDSProtocol {
    func IDSFeatures(features: IDSFeatures) {
        ()
    }
    
    func IDSStatusChanged(statusChanged: IDSStatusChanged) {
        //var amount:Float = 0
        
        if statusChanged.activeBolusStatusChanged == true {
            self.bolusDelivery?.inProgress = true
        }
        
        //should this be in status, not status changed? track the previous insulin amount remaining and subtract the new value
        /*if statusChanged.totalDailyInsulinStatusChanged! {
            if self.bolusDelivery?.duration != 0 {
                amount = (self.bolusDelivery?.administrationAmount)! / (self.bolusDelivery?.duration)!
            } else {
                amount = (self.bolusDelivery?.administrationAmount)!
            }
            self.bolusDelivery?.deliveredAmount += amount
        }*/
        
        //print("delivered amount: \(String(describing: self.bolusDelivery?.deliveredAmount))")
        print("administration amount: \(String(describing: self.bolusDelivery?.administrationAmount))")
        print("in progress: \(String(describing: self.bolusDelivery?.inProgress))")
        print("insulin changed: \(String(describing: statusChanged.totalDailyInsulinStatusChanged ))")
        
        /*if (statusChanged.totalDailyInsulinStatusChanged == true && self.bolusDelivery?.inProgress == true && self.bolusDelivery?.deliveredAmount == self.bolusDelivery?.administrationAmount) {
            self.bolusDelivery?.isFinished = true
            print("BOLUS DELIVERY COMPLETE")
            buttonsEnabled(enabled: true)
        }*/
        //IDS.sharedInstance().readStatus()
    }
    
    func IDSStatusUpdate(status: IDSStatus) {
        print("IDSStatusUpdate")
        var insulinRemainingDifference: Float = self.insulinRemaining - status.reservoirRemainingAmount
        insulinRemainingDifference = Float(Double(insulinRemainingDifference).rounded(toPlaces: 2))
        self.bolusDelivery?.deliveredAmount += insulinRemainingDifference
        print("delivered amount: \(String(describing: self.bolusDelivery?.deliveredAmount))")
        
        insulinRemaining = status.reservoirRemainingAmount
        insulinRemainingLabel.text = status.reservoirRemainingAmount.description
        print("remaining amount: \(status.reservoirRemainingAmount.description)")
        let percentRemaining: CGFloat = CGFloat(status.reservoirRemainingAmount / 180) * 100
        insulinRemainingRing.setProgress(value: percentRemaining, animationDuration: 10, completion: nil)
        
        if (self.bolusDelivery?.inProgress == true && self.bolusDelivery?.deliveredAmount == self.bolusDelivery?.administrationAmount) {
            self.bolusDelivery?.isFinished = true
            print("BOLUS DELIVERY COMPLETE")
            buttonsEnabled(enabled: true)
        
            if IDSFhir.IDSFhirInstance.patient != nil {
                if (self.bolusDelivery?.isFinished == true) { //} && self.bolusDelivery?.bolusID != nil) {
                    let date = Date()
                    IDSFhir.IDSFhirInstance.createMedicationAdministration(administeredAmount: (self.bolusDelivery?.administrationAmount)!, onDate: date, prescriptionID: self.bolusDelivery?.medicationRequestID) { (medicationAdministration, error) -> Void in
                        if let error = error {
                            print("error creating medication administration: \(error)")
                            self.showAlert(title: "FHIR Error", message: "error creating medication administration")
                        }
                    
                        if error == nil {
                            print("medication administration created with id: \(medicationAdministration.id!)")
                            self.medicationAdministration = medicationAdministration
                            }
                        }
                }
            }
        }
    }
    
    func IDSAnnunciationStatusUpdate(annunciation: IDSAnnunciationStatus) {
        ()
    }
    
    
}

extension SessionViewController: IDSBatteryProtocol {
    func IDSBatteryLevel(level: UInt8) {
        print("IDSBatteryLevel")
        batteryLevelLabel.text = level.description + "%"
    }
}

extension SessionViewController: IDSStatusReaderControlPointProtcol {
    func statusReaderResponseCode(code: UInt16, error: UInt8) {
        ()
    }
    
    func resetStatusUpdated(responseCode: UInt8) {
        ()
    }
    
    func numberOfActiveBolusIDS(count: UInt8) {
        ()
    }
    
    func bolusActiveDelivery(bolusDelivery: ActiveBolusDelivery) {
        ()
    }
    
    func basalActiveDelivery(basalDelivery: ActiveBasalRateDelivery) {
        ()
    }
    
    func totalDailyInsulinDeliveredStatus(status: TotalDailyInsulinDeliveredStatus) {
        ()
    }
    
    func counterValues(counter: Counter) {
        ()
    }
    
    func deliveredInsulin(insulinAmount: DeliveredInsulin) {
        ()
    }
    
    func insulinOnBoard(insulinAmount: InsulinOnBoard) {
        ()
    }
}

extension SessionViewController: IDSCommandControlPointProtcol {
    func commandControlPointResponseCode(code: UInt16, error: UInt8) {
        ()
    }
    
    func snoozedAnnunciation(annunciation: UInt16) {
        ()
    }
    
    func confirmedAnnunciation(annunciation: UInt16) {
        ()
    }
    
    func writeBasalRateProfileTemplateResponse() {
        ()
    }
    
    func getTBRTemplateResponse(template: TBRTemplate) {
        ()
    }
    
    func setTBRTemplateResponse(templateNumber: UInt8) {
        ()
    }
    
    func setBolusResponse(bolusID: UInt16) {
        print("setBolusResponse")
        self.bolusDelivery?.bolusID = bolusID
    }
    
    func cancelBolusResponse(bolusID: UInt16) {
        ()
    }
    
    func getAvailableBolusResponse(availableBoluses: UInt8) {
        ()
    }
    
    func getBolusTemplateResponse(template: BolusTemplate) {
        ()
    }
    
    func setBolusTemplateResponse(template: UInt8) {
        ()
    }
    
    func templateStatusAndDetails(templateStatuses: [TemplateStatus]) {
        ()
    }
    
    func resetProfileTemplates(templates: [UInt8]) {
        ()
    }
    
    func activatedProfileTemplates(templates: [UInt8]) {
        ()
    }
    
    func activateProfileTemplates(templates: [UInt8]) {
        ()
    }
    
    func writeISFProfileTemplateResponse(templateNumber: UInt8) {
        ()
    }
    
    func writeI2CHOProfileTemplateResponse(templateNumber: UInt8) {
        ()
    }
    
    func writeTargetGlucoseRangeProfileTemplateResponse(templateNumber: UInt8) {
        ()
    }
    
    func getMaxBolusAmountResponse(bolusAmount: Float) {
        ()
    }
    
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

