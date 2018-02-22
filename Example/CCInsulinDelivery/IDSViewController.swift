//
//  IDSViewController.swift
//  CCInsulinDelivery
//
//  Created by Kevin Tallevi on 9/13/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import CCBluetooth
import CoreBluetooth
import CCInsulinDelivery


class IDSViewController: UITableViewController, IDSProtocol {
    let cellIdentifier = "IDSCellIdentifier"
    var idsFeatures: IDSFeatures!
    var idsStatusChanged: IDSStatusChanged!
    var idsStatus: IDSStatus!
    var idsAnnunciationStatus: IDSAnnunciationStatus!
    var peripheral : CBPeripheral!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("IDSViewController")
        IDS.sharedInstance().idsDelegate = self
        //idsStatusReaderControlPoint = IDSStatusReaderControlPoint()
        //idsStatusReaderControlPoint.idsStatusReaderControlPointDelegate = self
        IDSStatusReaderControlPoint.sharedInstance().idsStatusReaderControlPointDelegate = self
        IDSCommandData.sharedInstance().idsCommandDataDelegate = self
        IDSCommandControlPoint.sharedInstance().idsCommandControlPointDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.refreshTable()
    }

    func refreshTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    //MARK
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
            action.isEnabled = true
        })
        self.present(alert, animated: true)
    }
    
    func bolusSelectionAlert() {
        let alert = UIAlertController(title: "Bolus Selection", message: "Select Bolus", preferredStyle: .actionSheet)
        
        for i in 0 ..< Int(IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS.count) {
            let buttonTitle: String = IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS[i].description
            
            alert.addAction(UIAlertAction(title: buttonTitle, style: .default) { (action:UIAlertAction!) in
                print(buttonTitle + " selected")
                IDSCommandControlPoint.sharedInstance().cancelBolus(bolusID: UInt16(buttonTitle)!)
            })
        }
        self.present(alert, animated: true)
    }
    
    func getCounterTypeAlert() {
        let alert = UIAlertController(title: "Counter Type Selection", message: "Select Counter Type", preferredStyle: .actionSheet)
        
        for counterType in IDSStatusReaderControlPoint.CounterTypes.allValues {
            let buttonTitle: String = counterType.description
            
            alert.addAction(UIAlertAction(title: buttonTitle, style: .default) { (action:UIAlertAction!) in
                print(buttonTitle + " selected")
                IDSStatusReaderControlPoint.sharedInstance().getCounter(counterType: counterType.rawValue)
            })
        }
        self.present(alert, animated: true)
    }
    
    func selectTemplate(_ title: String, message: String, templateType: UInt8, completion: @escaping (_ value: UInt8?)->Void) {
        if IDSCommandData.sharedInstance().templatesStatusAndDetails.count == 0 {
            showAlert(title: "No stored template statuses", message: "Get template status and details first!")
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        for template in IDSCommandData.sharedInstance().templatesStatusAndDetails {
            if templateType == 0 {
                let actionTitle = String(format: "Template Number: %d\nConfigurable: %@\nConfigured: %@", template.templateNumber, template.configurable.description, template.configured.description)
                let action = UIAlertAction(title: actionTitle,
                                           style: UIAlertActionStyle.default,
                                           handler: { void in completion(template.templateNumber)})
                alertController.addAction(action)
            } else if template.templateType == templateType {
                let actionTitle = String(format: "Template Number: %d\nConfigurable: %@\nConfigured: %@", template.templateNumber, template.configurable.description, template.configured.description)
                let action = UIAlertAction(title: actionTitle,
                                       style: UIAlertActionStyle.default,
                                       handler: { void in completion(template.templateNumber)})
                alertController.addAction(action)
            }
        }
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
        UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 4
        UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).font = UIFont.systemFont(ofSize: 8.0)
        //UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).textAlignment = .left
    }
    
    // IDSProtocol
    func IDSDisconnected(ids: CBPeripheral) {
        print("IDSDisconnected")
    }

    func IDSConnected(ids: CBPeripheral) {
        print("IDSConnected")
        self.peripheral = ids
    }

    func IDSFeatures(features: IDSFeatures) {
        print("IDSViewController#IDSFeatures")
        idsFeatures = features
        
        self.refreshTable()
    }
    
    func IDSStatusChanged(statusChanged: IDSStatusChanged) {
        print("IDSViewController#IDSStatusChanged")
        idsStatusChanged = statusChanged
        
        self.refreshTable()
    }
    
    func IDSStatusUpdate(status: IDSStatus) {
        print("IDSViewController#IDSStatusUpdate")
        idsStatus = status
        
        self.refreshTable()
    }
    
    func IDSAnnunciationStatusUpdate(annunciation: IDSAnnunciationStatus) {
        print("IDSViewController#IDSAnnunciationStatusUpdate")
        self.idsAnnunciationStatus = annunciation
        
        self.refreshTable()
    }
    
    func showActiveBolusIDS() {
        var activeBolusIDSStr: String = ""
        activeBolusIDSStr.append("Number of Active IDS: " + IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS.count.description + "\n\r")
        if IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS.count > 0 {
            for i in 0 ..< Int(IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS.count) {
                activeBolusIDSStr.append("Bolus ID: \(String(describing: IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS[i]))\n\r")
            }
            self.showAlert(title: "Active Bolus ID's", message: activeBolusIDSStr)
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if(idsFeatures != nil) {
                return 18
            } else {
                return 0
            }
        case 1:
            if(idsStatusChanged != nil) {
                return 8
            } else {
                return 0
            }
        case 2:
            if(idsStatus != nil) {
                return 4
            } else {
                return 0
            }
        case 3:
            if(idsAnnunciationStatus != nil) {
                if(idsAnnunciationStatus.annunciationPresent)! {
                    return 3
                } else {
                    return 0
                }
            } else {
                return 0
            }
        case 4:
            return 8
        case 5:
            return 31
        case 6:
            return 13
        case 7:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as UITableViewCell
        
        switch indexPath.section {
        case 0:
            if(idsFeatures != nil) {
                switch indexPath.row {
                case 0:
                    cell.textLabel!.text = idsFeatures.e2eProtectionSupported?.description
                    cell.detailTextLabel!.text = "E2E Protection Supported"
                case 1:
                    cell.textLabel!.text = idsFeatures.basalRateSupported?.description
                    cell.detailTextLabel!.text = "Basal Rate Supported"
                case 2:
                    cell.textLabel!.text = idsFeatures.tbrAbsoluteSupported?.description
                    cell.detailTextLabel!.text = "TBR Absolute Supported"
                case 3:
                    cell.textLabel!.text = idsFeatures.tbrRelativeSupported?.description
                    cell.detailTextLabel!.text = "TBR Relative Supported"
                case 4:
                    cell.textLabel!.text = idsFeatures.tbrTemplateSupported?.description
                    cell.detailTextLabel!.text = "TBR Template Supported"
                case 5:
                    cell.textLabel!.text = idsFeatures.fastBolusSupported?.description
                    cell.detailTextLabel!.text = "Fast Bolus Supported"
                case 6:
                    cell.textLabel!.text = idsFeatures.extendedBolusSupported?.description
                    cell.detailTextLabel!.text = "Extended Bolus Supported"
                case 7:
                    cell.textLabel!.text = idsFeatures.multiwaveBolusSupported?.description
                    cell.detailTextLabel!.text = "Multiwave Bolus Supported"
                case 8:
                    cell.textLabel!.text = idsFeatures.bolusDelayTimeSupported?.description
                    cell.detailTextLabel!.text = "Bolus Delay Time Supported"
                case 9:
                    cell.textLabel!.text = idsFeatures.bolusTemplateSupported?.description
                    cell.detailTextLabel!.text = "Bolus Template Supported"
                case 10:
                    cell.textLabel!.text = idsFeatures.bolusActivationTypeSupported?.description
                    cell.detailTextLabel!.text = "Bolus Activation Type Supported"
                case 11:
                    cell.textLabel!.text = idsFeatures.multipleBondSupported?.description
                    cell.detailTextLabel!.text = "Multiple Bond Supported"
                case 12:
                    cell.textLabel!.text = idsFeatures.isfProfileTemplateSupported?.description
                    cell.detailTextLabel!.text = "ISF Profile Template Supported"
                case 13:
                    cell.textLabel!.text = idsFeatures.i2choRatioProfileTemplateSupported?.description
                    cell.detailTextLabel!.text = "I2CHO Ratio Profile Template Supported"
                case 14:
                    cell.textLabel!.text = idsFeatures.targetGlucoseRangeProfileTemplateSupported?.description
                    cell.detailTextLabel!.text = "Target Glucose Range Profile Template Supported"
                case 15:
                    cell.textLabel!.text = idsFeatures.insulinOnBoardSupported?.description
                    cell.detailTextLabel!.text = "Insulin On Board Supported"
                case 16:
                    cell.textLabel!.text = idsFeatures.featureExtension?.description
                    cell.detailTextLabel!.text = "Feature Extension"
                case 17:
                    cell.textLabel!.text = idsFeatures.insulinConcentration?.description
                    cell.detailTextLabel!.text = "Insulin Concentration"
                default:
                    cell.textLabel!.text = ""
                    cell.detailTextLabel!.text = ""
                }
            }
        case 1:
            if(idsStatusChanged != nil) {
                switch indexPath.row {
                case 0:
                    cell.textLabel!.text = idsStatusChanged.therapyControlStateChanged?.description
                    cell.detailTextLabel!.text = "Therapy Control State Changed"
                case 1:
                    cell.textLabel!.text = idsStatusChanged.operationalStateChanged?.description
                    cell.detailTextLabel!.text = "Operational State Changed"
                case 2:
                    cell.textLabel!.text = idsStatusChanged.reservoirStatusChanged?.description
                    cell.detailTextLabel!.text = "Reservoir Status Changed"
                case 3:
                    cell.textLabel!.text = idsStatusChanged.annunciationStatusChanged?.description
                    cell.detailTextLabel!.text = "Annunciation Status Changed"
                case 4:
                    cell.textLabel!.text = idsStatusChanged.totalDailyInsulinStatusChanged?.description
                    cell.detailTextLabel!.text = "Total Daily Insulin Status Changed"
                case 5:
                    cell.textLabel!.text = idsStatusChanged.activeBasalRateStatusChanged?.description
                    cell.detailTextLabel!.text = "Active Basal Rate Status Changed"
                case 6:
                    cell.textLabel!.text = idsStatusChanged.activeBolusStatusChanged?.description
                    cell.detailTextLabel!.text = "Active Bolus Status Changed"
                case 7:
                    cell.textLabel!.text = idsStatusChanged.historyEventRecorded?.description
                    cell.detailTextLabel!.text = "History Event Recorded"
                default:
                    cell.textLabel!.text = ""
                    cell.detailTextLabel!.text = ""
                }
            }
        case 2:
            if(idsStatus != nil) {
                switch indexPath.row {
                case 0:
                    cell.textLabel!.text = IDSStatus.TherapyControlState(rawValue: idsStatus.therapyControlState)?.description
                    cell.detailTextLabel!.text = "Therapy Control State"
                case 1:
                    cell.textLabel!.text = IDSStatus.OperationalStateField(rawValue: idsStatus.operationalState)?.description
                    cell.detailTextLabel!.text = "Operational State"
                case 2:
                    cell.textLabel!.text = idsStatus.reservoirRemainingAmount.description
                    cell.detailTextLabel!.text = "Reservoir Remaining Amount"
                case 3:
                    cell.textLabel!.text = idsStatus.reservoirAttached?.description
                    cell.detailTextLabel!.text = "Reservoir Attached"
                default:
                    cell.textLabel!.text = ""
                    cell.detailTextLabel!.text = ""
                }
            }
        case 3:
            if(idsAnnunciationStatus != nil) {
                if(idsAnnunciationStatus.annunciationPresent)! {
                    switch indexPath.row {
                    case 0:
                        cell.textLabel!.text = idsAnnunciationStatus.annunciationInstanceID.description
                        cell.detailTextLabel!.text = "Annunciation Instance ID"
                    case 1:
                        cell.textLabel!.text = IDSAnnunciationStatus.AnnunciationTypeValues(rawValue: idsAnnunciationStatus.annunciationType)?.description
                        cell.detailTextLabel!.text = "Annunciation Type"
                    case 2:
                        cell.textLabel!.text = IDSAnnunciationStatus.AnnunciationStatusValues(rawValue: idsAnnunciationStatus.annunciationStatus)?.description
                        cell.detailTextLabel!.text = "Annunciation Status"
                    default:
                        cell.textLabel!.text = ""
                        cell.detailTextLabel!.text = ""
                    }
                }
            }
        case 4:
            switch indexPath.row {
            case 0:
                if IDSStatusReaderControlPoint.sharedInstance().resetResponseCode != 0 {
                    let response = IDSStatusReaderControlPoint.StatusReaderResponseCodes(rawValue: IDSStatusReaderControlPoint.sharedInstance().resetResponseCode)?.description
                    cell.textLabel!.text = response!
                } else {
                    cell.textLabel!.text = ""
                }
                cell.detailTextLabel!.text = "Reset Status"
            case 1:
                /*if IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS.count != 0 {
                    cell.textLabel!.text = "Tap for response details"
                } else {
                    cell.textLabel!.text = ""
                }*/
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Active Bolus IDs"
            case 2:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Active Bolus Delivery"
            case 3:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Active Basal Rate Delivery"
            case 4:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Total Daily Insulin Status"
            case 5:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Counter"
            case 6:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Delivered Insulin"
            case 7:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Insulin On Board"
            default:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = ""
            }
        case 5:
            switch indexPath.row {
            case 0:
                /*if IDSCommandData.sharedInstance().therapyControlState != nil {
                    let therapyControlState = IDSCommandControlPoint.ResponseCodes(rawValue: IDSCommandData.sharedInstance().therapyControlState!)?.description
                    cell.textLabel!.text = therapyControlState!
                } else {
                    cell.textLabel!.text = ""
                }*/
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Set Therapy Control State"
            case 1:
                /*if IDSCommandData.sharedInstance().flightModeStatus != nil {
                    let flightModeStatus = IDSCommandControlPoint.ResponseCodes(rawValue: IDSCommandData.sharedInstance().flightModeStatus!)?.description
                    cell.textLabel!.text = flightModeStatus!
                } else {
                    cell.textLabel!.text = ""
                }*/
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Set Flight Mode"
            case 2:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Snooze Annunciation"
            case 3:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Confirm Annunciation"
            case 4:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Read Basal Rate Profile Template"
            case 5:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Write Basal Rate Profile Template"
            case 6:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Set TBR Adjustment"
            case 7:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Cancel TBR Adjustment"
            case 8:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get TBR Template"
            case 9:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Set TBR Template"
            case 10:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Set Bolus"
            case 11:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Cancel Bolus"
            case 12:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Available Boluses"
            case 13:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Bolus Template"
            case 14:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Set Bolus Template"
            case 15:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Template Status and Details"
            case 16:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Reset Template Status"
            case 17:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Activate Profile Templates"
            case 18:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Activated Profile Templates"
            case 19:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Start Priming"
            case 20:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Stop Priming"
            case 21:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Set Initial Reservoir Fill Level"
            case 22:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Reset Reservoir Insulin Operation Time"
            case 23:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Read ISF Profile Template"
            case 24:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Write ISF Profile Template"
            case 25:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Read I2CHO Ratio Profile Template"
            case 26:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Write I2CHO Ratio Profile Template"
            case 27:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Read Target Glucose Range Profile Template"
            case 28:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Write Target Glucose Range Profile Template"
            case 29:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Max Bolus Amount"
            case 30:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Set Max Bolus Amount"
            default:
                ()
            }
        case 6:
            switch(indexPath.row) {
                case 0:
                    cell.textLabel!.text = ""
                    cell.detailTextLabel!.text = "Number Of All Stored Records"
                case 1:
                    cell.textLabel!.text = ""
                    cell.detailTextLabel!.text = "Report All Records"
                case 2:
                    cell.textLabel!.text = ""
                    cell.detailTextLabel!.text = "Report Records Greater Than Or Equal To"
                case 3:
                    cell.textLabel!.text = ""
                    cell.detailTextLabel!.text = "Report Records Less Than Or Equal To"
                case 4:
                    cell.textLabel!.text = ""
                    cell.detailTextLabel!.text = "Report Records Within Range"
                case 5:
                    cell.textLabel!.text = ""
                    cell.detailTextLabel!.text = "Report First Record"
                case 6:
                    cell.textLabel!.text = ""
                    cell.detailTextLabel!.text = "Report Last Record"
                case 7:
                    cell.textLabel!.text = ""
                    cell.detailTextLabel!.text = "Delete All Records"
                case 8:
                    cell.textLabel!.text = ""
                    cell.detailTextLabel!.text = "Delete Records Greater Than Or Equal To"
                case 9:
                    cell.textLabel!.text = ""
                    cell.detailTextLabel!.text = "Delete Records Less Than Or Equal To"
                case 10:
                    cell.textLabel!.text = ""
                    cell.detailTextLabel!.text = "Delete Records Within Range"
                case 11:
                    cell.textLabel!.text = ""
                    cell.detailTextLabel!.text = "Delete First Record"
                case 12:
                    cell.textLabel!.text = ""
                    cell.detailTextLabel!.text = "Delete Last Record"
                default:
                    ()
            }
        case 7:
            switch(indexPath.row) {
                case 0:
                    cell.textLabel!.text = ""
                    cell.detailTextLabel!.text = "Set current time"
                default:
                    ()
            }
        default:
            ()
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 7 +
            IDS.sharedInstance().currentTimeServiceSupported.intValue +
            IDS.sharedInstance().batteryServiceSupported.intValue
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "IDS Features"
        case 1:
            return "IDS Status Changed"
        case 2:
            return "IDS Status"
        case 3:
            return "IDS Annunciation"
        case 4:
            return "IDS Status Reader Control Point"
        case 5:
            return "IDS Command Control Point"
        case 6:
            return "Record Access Control Point"
        case 7:
            return "Current Date Time"
        default:
            return ""
        }
    }
    
    
    
    //MARK: - table delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("didSelectRowAt section: \(indexPath.section) row: \(indexPath.row)")
        
        switch(indexPath.section) {
            case 4:
                switch(indexPath.row) {
                    case 0:
                        IDSStatusReaderControlPoint.sharedInstance().resetSensorStatus()
                    case 1:
                        IDSStatusReaderControlPoint.sharedInstance().getActiveBolusIDs()
                        /*if IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS.count == 0 {
                            IDSStatusReaderControlPoint.sharedInstance().getActiveBolusIDs()
                        } else {
                            self.showActiveBolusIDS()
                        }*/
                    case 2:
                        if IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS.count > 0 {
                            //self.bolusSelectionAlert()
                        } else {
                            self.showAlert(title: "Message", message: "Get active bolus ID's first")
                        }
                    case 3:
                        IDSStatusReaderControlPoint.sharedInstance().getActiveBasalRateDelivery()
                    case 4:
                        IDSStatusReaderControlPoint.sharedInstance().getTotalDailyInsulinStatus()
                    case 5:
                        self.getCounterTypeAlert()
                    case 6:
                        IDSStatusReaderControlPoint.sharedInstance().getDeliveredInsulin()
                    case 7:
                        IDSStatusReaderControlPoint.sharedInstance().getInsulinOnBoard()
                    default:
                        ()
                }
            case 5:
                switch(indexPath.row) {
                    case 0:
                        IDSCommandControlPoint.sharedInstance().setTherapyControlState()
                    case 1:
                        IDSCommandControlPoint.sharedInstance().setFlightMode()
                    case 2:
                        IDSCommandControlPoint.sharedInstance().snoozeAnnunciation(annunciation: self.idsAnnunciationStatus.annunciationInstanceID)
                    case 3:
                        IDSCommandControlPoint.sharedInstance().confirmAnnunciation(annunciation: self.idsAnnunciationStatus.annunciationInstanceID)
                    case 4:
                        selectTemplate("Basal Rate Profile Templates", message: "", templateType: TemplateType.basalRateProfileTemplate.rawValue) { (value) -> Void in
                            if let value = value {
                                IDSCommandControlPoint.sharedInstance().readBasalRateProfileTemplate(templateNumber: value)
                            }
                        }
                    case 5:
                        selectTemplate("Basal Rate Profile Templates", message: "", templateType: TemplateType.basalRateProfileTemplate.rawValue) { (value) -> Void in
                            if let value = value {
                                IDSCommandControlPoint.sharedInstance().writeBasalRateProfileTemplate(templateNumber: value)
                            }
                        }
                    case 6:
                        IDSCommandControlPoint.sharedInstance().setTBRAdjustment()
                    case 7:
                        IDSCommandControlPoint.sharedInstance().cancelTBRAdjustment()
                    case 8:
                        selectTemplate("TBR Templates", message: "", templateType: TemplateType.tbrTemplate.rawValue) { (value) -> Void in
                            if let value = value {
                                IDSCommandControlPoint.sharedInstance().getTBRTemplate(templateNumber: value)
                            }
                        }
                    case 9:
                        selectTemplate("TBR Templates", message: "", templateType: TemplateType.tbrTemplate.rawValue) { (value) -> Void in
                            if let value = value {
                                IDSCommandControlPoint.sharedInstance().setTBRTemplate(templateNumber: value)
                            }
                        }
                    case 10:
                        IDSCommandControlPoint.sharedInstance().setBolus()
                    case 11:
                        if(Int(IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS.count) > 0) {
                            //IDSCommandControlPoint.sharedInstance().cancelBolus()
                            self.bolusSelectionAlert()
                        } else {
                            showAlert(title: "Cancel Bolus", message: "Get Active Bolus IDs first")
                        }
                    case 12:
                        IDSCommandControlPoint.sharedInstance().getAvailableBoluses()
                    case 13:
                        selectTemplate("Bolus Templates", message: "", templateType: TemplateType.bolusTemplate.rawValue) { (value) -> Void in
                            if let value = value {
                                IDSCommandControlPoint.sharedInstance().getBolusTemplate(templateNumber: value)
                            }
                        }
                    case 14:
                        selectTemplate("Bolus Templates", message: "", templateType: TemplateType.bolusTemplate.rawValue) { (value) -> Void in
                            if let value = value {
                                IDSCommandControlPoint.sharedInstance().setBolusTemplate(templateNumber: value)
                            }
                        }
                    case 15:
                        IDSCommandControlPoint.sharedInstance().getTemplateStatusAndDetails()
                    case 16:
                        //IDSCommandControlPoint.sharedInstance().resetTemplateStatus(templatesNumbers: [1,2,3])
                        selectTemplate("Available Templates", message: "", templateType: 0) { (value) -> Void in
                            if let value = value {
                                var templates:[UInt8] = []
                                templates.append(value)
                                IDSCommandControlPoint.sharedInstance().resetTemplateStatus(templatesNumbers: templates)
                            }
                    }
                    case 17:
                        //IDSCommandControlPoint.sharedInstance().activateProfileTemplates(templatesNumbers: [1,2,3])
                        selectTemplate("Available Templates", message: "", templateType: 0) { (value) -> Void in
                            if let value = value {
                                var templates:[UInt8] = []
                                templates.append(value)
                                IDSCommandControlPoint.sharedInstance().activateProfileTemplates(templatesNumbers: templates)
                            }
                        }
                    case 18:
                        IDSCommandControlPoint.sharedInstance().getActivatedProfileTemplates()
                    case 19:
                        IDSCommandControlPoint.sharedInstance().startPriming()
                    case 20:
                        IDSCommandControlPoint.sharedInstance().stopPriming()
                    case 21:
                        IDSCommandControlPoint.sharedInstance().setInitialReservoirFillLevel()
                    case 22:
                        IDSCommandControlPoint.sharedInstance().resetReservoirInsulinOperationTime()
                    case 23:
                        selectTemplate("ISF Templates", message: "", templateType: TemplateType.isfProfileTemplate.rawValue) { (value) -> Void in
                            if let value = value {
                                IDSCommandControlPoint.sharedInstance().readISFProfileTemplate(templateNumber: value)
                            }
                        }
                    case 24:
                        selectTemplate("ISF Templates", message: "", templateType: TemplateType.isfProfileTemplate.rawValue) { (value) -> Void in
                            if let value = value {
                                IDSCommandControlPoint.sharedInstance().writeISFProfileTemplate(templateNumber: value)
                            }
                        }
                    case 25:
                        selectTemplate("I2CHO Templates", message: "", templateType: TemplateType.i2choTemplate.rawValue) { (value) -> Void in
                            if let value = value {
                                IDSCommandControlPoint.sharedInstance().readI2CHORatioProfileTemplate(templateNumber: value)
                            }
                        }
                    case 26:
                        selectTemplate("I2CHO Templates", message: "", templateType: TemplateType.i2choTemplate.rawValue) { (value) -> Void in
                            if let value = value {
                                IDSCommandControlPoint.sharedInstance().writeI2CHORatioProfileTemplate(templateNumber: value)
                            }
                        }
                    case 27:
                        selectTemplate("Target Glucose Range Profile Templates", message: "", templateType: TemplateType.targetGlucoseTemplate.rawValue) { (value) -> Void in
                            if let value = value {
                                IDSCommandControlPoint.sharedInstance().readTargetGlucoseRangeProfileTemplate(templateNumber: value)
                            }
                        }
                    case 28:
                        selectTemplate("Target Glucose Range Profile Templates", message: "", templateType: TemplateType.targetGlucoseTemplate.rawValue) { (value) -> Void in
                            if let value = value {
                                IDSCommandControlPoint.sharedInstance().writeTargetGlucoseRangeProfileTemplate(templateNumber: value)
                            }
                        }
                    case 29:
                        IDSCommandControlPoint.sharedInstance().getMaxBolusAmount()
                    case 30:
                        IDSCommandControlPoint.sharedInstance().setMaxBolusAmount(maxBolusAmount: 9.0)
                    default:
                        ()
            }
            case 6:
                switch(indexPath.row) {
                    case 0:
                        IDSRecordAccessControlPoint.sharedInstance().reportNumberOfAllStoredRecords()
                    case 1:
                        IDSRecordAccessControlPoint.sharedInstance().reportAllRecords()
                    case 2:
                        IDSRecordAccessControlPoint.sharedInstance().reportRecordsGreaterThanOrEqualTo(recordNumber: 1)
                    case 3:
                        IDSRecordAccessControlPoint.sharedInstance().reportRecordsLessThanOrEqualTo(recordNumber: 5)
                    case 4:
                        IDSRecordAccessControlPoint.sharedInstance().reportRecordsWithinRange(from: 1, to: 5)
                    case 5:
                        IDSRecordAccessControlPoint.sharedInstance().reportFirstRecord()
                    case 6:
                        IDSRecordAccessControlPoint.sharedInstance().reportLastRecord()
                    case 7:
                        IDSRecordAccessControlPoint.sharedInstance().deleteAllRecords()
                    case 8:
                        IDSRecordAccessControlPoint.sharedInstance().deleteRecordsGreaterThanOrEqualTo(recordNumber: 1)
                    case 9:
                        IDSRecordAccessControlPoint.sharedInstance().deleteRecordsLessThanOrEqualTo(recordNumber: 5)
                    case 10:
                        IDSRecordAccessControlPoint.sharedInstance().deleteRecordsWithinRange(from: 1, to: 5)
                    case 11:
                        IDSRecordAccessControlPoint.sharedInstance().deleteFirstRecord()
                    case 12:
                        IDSRecordAccessControlPoint.sharedInstance().deleteLastRecord()
                    default:
                        ()
                }
            case 7:
                switch(indexPath.row) {
                    case 0:
                        IDSDateTime.sharedInstance().writeCurrentDateTime()
                default:
                    ()
            }
            default:
                ()
        }
    }
}

