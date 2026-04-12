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
    @State private var selectedFilter: MapMarkerFilter = .all
    @State private var selectedParkingSpotID: Int?
    @State private var selectedFacilityID: Int?
    @State private var availabilityBySourceName: [String: ParkingAvailability] = [:]
    @State private var isLoadingAvailability = false
    @State private var availabilityErrorMessage: String?
    @State private var facilities: [MapFacility] = []
    @State private var facilityLoadMessage: String?
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
                        selectedFilter: selectedFilter,
                        selectedParkingSpot: selectedParkingSpot,
                        onFilterTap: {
                            isFilterSheetPresented = true
                        },
                        onFilterSelect: { filter in
                            selectedFilter = filter
                            clearSelectionIfNeeded(for: filter)
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
                        .padding(.bottom, 5)
                    } else if let selectedReservableFacility {
                        FacilityInfoCard(
                            facility: selectedReservableFacility
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 5)
                    }
                }

                if isFilterSheetPresented {
                    ParkingFilterSheet(
                        searchText: $searchText,
                        selectedFilter: $selectedFilter,
                        selectedParkingSpotID: $selectedParkingSpotID,
                        filterOptions: MapMarkerFilter.allCases,
                        searchResults: filteredSearchResults,
                        onClose: {
                            isFilterSheetPresented = false
                        },
                        onResultSelect: { result in
                            switch result {
                            case .parking(let spot):
                                select(spot)
                            case .facility(let facility):
                                select(facility)
                            }
                        }
                    )
                    .zIndex(10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
            .animation(.spring(response: 0.34, dampingFraction: 0.86), value: isFilterSheetPresented)
            .task {
                await loadFacilitiesIfNeeded()
            }
        }
    }

    private var mapLayer: some View {
        Map(position: $cameraPosition) {
            ForEach(filteredFacilities) { facility in
                Annotation(facility.name, coordinate: facility.coordinate, anchor: .bottom) {
                    Button {
                        select(facility)
                    } label: {
                        FacilityMarker(
                            title: facility.name,
                            isSelected: selectedFacilityID == facility.id,
                            isReservable: facility.isReservable
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            ForEach(filteredMapParkingSpots) { spot in
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

    private var filteredSearchResults: [MapSearchResult] {
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else {
            return []
        }

        let parkingResults = parkingSpots.compactMap { spot -> MapSearchResult? in
            guard spot.name.localizedCaseInsensitiveContains(trimmedText) else {
                return nil
            }
            return .parking(spot)
        }

        let facilityResults = facilities.compactMap { facility -> MapSearchResult? in
            let matchesText = facility.name.localizedCaseInsensitiveContains(trimmedText)
                || (facility.info?.localizedCaseInsensitiveContains(trimmedText) ?? false)

            guard matchesText else { return nil }

            switch selectedFilter {
            case .all:
                return .facility(facility)
            case .parking:
                return nil
            case .reservableFacility:
                return facility.isReservable ? .facility(facility) : nil
            case .otherFacility:
                return facility.isReservable ? nil : .facility(facility)
            }
        }

        switch selectedFilter {
        case .all:
            return parkingResults + facilityResults
        case .parking:
            return parkingResults
        case .reservableFacility, .otherFacility:
            return facilityResults
        }
    }

    private var selectedParkingSpot: ParkingSpot? {
        parkingSpots.first { $0.id == selectedParkingSpotID }
    }

    private var selectedReservableFacility: MapFacility? {
        guard let selectedFacilityID else { return nil }

        return facilities.first {
            $0.id == selectedFacilityID && $0.isReservable
        }
    }

    private var filteredMapParkingSpots: [ParkingSpot] {
        switch selectedFilter {
        case .all, .parking:
            return parkingSpots
        case .reservableFacility, .otherFacility:
            return []
        }
    }

    private var filteredFacilities: [MapFacility] {
        switch selectedFilter {
        case .all:
            return facilities
        case .parking:
            return []
        case .reservableFacility:
            return facilities.filter(\.isReservable)
        case .otherFacility:
            return facilities.filter { !$0.isReservable }
        }
    }

    private func select(_ spot: ParkingSpot) {
        selectedParkingSpotID = spot.id
        selectedFacilityID = nil
        focus(on: spot)
        loadAvailability(for: spot)
    }

    private func select(_ facility: MapFacility) {
        selectedFacilityID = facility.id
        selectedParkingSpotID = nil
        cameraPosition = .region(
            MKCoordinateRegion(
                center: facility.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.0045, longitudeDelta: 0.0045)
            )
        )
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

    private func loadFacilitiesIfNeeded() async {
        guard facilities.isEmpty else { return }

        do {
            let fetchedFacilities = try await MapFacilityService.fetchAllFacilities()
            await MainActor.run {
                facilities = fetchedFacilities
                facilityLoadMessage = "시설물 \(fetchedFacilities.count)개 표시"
            }
        } catch {
            await MainActor.run {
                facilityLoadMessage = error.localizedDescription
            }
        }
    }

    private func clearSelectionIfNeeded(for filter: MapMarkerFilter) {
        switch filter {
        case .all:
            break
        case .parking:
            selectedFacilityID = nil
        case .reservableFacility:
            selectedParkingSpotID = nil
            if let selectedFacilityID,
               let selectedFacility = facilities.first(where: { $0.id == selectedFacilityID }),
               !selectedFacility.isReservable {
                self.selectedFacilityID = nil
            }
        case .otherFacility:
            selectedParkingSpotID = nil
            if let selectedFacilityID,
               let selectedFacility = facilities.first(where: { $0.id == selectedFacilityID }),
               selectedFacility.isReservable {
                self.selectedFacilityID = nil
            }
        }
    }
}

#Preview {
    MapView()
}
