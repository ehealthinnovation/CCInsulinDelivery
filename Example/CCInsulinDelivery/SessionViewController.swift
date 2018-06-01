//
//  SessionViewController.swift
//  CCInsulinDelivery_Example
//
//  Created by Kevin Tallevi on 3/5/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

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
    @IBOutlet weak var deliveryingInsulinLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        var duration: Int
        var medicationRequestID: Int?
        
        init(bolusID: UInt16?, inProgress: Bool?, isFinished: Bool?, administrationAmount: Float, deliveredAmount: Float, duration: Int, medicationRequestID: Int?) {
            self.bolusID = bolusID
            self.inProgress = inProgress
            self.isFinished = isFinished
            self.administrationAmount = administrationAmount
            self.deliveredAmount = deliveredAmount
            self.duration = duration
            self.medicationRequestID = medicationRequestID
        }
    }
    var bolusDelivery: activeBolusDelivery?
    var administrationAmountStr: String = ""
    var deliveredAmountStr: String = ""
    
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
        deliveryingInsulinLabel.isHidden = true
        activityIndicator.isHidden = true
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
        inputInsulinAmount(message: "Input insulin amount", extended: false) { (amount, duration) -> Void in
            if let amount = amount {
                print("AMOUNT: \(amount)")
                
                if amount == 0.0 {
                    self.showAlert(title: "Must provide an insulin amount larger than zero", message: "")
                    return
                }
                
                if self.insulinRemaining < amount {
                    self.showAlert(title: "Insufficient insulin for delivery", message: "")
                    return
                }
                self.buttonsEnabled(enabled: false)
            
                self.bolusDelivery = activeBolusDelivery(bolusID: nil, inProgress: false, isFinished: false, administrationAmount:amount, deliveredAmount:0, duration: 0, medicationRequestID: nil)
                self.administrationAmountStr = String(format: "%.1f", (self.bolusDelivery?.administrationAmount)!)
                
                let date = Date()
                if IDSFhir.IDSFhirInstance.patient != nil {
                    IDSFhir.IDSFhirInstance.createMedicationRequest(amount: amount, duration: 0, onDate: date) { (medicationRequest, error) -> Void in
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
                
                IDSCommandControlPoint.sharedInstance().setBolus(fastAmount: amount,
                                                                 extendedAmount: 0,
                                                                 duration: 0,
                                                                 delayTime: 0,
                                                                 templateNumber: 0,
                                                                 activationType: 0,
                                                                 bolusDeliveryReasonCorrection: false,
                                                                 bolusDeliveryReasonMeal: false)
                self.deliveryingInsulinLabel.isHidden = false
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
            
            }
        }
    }
    
    @IBAction func extendedBolusButtonAction(_ sender: Any) {
        inputInsulinAmount(message: "Input insulin amount and duration", extended: true) { (amount, duration) -> Void in
            if let amount = amount {
                print("AMOUNT: \(amount)")
                if amount == 0.0 {
                    self.showAlert(title: "Must provide an insulin amount larger than zero", message: "")
                    return
                }
                if let duration = duration {
                    print("DURATION: \(duration)")
                    if duration == 0 {
                        self.showAlert(title: "Must provide a duration larger than zero", message: "")
                        return
                    }
                    if self.insulinRemaining < amount {
                        self.showAlert(title: "Insufficient insulin for delivery", message: "")
                        return
                    }
                    self.buttonsEnabled(enabled: false)
                    
                    self.bolusDelivery = activeBolusDelivery(bolusID: nil, inProgress: false, isFinished: false, administrationAmount:amount, deliveredAmount:0, duration: duration, medicationRequestID: nil)
                    self.administrationAmountStr = String(format: "%.1f", (self.bolusDelivery?.administrationAmount)!)
                    
                    let date = Date()
                    if IDSFhir.IDSFhirInstance.patient != nil {
                        IDSFhir.IDSFhirInstance.createMedicationRequest(amount: amount, duration: duration, onDate: date) { (medicationRequest, error) -> Void in
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
                                                                     extendedAmount: amount,
                                                                     duration: UInt16(duration),
                                                                     delayTime: 0,
                                                                     templateNumber: 0,
                                                                     activationType: 0,
                                                                     bolusDeliveryReasonCorrection: false,
                                                                     bolusDeliveryReasonMeal: false)
                    
                    self.deliveryingInsulinLabel.isHidden = false
                    self.activityIndicator.isHidden = false
                    self.activityIndicator.startAnimating()
                }
            }
        }
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
    
    func inputInsulinAmount(message: String, extended: Bool, completion: @escaping (_ value: Float?, _ duration: Int?)->Void) {
        let alert = UIAlertController(title: "Insulin", message: message, preferredStyle: .alert)
        
        alert.addTextField { (amountTextField) in
            amountTextField.text = ""
            amountTextField.placeholder = "Amount (IU)"
            amountTextField.keyboardType = UIKeyboardType.decimalPad
        }
        if(extended) {
            alert.addTextField { (durationTextField) in
                durationTextField.text = ""
                durationTextField.placeholder = "Duration (Minutes)"
                durationTextField.keyboardType = UIKeyboardType.numberPad
            }
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { void in
            let amount = alert.textFields![0]
            
            if(extended) {
                let duration = Int(alert.textFields![1].text!) ?? 0
                completion(amount.text?.floatValue, duration)
            } else {
                completion(amount.text?.floatValue, 0)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension SessionViewController: IDSProtocol {
    func IDSFeatures(features: IDSFeatures) {
        ()
    }
    
    func IDSStatusChanged(statusChanged: IDSStatusChanged) {
        if statusChanged.activeBolusStatusChanged == true {
            self.bolusDelivery?.inProgress = true
        }
        
        print("administration amount: \(String(describing: self.bolusDelivery?.administrationAmount))")
        print("in progress: \(String(describing: self.bolusDelivery?.inProgress))")
        print("insulin changed: \(String(describing: statusChanged.totalDailyInsulinStatusChanged ))")
    }
    
    func IDSStatusUpdate(status: IDSStatus) {
        print("IDSStatusUpdate")
        
        if self.bolusDelivery?.inProgress == true {
            if status.reservoirRemainingAmount < self.insulinRemaining {
                var insulinRemainingDifference: Float = self.insulinRemaining - status.reservoirRemainingAmount
                insulinRemainingDifference = Float(Double(insulinRemainingDifference).rounded(toPlaces: 1))
                self.bolusDelivery?.deliveredAmount += insulinRemainingDifference
                deliveredAmountStr = String(format: "%.1f", (self.bolusDelivery?.deliveredAmount)!)
                print("delivered amount: \(deliveredAmountStr)")
                
                insulinRemaining = status.reservoirRemainingAmount
                insulinRemainingLabel.text = status.reservoirRemainingAmount.description + " IU"
                print("remaining amount: \(String(format: "%.1f", status.reservoirRemainingAmount))")
                let percentRemaining: CGFloat = CGFloat(status.reservoirRemainingAmount / 180) * 100
                insulinRemainingRing.setProgress(to: percentRemaining, duration: 5, completion: nil)
            }
        } else {
            insulinRemaining = status.reservoirRemainingAmount
            insulinRemainingLabel.text = status.reservoirRemainingAmount.description + " IU"
            print("remaining amount: \(String(format: "%.1f", status.reservoirRemainingAmount))")
            let percentRemaining: CGFloat = CGFloat(status.reservoirRemainingAmount / 180) * 100
            insulinRemainingRing.setProgress(to: percentRemaining, duration: 5, completion: nil)
        }
        
        if (self.bolusDelivery?.inProgress == true && deliveredAmountStr == administrationAmountStr) {
            self.bolusDelivery?.isFinished = true
            buttonsEnabled(enabled: true)
            self.deliveryingInsulinLabel.isHidden = true
            self.activityIndicator.isHidden = true
            
            if IDSFhir.IDSFhirInstance.patient != nil {
                if (self.bolusDelivery?.isFinished == true) {
                    let date = Date()
                    IDSFhir.IDSFhirInstance.createMedicationAdministration(administeredAmount: (self.bolusDelivery?.administrationAmount)!, duration: (self.bolusDelivery?.duration)!, onDate: date, prescriptionID: self.bolusDelivery?.medicationRequestID) { (medicationAdministration, error) -> Void in
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
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}