extension IDSViewController: IDSStatusReaderControlPointProtcol {
    func statusReaderResponseCode(code: UInt16, error: UInt8) {
        print("statusReaderResponseCode")
        let codeDescription = IDSStatusReaderControlPoint.StatusReaderOpCodes(rawValue: code)?.description
        let errorDescription = IDSStatusReaderControlPoint.StatusReaderResponseCodes(rawValue: error)?.description
        showAlert(title: codeDescription!, message: errorDescription!)
    }
    
    func resetStatusUpdated(responseCode: UInt8) {
        let response = IDSStatusReaderControlPoint.StatusReaderResponseCodes(rawValue: responseCode)?.description
        showAlert(title: "Reset Status Updated", message: response!)
    }
    
    func numberOfActiveBolusIDS(count: UInt8) {
        self.showActiveBolusIDS()
    }
    
    func bolusActiveDelivery(bolusDelivery: String) {
        self.showAlert(title: "Active Bolus Delivery", message: bolusDelivery)
    }
    
    func basalActiveDelivery(basalDelivery: String) {
        self.showAlert(title: "Active Basal Delivery", message: basalDelivery)
    }
    
    func totalDailyInsulinDeliveredStatus(status: String) {
        self.showAlert(title: "Total Daily Insulin Delivered", message: status)
    }
    
