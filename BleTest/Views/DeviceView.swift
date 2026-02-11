//
//  DeviceView.swift
//  BleTest
//
//  Created by Andrew on 25/01/2026
//

import SwiftUI
import CoreBluetooth


//@available(iOS 15.0, *)
struct DeviceView: View {
	@EnvironmentObject var bleManager: BLEManager
	@State private var msgLines: [CmdLine]!
	@State private var cmdText = ""

	var deviceID: Int

	var body: some View {
		ZStack {
			Color("ThemeColor")
				.edgesIgnoringSafeArea(.all)
			ScrollView {
				LazyVStack(alignment: .leading) {
					ForEach(msgLines, id:\.id) { message in
						MessageRow(chatLine: message)
					}
				}
			}
			.padding(EdgeInsets(top: 10, leading: 20, bottom: 50, trailing: 0))
			.safeAreaInset(edge: .bottom) {
				Group {
					TextField("Command", text: $cmdText)
						.disableAutocorrection(true)
						.onSubmit {
							guard cmdText.isEmpty == false else { return }
							self.onSubmit()
						}
						.textFieldStyle(.roundedBorder)
				}
			}
		}
    }

	func onSubmit() {
		// Perform action when the command is entered
		print("Submitted value: \(cmdText)")
	}
}

