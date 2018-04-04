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
import SMART

class IDSViewController: UITableViewController {
    let cellIdentifier = "IDSCellIdentifier"
    var idsFeatures: IDSFeatures!
    var idsStatusChanged: IDSStatusChanged!
    var idsStatus: IDSStatus!
    var idsAnnunciationStatus: IDSAnnunciationStatus!
    var peripheral : CBPeripheral!
    var batteryLevel: String!
    
    var givenName: FHIRString = "Lisa"
    var familyName: FHIRString = "Simpson"
    
    enum Section: Int {
        case fhirPatient,
        fhirDevice,
        idsFeatures,
        idsStatusChanged,
        idsStatus,
        idsAnnunciation,
        idsStatusReaderControlPoint,
        idsCommandControlPoint,
        recordAccessControlPoint,
        currentDateTime,
        battery,
        session,
        count
        
        public func description() -> String {
            switch self {
            case .fhirPatient:
                return "FHIR Patient"
            case .fhirDevice:
                return "FHIR Device"
            case .idsFeatures:
                return "IDS Features"
            case .idsStatusChanged:
                return "IDS Status Changed"
            case .idsStatus:
                return "IDS Status"
            case .idsAnnunciation:
                return "IDS Annunciation"
            case .idsStatusReaderControlPoint:
                return "IDS Status Reader Control Point"
            case .idsCommandControlPoint:
                return "IDS Command Control Point"
            case .recordAccessControlPoint:
                return "Record Access Control Point"
            case .currentDateTime:
                return "Current Date Time Service"
            case .battery:
                return "Battery Service"
            case .session:
                return "Session"
            case .count:
                fatalError("invalid")
            }
        }
        
        public func rowCount() -> Int {
            switch self {
            case .fhirPatient:
                return 1
            case .fhirDevice:
                return 1
            case .idsFeatures:
                return IDSFeatures.count.rawValue
            case .idsStatusChanged:
                return IDSStatusChanged.count.rawValue
            case .idsStatus:
                return IDSStatus.count.rawValue
            case .idsAnnunciation:
                return IDSAnnunication.count.rawValue
            case .idsStatusReaderControlPoint:
                return IDSStatusReaderControlPoint.count.rawValue
            case .idsCommandControlPoint:
                return IDSCommandControlPoint.count.rawValue
            case .recordAccessControlPoint:
                return RecordAccessControlPoint.count.rawValue
            case .currentDateTime:
                return 1
            case .battery:
                return 1
            case .session:
                return 1
            case .count:
                fatalError("invalid")
            }
        }
        
        enum IDSFeatures: Int {
            case e2eProtectionSupported,
            basalRateSupported,
            tbrAbsoluteSupported,
            tbrRelativeSupported,
            tbrTemplateSupported,
            fastBolusSupported,
            extendedBolusSupported,
            multiwaveBolusSupported,
            bolusDelayTimeSupported,
            bolusTemplateSupported,
            bolusActivationTypeSupported,
            multipleBondSupported,
            isfProfileTemplateSupported,
            i2choRatioProfileTemplateSupported,
            targetGlucoseRangeProfileSupported,
            insulinOnBoardSupported,
            featureExtension,
            insulinConcentration,
            count
        }
        enum IDSStatusChanged: Int {
            case therapyControlStateChanged,
            operationalStateChanged,
            reservoirStatusChanged,
            annunciationStatusChanged,
            totalDailyInsulinStatusChanged,
            activeBasalRateStatusChanged,
            activeBolusStatusChanged,
            historyEventRecorded,
            count
        }
        enum IDSStatus: Int {
            case therapyControlState,
            operationalState,
            reservoirRemainingAmount,
            reservoirAttached,
            count
        }
        enum IDSAnnunication: Int {
            case annunciationInstanceID,
            annunciationType,
            annunciationStatus,
            count
        }
        enum IDSStatusReaderControlPoint: Int {
            case resetStatus,
            getActiveBolusIDs,
            getActiveBolusDelivery,
            getActiveBasalRateDelivery,
            getTotalDailyInsulinStatus,
            getCounter,
            getDeliveredInsulin,
            getInsulinOnBoard,
            count
        }
        enum IDSCommandControlPoint: Int {
            case setTherapyControlState,
            setFlightMode,
            snoozeAnnunciation,
            confirmAnnunciation,
            readBasalRateProfileTemplate,
            writeBasalRateProfileTemplate,
            setTBRAdjustment,
            cancelTBRAdjustment,
            getTBRTemplate,
            setTBRTemplate,
            setBolus,
            cancelBolus,
            getAvailableBoluses,
            getBolusTemplate,
            setBolusTemplate,
            getTemplateStatusAndDetails,
            resetTemplateStatus,
            activateProfileTemplates,
            getActivatedProfileTemplates,
            startPriming,
            stopPriming,
            setInitialReservoirLevel,
            resetReservoirInsulinOperationTime,
            readISFProfileTemplate,
            writeISFProfileTemplate,
            readI2CHORatioProfileTemplate,
            writeI2CHORatioProfileTemplate,
            readTargetGlucoseRangeProfileTemplate,
            writeTargetGlucoseRangeProfileTemplate,
            getMaxBolusAmount,
            setMaxBolusAmount,
            count
        }
        enum RecordAccessControlPoint: Int {
            case numberOfAllStoredRecords,
            reportAllRecords,
            reportRecordsGreaterThanOrEqualTo,
            reportRecordsLessThanOrEqualTo,
            reportRecordsWithinRange,
            reportFirstRecord,
            reportLastRecord,
            deleteAllRecords,
            deleteRecordsGreaterThanOrEqualTo,
            deleteRecordsLessThanOrEqualTo,
            deleteRecordsWithinRange,
            deleteFirstRecord,
            deleteLastRecord,
            count
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("IDSViewController")
        IDS.sharedInstance().idsDelegate = self
        IDS.sharedInstance().idsConnectionDelegate = self
        IDS.sharedInstance().idsDeviceInformationDelete = self
        IDS.sharedInstance().idsBatteryDelete = self
        IDSStatusReaderControlPoint.sharedInstance().idsStatusReaderControlPointDelegate = self
        IDSCommandData.sharedInstance().idsCommandDataDelegate = self
        IDSCommandControlPoint.sharedInstance().idsCommandControlPointDelegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
        //self.refreshTable()
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
    
