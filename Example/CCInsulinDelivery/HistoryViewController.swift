//
//  HistoryViewController.swift
//  CCInsulinDelivery_Example
//
//  Created by Kevin Tallevi on 5/28/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import CCInsulinDelivery

class HistoryViewController: UITableViewController {
    let cellIdentifier = "HistoryEventCellIdentifier"
    
    //MARK: - table source methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return IDS.sharedInstance().historyEvents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as UITableViewCell
        cell.textLabel?.numberOfLines = 0
        
        let event: IDSHistoryEvent = IDS.sharedInstance().historyEvents[indexPath.row]
        cell.textLabel?.text = IDSDataTypes.EventType(rawValue:event.event)?.description
        
        let eventType: UInt16 = event.event
        switch eventType {
            case IDSDataTypes.EventType.basalRateProfileTemplateTimeBlockChanged.rawValue:
                cell.detailTextLabel!.text = "Tap for details (Offset: \(event.offset) seconds)"
            case IDSDataTypes.EventType.tbrTemplateChanged.rawValue:
                cell.detailTextLabel!.text = "Tap for details (Offset: \(event.offset) seconds)"
            case IDSDataTypes.EventType.isfProfileTemplateTimeBlockChanged.rawValue:
                cell.detailTextLabel!.text = "Tap for details (Offset: \(event.offset) seconds)"
            case IDSDataTypes.EventType.i2choRatioProfileTemplateTimeBlockChanged.rawValue:
                cell.detailTextLabel!.text = "Tap for details (Offset: \(event.offset) seconds)"
            case IDSDataTypes.EventType.targetGlucoseRangeProfileTemplateTimeBlockChanged.rawValue:
                cell.detailTextLabel!.text = "Tap for details (Offset: \(event.offset) seconds)"
            default:
                cell.detailTextLabel!.text = event.eventDescription + " " + "(Offset: \(event.offset) seconds)"
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "History Events"
    }
    
    //MARK: - table delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        print("didSelectRowAt section: \(indexPath.section) row: \(indexPath.row)")
        
        let event: IDSHistoryEvent = IDS.sharedInstance().historyEvents[indexPath.row]
        cell.textLabel?.text = IDSDataTypes.EventType(rawValue:event.event)?.description
        
        let eventType: UInt16 = event.event
        switch eventType {
        case IDSDataTypes.EventType.basalRateProfileTemplateTimeBlockChanged.rawValue:
            showAlert(title: "Basal rate profile template time block changed", message: event.eventDescription)
        case IDSDataTypes.EventType.tbrTemplateChanged.rawValue:
            showAlert(title: "TBR template changed", message: event.eventDescription)
        case IDSDataTypes.EventType.isfProfileTemplateTimeBlockChanged.rawValue:
            showAlert(title: "ISF profile template time block changed", message: event.eventDescription)
        case IDSDataTypes.EventType.i2choRatioProfileTemplateTimeBlockChanged.rawValue:
            showAlert(title: "I2CHO ratio profile template time block changed", message: event.eventDescription)
        case IDSDataTypes.EventType.targetGlucoseRangeProfileTemplateTimeBlockChanged.rawValue:
            showAlert(title: "Target glucose range profile template time block changed", message: event.eventDescription)
        default:
            ()
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
            action.isEnabled = true
        })
        self.present(alert, animated: true)
    }
}
