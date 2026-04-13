import Combine
import CoreLocation
import Foundation
import SwiftUI
import UserNotifications

final class GlobalState: ObservableObject {
    private enum StorageKey {
        static let userLoginStatus = "userLoginStatus"
        static let currentUserID = "currentUserID"
        static let currentUserEmail = "currentUserEmail"
        static let currentUserName = "currentUserName"
        static let currentUserPhone = "currentUserPhone"
        static let currentUserDate = "currentUserDate"
        static let currentUserId = "currentUserId"

        static func favoriteFacilityIDs(for userID: Int?) -> String {
            if let userID {
                return "favoriteFacilityIDs_\(userID)"
            }

            return "favoriteFacilityIDs_guest"
        }
    }

    @Published var userLoginStatus = false
    @Published var currentUserID: Int?
    @Published var currentUserEmail = ""
    @Published var currentUserName = ""
    @Published var currentUserPhone = ""
    @Published var currentUserDate = ""
    @Published var selectedMainTab: MainTab = .home
    @Published var isRoutePresented = false
    @Published var selectedParkingLot: ParkingLot?
    @Published var routeRequestID = UUID()
    @Published var selectedMapFacilityID: Int?
    @Published var mapSelectionRequestID = UUID()
    @Published var notifications: [String] = []
    @Published var favoriteFacilityIDs: Set<Int> = []

    private var chatReplyListener: ChatListenerToken?
    private var knownAdminMessageIDs: Set<String> = []
    private var hasLoadedInitialAdminMessages = false

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
        favoriteFacilityIDs = loadFavoriteFacilityIDs(for: currentUserID)

        requestNotificationAuthorization()

        if userLoginStatus {
            startChatReplyListenerIfNeeded()
        }
    }

    func login(email: String, name: String? = nil, phone: String? = nil, date: String? = nil, userId: Int? = nil) {
        currentUserID = userId
        currentUserEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        currentUserName = (name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        currentUserPhone = (phone ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        currentUserDate = (date ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        userLoginStatus = true
        persistUserSession()
        favoriteFacilityIDs = loadFavoriteFacilityIDs(for: userId)
        startChatReplyListenerIfNeeded()
    }

    func logout() {
        currentUserID = nil
        currentUserEmail = ""
        currentUserName = ""
        currentUserPhone = ""
        currentUserDate = ""
        userLoginStatus = false
        clearUserSession()
        favoriteFacilityIDs = loadFavoriteFacilityIDs(for: nil)
        stopChatReplyListener()
    }

    func showRoute(to parkingLot: ParkingLot) {
        selectedParkingLot = parkingLot
        isRoutePresented = true
        routeRequestID = UUID()
    }

    func showFacilityOnMap(facilityID: Int) {
        selectedMapFacilityID = facilityID
        selectedMainTab = .map
        mapSelectionRequestID = UUID()
    }

    func isFavoriteFacility(_ facilityID: Int) -> Bool {
        favoriteFacilityIDs.contains(facilityID)
    }

    func toggleFavoriteFacility(_ facilityID: Int) {
        if favoriteFacilityIDs.contains(facilityID) {
            favoriteFacilityIDs.remove(facilityID)
        } else {
            favoriteFacilityIDs.insert(facilityID)
        }

        saveFavoriteFacilityIDs()
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
    }

    private func clearUserSession() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: StorageKey.userLoginStatus)
        defaults.removeObject(forKey: StorageKey.currentUserID)
        defaults.removeObject(forKey: StorageKey.currentUserEmail)
        defaults.removeObject(forKey: StorageKey.currentUserName)
        defaults.removeObject(forKey: StorageKey.currentUserPhone)
        defaults.removeObject(forKey: StorageKey.currentUserDate)
    }

    private func loadFavoriteFacilityIDs(for userID: Int?) -> Set<Int> {
        let defaults = UserDefaults.standard
        let key = StorageKey.favoriteFacilityIDs(for: userID)
        let ids = defaults.array(forKey: key) as? [Int] ?? []
        return Set(ids)
    }

    private func saveFavoriteFacilityIDs() {
        let defaults = UserDefaults.standard
        let key = StorageKey.favoriteFacilityIDs(for: currentUserID)
        defaults.set(Array(favoriteFacilityIDs).sorted(), forKey: key)
    }

    private func startChatReplyListenerIfNeeded() {
        guard userLoginStatus, let currentUserID else { return }

        stopChatReplyListener()
        knownAdminMessageIDs = []
        hasLoadedInitialAdminMessages = false

        chatReplyListener = ChatFirestoreService.observeMessages(userID: currentUserID) { [weak self] messages in
            self?.handleIncomingChatMessages(messages)
        }
    }

    private func stopChatReplyListener() {
        chatReplyListener?.cancel()
        chatReplyListener = nil
        knownAdminMessageIDs.removeAll()
        hasLoadedInitialAdminMessages = false
    }

    private func handleIncomingChatMessages(_ messages: [ChatMessage]) {
        let adminMessages = messages.filter { $0.senderType == .admin }

        if !hasLoadedInitialAdminMessages {
            knownAdminMessageIDs = Set(adminMessages.map(\.id))
            hasLoadedInitialAdminMessages = true
            return
        }

        let newMessages = adminMessages
            .filter { !knownAdminMessageIDs.contains($0.id) }
            .sorted { $0.createdAt < $1.createdAt }

        guard !newMessages.isEmpty else { return }

        knownAdminMessageIDs.formUnion(newMessages.map(\.id))

        for message in newMessages {
            let summary = "관리자 답변: \(message.text)"
            notifications.insert(summary, at: 0)
            notifications = Array(notifications.prefix(20))
            scheduleLocalNotification(for: summary)
        }
    }

    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    private func scheduleLocalNotification(for body: String) {
        let content = UNMutableNotificationContent()
        content.title = "새 문의 답변"
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