    func counterValues(counter: String) {
        self.showAlert(title: "Counter", message: counter)
    }
    
    func deliveredInsulin(insulinAmount: String) {
        self.showAlert(title: "Delivered Insulin", message: insulinAmount)
    }
    
    func insulinOnBoard(insulinAmount: String) {
        self.showAlert(title: "Insulin OnBoard", message: insulinAmount)
    }
}

extension IDSViewController: IDSCommandDataProtocol {
    func commandDataResponseCode(code: UInt16, error: UInt8) {
        print("commandDataResponseCode")
        let codeDescription = IDSOpCodes.OpCodes(rawValue: code)?.description
        let errorDescription = IDSOpCodes.ResponseCodes(rawValue: error)?.description
        showAlert(title: codeDescription!, message: errorDescription!)
    }
    
    func basalRateProfileTemplate(template: BasalRateProfileTemplate) {
        print("basalRateProfileTemplate")
    }
    
    func isfProfileTemplate(template: ISFProfileTemplate) {
        print("isfProfileTemplate")
    }
    
    func i2choRatioProfileTemplate(template: I2CHORatioProfileTemplate) {
        print("i2choRatioProfileTemplate")
    }
    
    func targetGlucoseRangeProfileTemplate(template: TargetGlucoseRangeProfileTemplate) {
        print("targetGlucoseRangeProfileTemplate")
    }
}

