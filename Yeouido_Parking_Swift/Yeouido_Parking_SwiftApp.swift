//
//  Yeouido_Parking_SwiftApp.swift
//  Yeouido_Parking_Swift
//
//  Created by MAC on 4/8/26.
//

import SwiftUI
import FirebaseCore

@main
struct Yeouido_Parking_SwiftApp: App {
    @StateObject private var globalState = GlobalState()
    @StateObject private var parkingLocationService = ParkingLocationService()
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = false

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(globalState)
                .environmentObject(parkingLocationService)
                .preferredColorScheme(isDarkModeEnabled ? .dark : .light)
        }
    }
}
