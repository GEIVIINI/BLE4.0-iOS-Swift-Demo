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
    var characteristicsDic: CBUUID?
    
    
    var isOpen = false
    
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
            let scanController : ScanViewController = segue.destination as! ScanViewController
            
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
        manager?.cancelPeripheralConnection(mainPeripheral!)
    }
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        var str = "{switch:true}"
        if isOpen {
            str = "{switch:true}"
            isOpen = !isOpen
        } else {
            str = "{switch:false}"
            isOpen = !isOpen
        }
        let data = Data(str.utf8)
        self.mainPeripheral?.writeValue(data, for: mainCharacteristic!, type: .withResponse)

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
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            mainCharacteristic = characteristic
            //Set Notify is useful to read incoming data async
            peripheral.setNotifyValue(true, for: characteristic)
            print("Found Bluno Data Characteristic")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let stringValue = String(data: characteristic.value!, encoding: String.Encoding.utf8)!
        recievedMessageText.text = stringValue
    }
    
}
