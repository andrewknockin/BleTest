//
//  PeripheralLineView.swift
//  BleTest
//
//  Created by Andrew on 25/01/2026
//

import SwiftUI

struct TextLine: View {
    @State var periph: Device

    var body: some View {
        HStack {
            Text(periph.name).padding()
            Spacer()
            Text(String(periph.rssi)).padding()
        }
    }
}

struct PeripheralLineView: View {
    @State var peri: Device

    var body: some View {
        let _ = print("PeripheralLineView")
		TextLine(periph: peri).foregroundColor(.green)
    }
}

let peri0 = Device(ident: 1, name: "Andrew", rssi: -70)
#Preview("peri0") {
//    PeripheralLineView(peri: peri0)
    TextLine(periph: peri0)
}
