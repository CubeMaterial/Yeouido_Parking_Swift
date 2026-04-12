//
//  Map.swift
//  Yeouido_Parking_Swift
//
//  Created by Codex on 8/18/25.
//

import MapKit
import SwiftUI

struct MapView: View {
    @State private var searchText = ""
    @State private var isFilterSheetPresented = false
    @State private var selectedParkingSpotID: Int?
    @State private var recentParkingSpotIDs: [Int] = []
    @State private var availabilityBySourceName: [String: ParkingAvailability] = [:]
    @State private var isLoadingAvailability = false
    @State private var availabilityErrorMessage: String?
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.5276, longitude: 126.9329),
            span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        )
    )

    private let parkingSpots = ParkingSpot.sampleSpots
    private let availabilityService = MapParkingAvailabilityService.shared

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                mapLayer
                mapShade

                VStack(spacing: 0) {
                    MapFilterBar(
                        selectedParkingSpot: selectedParkingSpot,
                        onFilterTap: {
                            isFilterSheetPresented = true
                        },
                        onSelectedSpotTap: { spot in
                            select(spot)
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    Spacer()

                    if let selectedParkingSpot {
                        ParkingInfoCard(
                            parkingSpot: selectedParkingSpot,
                            availability: availabilityBySourceName[selectedParkingSpot.sourceName],
                            isLoading: isLoadingAvailability,
                            errorMessage: availabilityErrorMessage
                        )
                        .padding(.horizontal, 16)
                        .ignoresSafeArea(edges: .bottom)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
            .animation(.spring(response: 0.34, dampingFraction: 0.86), value: isFilterSheetPresented)
            .fullScreenCover(isPresented: $isFilterSheetPresented) {
                ParkingFilterSheet(
                    searchText: $searchText,
                    selectedParkingSpotID: $selectedParkingSpotID,
                    recentParkingSpots: recentParkingSpots,
                    filteredParkingSpots: filteredParkingSpots,
                    onClose: {
                        isFilterSheetPresented = false
                    },
                    onFocus: { spot in
                        select(spot)
                    }
                )
                .presentationBackground(.clear)
            }
        }
    }

    private var mapLayer: some View {
        Map(position: $cameraPosition) {
            ForEach(parkingSpots) { spot in
                Annotation(spot.name, coordinate: spot.coordinate, anchor: .bottom) {
                    Button {
                        select(spot)
                    } label: {
                        ParkingMarker(
                            title: spot.shortDisplayName,
                            isSelected: selectedParkingSpotID == spot.id
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControlVisibility(.hidden)
        .ignoresSafeArea()
    }

    private var mapShade: some View {
        LinearGradient(
            colors: [
                Color.black.opacity(0.12),
                Color.clear,
                Color.black.opacity(0.06)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var filteredParkingSpots: [ParkingSpot] {
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedText.isEmpty {
            return parkingSpots
        }

        return parkingSpots.filter { $0.name.localizedCaseInsensitiveContains(trimmedText) }
    }

    private var selectedParkingSpot: ParkingSpot? {
        parkingSpots.first { $0.id == selectedParkingSpotID }
    }

    private var recentParkingSpots: [ParkingSpot] {
        recentParkingSpotIDs.compactMap { id in
            parkingSpots.first(where: { $0.id == id })
        }
    }

    private func select(_ spot: ParkingSpot) {
        selectedParkingSpotID = spot.id
        registerRecentSpot(spot.id)
        focus(on: spot)
        loadAvailability(for: spot)
    }

    private func registerRecentSpot(_ id: Int) {
        recentParkingSpotIDs.removeAll { $0 == id }
        recentParkingSpotIDs.append(id)

        if recentParkingSpotIDs.count > 3 {
            recentParkingSpotIDs.removeFirst(recentParkingSpotIDs.count - 3)
        }
    }

    private func focus(on spot: ParkingSpot) {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: spot.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.0045, longitudeDelta: 0.0045)
            )
        )
    }

    private func loadAvailability(for spot: ParkingSpot) {
        if availabilityBySourceName[spot.sourceName] != nil {
            availabilityErrorMessage = nil
            return
        }

        isLoadingAvailability = true
        availabilityErrorMessage = nil

        Task {
            do {
                let availabilities = try await availabilityService.fetchAvailabilities()
                await MainActor.run {
                    availabilityBySourceName = availabilities
                    isLoadingAvailability = false

                    if availabilities[spot.sourceName] == nil {
                        availabilityErrorMessage = "잔여 대수를 찾지 못했습니다."
                    }
                }
            } catch {
                await MainActor.run {
                    isLoadingAvailability = false
                    availabilityErrorMessage = "잔여 대수를 불러오지 못했습니다."
                }
            }
        }
    }
}

#Preview {
    MapView()
}