extension IDSViewController: IDSCommandControlPointProtcol {
    func commandControlPointResponseCode(code: UInt16, error: UInt8) {
        print("commandDataResponseCode")
        let codeDescription = IDSOpCodes.OpCodes(rawValue: code)?.description
        let errorDescription = IDSOpCodes.ResponseCodes(rawValue: error)?.description
        showAlert(title: codeDescription!, message: errorDescription!)
    }
    
    func therapyControlStateUpdated(state: UInt8) {
        let response = IDSStatusReaderControlPoint.StatusReaderResponseCodes(rawValue: state)?.description
        print("therapyControlStateUpdated: \(String(describing: response))")
        showAlert(title: "Set Therapy Control State", message: state.description)
    }
    
    func snoozedAnnunciation(annunciation: UInt16) {
        print("snoozedAnnunciation: \(annunciation)")
        showAlert(title: "Snooze Annunciation", message: "Success")
    }
    
    func confirmedAnnunciation(annunciation: UInt16) {
        print("confirmedAnnunciation: \(annunciation)")
        showAlert(title: "Confirm Annunciation", message: "Success")
    }
    
    func writeBasalRateProfileTemplateResponse() {
        print("writeBasalRateProfileTemplate")
        showAlert(title: "Write Basal Rate Profile Template", message: "Success")
    }
    
