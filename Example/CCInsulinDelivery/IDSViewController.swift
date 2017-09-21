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
    var peripheral : CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("IDSViewController")
        IDS.sharedInstance().idsDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.refreshTable()
    }

    func refreshTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    // IDSProtocol
    func IDSDisconnected(ids: CBPeripheral) {
        print("IDSDisconnected")
    }

    func IDSConnected(ids: CBPeripheral) {
        print("IDSConnected")
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
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if(idsFeatures != nil) {
                return 11
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
        default:
            cell.textLabel!.text = ""
            cell.detailTextLabel!.text = ""
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
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
        default:
            return ""
        }
    }
    
    //MARK: - table delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("didSelectRowAt")
    }

}
