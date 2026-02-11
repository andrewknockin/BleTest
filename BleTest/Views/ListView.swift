//
//  ListView.swift
//  BleTest
//
//  Created by Andrew on 25/01/2026
//

import SwiftUI

struct ListView: View {
	@EnvironmentObject var bleManager: BLEManager

    var body: some View {
		NavigationView {
            VStack {
                List {
					ForEach(bleManager.devicesFound, id: \.id) { device in
						NavigationLink(destination: DeviceView(deviceID: device.id)) {
							PeripheralLineView(peri: device)
                        }
                    }
                }
                .navigationTitle("Bluetooth Devices")
                .navigationBarTitleDisplayMode(.inline)
                if !bleManager.isScanning {
                    Button(action: bleManager.startScanning) {
                        Text("Scan")
                    }
                }
                else {
                    Text("Scanning")
                }
            }
        }
    }
}

#Preview() {
    ListView()
}

