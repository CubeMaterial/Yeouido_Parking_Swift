import Foundation
import SwiftUI

enum AuthAPIError: LocalizedError {
    case notRegistered(String)
    case message(String)
    case invalidResponse
    case connection

    var errorDescription: String? {
        switch self {
        case .notRegistered(let message):
            return message
        case .message(let message):
            return message
        case .invalidResponse:
            return "서버 응답을 확인할 수 없습니다."
        case .connection:
            return "FastAPI 서버에 연결할 수 없습니다. 서버 실행과 주소를 확인해 주세요."
        }
    }
}

enum AuthAPI {
    static let baseURL = URL(string: "http://127.0.0.1:8000")!

    struct LoginRequest: Encodable {
        let user_email: String
        let user_password: String
    }

    struct SignupRequest: Encodable {
        let user_email: String
        let user_password: String
        let user_name: String?
    }

    struct LoginResponse: Decodable {
        let status: String
        let userID: Int
        let userEmail: String
        let userName: String?
        let userDate: String?

        enum CodingKeys: String, CodingKey {
            case status
            case userID = "user_id"
            case userEmail = "user_email"
            case userName = "user_name"
            case userDate = "user_date"
        }
    }

    struct SignupResponse: Decodable {
        let status: String
    }

    private struct APIErrorResponse: Decodable {
        let detail: APIErrorDetail
    }

    private enum APIErrorDetail: Decodable {
        struct ValidationIssue: Decodable {
            let msg: String
        }

        case text(String)
        case validation([ValidationIssue])

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let text = try? container.decode(String.self) {
                self = .text(text)
                return
            }

            if let validation = try? container.decode([ValidationIssue].self) {
                self = .validation(validation)
                return
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported error detail format."
            )
        }

        var message: String {
            switch self {
            case .text(let text):
                return text
            case .validation(let issues):
                return issues.first?.msg ?? "요청 처리에 실패했습니다."
            }
        }
    }

    static func login(email: String, password: String) async throws -> LoginResponse {
        try await request(
            path: "auth/login",
            body: LoginRequest(user_email: email, user_password: password),
            responseType: LoginResponse.self
        )
    }

    static func signup(email: String, password: String, name: String) async throws -> SignupResponse {
        try await request(
            path: "auth/users",
            body: SignupRequest(
                user_email: email,
                user_password: password,
                user_name: name.isEmpty ? nil : name
            ),
            responseType: SignupResponse.self
        )
    }

    private static func request<Body: Encodable, Response: Decodable>(
        path: String,
        body: Body,
        responseType: Response.Type
    ) async throws -> Response {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.timeoutInterval = 5
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AuthAPIError.connection
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthAPIError.invalidResponse
        }

        if (200..<300).contains(httpResponse.statusCode) {
            return try JSONDecoder().decode(responseType, from: data)
        }

        let detail = (try? JSONDecoder().decode(APIErrorResponse.self, from: data).detail.message)
            ?? "요청 처리에 실패했습니다."

        if httpResponse.statusCode == 404 {
            throw AuthAPIError.notRegistered(detail)
        }

        throw AuthAPIError.message(detail)
    }
}

func normalizedEmail(_ value: String) -> String {
    value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
}

func isValidEmail(_ value: String) -> Bool {
    value.range(
        of: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$",
        options: .regularExpression
    ) != nil
}

func isValidSignupPassword(_ value: String) -> Bool {
    value.range(
        of: "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d@$!%*#?&]{8,}$",
        options: .regularExpression
    ) != nil
}

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
            globalState.login(email: response.userEmail)
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
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.96, green: 0.98, blue: 1.0))
                .frame(width: 176, height: 112)

            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    HStack(alignment: .bottom, spacing: 10) {
                        VStack(spacing: 6) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 0.29, green: 0.61, blue: 0.96))
                                    .frame(width: 38, height: 38)

                                Text("P")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                            }

                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.92, green: 0.79, blue: 0.47))
                                .frame(width: 30, height: 5)
                        }

                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(Color(red: 0.96, green: 0.38, blue: 0.34))
                            .offset(y: 6)

                        HStack(alignment: .bottom, spacing: 4) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.78, green: 0.86, blue: 0.93))
                                .frame(width: 22, height: 28)

                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.73, green: 0.82, blue: 0.90))
                                .frame(width: 28, height: 40)
                        }

                        VStack(spacing: 4) {
                            Circle()
                                .fill(Color(red: 0.97, green: 0.78, blue: 0.46))
                                .frame(width: 14, height: 14)

                            Image(systemName: "tree.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(Color(red: 0.37, green: 0.70, blue: 0.43))
                        }
                    }

                    Capsule()
                        .fill(Color(red: 0.59, green: 0.82, blue: 0.49))
                        .frame(width: 150, height: 22)
                }
                .padding(.bottom, 10)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(GlobalState())
    }
}
