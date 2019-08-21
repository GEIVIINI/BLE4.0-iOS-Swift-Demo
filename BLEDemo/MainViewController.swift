//
//  MainViewController.swift
//  CompassCompanion
//
//  Created by Rick Smith on 04/07/2016.
//  Copyright © 2016 Rick Smith. All rights reserved.
//

import UIKit
import CoreBluetooth

class MainViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var manager: CBCentralManager?
    var mainPeripheral: CBPeripheral?
    var mainCharacteristic: CBCharacteristic?
    
    
    let BLEService = "FEA7D4D0-7C81-41A3-9B1E-553B6CC4A17C"
    let BLECharacteristic = "FEA7D4D0-7C81-41A3-9B1E-553B6CC4A17C"
    
    private let UuidSerialService = "FEA7D4D0-7C81-41A3-9B1E-553B6CC4A17C"
    private let UuidTx =            "FEA7D4D0-7C81-41A3-9B1E-553B6CC4A17C"
    private let UuidRx =            "FEA7D4D0-7C81-41A3-9B1E-553B6CC4A17C"
    var txCharacteristic: CBCharacteristic?
    var rxCharacteristic: CBCharacteristic?
    var serialPortPeripheral: CBPeripheral?

    
    
    //let BLEService = "DFB0"
    //let BLECharacteristic = "DFB1"
    
    @IBOutlet weak var recievedMessageText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CBCentralManager(delegate: self, queue: nil);
        
        customiseNavigationBar()
    }
    
    func customiseNavigationBar () {
        
        self.navigationItem.rightBarButtonItem = nil
        
        let rightButton = UIButton()
        
        if (mainPeripheral == nil) {
            rightButton.setTitle("Scan", for: [])
            rightButton.setTitleColor(UIColor.blue, for: [])
            rightButton.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 60, height: 30))
            rightButton.addTarget(self, action: #selector(self.scanButtonPressed), for: .touchUpInside)
        } else {
            rightButton.setTitle("Disconnect", for: [])
            rightButton.setTitleColor(UIColor.blue, for: [])
            rightButton.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 100, height: 30))
            rightButton.addTarget(self, action: #selector(self.disconnectButtonPressed), for: .touchUpInside)
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = rightButton
        self.navigationItem.rightBarButtonItem = rightBarButton
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "scan-segue") {
            let scanController : ScanTableViewController = segue.destination as! ScanTableViewController
            
            //set the manager's delegate to the scan view so it can call relevant connection methods
            manager?.delegate = scanController
            scanController.manager = manager
            scanController.parentView = self
        }
        
    }
    
    // MARK: Button Methods
    
    @objc func scanButtonPressed() {
        performSegue(withIdentifier: "scan-segue", sender: nil)
    }
    
    @objc func disconnectButtonPressed() {
        //this will call didDisconnectPeripheral, but if any other apps are using the device it will not immediately disconnect
        manager?.cancelPeripheralConnection(mainPeripheral!)
    }
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {

        let alert = UIAlertController(title: "Command", message: "Enter a iot command.", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "example : switch:true"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let dataToSend = textField?.text!.data(using: String.Encoding.utf8)
            
            self.serialPortPeripheral?.writeValue(dataToSend!, for: self.txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
            
//            if (self.mainPeripheral != nil) {
//                if let mainCharacteristicData = self.mainCharacteristic {
//                    self.mainPeripheral?.writeValue(dataToSend!, for: mainCharacteristicData, type: CBCharacteristicWriteType.withoutResponse)
//                    print("Success")
//                } else {
//                    print("failed")
//                }
//            } else {
//                print("haven't discovered device yet")
//            }
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - CBCentralManagerDelegate Methods
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        mainPeripheral = nil
        customiseNavigationBar()
        print("Disconnected" + peripheral.name!)
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
    }
    
    // MARK: CBPeripheralDelegate Methods
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        for service in peripheral.services! {
            
            print("Service found with UUID: " + service.uuid.uuidString)
            
            //device information service
            if (service.uuid.uuidString == "180A") {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
            //GAP (Generic Access Profile) for Device Name
            // This replaces the deprecated CBUUIDGenericAccessProfileString
            if (service.uuid.uuidString == "1800") {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
            //Bluno Service
            if (service.uuid.uuidString == BLEService) {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
            //Pai Test
            
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
    }
    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//
//        //get device name
//        if (service.uuid.uuidString == "1800") {
//
//            for characteristic in service.characteristics! {
//
//                if (characteristic.uuid.uuidString == "2A00") {
//                    peripheral.readValue(for: characteristic)
//                    print("Found Device Name Characteristic")
//                }
//
//            }
//
//        }
//
//        if (service.uuid.uuidString == "180A") {
//
//            for characteristic in service.characteristics! {
//
//                if (characteristic.uuid.uuidString == "2A29") {
//                    peripheral.readValue(for: characteristic)
//                    print("Found a Device Manufacturer Name Characteristic")
//                } else if (characteristic.uuid.uuidString == "2A23") {
//                    peripheral.readValue(for: characteristic)
//                    print("Found System ID")
//                }
//
//            }
//
//        }
//
//        if (service.uuid.uuidString == BLEService) {
//
//            for characteristic in service.characteristics! {
//
//                if (characteristic.uuid.uuidString == BLECharacteristic) {
//                    //we'll save the reference, we need it to write data
//                    mainCharacteristic = characteristic
//
//                    //Set Notify is useful to read incoming data async
//                    peripheral.setNotifyValue(true, for: characteristic)
//                    print("Found Bluno Data Characteristic")
//                }
//
//            }
//
//        }
//
//        //Pai test
//
//        for characteristic in service.characteristics! {
//            mainCharacteristic = characteristic
//            //Set Notify is useful to read incoming data async
//            peripheral.setNotifyValue(true, for: characteristic)
//            print("Found Bluno Data Characteristic")
//        }
//
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//
//
//        if (characteristic.uuid.uuidString == "2A00") {
//            //value for device name recieved
//            let deviceName = characteristic.value
//            print(deviceName ?? "No Device Name")
//        } else if (characteristic.uuid.uuidString == "2A29") {
//            //value for manufacturer name recieved
//            let manufacturerName = characteristic.value
//            print(manufacturerName ?? "No Manufacturer Name")
//        } else if (characteristic.uuid.uuidString == "2A23") {
//            //value for system ID recieved
//            let systemID = characteristic.value
//            print(systemID ?? "No System ID")
//        } else if (characteristic.uuid.uuidString == BLECharacteristic) {
//            //data recieved
//            if(characteristic.value != nil) {
//                let stringValue = String(data: characteristic.value!, encoding: String.Encoding.utf8)!
//
//                recievedMessageText.text = stringValue
//            }
//        }
//
//        // Pai test
//
//        let stringValue = String(data: characteristic.value!, encoding: String.Encoding.utf8)!
//        recievedMessageText.text = stringValue
//
//
//    }
    
    
    
    
    //Pai
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                // Tx:
                if characteristic.uuid == CBUUID(string: UuidTx) {
                    print("Tx char found: \(characteristic.uuid)")
                    txCharacteristic = characteristic
                }

                // Rx:
                if characteristic.uuid == CBUUID(string: UuidRx) {
                    rxCharacteristic = characteristic
                    if let rxCharacteristic = rxCharacteristic {
                        print("Rx char found: \(characteristic.uuid)")
                        serialPortPeripheral?.setNotifyValue(true, for: rxCharacteristic)
                    }
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let rxData = characteristic.value
        if let rxData = rxData {
            let numberOfBytes = rxData.count
            var rxByteArray = [UInt8](repeating: 0, count: numberOfBytes)
            (rxData as NSData).getBytes(&rxByteArray, length: numberOfBytes)
            print(rxByteArray)
        }
    }
    
}

