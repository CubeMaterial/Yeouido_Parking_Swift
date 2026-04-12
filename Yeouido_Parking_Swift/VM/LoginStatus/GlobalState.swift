import Combine
import CoreLocation
import Foundation
import SwiftUI

final class GlobalState: ObservableObject {
    private enum StorageKey {
        static let userLoginStatus = "userLoginStatus"
        static let currentUserID = "currentUserID"
        static let currentUserEmail = "currentUserEmail"
        static let currentUserName = "currentUserName"
        static let currentUserPhone = "currentUserPhone"
        static let currentUserDate = "currentUserDate"
        static let currentUserId = "currentUserId"
    }

    @Published var userLoginStatus = false
    @Published var currentUserID: Int?
    @Published var currentUserEmail = ""
    @Published var currentUserName = ""
    @Published var currentUserPhone = ""
    @Published var currentUserDate = ""
    @Published var currentUserId: Int = 0
    @Published var selectedMainTab: MainTab = .home
    @Published var isRoutePresented = false
    @Published var selectedParkingLot: ParkingLot?
    @Published var routeRequestID = UUID()

    init() {
        let defaults = UserDefaults.standard
        userLoginStatus = defaults.bool(forKey: StorageKey.userLoginStatus)
        if defaults.object(forKey: StorageKey.currentUserID) != nil {
            currentUserID = defaults.integer(forKey: StorageKey.currentUserID)
        }
        currentUserEmail = defaults.string(forKey: StorageKey.currentUserEmail) ?? ""
        currentUserName = defaults.string(forKey: StorageKey.currentUserName) ?? ""
        currentUserPhone = defaults.string(forKey: StorageKey.currentUserPhone) ?? ""
        currentUserDate = defaults.string(forKey: StorageKey.currentUserDate) ?? ""
        currentUserId = defaults.integer(forKey: StorageKey.currentUserId)
    }

    func login(email: String, name: String? = nil, phone: String? = nil, date: String? = nil, userId: Int? = nil) {
        currentUserEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        currentUserName = (name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        currentUserPhone = (phone ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        currentUserDate = (date ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        currentUserId = (userId ?? 0)
        userLoginStatus = true
        persistUserSession()
    }

    func logout() {
        currentUserID = nil
        currentUserEmail = ""
        currentUserName = ""
        currentUserPhone = ""
        currentUserDate = ""
        currentUserId = 0
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
        if let currentUserID {
            defaults.set(currentUserID, forKey: StorageKey.currentUserID)
        } else {
            defaults.removeObject(forKey: StorageKey.currentUserID)
        }
        defaults.set(currentUserEmail, forKey: StorageKey.currentUserEmail)
        defaults.set(currentUserName, forKey: StorageKey.currentUserName)
        defaults.set(currentUserPhone, forKey: StorageKey.currentUserPhone)
        defaults.set(currentUserDate, forKey: StorageKey.currentUserDate)
        defaults.set(currentUserId, forKey: StorageKey.currentUserId)
    }

    private func clearUserSession() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: StorageKey.userLoginStatus)
        defaults.removeObject(forKey: StorageKey.currentUserID)
        defaults.removeObject(forKey: StorageKey.currentUserEmail)
        defaults.removeObject(forKey: StorageKey.currentUserName)
        defaults.removeObject(forKey: StorageKey.currentUserPhone)
        defaults.removeObject(forKey: StorageKey.currentUserDate)
        defaults.removeObject(forKey: StorageKey.currentUserId)
    }
}
