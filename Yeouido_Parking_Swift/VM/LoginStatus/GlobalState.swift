import Combine
import CoreLocation
import Foundation
import SwiftUI

final class GlobalState: ObservableObject {
    @Published var userLoginStatus = false
    @Published var currentUserEmail = ""
    @Published var currentUserName = ""
    @Published var selectedMainTab: MainTab = .home
    @Published var isRoutePresented = false
    @Published var selectedParkingLot: ParkingLot?
    @Published var routeRequestID = UUID()

    func login(email: String, name: String? = nil) {
        currentUserEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        currentUserName = (name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        userLoginStatus = true
    }

    func logout() {
        currentUserEmail = ""
        currentUserName = ""
        userLoginStatus = false
    }

    func showRoute(to parkingLot: ParkingLot) {
        selectedParkingLot = parkingLot
        isRoutePresented = true
        routeRequestID = UUID()
    }
}
