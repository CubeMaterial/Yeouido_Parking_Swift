import Combine
import CoreLocation
import Foundation
import SwiftUI

final class GlobalState: ObservableObject {
    private enum StorageKey {
        static let userLoginStatus = "userLoginStatus"
        static let currentUserEmail = "currentUserEmail"
        static let currentUserName = "currentUserName"
        static let currentUserPhone = "currentUserPhone"
        static let currentUserDate = "currentUserDate"
    }

    @Published var userLoginStatus = false
    @Published var currentUserEmail = ""
    @Published var currentUserName = ""
    @Published var currentUserPhone = ""
    @Published var currentUserDate = ""
    @Published var selectedMainTab: MainTab = .home
    @Published var isRoutePresented = false
    @Published var selectedParkingLot: ParkingLot?
    @Published var routeRequestID = UUID()

    init() {
        let defaults = UserDefaults.standard
        userLoginStatus = defaults.bool(forKey: StorageKey.userLoginStatus)
        currentUserEmail = defaults.string(forKey: StorageKey.currentUserEmail) ?? ""
        currentUserName = defaults.string(forKey: StorageKey.currentUserName) ?? ""
        currentUserPhone = defaults.string(forKey: StorageKey.currentUserPhone) ?? ""
        currentUserDate = defaults.string(forKey: StorageKey.currentUserDate) ?? ""
    }

    func login(email: String, name: String? = nil, phone: String? = nil, date: String? = nil) {
        currentUserEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        currentUserName = (name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        currentUserPhone = (phone ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        currentUserDate = (date ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        userLoginStatus = true
        persistUserSession()
    }

    func logout() {
        currentUserEmail = ""
        currentUserName = ""
        currentUserPhone = ""
        currentUserDate = ""
        userLoginStatus = false
        clearUserSession()
    }

    func showRoute(to parkingLot: ParkingLot) {
        selectedParkingLot = parkingLot
        isRoutePresented = true
        routeRequestID = UUID()
    }

    private func persistUserSession() {
        let defaults = UserDefaults.standard
        defaults.set(userLoginStatus, forKey: StorageKey.userLoginStatus)
        defaults.set(currentUserEmail, forKey: StorageKey.currentUserEmail)
        defaults.set(currentUserName, forKey: StorageKey.currentUserName)
        defaults.set(currentUserPhone, forKey: StorageKey.currentUserPhone)
        defaults.set(currentUserDate, forKey: StorageKey.currentUserDate)
    }

    private func clearUserSession() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: StorageKey.userLoginStatus)
        defaults.removeObject(forKey: StorageKey.currentUserEmail)
        defaults.removeObject(forKey: StorageKey.currentUserName)
        defaults.removeObject(forKey: StorageKey.currentUserPhone)
        defaults.removeObject(forKey: StorageKey.currentUserDate)
    }
}