    func getTBRTemplateResponse(template: TBRTemplate) {
        print("getTBRTemplateResponse")
        showAlert(title: "Get TBR Template", message: "Success")
    }
    
    func setTBRTemplateResponse(templateNumber: UInt8) {
        print("setTBRTemplateResponse")
        showAlert(title: "Set TBR Template (template number: \(templateNumber.description))", message: "Success")
    }
    
    func setBolusResponse(bolusID: UInt16) {
        print("setBolusResponse")
        showAlert(title: "Set Bolus (Bolus ID: \(bolusID.description))", message: "Success")
    }
    
    func cancelBolusResponse(bolusID: UInt16) {
        print("cancelBolusResponse")
        showAlert(title: "Cancel Bolus (Bolus ID: \(bolusID.description))", message: "Success")
    }
    
    func getAvailableBolusResponse(availableBoluses: UInt8) {
        print("getAvailableBolusResponse")
        let fastBolusAvailable = Int(availableBoluses).bit(0)
        let extendedBolusAvailable = Int(availableBoluses).bit(1)
        let multiwaveBolusAvailable = Int(availableBoluses).bit(2)
        let availableBolusesString = String(format: "Fast Bolus Available: %d\n\rExtended Bolus Available: %d\n\rMultiwave Bolus Available: %d", fastBolusAvailable, extendedBolusAvailable, multiwaveBolusAvailable)
        showAlert(title: "Get Available Bolus Response", message: availableBolusesString)
    }
    
