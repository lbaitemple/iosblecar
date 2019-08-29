//
//  ViewController.swift
//  BlueApp
//
//  Created by Li Bai on 8/22/19.
//  Copyright © 2019 Li Bai. All rights reserved.
//

import UIKit
import CoreBluetooth
import WebKit

let BLE_UART_Service_CBUUID = CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")
let BLE_UARTRX_Characteristic_CBUUID = CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e")
let BLE_UARTTX_Characteristic_CBUUID = CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e")
var  connectStatus = false
var txCharacteristic : CBCharacteristic?
var rxCharacteristic : CBCharacteristic?
var peripheralUARTMonitor : CBPeripheral?
var characteristicASCIIValue = NSString()
var turn:Float = 0.5
var speed:Float = 0.5
var timer: Timer?
var ipaddress = ""

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate{

    @IBOutlet weak var mBlueDeviceName: UILabel!
    @IBOutlet weak var mWebView: WKWebView!
    @IBOutlet weak var ProgressTurn: UIProgressView!
    @IBOutlet weak var ProgressSpeed: UIProgressView!

    
    
    @IBOutlet weak var mtxtIPAddress: UITextField!
    @IBAction func mtxtIPAddressAction(_ sender: Any) {
        ipaddress = mtxtIPAddress.text!
    }
    
    @IBAction func btnLeftActionDown(_ sender: Any) {
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(rapidLeftFire), userInfo: nil, repeats: true)
    }
    
    @IBAction func btnLeftActionUp(_ sender: Any) {
        timer?.invalidate()
        turn = 0.5
        ProgressTurn.setProgress(turn, animated: true)
        writeValue(data:"\(turn), \(speed)")

    }

    @IBAction func btnRightActionDown(_ sender: Any) {
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(rapidRightFire), userInfo: nil, repeats: true)
    }
    @IBAction func btnRightActionUp(_ sender: Any) {
        timer?.invalidate()
        turn = 0.5
        ProgressTurn.setProgress(turn, animated: true)
        writeValue(data:"\(turn), \(speed)")
    }
    
    
    @IBAction func btnUpActionUp(_ sender: Any) {
        timer?.invalidate()
        speed = 0.5
        ProgressSpeed.setProgress(speed, animated: true)
        writeValue(data:"\(turn), \(speed)")

    }
    @IBAction func btnUpActionDown(_ sender: Any) {
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(rapidUpFire), userInfo: nil, repeats: true)
    }

    @IBAction func btnDownActionDown(_ sender: Any) {
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(rapidDownFire), userInfo: nil, repeats: true)
    }
    @IBAction func btnDownActionUp(_ sender: Any) {
        timer?.invalidate()
        speed = 0.5
        ProgressSpeed.setProgress(speed, animated: true)
        writeValue(data:"\(turn), \(speed)")
    }


    @objc func rapidLeftFire() {
        turn = turn - 0.1
        if (turn < 0){
            turn = 0
        }
        ProgressTurn.setProgress(turn, animated: true)
         writeValue(data:"\(turn), \(speed)")
    }
    
    @objc func rapidRightFire() {
        turn = turn + 0.1
        if (turn > 1){
            turn = 1
        }
        ProgressTurn.setProgress(turn, animated: true)
        writeValue(data:"\(turn), \(speed)")
    }
    
    @objc func rapidDownFire() {
        speed = speed - 0.1
        if (speed < 0){
            speed = 0
        }
        ProgressSpeed.setProgress(speed, animated: true)
        writeValue(data:"\(turn), \(speed)")

    }
    
    @objc func rapidUpFire() {
        speed = speed + 0.1
        if (speed > 1){
            speed = 1
        }
        ProgressSpeed.setProgress(speed, animated: true)
        writeValue(data:"\(turn), \(speed)")

    }
    

    
    var centralManager: CBCentralManager?
