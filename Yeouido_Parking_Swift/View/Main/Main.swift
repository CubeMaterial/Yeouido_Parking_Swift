//
//  Main.swift
//  Yeouido_Parking_Swift
//
//  Created by 이상현 on 4/12/26.
//

import SwiftUI
import UIKit

struct MainView: View {
    @EnvironmentObject private var globalState: GlobalState
    @State private var isLoginPresented = false

    var body: some View {
        ZStack {
            switch globalState.selectedMainTab {
            case .home:
                HomeView()
            case .reservation:
                ReservationView()
            case .map:
                MapView()
            case .facility:
                FacilityView()
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            MainFloatingTabBar(
                selectedTab: selectedTabBinding,
                isLoggedIn: globalState.userLoginStatus
            )
            .padding(.horizontal, 18)
            .padding(.top, 6)
            .padding(.bottom, 12)
        }
        .fullScreenCover(isPresented: $isLoginPresented) {
            LoginView()
                .environmentObject(globalState)
        }
    }

    private var selectedTabBinding: Binding<MainTab> {
        Binding(
            get: { globalState.selectedMainTab },
            set: { newValue in
                if newValue == .reservation && !globalState.userLoginStatus {
                    isLoginPresented = true
                    globalState.selectedMainTab = .home
                    return
                }

                globalState.selectedMainTab = newValue
            }
        )
    }
}

private struct MainFloatingTabBar: View {
    @Binding var selectedTab: MainTab
    let isLoggedIn: Bool

    private let tabs: [MainTab] = [.home, .reservation, .map, .facility]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(tabs, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "63C9F2"),
                                                Color(hex: "75D6AF")
                                            ],
                                            startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 44, height: 28)
                                    .shadow(color: Color(hex: "63C9F2").opacity(0.18), radius: 8, y: 4)
                            }

                            Image(systemName: tab.symbolName)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(selectedTab == tab ? .white : Color(hex: "1F3F38"))
                        }

                        Text(tab.title)
                            .font(.system(size: 10, weight: selectedTab == tab ? .bold : .medium))
                            .foregroundStyle(selectedTab == tab ? Color(hex: "167A8C") : Color.black.opacity(0.72))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 3)
                    .contentShape(Rectangle())
                    .overlay(alignment: .top) {
                        if !isLoggedIn && tab == .reservation {
                            Text("로그인 필요")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color(hex: "167A8C"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.white.opacity(0.98))
                                .clipShape(Capsule())
                                .offset(y: -24)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.white.opacity(0.92))

                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.9),
                                Color(hex: "D7F3EC")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: Color.black.opacity(0.06), radius: 16, y: 6)
    }
}

#Preview {
    MainView()
}
