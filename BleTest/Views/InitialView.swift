//
//  InitialView.swift
//  BleTest
//
//  Created by Andrew on 25/01/2026
//

import SwiftUI

struct InitialView: View {
	@EnvironmentObject var bleManager: BLEManager

	init() {
		print("InitialView initializing")
	}

    var body: some View {
        VStack (spacing: 10) {
			if !bleManager.isBluetoothOn {
				BleOffView()
            }
            else {
				ListView()
            }
        }
    }
}

struct BleOffView: View {

	var body: some View {
		VStack (spacing: 10) {
			Text("Bluetooth is OFF")
				.foregroundColor(.red)
			Text("Please enable in Settings")
				.foregroundColor(.red)
		}
	}
}

#Preview("1") {
	BleOffView()
}

#Preview("2") {
    InitialView()
}

