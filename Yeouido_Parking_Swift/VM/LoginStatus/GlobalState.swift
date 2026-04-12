import Combine
import Foundation
import SwiftUI

final class GlobalState: ObservableObject {
    @Published var userLoginStatus = false
    @Published var currentUserEmail = ""

    func login(email: String) {
        currentUserEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        userLoginStatus = true
    }

    func logout() {
        currentUserEmail = ""
        userLoginStatus = false
    }
}
