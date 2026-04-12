import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var globalState: GlobalState

    @State private var email = ""
    @State private var password = ""
    @State private var notice = ""
    @State private var showSignupPrompt = false
    @State private var showSignupPage = false
    @State private var pendingSignupEmail = ""
    @State private var pendingSignupPassword = ""
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.42, green: 0.70, blue: 0.98),
                        Color(red: 0.56, green: 0.86, blue: 0.92)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack {
                        Spacer(minLength: 56)

                        VStack(spacing: 20) {
                            ParkingHeaderArtwork()

                            VStack(spacing: 8) {
                                Text("로그인")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundStyle(Color(red: 0.19, green: 0.28, blue: 0.39))

                                Text("서비스를 이용하려면 로그인해 주세요")
                                    .font(.footnote)
                                    .foregroundStyle(Color.secondary)
                            }

                            VStack(spacing: 12) {
                                TextField("아이디 또는 이메일", text: $email)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                                    .autocorrectionDisabled()
                                    .padding(.horizontal, 16)
                                    .frame(height: 52)
                                    .background(Color(red: 0.95, green: 0.96, blue: 0.98))
                                    .clipShape(RoundedRectangle(cornerRadius: 18))

                                SecureField("비밀번호", text: $password)
                                    .padding(.horizontal, 16)
                                    .frame(height: 52)
                                    .background(Color(red: 0.95, green: 0.96, blue: 0.98))
                                    .clipShape(RoundedRectangle(cornerRadius: 18))

                                Text("비밀번호는 8자 이상 가능합니다.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            if !notice.isEmpty {
                                Text(notice)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Button {
                                Task {
                                    await login()
                                }
                            } label: {
                                Text(isSubmitting ? "로그인 중..." : "로그인")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.20, green: 0.53, blue: 0.96),
                                                Color(red: 0.15, green: 0.47, blue: 0.90)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(color: Color.blue.opacity(0.25), radius: 8, y: 4)
                            }
                            .disabled(isSubmitting)

                            VStack(spacing: 14) {
                                Divider()

                                HStack(spacing: 0) {
                                    Button("회원가입") {
                                        pendingSignupEmail = normalizedEmail(email)
                                        pendingSignupPassword = password
                                        showSignupPage = true
                                    }
                                    .buttonStyle(.plain)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(Color(red: 0.34, green: 0.39, blue: 0.47))

                                    Button("아이디 찾기 / 비밀번호 찾기") {
                                    }
                                    .buttonStyle(.plain)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .foregroundStyle(Color(red: 0.34, green: 0.39, blue: 0.47))
                                }
                                .font(.footnote)
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 32)
                        .frame(maxWidth: 380)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .shadow(color: Color.black.opacity(0.10), radius: 24, y: 14)
                        .padding(.horizontal, 24)

                        Spacer(minLength: 56)
                    }
                    .frame(maxWidth: .infinity)
                }

                if showSignupPrompt {
                    Color.black.opacity(0.24)
                        .ignoresSafeArea()

                    signupPrompt
                        .padding(24)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: showSignupPrompt)
            .navigationDestination(isPresented: $showSignupPage) {
                SignupView(
                    prefilledEmail: pendingSignupEmail,
                    prefilledPassword: pendingSignupPassword
                )
                .environmentObject(globalState)
            }
        }
    }

    private var signupPrompt: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("존재하지 않는 회원입니다. 회원 가입 하시겠습니까?")
                .font(.headline)

            HStack(spacing: 12) {
                Button("네") {
                    showSignupPrompt = false
                    showSignupPage = true
                }
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Button("아니요") {
                    showSignupPrompt = false
                }
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color.red)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
    }

    @MainActor
    private func login() async {
        let normalized = normalizedEmail(email)

        guard isValidEmail(normalized) else {
            notice = "이메일 형식을 확인해 주세요."
            return
        }

        guard !password.isEmpty else {
            notice = "비밀번호를 입력해 주세요."
            return
        }

        guard password.count >= 8 else {
            notice = "비밀번호는 8자 이상 입력해 주세요."
            return
        }

        isSubmitting = true
        notice = ""

        do {
            let response = try await AuthAPI.login(email: normalized, password: password)
            globalState.login(
                email: response.userEmail,
                name: response.userName,
                phone: response.userPhone,
                date: response.userDate,
                userId: response.userID
            )
        } catch AuthAPIError.notRegistered {
            pendingSignupEmail = normalized
            pendingSignupPassword = password
            showSignupPrompt = true
        } catch {
            notice = error.localizedDescription
        }

        isSubmitting = false
    }
}

private struct ParkingHeaderArtwork: View {
    var body: some View {
        Image("Logo")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 176, maxHeight: 112)
            .frame(maxWidth: .infinity)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(GlobalState())
    }
}
