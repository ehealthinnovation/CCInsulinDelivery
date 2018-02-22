//
//  IDSDateTime.swift
//  
//
//  Created by Kevin Tallevi on 1/2/18.
//

import Foundation
import CoreBluetooth
import CCBluetooth

var thisIDSDateTime : IDSDateTime?

public class IDSDateTime : NSObject {
    public var peripheral: CBPeripheral?
    
    public class func sharedInstance() -> IDSDateTime {
        if thisIDSDateTime == nil {
            thisIDSDateTime = IDSDateTime()
        }
        return thisIDSDateTime!
    }
    
    func writeDateTime() {
        let bluetoothDateTime = BluetoothDateTime()
        let exactTime: NSData = bluetoothDateTime.exactTime256ToData()
        
        let packet = NSMutableData()
        
        packet.append(exactTime.bytes, length: exactTime.length)
        packet.appendByte(0x00)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(currentTimeCharacteristic)!), data: packet as Data)
        }
    }
    
    func writeTimeZoneAndDSTOffset() {
        let bluetoothDateTime = BluetoothDateTime()
        let timeZoneInt = bluetoothDateTime.timeZone()
        let dstInt = bluetoothDateTime.dstOffset()

        let packet = NSMutableData(bytes: [ Int8(timeZoneInt),
                                            Int8(dstInt),
                                            ] as [Int8], length: 2)
        
        if let peripheral = self.peripheral {
            Bluetooth.sharedInstance().writeCharacteristic((peripheral.findCharacteristicByUUID(localTimeInformation)!), data: packet as Data)
        }
    }
    
    public func writeCurrentDateTime() {
        writeTimeZoneAndDSTOffset()
        writeDateTime()
    }
}
