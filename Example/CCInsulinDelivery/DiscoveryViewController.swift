//
//  DiscoveryViewController.swift
//  CCInsulinDelivery
//
//  Created by ktallevi on 09/11/2017.
//  Copyright (c) 2017 ktallevi. All rights reserved.
//

import Foundation
import UIKit
import CCBluetooth
import CoreBluetooth
import CCInsulinDelivery

class DiscoveryViewController: UITableViewController, IDSDiscoveryProtocol, Refreshable {
    let cellIdentifier = "IDSDevicesCellIdentifier"
    var discoveredIDSDevices: Array<CBPeripheral> = Array<CBPeripheral>()
    var previouslyConnectedIDSDevices: Array<CBPeripheral> = Array<CBPeripheral>()
    var peripheral : CBPeripheral!
    let rc = UIRefreshControl()
    let browser = NetServiceBrowser()
    var fhirService = NetService()
    var fhirServiceIP: String?
    @IBOutlet weak var discoverFHIRServersButton: UIBarButtonItem!
   
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
    }

    func refreshTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    @IBAction func discoverFHIRServersButtonAction(_ sender: Any) {
        print("discoverFHIRServersButtonAction")
        self.browser.delegate = self
        self.browser.searchForServices(ofType: "_http._tcp.", inDomain: "local")
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
            let ids = Array(discoveredIDSDevices)[indexPath.row]
            self.peripheral = ids
            self.addPreviouslySelectedIDS(self.peripheral)
            self.didSelectDiscoveredIDS(Array(self.discoveredIDSDevices)[indexPath.row])
        } else {
            let ids = Array(previouslyConnectedIDSDevices)[indexPath.row]
            self.peripheral = ids
            self.didSelectPreviouslySelectedIDS(Array(self.previouslyConnectedIDSDevices)[indexPath.row])
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "segueToIDSView", sender: self)
    }
    
    func didSelectDiscoveredIDS(_ peripheral:CBPeripheral) {
        print("DiscoveryViewController#didSelectDiscoveredIDS \(String(describing: peripheral.name))")
        Bluetooth.sharedInstance().connectPeripheral(peripheral)
    }
    
    func didSelectPreviouslySelectedIDS(_ peripheral:CBPeripheral) {
        print("DiscoveryViewController#didSelectPreviouslySelectedIDS \(String(describing: peripheral.name))")
        Bluetooth.sharedInstance().reconnectPeripheral(peripheral.identifier.uuidString)
    }
    
    func addPreviouslySelectedIDS(_ cbPeripheral:CBPeripheral) {
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
    
    func getIPV4StringfromAddress(address: [Data]) -> String {
        
        let data = address.first! as NSData
        
        var values: [Int] = [0, 0, 0, 0]
        
        for i in 0...3 {
            data.getBytes(&values[i], range: NSRange(location: i+4, length: 1))
        }
        
        let ipStr = String(format: "%d.%d.%d.%d", values[0], values[1], values[2], values[3])
        
        return ipStr
    }
    
    func showFHIRServerAlertController() {
        let alert = UIAlertController(title: "Select FHIR server", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "fhirtest.uhn.ca", style: .default) { action in
            action.isEnabled = true
            FHIR.fhirInstance.setFHIRServerAddress(address: "fhirtest.uhn.ca")
        })
        alert.addAction(UIAlertAction(title: self.fhirService.name, style: .default) { action in
            action.isEnabled = true
            FHIR.fhirInstance.setFHIRServerAddress(address: self.fhirServiceIP!)
        })
        
        self.present(alert, animated: true)
    }
}

extension DiscoveryViewController: NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        if service.name.contains("fhir") {
            print("found fhir server")
            self.browser.stop()
            fhirService = service
            fhirService.delegate = self
            fhirService.resolve(withTimeout: 5.0)
        }
    }
}

extension DiscoveryViewController: NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        fhirServiceIP = self.getIPV4StringfromAddress(address:sender.addresses!) + ":" + String(sender.port)
        
        self.showFHIRServerAlertController()
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("didNotResolve")
    }
    
    func netServiceWillResolve(_ sender: NetService) {
        print("netServiceWillResolve")
    }
}


