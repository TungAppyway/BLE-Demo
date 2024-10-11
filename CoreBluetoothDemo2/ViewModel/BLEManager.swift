//
//  BLEManager.swift
//  CoreBluetoothDemo
//
//  Created by Tung Vu on 2024/10/01.
//

import Foundation
import SwiftUI
import CoreBluetooth
import UserNotifications
import AVFoundation

public class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var myCentral: CBCentralManager!
    @Published var isSwitchedOn = false
    @Published var peripherals: [CBPeripheral] = []
    @Published var connectingCBperipheral: CBPeripheral?
    @Published var connectedCBperipheral: CBPeripheral?
    
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error)")
            }
        }
    }
    
    override public init() {
        super.init()
        myCentral = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: "myCentralManagerIdentifier.tungvu"])
    }
    
    public func startScanning() {
        myCentral.scanForPeripherals(withServices: nil)
    }
    
    public func stopScanning() {
        myCentral.stopScan()
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        if let restoredPeripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            for peripheral in restoredPeripherals {
                guard peripheral.name == connectedCBperipheral?.name else {
                    return
                }
                
                sendNotification(title: "Restored", body: "Restored connection to \(peripheral.name ?? "device")")
                // You can also discover services, etc.
            }
        }
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isSwitchedOn = central.state == .poweredOn
        if isSwitchedOn {
            startScanning()
        } else {
            stopScanning()
        }
    }

    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name != nil else { return }
        DispatchQueue.main.async {
            if !self.peripherals.contains(where: { $0.identifier == peripheral.identifier }) {
                self.peripherals.append(peripheral)
            }
            
            if let connectingCBperipheral = self.connectingCBperipheral, self.connectedCBperipheral == nil {
                self.myCentral.stopScan()
                self.connect(to: connectingCBperipheral)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        print("Discovered services for peripheral: \(peripheral.name ?? "Unkown") \(peripheral.services?.count ?? 0) services")
        peripheral.services?.forEach {
            print($0.uuid)
        }
    }
    
    public func selectPheripheralToObserveConnection(_ item: CBPeripheral) {
        connectingCBperipheral = item
    }
    
    func disconect() {
        guard let item = connectedCBperipheral else { return }
        myCentral.cancelPeripheralConnection(item)
    }
    
    func connect(to peripheral: CBPeripheral) {
        guard let cbperipheral = myCentral.retrievePeripherals(withIdentifiers: [peripheral.identifier]).first,
        cbperipheral.state != .connected else { return }
        
        myCentral.connect(cbperipheral, options: [:])
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard peripheral != connectedCBperipheral else { return }
        print("Connected to \(peripheral.name ?? "Unknown") ", peripheral.identifier.uuidString)
        connectedCBperipheral = peripheral
        peripheral.delegate = self
        sendNotification(title: "Connected", body: "Connected to \(peripheral.name ?? "device")")
        peripheral.discoverServices(nil)
        print("Start discover services")
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        print("Did disconnect to \(peripheral)", error?.localizedDescription ?? "")
        connectedCBperipheral = nil
        sendNotification(title: "Disconnected", body: "Disconnected from \(peripheral.name ?? "device")")
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        print(peripheral.name ?? "unkowned", "failed to connect", error?.localizedDescription)
    }
}

//extension HomeViewController : CBCentralManagerDelegate, CBPeripheralDelegate {
//  
//  func centralManagerDidUpdateState(_ central: CBCentralManager) {
//    
//    print("SLIMA: centralManagerDidUpdateState = \(central.state)")
//    
//    switch central.state {
//        
//        case .poweredOn:
//
//      
//      central.registerForConnectionEvents()
//          
//
//          let option:[String: Any] = [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: false)]
//          central.scanForPeripherals(withServices: nil, options: option)
//
////      central.retrieveConnectedPeripherals(withServices: [CBUUID(string: "FE2C")]) .map { peripheral in
////        print("SLIMA: connecteed peripheral = \(peripheral.name) , state = \(peripheral.state) , \(peripheral.identifier)")
////
////      }
//      
////      central.retrievePeripherals(withIdentifiers: [NSUUID(uuidString: "F2A0CFD0-0B12-DF44-D262-2AAFBA8183C7")]).map { peripheral in
////        print("SLIMA: connecteeeed peripheral = \(peripheral.name) , state = \(peripheral.state) , \(peripheral.identifier)")
////
////      }
//
//            break
//       
//        default:
//            break
//        } // End Swith
//    
//  }
//  
//  
//  func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
//    print("SLIMA: event \(event)")
//    print("SLIMA: connectionEventDidOccur = \(peripheral.name) , state = \(peripheral.state) , \(peripheral.identifier)")
//    peripheral.services?.map {
//      print("SLIMA: connectionEventDidOccur Service = \($0.uuid) , \($0.description)")
//    }
//
//  }
//  
//  
//  
//  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//    
//    print("SLIMA: peripheral = \(peripheral.name) , state = \(peripheral.state) , \(peripheral.identifier)")
//    peripheral.services?.map {
//      print("SLIMA: Service = \($0.uuid) , \($0.description)")
//    }
//    
//    if (peripheral.name?.contains("JBL") == true) {
//      cbManager?.stopScan()
//     
//      print("SLIMA: Trying to connect")
//      cbManager?.connect(peripheral)
//     
//      // hold strong reference
//      connectedPeripheral = peripheral
//    }
//    
//  }
//  
//  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
//    print("SLIMA: discoverServices:")
//    peripheral.services?.forEach({ service in
//      print("SLIMA: service : \(service.description) , \(service.uuid)")
//    })
//  }
//  
//  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//    
//    if (peripheral.name?.contains("JBL") == true) {
//    
//      // Start discivering services .. CBUUID
//      peripheral.delegate = self
//      peripheral.discoverServices(nil)
//    }
//  }
//  
//  func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
//    if (peripheral.name?.contains("JBL") == true) {
//      print("SLIMA: didFailToConnect peripheral = \(peripheral.name) , state = \(error) ")
//     
//    }
//  }
//  
//}
