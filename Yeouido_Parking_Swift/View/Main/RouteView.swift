//
//  RouteView.swift
//  Yeouido_Parking_Swift
//
//  Created by Codex on 8/18/25.
//

import MapKit
import SwiftUI

struct RouteView: View {
    @EnvironmentObject private var globalState: GlobalState
    @EnvironmentObject private var parkingLocationService: ParkingLocationService

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var route: MKRoute?
    @State private var isLoadingRoute = false
    @State private var routeErrorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $cameraPosition) {
                    UserAnnotation()

                    ForEach(parkingLocationService.parkingLots) { parkingLot in
                        Marker(parkingLot.name, coordinate: parkingLot.coordinate)
                            .tint(globalState.selectedParkingLot == parkingLot ? .blue : .red)
                    }

                    if let route {
                        MapPolyline(route)
                            .stroke(.blue, lineWidth: 6)
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .mapControls {
                    MapCompass()
                    MapUserLocationButton()
                }

                if let selectedParkingLot = globalState.selectedParkingLot {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(selectedParkingLot.name)
                            .font(.headline)

                        Text(selectedParkingLot.address)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if let route {
                            Text("예상 거리 \(formattedDistance(route.distance)) · 약 \(formattedTravelTime(route.expectedTravelTime))")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        } else if isLoadingRoute {
                            Text("경로를 불러오는 중입니다.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        } else if let routeErrorMessage {
                            Text(routeErrorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(20)
                }
            }
            .navigationTitle("경로")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("닫기") {
                        globalState.isRoutePresented = false
                    }
                }
            }
            .task {
                parkingLocationService.requestAuthorization()
                await updateRouteIfNeeded()
            }
            .onChange(of: globalState.routeRequestID) {
                Task {
                    await updateRouteIfNeeded()
                }
            }
            .onChange(of: parkingLocationService.locationUpdateID) {
                Task {
                    await updateRouteIfNeeded()
                }
            }
        }
    }

    private func updateRouteIfNeeded() async {
        guard let destination = globalState.selectedParkingLot else {
            route = nil
            return
        }

        guard let currentLocation = parkingLocationService.currentLocation else {
            routeErrorMessage = "현재 위치를 확인할 수 없습니다."
            return
        }

        isLoadingRoute = true
        routeErrorMessage = nil

        do {
            let newRoute = try await ParkingRouteService.route(
                from: currentLocation.coordinate,
                to: destination.coordinate
            )
            route = newRoute
            cameraPosition = .rect(newRoute.polyline.boundingMapRect)
        } catch {
            route = nil
            routeErrorMessage = "경로를 불러오지 못했습니다."
        }

        isLoadingRoute = false
    }

    private func formattedDistance(_ distance: CLLocationDistance) -> String {
        if distance >= 1000 {
            return String(format: "%.1fkm", distance / 1000)
        }

        return "\(Int(distance))m"
    }

    private func formattedTravelTime(_ time: TimeInterval) -> String {
        let minutes = max(1, Int(time / 60))
        return "\(minutes)분"
    }
}

#Preview {
    RouteView()
        .environmentObject(GlobalState())
        .environmentObject(ParkingLocationService())
}
