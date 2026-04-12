import Combine
import CoreLocation
import Foundation
import SwiftUI

final class GlobalState: ObservableObject {
    @Published var userLoginStatus = false
    @Published var currentUserEmail = ""
    @Published var selectedMainTab: MainTab = .home
    @Published var isRoutePresented = false
    @Published var selectedParkingLot: ParkingLot?
    @Published var routeRequestID = UUID()

    func login(email: String) {
        currentUserEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        userLoginStatus = true
    }

    func logout() {
        currentUserEmail = ""
        userLoginStatus = false
    }

    func showRoute(to parkingLot: ParkingLot) {
        selectedParkingLot = parkingLot
        isRoutePresented = true
        routeRequestID = UUID()
    }
}
