import SwiftUI

private struct StoredUser: Codable {
    let email: String
    let password: String
    let name: String
}

private enum AuthStorage {
    static let key = "registered_users"

    static func loadUsers() -> [StoredUser] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let users = try? JSONDecoder().decode([StoredUser].self, from: data)
        else {
            return []
        }

        return users
    }

    static func findUser(email: String) -> StoredUser? {
        let normalizedEmail = email.lowercased()
        return loadUsers().first { $0.email.lowercased() == normalizedEmail }
    }

    static func save(user: StoredUser) {
        var users = loadUsers().filter { $0.email.lowercased() != user.email.lowercased() }
        users.append(user)

        guard let data = try? JSONEncoder().encode(users) else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)
    }
}

struct LoginView: View {
    @EnvironmentObject private var globalState: GlobalState

    @State private var email = ""
    @State private var password = ""
    @State private var notice = ""
    @State private var showSignupPopup = false
    @State private var signupEmail = ""
    @State private var signupPassword = ""
    @State private var signupName = ""
    @State private var verificationCode = ""
    @State private var sentVerificationCode = ""
    @State private var signupNotice = ""

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("로그인")
                    .font(.largeTitle.bold())

                VStack(alignment: .leading, spacing: 12) {
                    Text("이메일")
                        .font(.headline)
                    TextField("name@example.com", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 12)
                        .frame(height: 48)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Text("비밀번호")
                        .font(.headline)
                    SecureField("비밀번호를 입력하세요", text: $password)
                        .padding(.horizontal, 12)
                        .frame(height: 48)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                if !notice.isEmpty {
                    Text(notice)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Button(action: login) {
                    Text("로그인")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Text("가입되지 않은 이메일이면 회원가입 팝업이 열립니다.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(24)

            if showSignupPopup {
                Color.black.opacity(0.24)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeSignup()
                    }

                signupPopup
                    .padding(24)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showSignupPopup)
    }

    private var signupPopup: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("회원가입")
                    .font(.title2.bold())
                Spacer()
                Button("닫기") {
                    closeSignup()
                }
            }

            Group {
                TextField("이름", text: $signupName)
                    .padding(.horizontal, 12)
                    .frame(height: 46)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                TextField("이메일", text: $signupEmail)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 12)
                    .frame(height: 46)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                SecureField("비밀번호", text: $signupPassword)
                    .padding(.horizontal, 12)
                    .frame(height: 46)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            HStack(spacing: 10) {
                TextField("인증 코드", text: $verificationCode)
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 12)
                    .frame(height: 46)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Button("인증 요청") {
                    sendVerificationCode()
                }
                .frame(height: 46)
                .padding(.horizontal, 12)
                .background(Color.orange)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            if !signupNotice.isEmpty {
                Text(signupNotice)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Button(action: signup) {
                Text("회원가입 완료")
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
    }

    private func login() {
        let normalizedEmail = normalized(email)

        guard isValidEmail(normalizedEmail) else {
            notice = "이메일 형식을 확인해 주세요."
            return
        }

        guard !password.isEmpty else {
            notice = "비밀번호를 입력해 주세요."
            return
        }

        guard let user = AuthStorage.findUser(email: normalizedEmail) else {
            signupEmail = normalizedEmail
            signupPassword = password
            signupName = ""
            verificationCode = ""
            sentVerificationCode = ""
            signupNotice = "가입되지 않은 이메일입니다. 회원가입을 진행해 주세요."
            showSignupPopup = true
            notice = ""
            return
        }

        guard user.password == password else {
            notice = "비밀번호가 일치하지 않습니다."
            return
        }

        globalState.login(email: normalizedEmail)
        notice = ""
    }

    private func sendVerificationCode() {
        let normalizedEmail = normalized(signupEmail)

        guard isValidEmail(normalizedEmail) else {
            signupNotice = "회원가입 이메일 형식을 확인해 주세요."
            return
        }

        guard isValidPassword(signupPassword) else {
            signupNotice = "비밀번호는 8자 이상이며 영문과 숫자를 모두 포함해야 합니다."
            return
        }

        signupEmail = normalizedEmail
        sentVerificationCode = String(format: "%06d", Int.random(in: 0...999999))
        signupNotice = "\(normalizedEmail)로 인증 코드를 전송했습니다. 개발용 코드: \(sentVerificationCode)"
    }

    private func signup() {
        let normalizedEmail = normalized(signupEmail)

        guard isValidEmail(normalizedEmail) else {
            signupNotice = "회원가입 이메일 형식을 확인해 주세요."
            return
        }

        guard isValidPassword(signupPassword) else {
            signupNotice = "비밀번호는 8자 이상이며 영문과 숫자를 모두 포함해야 합니다."
            return
        }

        guard !sentVerificationCode.isEmpty else {
            signupNotice = "먼저 인증 요청을 진행해 주세요."
            return
        }

        guard verificationCode == sentVerificationCode else {
            signupNotice = "인증 코드가 일치하지 않습니다."
            return
        }

        let user = StoredUser(
            email: normalizedEmail,
            password: signupPassword,
            name: signupName.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        AuthStorage.save(user: user)
        email = normalizedEmail
        password = signupPassword
        globalState.login(email: normalizedEmail)
        notice = "회원가입 후 로그인되었습니다."
        closeSignup()
    }

    private func closeSignup() {
        showSignupPopup = false
        verificationCode = ""
    }

    private func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func isValidEmail(_ value: String) -> Bool {
        value.range(
            of: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$",
            options: .regularExpression
        ) != nil
    }

    private func isValidPassword(_ value: String) -> Bool {
        value.range(
            of: "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d@$!%*#?&]{8,}$",
            options: .regularExpression
        ) != nil
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(GlobalState())
    }
}
