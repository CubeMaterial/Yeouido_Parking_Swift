//
//  Main.swift
//  Yeouido_Parking_Swift
//
//  Created by 이상현 on 4/12/26.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }

            ReservationView()
                .tabItem {
                    Label("예약", systemImage: "calendar")
                }

            MapView()
                .tabItem {
                    Label("지도", systemImage: "map.fill")
                }

            FacilityView()
                .tabItem {
                    Label("시설", systemImage: "building.2.fill")
                }
        }
    }
}

#Preview {
    MainView()
}
