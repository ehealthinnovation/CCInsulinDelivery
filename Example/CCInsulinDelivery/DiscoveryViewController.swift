//
//  DiscoveryViewController.swift
//  CCInsulinDelivery
//
//  Created by ktallevi on 09/11/2017.
//  Copyright (c) 2017 ktallevi. All rights reserved.
//

import UIKit
import CCBluetooth
import CoreBluetooth
import CCInsulinDelivery

class DiscoveryViewController: UITableViewController, IDSDiscoveryProtocol {
    let cellIdentifier = "IDSDevicesCellIdentifier"
    var discoveredIDSDevices: Array<CBPeripheral> = Array<CBPeripheral>()
    var previouslyConnectedIDSDevices: Array<CBPeripheral> = Array<CBPeripheral>()
    var peripheral : CBPeripheral!
    let rc = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("DiscoveryViewController#viewDidLoad")
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        
        IDS.sharedInstance().idsDiscoveryDelegate = self
    }
    
    @objc func onRefresh() {
        refreshControl?.endRefreshing()
        discoveredIDSDevices.removeAll()
        
        self.refreshTable()
        
        //IDS.sharedInstance().scanForIDSDevices()
        //Glucose.sharedInstance().glucoseMeterDiscoveryDelegate = self
        //Glucose.sharedInstance().scanForGlucoseMeters()
    }

    func refreshTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func IDSDiscovered(IDSDevice:CBPeripheral) {
        print("DiscoveryViewController#IDSDiscovered")
        discoveredIDSDevices.append(IDSDevice)
        print("ids device: \(String(describing: IDSDevice.name))")
        
        self.refreshTable()
    }
    
    // MARK: Table data source methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return discoveredIDSDevices.count
        } else {
            return previouslyConnectedIDSDevices.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as UITableViewCell
        
        if (indexPath.section == 0) {
            let peripheral = Array(self.discoveredIDSDevices)[indexPath.row]
            cell.textLabel!.text = peripheral.name
            cell.detailTextLabel!.text = peripheral.identifier.uuidString
        } else {
            let peripheral = Array(self.previouslyConnectedIDSDevices)[indexPath.row]
            cell.textLabel!.text = peripheral.name
            cell.detailTextLabel!.text = peripheral.identifier.uuidString
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Discovered IDS Devices"
        } else {
            return "Previously Connected IDS Devices"
        }
    }
    
    //MARK: table delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.section == 0) {
            let glucoseMeter = Array(discoveredIDSDevices)[indexPath.row]
            self.peripheral = glucoseMeter
            self.addPreviouslySelectedGlucoseMeter(self.peripheral)
            self.didSelectDiscoveredGlucoseMeter(Array(self.discoveredIDSDevices)[indexPath.row])
        } else {
            let glucoseMeter = Array(previouslyConnectedIDSDevices)[indexPath.row]
            self.peripheral = glucoseMeter
            self.didSelectPreviouslySelectedGlucoseMeter(Array(self.previouslyConnectedIDSDevices)[indexPath.row])
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "segueToIDSView", sender: self)
    }
    
    func didSelectDiscoveredGlucoseMeter(_ peripheral:CBPeripheral) {
        print("ViewController#didSelectDiscoveredPeripheral \(String(describing: peripheral.name))")
        Bluetooth.sharedInstance().connectPeripheral(peripheral)
    }
    
    func didSelectPreviouslySelectedGlucoseMeter(_ peripheral:CBPeripheral) {
        print("ViewController#didSelectPreviouslyConnectedPeripheral \(String(describing: peripheral.name))")
        Bluetooth.sharedInstance().reconnectPeripheral(peripheral.identifier.uuidString)
    }
    
    func addPreviouslySelectedGlucoseMeter(_ cbPeripheral:CBPeripheral) {
        var peripheralAlreadyExists: Bool = false
        
        for aPeripheral in self.previouslyConnectedIDSDevices {
            if (aPeripheral.identifier.uuidString == cbPeripheral.identifier.uuidString) {
                peripheralAlreadyExists = true
            }
        }
        
        if (!peripheralAlreadyExists) {
            self.previouslyConnectedIDSDevices.append(cbPeripheral)
        }
    }

}

