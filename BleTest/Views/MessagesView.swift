//
//  MessagesView.swift
//  BleTest
//
//  Created by Andrew on 25/01/2026
//

import SwiftUI

struct MessageRow: View {
	var chatLine: CmdLine

	var body: some View {
		HStack {
			Text(chatLine.timestamp, formatter: itemFormatter)
			Text(chatLine.msg).foregroundColor(
				chatLine.isCmd ? .green : .purple)
			Spacer()
		}
	}
}

private let itemFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateStyle = .none
	formatter.timeStyle = .medium
	return formatter
}()


//@available(iOS 15.0, *)
struct MessagesView: View {
	@State private var msgLines: [CmdLine]
	@State private var cmdText = ""

	var deviceID: Int

	var body: some View {
		ZStack {
			Content(msgLines: $msgLines)
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

	func onSubmit() {
		// Perform action when the command is entered
		print("Submitted value: \(cmdText)")
	}
}

private struct Content: View {
	@Binding var msgLines: [CmdLine]

	var body: some View {
		List(msgLines) { message in
			MessageRow(chatLine: message)
		}
		.padding(EdgeInsets(top: 10, leading: 10, bottom: 50, trailing: 10))
	}
}

#Preview("CmdLine rows") {
	VStack {
		MessageRow(chatLine: CmdLine(id: 1, msg: "A 0000", timestamp: Date(), isCmd: true))
		MessageRow(chatLine: CmdLine(id: 1, msg: "A 0000", timestamp: Date(), isCmd: false))
		MessageRow(chatLine: CmdLine(id: 1, msg: "i", timestamp: Date(), isCmd: true))
		MessageRow(chatLine: CmdLine(id: 1, msg: "LF0000094", timestamp: Date(), isCmd: false))
		MessageRow(chatLine: CmdLine(id: 1, msg: "A 0000", timestamp: Date(), isCmd: true))
	}
}
