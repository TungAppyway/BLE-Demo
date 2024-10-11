//
//  Peripheral.swift
//  CoreBluetoothDemo
//
//  Created by Tung Vu on 2024/10/01.
//

import Foundation

struct Peripheral: Identifiable {
    let id: UUID
    let name: String
    let rssi: Int
}
