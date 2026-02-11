//
//  Device.swift
//  BleTest
//
//  Created by Andrew on 02/02/2026.
//
import Foundation
import CoreBluetooth

struct Device: Identifiable, Hashable {
	let id: Int
	let name: String
	let rssi: Int
	var periph: CBPeripheral?
	var writeCharacteristic: CBCharacteristic?
	var readCharacteristic: CBCharacteristic?

	init(ident: Int, name: String, rssi: Int, periph: CBPeripheral) {
		self.id = ident
		self.name = name
		self.rssi = rssi
		self.periph = periph
		self.writeCharacteristic = nil
		self.readCharacteristic = nil
	}

	init(ident: Int, name: String, rssi: Int) {
		self.id = ident
		self.name = name
		self.rssi = rssi
		self.periph = nil
		self.writeCharacteristic = nil
		self.readCharacteristic = nil
	}

	mutating func setPeriph(p: CBPeripheral) {
		self.periph = p
	}

	mutating func setTX(char: CBCharacteristic) {
		self.writeCharacteristic = char
	}

	mutating func setRX(char: CBCharacteristic) {
		self.readCharacteristic = char
	}
}