    func getBolusTemplateResponse(template: BolusTemplate) {
        print("getBolusTemplateResponse")
        showAlert(title: "Get Bolus Template Response", message: "Template: \(template.description)")
    }
    
    func setBolusTemplateResponse(template: UInt8) {
        showAlert(title: "Set TBR Template", message: "Template Number: \(template)")
    }
    
    func templateStatusAndDetails(templateStatuses: [TemplateStatus]) {
        print("templateStatusAndDetails")
    }
    
    func resetProfileTemplates(templates: [UInt8]) {
        print("resetProfileTemplates")
        var templateNumberString = String("Templates Reset: ")
        for template in templates {
            templateNumberString.append(String(format: "#%@ ", template.description))
        }
        showAlert(title: "Reset Templates Response", message: templateNumberString)
    }
    
    func activateProfileTemplates(templates: [UInt8]) {
        print("activateProfileTemplates")
        var templateNumberString = String("Templates Activated: ")
        for template in templates {
            templateNumberString.append(String(format: "#%@ ", template.description))
        }
        showAlert(title: "Activate Templates Response", message: templateNumberString)
    }
    
    func activatedProfileTemplates(templates: [UInt8]) {
        print("activatedProfileTemplates")
        var templateNumberString = String("Activated Templates: ")
        if templates.count > 0 {
            for template in templates {
                templateNumberString.append(String(format: "#%@ ", template.description))
            }
        } else {
            templateNumberString.append("None")
        }
        showAlert(title: "Activated Templates", message: templateNumberString)
    }
    
    func writeISFProfileTemplateResponse(templateNumber: UInt8) {
        print("writeISFProfileTemplateResponse")
        let templateNumberString = String(format: "Template Number: %d", templateNumber)
        showAlert(title: "Write ISF Profile Template Response", message: templateNumberString)
    }
    
    func writeI2CHOProfileTemplateResponse(templateNumber: UInt8) {
        print("writeI2CHOProfileTemplateResponse")
        let templateNumberString = String(format: "Template Number: %d", templateNumber)
        showAlert(title: "Write I2CHO Profile Template Response", message: templateNumberString)
    }
    
    func writeTargetGlucoseRangeProfileTemplateResponse(templateNumber: UInt8) {
        print("writeTargetGlucoseRangeProfileTemplateResponse")
        let templateNumberString = String(format: "Template Number: %d", templateNumber)
        showAlert(title: "Write Target Glucose Range Profile Template Response", message: templateNumberString)
    }
    
    func getMaxBolusAmountResponse(bolusAmount: Float) {
        print("getMaxBolusAmountResponse")
        let bolusAmountString = String(format: "Bolus Amount: %1.0f", bolusAmount)
        showAlert(title: "Get Max Bolus Amount Response", message: bolusAmountString)
    }
}
