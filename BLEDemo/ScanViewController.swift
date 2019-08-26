//
//  ScanViewController.swift
//  BLEDemo
//
//  Created by Soemsak on 27/8/2562 BE.
//  Copyright © 2562 Rick Smith. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var peripherals:[CBPeripheral] = []
    var manager:CBCentralManager? = nil
    var parentView:MainViewController? = nil
    
    
    var mainCharacteristic: CBCharacteristic?
    var mainPeripheral: CBPeripheral?
    var isOpen = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loading.startAnimating()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scanBLEDevices()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scanTableCell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let peripheral = peripherals[indexPath.row]
        //        manager?.connect(peripheral, options: nil)
        var str = "{switch:true}"
        if isOpen {
            str = "{switch:true}"
            isOpen = !isOpen
        } else {
            str = "{switch:false}"
            isOpen = !isOpen
        }
        let data = Data(str.utf8)
        mainPeripheral?.writeValue(data, for: mainCharacteristic!, type: .withResponse)
    }
    
    // MARK: BLE Scanning
    
    func scanBLEDevices() {
        manager?.scanForPeripherals(withServices: nil, options: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.stopScanForBLEDevices()
        }
    }
    
    func stopScanForBLEDevices() {
        manager?.stopScan()
    }
    
    // MARK: - CBCentralManagerDelegate Methods
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(!peripherals.contains(peripheral)) {
            if peripheral.name != "" && peripheral.name != nil {
                /*
                for service in peripheral.services! {
                    print("Service found with UUID: " + service.uuid.uuidString)
                    peripheral.discoverCharacteristics(nil, for: service)
                }
                */
                if peripheral.name == "Node02" {
                    manager?.connect(peripheral, options: nil)
                    self.dismiss(animated: true, completion: nil)
                }
                peripherals.append(peripheral)
            }
        }
        self.tableView.reloadData()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        parentView?.mainPeripheral = peripheral
        peripheral.delegate = parentView
        peripheral.discoverServices(nil)
        manager?.delegate = parentView
        parentView?.customiseNavigationBar()
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        print("Connected to " +  peripheral.name!)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
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
        print("stringValue", stringValue)
        //recievedMessageText.text = stringValue
    }

}
