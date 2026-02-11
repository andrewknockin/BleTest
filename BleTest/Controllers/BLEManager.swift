//
//  BLEManager.swift
//  BleTest
//

import Foundation
import CoreBluetooth
internal import Combine

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
	var objectWillChange: ObservableObjectPublisher
	
    var centralBE: CBCentralManager!


	@Published var devicesFound: [Device] = []
	static var deviceList = [CBPeripheral]()
	var periphIds = [UUID]()
	var indexInDeviceList = -1    // dummy
	var writeCharacteristic: CBCharacteristic!
	var readCharacteristic: CBCharacteristic!

	@Published var isBluetoothOn = false
    @Published var isScanning = false
	@Published var cmdText = String()
	@Published var replyText = String()
	@Published var msgLines: [CmdLine] = []
	var bleSendQueue: [String] = []

	var activePeripheral: CBPeripheral!
	static let BLE_Service_UUID = CBUUID(string: "442FC824-FEA6-11E9-8F0B-362B9E155667")
	static let BLE_Characteristic_uuid_Tx = CBUUID(string: "442FCA90-FEA6-11E9-8F0B-362B9E155667")
	static let BLE_Characteristic_uuid_Rx = CBUUID(string: "442FCBE4-FEA6-11E9-8F0B-362B9E155667")
	static let DeviceHandle = "Loomfinity"

    var baseScan = Timer()

    override init() {
		print("BLEManager init START")
		self.objectWillChange = .init()
        super.init()
        centralBE = CBCentralManager(delegate: self, queue: nil)
		let _ = print("BLEManager init")
    }

	func qtyDevicesForView() -> Int {
		return devicesFound.count
	}

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            DispatchQueue.main.async {
				self.isBluetoothOn = true
            }
        }
        else if central.state == .poweredOff || central.state == .unauthorized || central.state == .unsupported || central.state == .resetting || central.state == .unknown {
            DispatchQueue.main.async {
                self.isBluetoothOn = false
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String
		{
            // if this is a new peripheral
            if !periphIds.contains(peripheral.identifier) {
                print("BLEManager didDiscover \(name) id: \(peripheral.identifier)")
                
                periphIds.append(peripheral.identifier)
				let newDevice = Device(ident: periphIds.count - 1, name: name, rssi: RSSI.intValue)

                devicesFound.append(newDevice)
                print("peripherals count is \(devicesFound.count)")
//                if periphIds.isEmpty {print ("periphIds is empty")}
				peripheral.delegate = self
				self.centralBE.connect(peripheral, options: nil)  // works when enabled
            } // else not identified so forget it
        }
    }
    
    /// save as activePeripheral and connect
    func connectToDevice(peripheral: CBPeripheral) {
        activePeripheral = peripheral
        activePeripheral.delegate = self
        print("BLEManager connectToDevice")
        centralBE.connect(activePeripheral, options: nil)
        // which either connects and receives a centralManager(_:didConnect:)
        // or subsequently generates centralManager(_:didFailToConnect:error:)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect")
		if peripheral.delegate == nil {print("In didConnect delegate nil"); return}
        discoverServices(peripheral: peripheral)
    }
    
    func startScanning() {
//        cleanupConnected()
        print("startScanning")
        centralBE.scanForPeripherals(withServices: nil, options: nil)
        DispatchQueue.main.async {
            self.isScanning = true
        }
        // Stop scan after 1.5 seconds
        baseScan = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(stopScanning), userInfo: nil, repeats: false)
    }

    @objc func stopScanning() {   // need @objc for above Timer selector
        print("stopScanning")
        centralBE.stopScan()
        if baseScan.isValid {baseScan.invalidate()}
        DispatchQueue.main.async {
            self.isScanning = false
        }
    }
    
    func disconnect(peripheral: CBPeripheral) {
        print("disconnect")
        centralBE.cancelPeripheralConnection(peripheral)
    }
    
    /// return -1 if not found, else index of peripheral type in types
    func getIndexOfPeripheral(peripheral: CBPeripheral) -> Int {
        // peripheral should be in the list, so find its position
        var i = 0
        let limit = devicesFound.count
        if limit == 0 {
            print("getIndexOfPeripheral found empty list")
            return -1
        }
		while (BLEManager.deviceList[i] != peripheral) && (i < limit) {i += 1}

        if i == limit {  // not found
            return -1
        }
		return i
    }
        
    func discoverServices(peripheral: CBPeripheral) {
		if peripheral.delegate == nil {print("In discoverServices delegate nil"); return}
		peripheral.discoverServices([])
    }
    
    // didDiscoverServices
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            print("ERROR didDiscoverServices for \(peripheral.identifier)")
            return
        }
        print("BLEManager didDiscoverServices count \(services.count)")
		if peripheral.delegate == nil {print("In didDiscoverServices delegate nil"); return}
        if services.count > 0 {
            discoverCharacteristics(peripheral: peripheral)
        }
    }

    // Call after discovering services
    func discoverCharacteristics(peripheral: CBPeripheral) {
        guard let services = peripheral.services else {
            print("discoverCharacteristics: no service for \(peripheral.identifier)")
            return
        }
        print("discoverCharacteristics for \(peripheral.identifier)")
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

	// Peripheral characteristics discovered
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		// found it again
		print("BLEManager didDiscoverCharacteristicsFor")
		var count = 0
		service.characteristics?.forEach { char in
			peripheral.readValue(for: char)
			if char.uuid == BLEManager.BLE_Characteristic_uuid_Rx {
				readCharacteristic = char
				peripheral.setNotifyValue(true, for: char)
				print("found read characteristic for CHAR id: \(char.uuid.uuidString)")
				count += 1
			} else if char.uuid == BLEManager.BLE_Characteristic_uuid_Tx {
				writeCharacteristic = char
				print("found write characteristic for CHAR id: \(char.uuid.uuidString)")
				count += 1
			}
		}
//		if count == 2 { doAfterConnection() }
	}


    /// return -1 if not found, else index in devciceList
    func getIndexInDeviceList(peripheral: CBPeripheral) -> Int {
        // peripheral should be in the list, so find its position
        var i = 0
        let c = devicesFound.count
        while (BLEManager.deviceList[i] != peripheral) && (i < c) {i = i + 1}
        
        if i == c { return -1 }  // not found
                                 // found, so which is it
        return i
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("didUpdateNotificationStateFor: \(error)")
            return
        }
        // check which characteristic has notified
        indexInDeviceList = getIndexInDeviceList(peripheral: peripheral)
		if indexInDeviceList == -1 { return }

		if characteristic.uuid == BLEManager.BLE_Characteristic_uuid_Rx {
            readValue(characteristic: characteristic)
        }
    }
    
	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		if let error = error {
			print("didUpdateValueFor: \(error)")
			return
		}
		// check which characteristic has notified
		indexInDeviceList = getIndexInDeviceList(peripheral: peripheral)
		if indexInDeviceList == -1 { return }

		if characteristic.uuid == BLEManager.BLE_Characteristic_uuid_Rx {
			readValue(characteristic: characteristic)
		}
	}

