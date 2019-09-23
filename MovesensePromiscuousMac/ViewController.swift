//
//  ViewController.swift
//  MovesensePromiscuousMac
//
//  Created by Mayur Bhandary on 9/17/19.
//  Copyright © 2019 Mayur Bhandary. All rights reserved.
//

import Cocoa
import CoreBluetooth

class ViewController: NSViewController, CBCentralManagerDelegate,CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Create a DispatchQueue to instantiate a CBCentralManager Object. This allows us to search for Bluetooth devices in the on a separate thread
        let centralQueue: DispatchQueue = DispatchQueue(label: "tools.sunyata.zendo", attributes: .concurrent)
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            
        case .unknown:
            print("Bluetooth status is UNKNOWN")
            
        case .resetting:
            print("Bluetooth status is RESETTING")
            
        case .unsupported:
            print("Bluetooth status is UNSUPPORTED")
            
        case .unauthorized:
            print("Bluetooth status is UNAUTHORIZED")
            
        case .poweredOff:
            print("Bluetooth status is POWERED OFF")
            
        case .poweredOn:
            print("Bluetooth status is POWERED ON")
            
        
            centralManager?.scanForPeripherals(withServices: [CBUUID(string: "0000fe06-0000-1000-8000-00805f9b34fb")])
        }
    }
    
    //Called when a peripheral device is discovered
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

    
        var bytes=[UInt8](repeating:0, count:16)
        var hr_bytes=[UInt8](repeating:0, count:4)
        print(advertisementData)
        
        if advertisementData["kCBAdvDataManufacturerData"] != nil{
            let payload: NSData = advertisementData["kCBAdvDataManufacturerData"]! as! NSData
            print(payload)
            
            payload.getBytes(&bytes,length:16)
            //let array=[UInt8](payload)
            
            print(bytes)
            var hr:Float = 0
            for i in 7...10{
                hr_bytes[i-7]=bytes[i]
            }
            memcpy(&hr,&hr_bytes,4)
            print(hr)
        }
    }
}

