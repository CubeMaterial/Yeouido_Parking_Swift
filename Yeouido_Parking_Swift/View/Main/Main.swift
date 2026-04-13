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

    var body: some View {
        ZStack {
            switch globalState.selectedMainTab {
            case .home:
                HomeView()
            case .map:
                MapView()
            case .facility:
                FacilityView()
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            MainFloatingTabBar(
                selectedTab: selectedTabBinding
            )
            .padding(.horizontal, 18)
            .padding(.top, 6)
            .padding(.bottom, 12)
        }
    }

    private var selectedTabBinding: Binding<MainTab> {
        Binding(
            get: { globalState.selectedMainTab },
            set: { newValue in
                globalState.selectedMainTab = newValue
            }
        )
    }
}

private struct MainFloatingTabBar: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        ZStack(alignment: .top) {
            HStack(spacing: 12) {
                sideTabButton(for: .home)

                Spacer(minLength: 92)

                sideTabButton(for: .facility)
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 8)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.white.opacity(0.9))

                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.92),
                                    Color(hex: "E4F5EF")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.06), radius: 14, y: 8)

            mapTabButton
                .offset(y: -20)
        }
    }

    private func sideTabButton(for tab: MainTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.symbolName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(selectedTab == tab ? Color(hex: "167A8C") : Color(hex: "1F3F38").opacity(0.72))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(selectedTab == tab ? Color(hex: "E5F8F4") : Color.clear)
                    )

                Text(tab.title)
                    .font(.system(size: 10, weight: selectedTab == tab ? .bold : .medium))
                    .foregroundStyle(selectedTab == tab ? Color(hex: "167A8C") : Color.black.opacity(0.68))
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var mapTabButton: some View {
        Button {
            selectedTab = .map
        } label: {
            ZStack {
                Circle()
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
                    .frame(width: 62, height: 62)
                    .shadow(color: Color(hex: "63C9F2").opacity(0.26), radius: 12, y: 8)

                Circle()
                    .stroke(Color.white.opacity(0.88), lineWidth: 4)
                    .frame(width: 62, height: 62)

                VStack(spacing: 1) {
                    Image(systemName: MainTab.map.symbolName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)

                    Text(MainTab.map.title)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white.opacity(0.95))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainView()
}
