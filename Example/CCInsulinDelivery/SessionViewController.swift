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

class SessionViewController: UIViewController {
    @IBOutlet weak var fastBolusButton: UIButton!
    @IBOutlet weak var extendedBolusButton: UIButton!
    @IBOutlet weak var batteryLevelLabel: UILabel!
    @IBOutlet weak var insulinRemainingLabel: UILabel!
    
    var medicationRequest: MedicationRequest?
    var medicationAdministration: MedicationAdministration?
    var bolusDeliveryInProgress: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IDS.sharedInstance().readStatus()
        IDS.sharedInstance().idsBatteryDelete = self
        IDS.sharedInstance().idsDelegate = self
        IDS.sharedInstance().readBatteryLevel()
        IDS.sharedInstance().readStatus()
    }
    
    @IBAction func fastBolusButtonAction(_ sender: Any) {
        IDSCommandControlPoint.sharedInstance().setBolus(fastAmount: 2.1,
                                                         extendedAmount: 0,
                                                         duration: 0,
                                                         delayTime: 0,
                                                         templateNumber: 0,
                                                         activationType: 0,
                                                         bolusDeliveryReasonCorrection: false,
                                                         bolusDeliveryReasonMeal: false)
    
        bolusDeliveryInProgress = true
        
        let date = Date()
        IDSFhir.IDSFhirInstance.createMedicationAdministration(administeredAmount: 2.1, onDate: date, prescription: nil) { (medicationAdministration, error) -> Void in
            if let error = error {
                print("error creating medication administration: \(error)")
            }
            
            if error == nil {
                print("medication administration created with id: \(medicationAdministration.id!)")
                self.medicationAdministration = medicationAdministration
            }
        }
    }
    
    @IBAction func extendedBolusButtonAction(_ sender: Any) {
        IDSCommandControlPoint.sharedInstance().setBolus(fastAmount: 0,
                                                         extendedAmount: 5.0,
                                                         duration: 30,
                                                         delayTime: 0,
                                                         templateNumber: 0,
                                                         activationType: 0,
                                                         bolusDeliveryReasonCorrection: false,
                                                         bolusDeliveryReasonMeal: false)
        bolusDeliveryInProgress = true
        
        let date = Date()
        IDSFhir.IDSFhirInstance.createMedicationRequest(amount: 5.0, duration: 30, onDate: date) { (medicationRequest, error) -> Void in
            if let error = error {
                print("error creating medication request: \(error)")
            }
            
            if error == nil {
                print("medication request created with id: \(medicationRequest.id!)")
                self.medicationRequest = medicationRequest
            }
        }
    }
}

extension SessionViewController: IDSProtocol {
    func IDSFeatures(features: IDSFeatures) {
        ()
    }
    
    func IDSStatusChanged(statusChanged: IDSStatusChanged) {
        if (statusChanged.totalDailyInsulinStatusChanged == true && bolusDeliveryInProgress == true) {
            bolusDeliveryInProgress = false
            print("BOLUS DELIVERY COMPLETE")
            IDSStatusReaderControlPoint.sharedInstance().resetSensorStatus()
        }
        IDS.sharedInstance().readStatus()
    }
    
    func IDSStatusUpdate(status: IDSStatus) {
        insulinRemainingLabel.text = status.reservoirRemainingAmount.description
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
