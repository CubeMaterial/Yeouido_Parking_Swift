//
//  Main.swift
//  Yeouido_Parking_Swift
//
//  Created by 이상현 on 4/12/26.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var globalState: GlobalState

    var body: some View {
        TabView(selection: $globalState.selectedMainTab) {
            HomeView()
                .tag(MainTab.home)
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }

            ReservationView()
                .tag(MainTab.reservation)
                .tabItem {
                    Label("예약", systemImage: "calendar")
                }

            MapView()
                .tag(MainTab.map)
                .tabItem {
                    Label("지도", systemImage: "map.fill")
                }

            FacilityView()
                .tag(MainTab.facility)
                .tabItem {
                    Label("시설", systemImage: "building.2.fill")
                }
        }
    }
}

#Preview {
    MainView()
}
