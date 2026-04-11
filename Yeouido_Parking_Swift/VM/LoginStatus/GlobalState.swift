import Observation

@Observable
final class GlobalState {
    var userLoginStatus = false
    var currentUserEmail = ""

    func login(email: String) {
        currentUserEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        userLoginStatus = true
    }

    func logout() {
        currentUserEmail = ""
        userLoginStatus = false
    }
}