    func selectBolus(completion: @escaping (_ value: UInt16?)->Void) {
        let alertController = UIAlertController(title: "Bolus Selection", message: "Select Bolus", preferredStyle: .actionSheet)
        
        for i in 0 ..< Int(IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS.count) {
                let actionTitle = String(format: "Bolus #%@", IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS[i].description)
                let action = UIAlertAction(title: actionTitle,
                                           style: UIAlertActionStyle.default,
                                           handler: { void in completion(IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS[i])})
                alertController.addAction(action)
        }
        self.present(alertController, animated: true)
    }
    
    func selectTemplate(_ title: String, message: String, templateType: UInt8, completion: @escaping (_ value: UInt8?)->Void) {
        if IDSCommandData.sharedInstance().templatesStatusAndDetails.count == 0 {
            showAlert(title: "No stored template statuses", message: "Get template status and details first!")
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        //
        // set font to alert via KVC, otherwise it'll get overwritten
        /*
         let titleAttributed = NSMutableAttributedString(
            string: title,
            attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 17)])
        alertController.setValue(titleAttributed, forKey: "attributedTitle")
        
        
        let messageAttributed = NSMutableAttributedString(
            string: alert.message!,
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(13)])
        alertController.setValue(messageAttributed, forKey: "attributedMessage")*/
        //
        
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
        //UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).font = UIFont.systemFont(ofSize: 8.0)
        //UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).textAlignment = .left
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
    
    public func searchForFHIRResources() {
        print("searchForFHIRResources")
        DispatchQueue.once(executeToken: "insulinDelivery.searchForFhirResources.runOnce") {
            IDSFhir.IDSFhirInstance.searchForPatient(given: String(describing:  IDSFhir.IDSFhirInstance.givenName), family: String(describing: IDSFhir.IDSFhirInstance.familyName)) { (bundle, error) -> Void in
                if let error = error {
                    print("error searching for patient: \(error)")
                }
                self.refreshTable()
            }
            
             IDSFhir.IDSFhirInstance.searchForDevice { (bundle, error) -> Void in
                if let error = error {
                    print("error searching for device: \(error)")
                }
                self.refreshTable()
                
                if bundle?.entry != nil {
                    IDSFhir.IDSFhirInstance.searchForSpecimen { (bundle, error) -> Void in
                        if let error = error {
                            print("error searching for specimen: \(error)")
                        }
                        
                        if bundle?.entry != nil {
                            print("specimen found")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue:section) else {
            fatalError("invalid section")
        }
        return section.rowCount()
        
        /*
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
        case 8:
            return 1
        case 9:
            return 1
        default:
            return 0
        }*/
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as UITableViewCell
        cell.textLabel?.numberOfLines = 0
        
        guard let section = Section(rawValue:indexPath.section) else {
            fatalError("invalid section")
        }
        
        switch section {
        case .fhirPatient:
            cell.textLabel!.text = "Given Name: \(self.givenName)\nFamily Name: \(self.familyName)"
            
            if IDSFhir.IDSFhirInstance.patient != nil {
                cell.detailTextLabel!.text = String(describing: "Patient FHIR ID: \(String(describing: IDSFhir.IDSFhirInstance.patient!.id!))")
                cell.accessoryView = nil
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.detailTextLabel!.text = "Patient: Tap to upload"
            }
        case .fhirDevice:
            if let manufacturer = IDS.sharedInstance().manufacturerName {
                cell.textLabel!.text = "Manufacturer: \(manufacturer)"
            }
            if let modelNumber = IDS.sharedInstance().modelNumber {
                cell.textLabel?.text?.append("\nModel: \(modelNumber)")
            }
            if let serialNumber = IDS.sharedInstance().serialNumber {
                cell.textLabel?.text?.append("\nSerial: \(serialNumber)")
            }
            if IDSFhir.IDSFhirInstance.device != nil {
                cell.detailTextLabel!.text = String(describing: "Device FHIR ID: \(String(describing: IDSFhir.IDSFhirInstance.device!.id!))")
                cell.accessoryView = nil
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.detailTextLabel!.text = "Device: Tap to upload"
            }
        case .idsFeatures:
            if(idsFeatures != nil) {
                guard let row = Section.IDSFeatures(rawValue:indexPath.row) else { fatalError("invalid row") }
                switch row {
                case .e2eProtectionSupported:
                    cell.textLabel!.text = idsFeatures.e2eProtectionSupported?.description
                    cell.detailTextLabel!.text = "E2E Protection Supported"
                case .basalRateSupported:
                    cell.textLabel!.text = idsFeatures.basalRateSupported?.description
                    cell.detailTextLabel!.text = "Basal Rate Supported"
                case .tbrAbsoluteSupported:
                    cell.textLabel!.text = idsFeatures.tbrAbsoluteSupported?.description
                    cell.detailTextLabel!.text = "TBR Absolute Supported"
                case .tbrRelativeSupported:
                    cell.textLabel!.text = idsFeatures.tbrRelativeSupported?.description
                    cell.detailTextLabel!.text = "TBR Relative Supported"
                case .tbrTemplateSupported:
                    cell.textLabel!.text = idsFeatures.tbrTemplateSupported?.description
                    cell.detailTextLabel!.text = "TBR Template Supported"
                case .fastBolusSupported:
                    cell.textLabel!.text = idsFeatures.fastBolusSupported?.description
                    cell.detailTextLabel!.text = "Fast Bolus Supported"
                case .extendedBolusSupported:
                    cell.textLabel!.text = idsFeatures.extendedBolusSupported?.description
                    cell.detailTextLabel!.text = "Extended Bolus Supported"
                case .multiwaveBolusSupported:
                    cell.textLabel!.text = idsFeatures.multiwaveBolusSupported?.description
                    cell.detailTextLabel!.text = "Multiwave Bolus Supported"
                case .bolusDelayTimeSupported:
                    cell.textLabel!.text = idsFeatures.bolusDelayTimeSupported?.description
                    cell.detailTextLabel!.text = "Bolus Delay Time Supported"
                case .bolusTemplateSupported:
                    cell.textLabel!.text = idsFeatures.bolusTemplateSupported?.description
                    cell.detailTextLabel!.text = "Bolus Template Supported"
                case .bolusActivationTypeSupported:
                    cell.textLabel!.text = idsFeatures.bolusActivationTypeSupported?.description
                    cell.detailTextLabel!.text = "Bolus Activation Type Supported"
                case .multipleBondSupported:
                    cell.textLabel!.text = idsFeatures.multipleBondSupported?.description
                    cell.detailTextLabel!.text = "Multiple Bond Supported"
                case .isfProfileTemplateSupported:
                    cell.textLabel!.text = idsFeatures.isfProfileTemplateSupported?.description
                    cell.detailTextLabel!.text = "ISF Profile Template Supported"
                case .i2choRatioProfileTemplateSupported:
                    cell.textLabel!.text = idsFeatures.i2choRatioProfileTemplateSupported?.description
                    cell.detailTextLabel!.text = "I2CHO Ratio Profile Template Supported"
                case .targetGlucoseRangeProfileSupported:
                    cell.textLabel!.text = idsFeatures.targetGlucoseRangeProfileTemplateSupported?.description
                    cell.detailTextLabel!.text = "Target Glucose Range Profile Template Supported"
                case .insulinOnBoardSupported:
                    cell.textLabel!.text = idsFeatures.insulinOnBoardSupported?.description
                    cell.detailTextLabel!.text = "Insulin On Board Supported"
                case .featureExtension:
                    cell.textLabel!.text = idsFeatures.featureExtension?.description
                    cell.detailTextLabel!.text = "Feature Extension"
                case .insulinConcentration:
                    cell.textLabel!.text = idsFeatures.insulinConcentration?.description
                    cell.detailTextLabel!.text = "Insulin Concentration"
                default:
                    cell.accessoryView = nil
                    cell.accessoryType = .none
                }
            }
        case .idsStatusChanged:
            if(idsStatusChanged != nil) {
                guard let row = Section.IDSStatusChanged(rawValue:indexPath.row) else { fatalError("invalid row") }
                switch row {
                case .therapyControlStateChanged:
                    cell.textLabel!.text = idsStatusChanged.therapyControlStateChanged?.description
                    cell.detailTextLabel!.text = "Therapy Control State Changed"
                case .operationalStateChanged:
                    cell.textLabel!.text = idsStatusChanged.operationalStateChanged?.description
                    cell.detailTextLabel!.text = "Operational State Changed"
                case .reservoirStatusChanged:
                    cell.textLabel!.text = idsStatusChanged.reservoirStatusChanged?.description
                    cell.detailTextLabel!.text = "Reservoir Status Changed"
                case .annunciationStatusChanged:
                    cell.textLabel!.text = idsStatusChanged.annunciationStatusChanged?.description
                    cell.detailTextLabel!.text = "Annunciation Status Changed"
                case .totalDailyInsulinStatusChanged:
                    cell.textLabel!.text = idsStatusChanged.totalDailyInsulinStatusChanged?.description
                    cell.detailTextLabel!.text = "Total Daily Insulin Status Changed"
                case .activeBasalRateStatusChanged:
                    cell.textLabel!.text = idsStatusChanged.activeBasalRateStatusChanged?.description
                    cell.detailTextLabel!.text = "Active Basal Rate Status Changed"
                case .activeBolusStatusChanged:
                    cell.textLabel!.text = idsStatusChanged.activeBolusStatusChanged?.description
                    cell.detailTextLabel!.text = "Active Bolus Status Changed"
                case .historyEventRecorded:
                    cell.textLabel!.text = idsStatusChanged.historyEventRecorded?.description
                    cell.detailTextLabel!.text = "History Event Recorded"
                default:
                    cell.accessoryView = nil
                    cell.accessoryType = .none
                }
            }
        case .idsStatus:
            if(idsStatus != nil) {
                guard let row = Section.IDSStatus(rawValue:indexPath.row) else { fatalError("invalid row") }
                switch row {
                case .therapyControlState:
                    cell.textLabel!.text = IDSStatus.TherapyControlState(rawValue: idsStatus.therapyControlState)?.description
                    cell.detailTextLabel!.text = "Therapy Control State"
                case .operationalState:
                    cell.textLabel!.text = IDSStatus.OperationalStateField(rawValue: idsStatus.operationalState)?.description
                    cell.detailTextLabel!.text = "Operational State"
                case .reservoirRemainingAmount:
                    cell.textLabel!.text = idsStatus.reservoirRemainingAmount.description
                    cell.detailTextLabel!.text = "Reservoir Remaining Amount"
                case .reservoirAttached:
                    cell.textLabel!.text = idsStatus.reservoirAttached?.description
                    cell.detailTextLabel!.text = "Reservoir Attached"
                default:
                    cell.textLabel!.text = ""
                    cell.detailTextLabel!.text = ""
                    cell.accessoryView = nil
                    cell.accessoryType = .none
                }
            }
        case .idsAnnunciation:
            if(idsAnnunciationStatus != nil) {
                if(idsAnnunciationStatus.annunciationPresent)! {
                    guard let row = Section.IDSAnnunication(rawValue:indexPath.row) else { fatalError("invalid row") }
                    switch row {
                    case .annunciationInstanceID:
                        cell.textLabel!.text = idsAnnunciationStatus.annunciationInstanceID.description
                        cell.detailTextLabel!.text = "Annunciation Instance ID"
                    case .annunciationType:
                        cell.textLabel!.text = IDSAnnunciationStatus.AnnunciationTypeValues(rawValue: idsAnnunciationStatus.annunciationType)?.description
                        cell.detailTextLabel!.text = "Annunciation Type"
                    case .annunciationStatus:
                        cell.textLabel!.text = IDSAnnunciationStatus.AnnunciationStatusValues(rawValue: idsAnnunciationStatus.annunciationStatus)?.description
                        cell.detailTextLabel!.text = "Annunciation Status"
                    default:
                        cell.accessoryView = nil
                        cell.accessoryType = .none
                    }
                }
            }
        case .idsStatusReaderControlPoint:
            guard let row = Section.IDSStatusReaderControlPoint(rawValue:indexPath.row) else { fatalError("invalid row") }
            switch row {
            case .resetStatus:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Reset Status"
            case .getActiveBolusIDs:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Active Bolus IDs"
            case .getActiveBolusDelivery:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Active Bolus Delivery"
            case .getActiveBasalRateDelivery:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Active Basal Rate Delivery"
            case .getTotalDailyInsulinStatus:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Total Daily Insulin Status"
            case .getCounter:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Counter"
            case .getDeliveredInsulin:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Delivered Insulin"
            case .getInsulinOnBoard:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Insulin On Board"
            default:
                cell.accessoryView = nil
                cell.accessoryType = .none
            }
        case .idsCommandControlPoint:
            guard let row = Section.IDSCommandControlPoint(rawValue:indexPath.row) else { fatalError("invalid row") }
            switch row {
            case .setTherapyControlState:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Set Therapy Control State"
            case .setFlightMode:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Set Flight Mode"
            case .snoozeAnnunciation:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Snooze Annunciation"
            case .confirmAnnunciation:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Confirm Annunciation"
            case .readBasalRateProfileTemplate:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Read Basal Rate Profile Template"
            case .writeBasalRateProfileTemplate:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Write Basal Rate Profile Template"
            case .setTBRAdjustment:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Set TBR Adjustment"
            case .cancelTBRAdjustment:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Cancel TBR Adjustment"
            case .getTBRTemplate:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get TBR Template"
            case .setTBRTemplate:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Set TBR Template"
            case .setBolus:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Set Bolus"
            case .cancelBolus:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Cancel Bolus"
            case .getAvailableBoluses:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Available Boluses"
            case .getBolusTemplate:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Bolus Template"
            case .setBolusTemplate:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Set Bolus Template"
            case .getTemplateStatusAndDetails:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Template Status and Details"
            case .resetTemplateStatus:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Reset Template Status"
            case .activateProfileTemplates:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Activate Profile Templates"
            case .getActivatedProfileTemplates:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Activated Profile Templates"
            case .startPriming:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Start Priming"
            case .stopPriming:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Stop Priming"
            case .setInitialReservoirLevel:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Set Initial Reservoir Fill Level"
            case .resetReservoirInsulinOperationTime:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Reset Reservoir Insulin Operation Time"
            case .readISFProfileTemplate:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Read ISF Profile Template"
            case .writeISFProfileTemplate:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Write ISF Profile Template"
            case .readI2CHORatioProfileTemplate:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Read I2CHO Ratio Profile Template"
            case .writeI2CHORatioProfileTemplate:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Write I2CHO Ratio Profile Template"
            case .readTargetGlucoseRangeProfileTemplate:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Read Target Glucose Range Profile Template"
            case .writeTargetGlucoseRangeProfileTemplate:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Write Target Glucose Range Profile Template"
            case .getMaxBolusAmount:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Get Max Bolus Amount"
            case .setMaxBolusAmount:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Set Max Bolus Amount"
            default:
                cell.accessoryView = nil
                cell.accessoryType = .none
            }
        case .recordAccessControlPoint:
            guard let row = Section.RecordAccessControlPoint(rawValue:indexPath.row) else { fatalError("invalid row") }
            switch row {
            case .numberOfAllStoredRecords:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Number Of All Stored Records"
            case .reportAllRecords:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Report All Records"
            case .reportRecordsGreaterThanOrEqualTo:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Report Records Greater Than Or Equal To"
            case .reportRecordsLessThanOrEqualTo:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Report Records Less Than Or Equal To"
            case .reportRecordsWithinRange:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Report Records Within Range"
            case .reportFirstRecord:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Report First Record"
            case .reportLastRecord:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Report Last Record"
            case .deleteAllRecords:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Delete All Records"
            case .deleteRecordsGreaterThanOrEqualTo:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Delete Records Greater Than Or Equal To"
            case .deleteRecordsLessThanOrEqualTo:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Delete Records Less Than Or Equal To"
            case .deleteRecordsWithinRange:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Delete Records Within Range"
            case .deleteFirstRecord:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Delete First Record"
            case .deleteLastRecord:
                cell.textLabel!.text = ""
                cell.detailTextLabel!.text = "Delete Last Record"
            default:
                cell.accessoryView = nil
                cell.accessoryType = .none
            }
        case .currentDateTime:
            cell.textLabel!.text = ""
            cell.detailTextLabel!.text = "Set current time"
        case .battery:
            if batteryLevel == nil {
                cell.textLabel!.text = "N/A"
            } else {
                cell.textLabel!.text = batteryLevel + "%"
            }
            cell.detailTextLabel!.text = "Battery Level"
        case .session:
            cell.textLabel!.text = ""
            cell.detailTextLabel!.text = "Start session"
        default:
            cell.accessoryView = nil
            cell.accessoryType = .none
        }
        
        return cell
}
        /*
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
        case 8:
            if batteryLevel == nil {
                cell.textLabel!.text = "N/A"
            } else {
                cell.textLabel!.text = batteryLevel + "%"
            }
            cell.detailTextLabel!.text = "Battery Level"
        case 9:
            cell.textLabel!.text = ""
            cell.detailTextLabel!.text = "Start session"
        default:
            ()
        }
        
        return cell
    }
*/
    
    func createActivityView() -> UIActivityIndicatorView {
        let activity = UIActivityIndicatorView(frame: .zero)
        activity.sizeToFit()
        
        activity.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.gray
        activity.startAnimating()
        
        return activity
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 11 +
            IDS.sharedInstance().currentTimeServiceSupported.intValue +
            IDS.sharedInstance().batteryServiceSupported.intValue
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionType = Section(rawValue: section)
        return sectionType?.description() ?? "none"
    }
    
    //MARK: - table delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        print("didSelectRowAt section: \(indexPath.section) row: \(indexPath.row)")
        
        guard let section = Section(rawValue:indexPath.section) else {
            fatalError("invalid section")
        }
        
        switch section {
        case .fhirPatient:
            if (IDSFhir.IDSFhirInstance.patient?.id) != nil {
                performSegue(withIdentifier: "segueToPatient", sender: self)
            } else {
                cell.accessoryView = self.createActivityView()
                IDSFhir.IDSFhirInstance.createPatient { (patient, error) -> Void in
                    if error == nil {
                        print("patient created with id: \(patient.id!)")
                    }
                    self.refreshTable()
                }
            }
        case .fhirDevice:
            if (IDSFhir.IDSFhirInstance.device?.id) != nil {
                performSegue(withIdentifier: "segueToDevice", sender: self)
            } else {
                cell.accessoryView = self.createActivityView()
                IDSFhir.IDSFhirInstance.createDevice { (device, error) -> Void in
                    if error == nil {
                        print("device created with id: \(device.id!)")
                        IDSFhir.IDSFhirInstance.createDeviceComponent { (error) -> Void in
                            if error == nil {
                                print("device component created with id: \(String(describing: IDSFhir.IDSFhirInstance.deviceComponent!.id!))")
                                IDSFhir.IDSFhirInstance.createSpecimen()
                            }
                            
                        }
                    }
                    self.refreshTable()
                }
            }
        case .idsStatusReaderControlPoint:
            guard let row = Section.IDSStatusReaderControlPoint(rawValue:indexPath.row) else { fatalError("invalid row") }
            switch row {
            case .resetStatus:
                IDSStatusReaderControlPoint.sharedInstance().resetSensorStatus()
            case .getActiveBolusIDs:
                IDSStatusReaderControlPoint.sharedInstance().getActiveBolusIDs()
            case .getActiveBolusDelivery:
                if IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS.count > 0 {
                    self.selectBolus() { (value) -> Void in
                        if let value = value {
                            IDSStatusReaderControlPoint.sharedInstance().getActiveBolusDelivery(bolusID: value)
                        }
                    }
                } else {
                    self.showAlert(title: "Message", message: "Get active bolus ID's first")
                }
            case .getActiveBasalRateDelivery:
                IDSStatusReaderControlPoint.sharedInstance().getActiveBasalRateDelivery()
            case .getTotalDailyInsulinStatus:
                IDSStatusReaderControlPoint.sharedInstance().getTotalDailyInsulinStatus()
            case .getCounter:
                self.getCounterTypeAlert()
            case .getDeliveredInsulin:
                IDSStatusReaderControlPoint.sharedInstance().getDeliveredInsulin()
            case .getInsulinOnBoard:
                IDSStatusReaderControlPoint.sharedInstance().getInsulinOnBoard()
            default:
                ()
            }
        case .idsCommandControlPoint:
            guard let row = Section.IDSCommandControlPoint(rawValue:indexPath.row) else { fatalError("invalid row") }
            switch row {
            case .setTherapyControlState:
                IDSCommandControlPoint.sharedInstance().setTherapyControlState()
            case .setFlightMode:
                IDSCommandControlPoint.sharedInstance().setFlightMode()
            case .snoozeAnnunciation:
                IDSCommandControlPoint.sharedInstance().snoozeAnnunciation(annunciation: self.idsAnnunciationStatus.annunciationInstanceID)
            case .confirmAnnunciation:
                IDSCommandControlPoint.sharedInstance().confirmAnnunciation(annunciation: self.idsAnnunciationStatus.annunciationInstanceID)
            case .readBasalRateProfileTemplate:
                selectTemplate("Basal Rate Profile Templates", message: "", templateType: TemplateType.basalRateProfileTemplate.rawValue) { (value) -> Void in
                    if let value = value {
                        IDSCommandControlPoint.sharedInstance().readBasalRateProfileTemplate(templateNumber: value)
                    }
                }
            case .writeBasalRateProfileTemplate:
                selectTemplate("Basal Rate Profile Templates", message: "", templateType: TemplateType.basalRateProfileTemplate.rawValue) { (value) -> Void in
                    if let value = value {
                        IDSCommandControlPoint.sharedInstance().writeBasalRateProfileTemplate(templateNumber: value)
                    }
                }
            case .setTBRAdjustment:
                IDSCommandControlPoint.sharedInstance().setTBRAdjustment()
            case .cancelTBRAdjustment:
                IDSCommandControlPoint.sharedInstance().cancelTBRAdjustment()
            case .getTBRTemplate:
                selectTemplate("TBR Templates", message: "", templateType: TemplateType.tbrTemplate.rawValue) { (value) -> Void in
                    if let value = value {
                        IDSCommandControlPoint.sharedInstance().getTBRTemplate(templateNumber: value)
                    }
                }
            case .setTBRTemplate:
                selectTemplate("TBR Templates", message: "", templateType: TemplateType.tbrTemplate.rawValue) { (value) -> Void in
                    if let value = value {
                        IDSCommandControlPoint.sharedInstance().setTBRTemplate(templateNumber: value)
                    }
                }
            case .setBolus:
                IDSCommandControlPoint.sharedInstance().setBolus(fastAmount: 7.5,
                                                                 extendedAmount: 0,
                                                                 duration: 0,
                                                                 delayTime: 0,
                                                                 templateNumber: 0,
                                                                 activationType: 0,
                                                                 bolusDeliveryReasonCorrection: false,
                                                                 bolusDeliveryReasonMeal: false)
            case .cancelBolus:
                if(Int(IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS.count) > 0) {
                    self.selectBolus() { (value) -> Void in
                        if let value = value {
                            IDSCommandControlPoint.sharedInstance().cancelBolus(bolusID: value)
                        }
                    }
                } else {
                    showAlert(title: "Cancel Bolus", message: "Get Active Bolus IDs first")
                }
            case .getAvailableBoluses:
                IDSCommandControlPoint.sharedInstance().getAvailableBoluses()
            case .getBolusTemplate:
                selectTemplate("Bolus Templates", message: "", templateType: TemplateType.bolusTemplate.rawValue) { (value) -> Void in
                    if let value = value {
                        IDSCommandControlPoint.sharedInstance().getBolusTemplate(templateNumber: value)
                    }
                }
            case .setBolusTemplate:
                selectTemplate("Bolus Templates", message: "", templateType: TemplateType.bolusTemplate.rawValue) { (value) -> Void in
                    if let value = value {
                        IDSCommandControlPoint.sharedInstance().setBolusTemplate(templateNumber: value)
                    }
                }
            case .getTemplateStatusAndDetails:
                IDSCommandControlPoint.sharedInstance().getTemplateStatusAndDetails()
            case .resetTemplateStatus:
                selectTemplate("Available Templates", message: "", templateType: 0) { (value) -> Void in
                    if let value = value {
                        var templates:[UInt8] = []
                        templates.append(value)
                        IDSCommandControlPoint.sharedInstance().resetTemplateStatus(templatesNumbers: templates)
                    }
                }
            case .activateProfileTemplates:
                selectTemplate("Available Templates", message: "", templateType: 0) { (value) -> Void in
                    if let value = value {
                        var templates:[UInt8] = []
                        templates.append(value)
                        IDSCommandControlPoint.sharedInstance().activateProfileTemplates(templatesNumbers: templates)
                    }
                }
            case .getActivatedProfileTemplates:
                IDSCommandControlPoint.sharedInstance().getActivatedProfileTemplates()
            case .startPriming:
                IDSCommandControlPoint.sharedInstance().startPriming()
            case .stopPriming:
                IDSCommandControlPoint.sharedInstance().stopPriming()
            case .setInitialReservoirLevel:
                IDSCommandControlPoint.sharedInstance().setInitialReservoirFillLevel()
            case .resetReservoirInsulinOperationTime:
                IDSCommandControlPoint.sharedInstance().resetReservoirInsulinOperationTime()
            case .readISFProfileTemplate:
                selectTemplate("ISF Templates", message: "", templateType: TemplateType.isfProfileTemplate.rawValue) { (value) -> Void in
                    if let value = value {
                        IDSCommandControlPoint.sharedInstance().readISFProfileTemplate(templateNumber: value)
                    }
                }
            case .writeISFProfileTemplate:
                selectTemplate("ISF Templates", message: "", templateType: TemplateType.isfProfileTemplate.rawValue) { (value) -> Void in
                    if let value = value {
                        IDSCommandControlPoint.sharedInstance().writeISFProfileTemplate(templateNumber: value)
                    }
                }
            case .readI2CHORatioProfileTemplate:
                selectTemplate("I2CHO Templates", message: "", templateType: TemplateType.i2choTemplate.rawValue) { (value) -> Void in
                    if let value = value {
                        IDSCommandControlPoint.sharedInstance().readI2CHORatioProfileTemplate(templateNumber: value)
                    }
                }
            case .writeI2CHORatioProfileTemplate:
                selectTemplate("I2CHO Templates", message: "", templateType: TemplateType.i2choTemplate.rawValue) { (value) -> Void in
                    if let value = value {
                        IDSCommandControlPoint.sharedInstance().writeI2CHORatioProfileTemplate(templateNumber: value)
                    }
                }
            case .readTargetGlucoseRangeProfileTemplate:
                selectTemplate("Target Glucose Range Profile Templates", message: "", templateType: TemplateType.targetGlucoseTemplate.rawValue) { (value) -> Void in
                    if let value = value {
                        IDSCommandControlPoint.sharedInstance().readTargetGlucoseRangeProfileTemplate(templateNumber: value)
                    }
                }
            case .writeTargetGlucoseRangeProfileTemplate:
                selectTemplate("Target Glucose Range Profile Templates", message: "", templateType: TemplateType.targetGlucoseTemplate.rawValue) { (value) -> Void in
                    if let value = value {
                        IDSCommandControlPoint.sharedInstance().writeTargetGlucoseRangeProfileTemplate(templateNumber: value)
                    }
                }
            case .getMaxBolusAmount:
                IDSCommandControlPoint.sharedInstance().getMaxBolusAmount()
            case .setMaxBolusAmount:
                IDSCommandControlPoint.sharedInstance().setMaxBolusAmount(maxBolusAmount: 9.0)
            default:
                ()
            }
        case .recordAccessControlPoint:
            guard let row = Section.RecordAccessControlPoint(rawValue:indexPath.row) else { fatalError("invalid row") }
            switch row {
            case .numberOfAllStoredRecords:
                IDSRecordAccessControlPoint.sharedInstance().reportNumberOfAllStoredRecords()
            case .reportAllRecords:
                IDSRecordAccessControlPoint.sharedInstance().reportAllRecords()
            case .reportRecordsGreaterThanOrEqualTo:
                IDSRecordAccessControlPoint.sharedInstance().reportRecordsGreaterThanOrEqualTo(recordNumber: 1)
            case .reportRecordsLessThanOrEqualTo:
                IDSRecordAccessControlPoint.sharedInstance().reportRecordsLessThanOrEqualTo(recordNumber: 5)
            case .reportRecordsWithinRange:
                IDSRecordAccessControlPoint.sharedInstance().reportRecordsWithinRange(from: 1, to: 5)
            case .reportFirstRecord:
                IDSRecordAccessControlPoint.sharedInstance().reportFirstRecord()
            case .reportLastRecord:
                IDSRecordAccessControlPoint.sharedInstance().reportLastRecord()
            case .deleteAllRecords:
                IDSRecordAccessControlPoint.sharedInstance().deleteAllRecords()
            case .deleteRecordsGreaterThanOrEqualTo:
                IDSRecordAccessControlPoint.sharedInstance().deleteRecordsGreaterThanOrEqualTo(recordNumber: 1)
            case .deleteRecordsLessThanOrEqualTo:
                IDSRecordAccessControlPoint.sharedInstance().deleteRecordsLessThanOrEqualTo(recordNumber: 5)
            case .deleteRecordsWithinRange:
                IDSRecordAccessControlPoint.sharedInstance().deleteRecordsWithinRange(from: 1, to: 5)
            case .deleteFirstRecord:
                IDSRecordAccessControlPoint.sharedInstance().deleteFirstRecord()
            case .deleteLastRecord:
                IDSRecordAccessControlPoint.sharedInstance().deleteLastRecord()
            default:
                ()
            }
        case .currentDateTime:
            IDSDateTime.sharedInstance().writeCurrentDateTime()
        case .session:
            performSegue(withIdentifier: "segueToSessionView", sender: self)
        default:
            ()
        }
    }
}

        /*
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
                            self.selectBolus() { (value) -> Void in
                                if let value = value {
                                    //IDSCommandControlPoint.sharedInstance().cancelBolus(bolusID: value)
                                    IDSStatusReaderControlPoint.sharedInstance().getActiveBolusDelivery(bolusID: value)
                                }
                            }
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
                        IDSCommandControlPoint.sharedInstance().setBolus(fastAmount: 7.5,
                                                                         extendedAmount: 0,
                                                                         duration: 0,
                                                                         delayTime: 0,
                                                                         templateNumber: 0,
                                                                         activationType: 0,
                                                                         bolusDeliveryReasonCorrection: false,
                                                                         bolusDeliveryReasonMeal: false)
                    case 11:
                        if(Int(IDSStatusReaderControlPoint.sharedInstance().activeBolusIDS.count) > 0) {
                            //IDSCommandControlPoint.sharedInstance().cancelBolus()
                            //self.bolusSelectionAlert()
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
                        selectTemplate("Available Templates", message: "", templateType: 0) { (value) -> Void in
                            if let value = value {
                                var templates:[UInt8] = []
                                templates.append(value)
                                IDSCommandControlPoint.sharedInstance().resetTemplateStatus(templatesNumbers: templates)
                            }
                    }
                    case 17:
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
            case 8:
                ()
            case 9:
                performSegue(withIdentifier: "segueToSessionView", sender: self)
            default:
                ()
        }
    }
}*/

extension IDSViewController: IDSProtocol {
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
}

extension IDSViewController: IDSBatteryProtocol {
    func IDSBatteryLevel(level: UInt8) {
        print("IDSBatteryLevel")
        batteryLevel = level.description
        self.refreshTable()
    }
}

extension IDSViewController: IDSDeviceInformationProtocol {
    func IDSSerialNumber(serialNumber: String) {
        print("IDSSerialNumber")
        if IDS.sharedInstance().modelNumber?.isEmpty == false {
            if IDS.sharedInstance().manufacturerName?.isEmpty == false {
                if IDS.sharedInstance().serialNumber?.isEmpty == false {
                    self.searchForFHIRResources()
                }
            }
        }
    }
    
    func IDSModelNumber(modelNumber: String) {
        print("IDSModelNumber")
        if IDS.sharedInstance().modelNumber?.isEmpty == false {
            if IDS.sharedInstance().manufacturerName?.isEmpty == false {
                if IDS.sharedInstance().serialNumber?.isEmpty == false {
                    self.searchForFHIRResources()
                }
            }
        }
    }
    
    func IDSManufacturer(manufacturerName: String) {
        print("IDSManufacturer")
        if IDS.sharedInstance().modelNumber?.isEmpty == false {
            if IDS.sharedInstance().manufacturerName?.isEmpty == false {
                if IDS.sharedInstance().serialNumber?.isEmpty == false {
                    self.searchForFHIRResources()
                }
            }
        }
    }
}

extension IDSViewController: IDSConnectionProtocol {
    func IDSDisconnected(ids: CBPeripheral) {
        print("IDSDisconnected")
    }
    
    func IDSConnected(ids: CBPeripheral) {
        print("IDSConnected")
        self.peripheral = ids
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
    
    func bolusActiveDelivery(bolusDelivery: ActiveBolusDelivery) {
        self.showAlert(title: "Active Bolus Delivery", message: bolusDelivery.bolusID.description)
    }
    
    func basalActiveDelivery(basalDelivery: ActiveBasalRateDelivery) {
        self.showAlert(title: "Active Basal Delivery", message: "")
    }
    
    func totalDailyInsulinDeliveredStatus(status: TotalDailyInsulinDeliveredStatus) {
        self.showAlert(title: "Total Daily Insulin Delivered Status", message: "")
    }
    
    func counterValues(counter: Counter) {
        self.showAlert(title: "Counter", message: "")
    }
    
    func deliveredInsulin(insulinAmount: DeliveredInsulin) {
        self.showAlert(title: "Delivered Insulin", message: "")
    }
    
    func insulinOnBoard(insulinAmount: InsulinOnBoard) {
        self.showAlert(title: "Insulin OnBoard", message: "")
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
