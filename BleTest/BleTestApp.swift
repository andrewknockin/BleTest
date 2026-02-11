//
//  BleTestApp.swift
//  BleTest
//
//  Created by Andrew on 05/02/2026.
//

import SwiftUI

@main
struct BleTestApp: App {
    @StateObject private var bleManager = BLEManager()

	init() {
		print("BleTestApp initializing")
	}
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bleManager)
        }
    }
}
