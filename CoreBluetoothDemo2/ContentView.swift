//
//  ContentView.swift
//  CoreBluetoothDemo2
//
//  Created by Tung Vu on 2024/10/01.
//

import SwiftUI

struct ContentView: View {
    @StateObject var bleManager = BLEManager()
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Bluetooth Devices")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .center)
            
            List(bleManager.peripherals, id: \.identifier) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name ?? "Unknown")
                        Text("\(item.state.rawValue)")
                    }
                    Spacer()
                    Button {
                        if bleManager.connectedCBperipheral?.identifier == item.identifier {
                            bleManager.disconect()
                        } else {
                            bleManager.selectPheripheralToObserveConnection(item)
                        }
                    } label: {
                        if item.state.rawValue == 2 {
                            Text("Connected")
                        } else if item.state.rawValue == 1 {
                            Text("Connecting")
                        } else {
                            Text("Connect")
                        }
                    }
                    
                }
            }
            
            Spacer()
            
            Text("STATUS")
                .font(.headline)
            
            if bleManager.isSwitchedOn {
                Text("Bluetooth is switched on")
                    .foregroundStyle(Color.green)
            } else {
                Text("Bluetooth is switched off")
                    .foregroundStyle(Color.red)
            }
            
            Spacer()
            
            VStack(spacing: 25) {
                Button {
                    bleManager.startScanning()
                } label: {
                    Text("Start scanning")
                }
                Button {
                    bleManager.stopScanning()
                } label: {
                    Text("Stop scanning")
                }
            }
        }
        .padding()
        .onAppear {
            if bleManager.isSwitchedOn {
                bleManager.startScanning()
            }
        }
    }
}

#Preview {
    ContentView()
}
