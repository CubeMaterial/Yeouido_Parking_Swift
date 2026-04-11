//
//  Yeouido_Parking_SwiftApp.swift
//  Yeouido_Parking_Swift
//
//  Created by MAC on 4/8/26.
//

import SwiftUI

@main
struct Yeouido_Parking_SwiftApp: App {
    @State private var globalState = GlobalState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(globalState)
        }
    }
}