// Functions used when device is decided
	func usePeripheral(number: Int) {
		indexInDeviceList = number
		activePeripheral = BLEManager.deviceList[number]
	}


    func readValue(characteristic: CBCharacteristic) {
        self.activePeripheral?.readValue(for: characteristic)
        guard let value = characteristic.value else { return }
		if let stringValue = String(data: value, encoding: .utf8) {
			cmdText = stringValue
		} else {
			cmdText = ""
		}
    }

    func write(value: Data, characteristic: CBCharacteristic) {
        self.activePeripheral?.writeValue(value, for: characteristic, type: .withResponse)
    }

    func dismountBle() {
        disconnect(peripheral: activePeripheral)
        activePeripheral = nil
    }

	// *** Sending

	/// add cmd to the send queue
	/// note that order is irrelevant - queue jumping is allowed in the short term
	func sendBle(_ cmd: String) -> Void {
		if activePeripheral.canSendWriteWithoutResponse {
			bleWrite(string: cmd)
		} else {
			bleSendQueue.append(cmd)
		}
		DispatchQueue.main.async {
			self.cmdText = String("")
		}
	}

	func bleWrite(string: String) {
		let value = Data(string.utf8)
		activePeripheral.writeValue(value, for: writeCharacteristic!, type: .withResponse)
		DispatchQueue.main.async {
			self.msgLines.append(CmdLine(id: self.msgLines.count, msg: string, timestamp: Date(), isCmd: false))
		}
	}

	func deQueueWrites(sendQueueTimer:Timer) {
		DispatchQueue.main.async {
			if !self.bleSendQueue.isEmpty, self.activePeripheral.canSendWriteWithoutResponse {
				let firstCmd = String(self.bleSendQueue.first!)
				print("Send <\(firstCmd)>")
				self.bleWrite(string: firstCmd)
				self.bleSendQueue.removeFirst() // Properly remove the first element
			}
		}
	}

}
