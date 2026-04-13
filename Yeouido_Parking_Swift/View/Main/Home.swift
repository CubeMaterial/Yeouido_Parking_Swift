//
//  Home.swift
//  Yeouido_Parking_Swift
//
//  Created by Codex on 8/18/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var globalState: GlobalState
    @EnvironmentObject private var parkingLocationService: ParkingLocationService
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = false
    @State private var isSearchPresented = false
    @State private var isNotificationPresented = false
    @State private var isMenuPresented = false
    @State private var weather = WeatherSummary.placeholder(location: "여의도")
    @State private var festivals: [FestivalItem] = []
    @State private var parkingAvailability: [String: Int] = [:]
    @State private var isInquiryExpanded = false
    @State private var isLoginRequiredPresented = false
    @State private var isChatPresented = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "63C9F2"),
                        Color(hex: "75B992")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Text("여한이 없을까?")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)

                        Spacer()

                        HeaderIconButton(systemName: "magnifyingglass") {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                                isNotificationPresented = false
                                isMenuPresented = false
                                isSearchPresented = true
                            }
                        }
                        HeaderIconButton(systemName: "bell") {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                                isSearchPresented = false
                                isMenuPresented = false
                                isNotificationPresented = true
                            }
                        }
                        HeaderIconButton(systemName: "line.3.horizontal") {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                                isSearchPresented = false
                                isNotificationPresented = false
                                isMenuPresented = true
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                    ZStack {
                        Color.white
                            .ignoresSafeArea(edges: .bottom)

                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 14) {
                                WeatherSectionView(
                                    weather: weather
                                )
                                .padding(.horizontal, 20)
                                .padding(.top, 18)

                                NearestParkingSectionView(
                                    parkingLot: parkingLocationService.nearestParkingLot,
                                    distanceText: parkingLocationService.nearestParkingDistanceText,
                                    availableCount: parkingAvailability[parkingLocationService.nearestParkingLot?.name ?? ""]
                                ) { parkingLot in
                                    globalState.showRoute(to: parkingLot)
                                }
                                .padding(.horizontal, 20)

                                FestivalSectionView(festivals: festivals)

                                ParkingHoursSectionView(
                                    title: "주차장 이용시간",
                                    hoursText: "06:00 - 23:00"
                                )
                                .padding(.horizontal, 20)

                                ParkingAvailabilityGridSectionView(
                                    parkingLots: ParkingLot.yeouidoLots,
                                    availability: parkingAvailability
                                )
                                .padding(.horizontal, 20)
                                .padding(.bottom, 150)
                            }
                        }
                        .refreshable {
                            await refreshHomeData()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 28,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 28
                        )
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if isSearchPresented || isNotificationPresented || isMenuPresented {
                    Color.black.opacity(0.18)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                                isSearchPresented = false
                                isNotificationPresented = false
                                isMenuPresented = false
                            }
                        }
                        .transition(.opacity)
                        .zIndex(1)

                    if isSearchPresented || isNotificationPresented {
                        VStack(spacing: 0) {
                            Color.white
                                .frame(height: 120)
                                .ignoresSafeArea(edges: .top)

                            Spacer()
                        }
                        .allowsHitTesting(false)
                        .zIndex(2)
                    }

                    if isSearchPresented {
                        SearchOverlayView(
                            isPresented: $isSearchPresented,
                            recentKeywords: ["어트랙션", "페스티벌"]
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(3)
                    }

                    if isNotificationPresented {
                        NotificationOverlayView(
                            isPresented: $isNotificationPresented,
                            notifications: []
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(3)
                    }

                    if isMenuPresented {
                        MenuDrawerView(
                            isPresented: $isMenuPresented,
                            isDarkModeEnabled: $isDarkModeEnabled,
                            onLoginTap: {
                                isLoginRequiredPresented = true
                            }
                        )
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        .zIndex(3)
                    }
                }

                VStack {
                    Spacer()

                    HStack {
                        Spacer()

                        InquiryFloatingButtonView(
                            isExpanded: $isInquiryExpanded,
                            isCompact: isMenuPresented,
                            onCallTap: openPhoneInquiry,
                            onChatTap: openChatInquiry
                        )
                        .offset(x: isMenuPresented ? -292 : 0, y: isMenuPresented ? 18 : 0)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 104)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(4)
            }
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await refreshHomeData()
            }
            .fullScreenCover(isPresented: $globalState.isRoutePresented) {
                RouteView()
                    .environmentObject(globalState)
                    .environmentObject(parkingLocationService)
            }
            .fullScreenCover(isPresented: $isLoginRequiredPresented) {
                LoginView()
                    .environmentObject(globalState)
            }
            .fullScreenCover(isPresented: $isChatPresented) {
                ChatView()
                    .environmentObject(globalState)
            }
        }
    }

    private func loadWeather() async {
        do {
            weather = try await WeatherService.fetchYeouidoWeather()
        } catch {
            weather = WeatherSummary.placeholder(location: "여의도")
        }
    }

    private func loadParkingAvailability() async {
        do {
            parkingAvailability = try await ParkingAvailabilityService.fetchYeouidoAvailability()
        } catch {
            parkingAvailability = [:]
        }
    }

    private func loadFestivals() async {
        do {
            festivals = try await FestivalService.fetchYeouidoFestivals()
        } catch {
            festivals = []
        }
    }

    private func refreshHomeData() async {
        parkingLocationService.requestAuthorization()
        await loadWeather()
        await loadParkingAvailability()
        await loadFestivals()
    }

    private func openPhoneInquiry() {
        guard let url = URL(string: "tel://15775252") else { return }
        openURL(url)
    }

    private func openChatInquiry() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
            isInquiryExpanded = false
        }

        guard globalState.userLoginStatus else {
            isLoginRequiredPresented = true
            return
        }

        isChatPresented = true
    }
}

private struct HeaderIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(.white.opacity(0.22))
                .clipShape(Circle())
        }
    }
}

#Preview {
    HomeView()
}
