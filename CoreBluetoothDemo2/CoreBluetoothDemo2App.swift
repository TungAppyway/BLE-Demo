//
//  CoreBluetoothDemo2App.swift
//  CoreBluetoothDemo2
//
//  Created by Tung Vu on 2024/10/01.
//

import SwiftUI

@main
struct CoreBluetoothDemo2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if let val = launchOptions?[.bluetoothCentrals] {
            sendNotification(title: "bluetoothCentrals", body: "didFinishLaunchingWithOptions")
        } else if let periphrals = launchOptions?[.bluetoothPeripherals] {
            sendNotification(title: "periphrals", body: "didFinishLaunchingWithOptions")
        }
        requestNotificationAuthorization()

        return true
    }
    
    func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
    
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error)")
            }
        }
    }
}
