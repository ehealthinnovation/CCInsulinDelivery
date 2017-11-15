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
    //var idsStatusReaderControlPoint: IDSStatusReaderControlPoint!
    var peripheral : CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("IDSViewController")
        IDS.sharedInstance().idsDelegate = self
        //idsStatusReaderControlPoint = IDSStatusReaderControlPoint()
        //idsStatusReaderControlPoint.idsStatusReaderControlPointDelegate = self
        IDSStatusReaderControlPoint.sharedInstance().idsStatusReaderControlPointDelegate = self
        IDSCommandData.sharedInstance().idsCommandDataDelegate = self
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
                IDSStatusReaderControlPoint.sharedInstance().getActiveBolusDelivery(bolusID: UInt16(buttonTitle)!)
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
        
        //let alertController = UIAlertController(title: "Response", message: activeBolusIDSStr, preferredStyle: .actionSheet)
        //let OKAction = UIAlertAction(title: "OK", style: .default)
        //alertController.addAction(OKAction)
        //self.present(alertController, animated: true)
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
                if IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS.count != 0 {
                    cell.textLabel!.text = "Tap for response details"
                } else {
                    cell.textLabel!.text = ""
                }
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
                if IDSCommandData.sharedInstance().therapyControlState != nil {
                    let therapyControlState = IDSCommandControlPoint.ResponseCodes(rawValue: IDSCommandData.sharedInstance().therapyControlState!)?.description
                    cell.textLabel!.text = therapyControlState!
                } else {
                    cell.textLabel!.text = ""
                }
                cell.detailTextLabel!.text = "Set Therapy Control State"
            case 1:
                if IDSCommandData.sharedInstance().flightModeStatus != nil {
                    let flightModeStatus = IDSCommandControlPoint.ResponseCodes(rawValue: IDSCommandData.sharedInstance().flightModeStatus!)?.description
                    cell.textLabel!.text = flightModeStatus!
                } else {
                    cell.textLabel!.text = ""
                }
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
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = ""
            }
        default:
            cell.textLabel!.text = ""
            cell.detailTextLabel!.text = ""
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
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
                        if IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS.count == 0 {
                            IDSStatusReaderControlPoint.sharedInstance().getActiveBolusIDs()
                        } else {
                            self.showActiveBolusIDS()
                        }
                    case 2:
                        if IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS.count > 0 {
                            self.bolusSelectionAlert()
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
                        IDSCommandControlPoint.sharedInstance().snoozeAnnunciation()
                    case 3:
                        IDSCommandControlPoint.sharedInstance().confirmAnnunciation()
                    case 4:
                        IDSCommandControlPoint.sharedInstance().readBasalRateProfileTemplate()
                    case 5:
                        IDSCommandControlPoint.sharedInstance().writeBasalRateProfileTemplate()
                    case 6:
                        IDSCommandControlPoint.sharedInstance().setTBRAdjustment()
                    case 7:
                        IDSCommandControlPoint.sharedInstance().cancelTBRAdjustment()
                    case 8:
                        IDSCommandControlPoint.sharedInstance().getTBRTemplate()
                    case 9:
                        IDSCommandControlPoint.sharedInstance().setTBRTemplate()
                    case 10:
                        IDSCommandControlPoint.sharedInstance().setBolus()
                    case 11:
                        IDSCommandControlPoint.sharedInstance().cancelBolus()
                    case 12:
                        IDSCommandControlPoint.sharedInstance().getAvailableBoluses()
                    case 13:
                        IDSCommandControlPoint.sharedInstance().getBolusTemplate()
                    case 14:
                        IDSCommandControlPoint.sharedInstance().setBolusTemplate()
                    case 15:
                        IDSCommandControlPoint.sharedInstance().getTemplateStatusAndDetails()
                    case 16:
                        IDSCommandControlPoint.sharedInstance().resetTemplateStatus()
                    case 17:
                        IDSCommandControlPoint.sharedInstance().activateProfileTemplates()
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
                        IDSCommandControlPoint.sharedInstance().readISFProfileTemplate()
                    case 24:
                        IDSCommandControlPoint.sharedInstance().writeISFProfileTemplate()
                    case 25:
                        IDSCommandControlPoint.sharedInstance().readI2CHORatioProfileTemplate()
                    case 26:
                        IDSCommandControlPoint.sharedInstance().writeI2CHORatioProfileTemplate()
                    case 27:
                        IDSCommandControlPoint.sharedInstance().readTargetGlucoseRangeProfileTemplate()
                    case 28:
                        IDSCommandControlPoint.sharedInstance().writeTargetGlucoseRangeProfileTemplate()
                    case 29:
                        IDSCommandControlPoint.sharedInstance().getMaxBolusAmount()
                    case 30:
                        IDSCommandControlPoint.sharedInstance().setMaxBolusAmount()
                    default:
                        ()
            }
            default:
                ()
        }
    }
}

extension IDSViewController: IDSStatusReaderControlPointProtcol {
    func resetStatusUpdated() {
        let response = IDSStatusReaderControlPoint.StatusReaderResponseCodes(rawValue: IDSStatusReaderControlPoint.sharedInstance().resetResponseCode)?.description
        //let response = IDSStatusReaderControlPoint.StatusReaderResponseCodes(rawValue: status)?.description
        print("resetStatusResponse: \(String(describing: response))")
        
        self.refreshTable()
    }
    
    func numberOfActiveBolusIDS(count: UInt8) {
        self.refreshTable()
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
    func therapyControlStateUpdated() {
        let response = IDSStatusReaderControlPoint.StatusReaderResponseCodes(rawValue: IDSCommandData.sharedInstance().therapyControlState!)?.description
        print("therapyControlStateUpdated: \(String(describing: response))")
        
        self.refreshTable()
    }
    
    func flightModeStatusUpdated() {
        let response = IDSStatusReaderControlPoint.StatusReaderResponseCodes(rawValue: IDSCommandData.sharedInstance().flightModeStatus!)?.description
        print("flightModeStatusUpdated: \(String(describing: response))")
        
        self.refreshTable()
    }
    
    func snoozedAnnunciation(annunciation: UInt16) {
        print("snoozedAnnunciation: \(annunciation)")
    }
    
    func confirmedAnnunciation(annunciation: UInt16) {
        print("confirmedAnnunciation: \(annunciation)")
    }
    
    func basalRateProfileTemplate(profile: String) {
        print("basalRateProfileTemplate")
    }
}