//    var peripheralUARTMonitor: CBPeripheral?
    
    @IBOutlet weak var txtCommand: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnConnect: UIButton!
    @IBAction func btnConnectAction(_ sender: Any)
    {
        if (connectStatus == false){
            print("try to   connect")
            centralManager?.scanForPeripherals(withServices: [BLE_UART_Service_CBUUID])
            btnConnect.isHidden = true
            btnConnect.setTitle("Disconnect", for: .normal)
            connectStatus = true
        
        }
        else{
            if peripheralUARTMonitor != nil {
                centralManager?.cancelPeripheralConnection(peripheralUARTMonitor!)
            }
             print("try to  disconnect")
            btnConnect.setTitle("Connect", for: .normal)
            mBlueDeviceName.text = ""
            connectStatus = false
        }
    }
    
    @IBAction func btnSendAction(_ sender: Any) {
        ipaddress = mtxtIPAddress.text!
        
        let myURL = URL(string:"http://\(ipaddress):8080/?action=stream")
        print(myURL!)
        let myRequest = URLRequest(url: myURL!)
        mWebView.load(myRequest)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ipaddress = mtxtIPAddress.text!

        let myURL = URL(string:"http://\(ipaddress):8080/?action=stream")
        print(myURL!)
        let myRequest = URLRequest(url: myURL!)
        mWebView.load(myRequest)
        
        // Do any additional setup after loading the view.
        let centralQueue: DispatchQueue = DispatchQueue(label: "com.uart.centralQueueName", attributes: .concurrent)

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
            
            DispatchQueue.main.async { () -> Void in
             }
            
            // STEP 3.2: scan for peripherals that we're interested in
            
        @unknown default:
            break
        } // END switch
        
    } // END func centralManagerDidUpdateState

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("look for")
        
        print(peripheral.name!)
        decodePeripheralState(peripheralState: peripheral.state)
        // STEP 4.2: MUST store a reference to the peripheral in
        // class instance variable
        peripheralUARTMonitor = peripheral
        // STEP 4.3: since HeartRateMonitorViewController
        // adopts the CBPeripheralDelegate protocol,
        // the peripheralHeartRateMonitor must set its
        // delegate property to HeartRateMonitorViewController
        // (self)
        peripheralUARTMonitor?.delegate = self
        
        // STEP 5: stop scanning to preserve battery life;
        // re-scan if disconnected
        centralManager?.stopScan()
        
        // STEP 6: connect to the discovered peripheral of interest
        centralManager?.connect(peripheralUARTMonitor!)
        
    } // END func centralManager(... didDiscover peripheral
    
    // STEP 7: "Invoked when a connection is successfully created with a peripheral."

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        DispatchQueue.main.async { () -> Void in
            print("found service" )
        }
        
        // STEP 8: look for services of interest on peripheral
        peripheralUARTMonitor?.discoverServices([BLE_UART_Service_CBUUID])
        
    } // END func centralManager(... didConnect peripheral
    
    

    // STEP 15: when a peripheral disconnects, take
    // use-case-appropriate action
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        print("Disconnected!")
        DispatchQueue.main.async { () -> Void in
            
        }
        
        // STEP 16: in this use-case, start scanning
        // for the same peripheral or another, as long
        // as they're HRMs, to come back online
        //centralManager?.scanForPeripherals(withServices: [BLE_UART_Service_CBUUID])
        
    } // END func centralManager(... didDisconnectPeripheral peripheral

    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        for service in peripheral.services! {
            
            if service.uuid == BLE_UART_Service_CBUUID {
                
                print("Service: \(service)")
                
                // STEP 9: look for characteristics of interest
                // within services of interest
                peripheral.discoverCharacteristics(nil, for: service)
                
            }
            
        }
        
    } // END func peripheral(... didDiscoverServices
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("charaterstic")
        for characteristic in service.characteristics! {
            print(characteristic)
            
            if characteristic.uuid == BLE_UARTRX_Characteristic_CBUUID {
                
                // STEP 11: subscribe to a single notification
                // for characteristic of interest;
                // "When you call this method to read
                // the value of a characteristic, the peripheral
                // calls ... peripheral:didUpdateValueForCharacteristic:error:
                //
                // Read    Mandatory
                //
                 rxCharacteristic = characteristic
                peripheral.readValue(for: characteristic)
                
            }
            
            if characteristic.uuid == BLE_UARTTX_Characteristic_CBUUID {
                
                // STEP 11: subscribe to regular notifications
                // for characteristic of interest;
                // "When you enable notifications for the
                // characteristic’s value, the peripheral calls
                // ... peripheral(_:didUpdateValueFor:error:)
                //
                // Notify    Mandatory
                //
                 txCharacteristic = characteristic
                print("--------------")
                print(txCharacteristic)
                print(">>>>>>>>>>>>>>")
                peripheral.setNotifyValue(true, for: characteristic)
                
            }
            
        } // END for
        
    } // END func peripheral(... didDiscoverCharacteristicsFor service
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("update")
        if characteristic.uuid == BLE_UARTTX_Characteristic_CBUUID {
            
            // STEP 13: we generally have to decode BLE
            // data into human readable format
             txCharacteristic = characteristic
            DispatchQueue.main.async { () -> Void in

                
            } // END DispatchQueue.main.async...
            
        } // END if characteristic.uuid ==...
        
        if characteristic.uuid == BLE_UARTRX_Characteristic_CBUUID {
            
            // STEP 14: we generally have to decode BLE
            // data into human readable format
             rxCharacteristic = characteristic
            DispatchQueue.main.async { () -> Void in
            }
        } // END if characteristic.uuid ==...
        
    } // END func peripheral(... didUpdateValueFor characteristic
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")
        
        if (error != nil) {
            print("Error changing notification state:\(String(describing: error?.localizedDescription))")
            
        } else {
            print("Characteristic's value subscribed")
        }
        
        if (characteristic.isNotifying) {
            print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
            DispatchQueue.main.async { () -> Void in
                self.btnConnect.isHidden = false
                self.mBlueDeviceName.text = "connect to \(peripheral.name!)"
            }
        }
        
    }
    
    
    

    
   func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("--- Error discovering services: error")
            return
        }
        print("Message sent")
    }
 
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
        print("Succeeded!")
    }

    
    func decodePeripheralState(peripheralState: CBPeripheralState) {
        
        switch peripheralState {
        case .disconnected:
            print("Peripheral state: disconnected")
            //connectStatus = false
            //btnConnect.setTitle("Connect", for: .normal)
        case .connected:
            print("Peripheral state: connected")
            //connectStatus = true
            //btnConnect.setTitle("Disconnect", for: .normal)
        case .connecting:
            print("Peripheral state: connecting")
        case .disconnecting:
            print("Peripheral state: disconnecting")
        @unknown default: break
        }
        
    } // END func decodePeripheralState(peripheralState
    
    
    
    func writeValue(data: String){
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        //change the "data" to valueString
        if let peripheralUARTMonitor = peripheralUARTMonitor{
            if let rxCharacteristic = rxCharacteristic {
                print("send: \(data)" )
                peripheralUARTMonitor.writeValue(valueString!, for: rxCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func writeCharacteristic(val: Int8){
        var val = val
        let ns = NSData(bytes: &val, length: MemoryLayout<Int8>.size)
        peripheralUARTMonitor!.writeValue(ns as Data, for: rxCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    
}

