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
    
    private var uuid_to_movesense_cache: [String: String] = [:] //STORED AS UUID:MOVESENSEID
    private var movesense_to_uuid_cache: [String: String] = [:] //STORED AS MOVESENSEID:UUID
    private var movesense_to_data_cache: [String: (Float,String)] = [:]
    
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

        //print(peripheral.identifier.uuidString)

        var bytes=[UInt8](repeating:0, count:16)
        var hr_bytes=[UInt8](repeating:0, count:4)
        var batt_byte=[UInt8](repeating:0, count:1)
        //print(advertisementData)
        
        if uuid_to_movesense_cache[peripheral.identifier.uuidString] != nil{// We have seen this UUID before
            if advertisementData["kCBAdvDataManufacturerData"] != nil{ //We received heart rate data
                let payload: NSData = advertisementData["kCBAdvDataManufacturerData"]! as! NSData
                //print(payload)
                
                payload.getBytes(&bytes,length:15)
                //let array=[UInt8](payload)
                
                //print(bytes)
                var hr:Float = 0
                var batt:UInt8 = 0
                var batt_level = ""
                for i in 7...10{
                    hr_bytes[i-7]=bytes[i]
                }
                
                batt_byte[0]=bytes[14]
                memcpy(&hr,&hr_bytes,4)
                memcpy(&batt,&batt_byte,1)
                if batt == 1 {
                    batt_level="Battery Full"
                }
                else{
                    batt_level="Battery Low"
                }
                
                
                movesense_to_data_cache[uuid_to_movesense_cache[peripheral.identifier.uuidString] as! String] = (hr,batt_level)
                
                
            }
        }
        else { //We have not seen this UUID before
            if advertisementData["kCBAdvDataLocalName"] != nil{//We received Movesense id
                
                let movesense_id = advertisementData["kCBAdvDataLocalName"] as! String
                
                //Only add a new entry in the tables if the movesense id has never been seen before
                if movesense_to_uuid_cache[movesense_id] == nil{
                    uuid_to_movesense_cache[peripheral.identifier.uuidString] = movesense_id
                    movesense_to_uuid_cache[movesense_id] = peripheral.identifier.uuidString
                }
                    
                //Otherwise, the UUID for movesense device has changed and we need to update it in the tables.
                else{
                    let old_uuid = movesense_to_uuid_cache[movesense_id] as! String
                    movesense_to_uuid_cache[movesense_id]=peripheral.identifier.uuidString
                    uuid_to_movesense_cache[old_uuid] = nil
                }
                
            }
            
        }
        
        print("\(movesense_to_data_cache as AnyObject)")
       
        
        
    }
}

