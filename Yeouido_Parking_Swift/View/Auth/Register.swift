//
//  Register.swift
//  Yeouido_Parking_Swift
//
//  Created by Restitutor on 4/12/26.
//

import SwiftUI

struct SignupView: View {
    @State private var emailOrId: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var phoneNumber: String = ""
    
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
            
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    topIllustration
                    
                    Text("회원가입")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color(hex: "#1F2937"))
                        .padding(.top, 24)
                    
                    Text("계정을 만들고 서비스를 이용해 보세요")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color(hex: "#6B7280"))
                        .padding(.top, 10)
                    
                    VStack(spacing: 14) {
                        RoundedInputField(
                            placeholder: "아이디 또는 이메일",
                            text: $emailOrId
                        )
                        
                        SecureRoundedInputField(
                            placeholder: "비밀번호",
                            text: $password
                        )
                        
                        SecureRoundedInputField(
                            placeholder: "비밀번호 확인",
                            text: $confirmPassword
                        )
                        
                        RoundedInputField(
                            placeholder: "휴대폰 번호",
                            text: $phoneNumber
                        )
                    }
                    .padding(.top, 32)
                    
                    Button(action: {
                        // 회원가입 액션
                    }) {
                        Text("회원가입")
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
                    .padding(.top, 24)
                    
                    Divider()
                        .padding(.top, 28)
                    
                    HStack(spacing: 6) {
                        Text("이미 계정이 있으신가요?")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(Color(hex: "#6B7280"))
                        
                        Button(action: {
                            // 로그인 화면 이동
                        }) {
                            Text("로그인")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.blue)
                        }
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
                
                Spacer()
            }
        }
    }
    
    private var topIllustration: some View {
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

struct RoundedInputField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
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

struct SecureRoundedInputField: View {
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
}
