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
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 10)
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

                Spacer(minLength: 86)

                sideTabButton(for: .facility)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.white.opacity(0.96))

                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.92),
                                    Color(hex: "E4F5EF")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.0
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.09), radius: 16, y: 10)

            mapTabButton
                .offset(y: -14)
        }
    }

    private func sideTabButton(for tab: MainTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 6) {
                Image(systemName: tab.symbolName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(selectedTab == tab ? Color(hex: "167A8C") : Color(hex: "1F3F38").opacity(0.72))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(selectedTab == tab ? Color(hex: "DDF5EE") : Color.clear)
                    )

                Text(tab.title)
                    .font(.system(size: 12, weight: selectedTab == tab ? .bold : .semibold))
                    .foregroundStyle(selectedTab == tab ? Color(hex: "167A8C") : Color.black.opacity(0.68))
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(selectedTab == tab ? Color(hex: "F1FBF8") : Color.clear)
            )
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
                    .frame(width: 80, height: 80)
                    .shadow(color: Color(hex: "63C9F2").opacity(0.34), radius: 14, y: 9)

                Circle()
                    .stroke(Color.white.opacity(0.88), lineWidth: 4)
                    .frame(width: 80, height: 80)

                VStack(spacing: 2) {
                    Image(systemName: MainTab.map.symbolName)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.white)

                    Text(MainTab.map.title)
                        .font(.system(size: 12, weight: .bold))
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
