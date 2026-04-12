import SwiftUI

struct SignupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var globalState: GlobalState

    @State private var email: String
    @State private var password: String
    @State private var confirmPassword: String
    @State private var name = ""
    @State private var verificationCode = ""
    @State private var sentVerificationCode = ""
    @State private var notice = ""
    @State private var isSubmitting = false

    init(prefilledEmail: String = "", prefilledPassword: String = "") {
        _email = State(initialValue: prefilledEmail)
        _password = State(initialValue: prefilledPassword)
        _confirmPassword = State(initialValue: prefilledPassword)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#63C9F2"),
                    Color(hex: "#75B992")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack {
                    Spacer(minLength: 32)

                    VStack(spacing: 0) {
                        SignupTopIllustration()

                        Text("회원가입")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color(hex: "#1F2937"))
                            .padding(.top, 24)

                        Text("계정을 만들고 서비스를 이용해 보세요")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(Color(hex: "#6B7280"))
                            .padding(.top, 10)

                        VStack(spacing: 14) {
                            SignupInputField(
                                placeholder: "이름",
                                text: $name
                            )

                            SignupInputField(
                                placeholder: "이메일",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                            SignupSecureInputField(
                                placeholder: "비밀번호",
                                text: $password
                            )

                            SignupSecureInputField(
                                placeholder: "비밀번호 확인",
                                text: $confirmPassword
                            )

                            Text("비밀번호는 8자 이상, 영문과 숫자를 모두 포함해야 합니다.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            HStack(spacing: 10) {
                                SignupInputField(
                                    placeholder: "인증 코드",
                                    text: $verificationCode,
                                    keyboardType: .numberPad
                                )

                                Button("인증 요청") {
                                    sendVerificationCode()
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: 104, height: 58)
                                .background(Color.orange)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            }
                        }
                        .padding(.top, 32)

                        if !notice.isEmpty {
                            Text(notice)
                                .font(.footnote)
                                .foregroundStyle(noticeColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 14)
                        }

                        Button {
                            Task {
                                await signup()
                            }
                        } label: {
                            Text(isSubmitting ? "회원가입 중..." : "회원가입 완료")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color.blue.opacity(0.95),
                                            Color.blue.opacity(0.85)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
                        }
                        .disabled(isSubmitting)
                        .padding(.top, 24)

                        Divider()
                            .padding(.top, 28)

                        HStack(spacing: 6) {
                            Text("이미 계정이 있으신가요?")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(Color(hex: "#6B7280"))

                            Button("로그인") {
                                dismiss()
                            }
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.blue)
                        }
                        .padding(.top, 22)
                        .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 30)
                    .frame(maxWidth: 390)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 42, style: .continuous))
                    .shadow(color: .black.opacity(0.14), radius: 24, x: 0, y: 14)
                    .padding(.horizontal, 24)

                    Spacer(minLength: 32)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var noticeColor: Color {
        notice.contains("전송") ? .secondary : .red
    }

    private func sendVerificationCode() {
        let normalized = normalizedEmail(email)

        guard isValidEmail(normalized) else {
            notice = "이메일 형식을 확인해 주세요."
            return
        }

        guard isValidSignupPassword(password) else {
            notice = "비밀번호는 8자 이상이며 영문과 숫자를 모두 포함해야 합니다."
            return
        }

        guard password == confirmPassword else {
            notice = "비밀번호가 일치하지 않습니다."
            return
        }

        email = normalized
        sentVerificationCode = String(format: "%06d", Int.random(in: 0...999999))
        notice = "\(normalized)로 인증 코드를 전송했습니다. 개발용 코드: \(sentVerificationCode)"
    }

    @MainActor
    private func signup() async {
        let normalized = normalizedEmail(email)
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard isValidEmail(normalized) else {
            notice = "이메일 형식을 확인해 주세요."
            return
        }

        guard isValidSignupPassword(password) else {
            notice = "비밀번호는 8자 이상이며 영문과 숫자를 모두 포함해야 합니다."
            return
        }

        guard password == confirmPassword else {
            notice = "비밀번호가 일치하지 않습니다."
            return
        }

        guard !sentVerificationCode.isEmpty else {
            notice = "먼저 인증 요청을 진행해 주세요."
            return
        }

        guard verificationCode == sentVerificationCode else {
            notice = "인증 코드가 일치하지 않습니다."
            return
        }

        isSubmitting = true
        notice = ""

        do {
            _ = try await AuthAPI.signup(
                email: normalized,
                password: password,
                name: trimmedName
            )
            let response = try await AuthAPI.login(email: normalized, password: password)
            globalState.login(email: response.userEmail)
        } catch {
            notice = error.localizedDescription
        }

        isSubmitting = false
    }
}

private struct SignupInputField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(Color(hex: "#1F2937"))
            .padding(.horizontal, 20)
            .frame(height: 58)
            .background(Color(hex: "#F6F8FA"))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.black.opacity(0.03), lineWidth: 1)
            )
    }
}

private struct SignupSecureInputField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        SecureField(placeholder, text: $text)
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(Color(hex: "#1F2937"))
            .padding(.horizontal, 20)
            .frame(height: 58)
            .background(Color(hex: "#F6F8FA"))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.black.opacity(0.03), lineWidth: 1)
            )
    }
}

private struct SignupTopIllustration: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#EAF4FB"))
                .frame(width: 180, height: 180)

            VStack(spacing: 10) {
                HStack(spacing: 18) {
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.blue.opacity(0.9))
                            .frame(width: 42, height: 52)
                            .overlay(
                                Text("P")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            )

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green.opacity(0.75))
                            .frame(width: 50, height: 8)
                    }

                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.9))
                            .frame(width: 42, height: 42)

                        Circle()
                            .fill(Color.white)
                            .frame(width: 14, height: 14)
                    }

                    VStack(spacing: 6) {
                        Circle()
                            .fill(Color.green.opacity(0.8))
                            .frame(width: 34, height: 34)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green.opacity(0.75))
                            .frame(width: 10, height: 28)
                    }
                }

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.green.opacity(0.22))
                    .frame(width: 140, height: 16)
            }
        }
        .frame(height: 170)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 8:
            (a, r, g, b) = (
                (int >> 24) & 0xff,
                (int >> 16) & 0xff,
                (int >> 8) & 0xff,
                int & 0xff
            )
        case 6:
            (a, r, g, b) = (
                255,
                (int >> 16) & 0xff,
                (int >> 8) & 0xff,
                int & 0xff
            )
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    SignupView()
        .environmentObject(GlobalState())
}
