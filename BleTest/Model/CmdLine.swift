//
//  CmdLine.swift
//  BleTest
//
//  Created by Andrew on 04/02/2026.
//

import Foundation

struct CmdLine: Identifiable {
	var id: Int
	var msg: String
	var timestamp: Date
	var isCmd: Bool // Cmd to Device true, Resp from Device false
}
