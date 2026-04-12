//
//  MenuDrawerView.swift
//  Yeouido_Parking_Swift
//
//  Created by Codex on 8/18/25.
//

import SwiftUI

struct MenuDrawerView: View {
    @Binding var isPresented: Bool
    @Binding var isDarkModeEnabled: Bool

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: 28) {
                    HStack {
                        Spacer()

                        Button {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.black)
                        }
                    }
                    .padding(.top, 12)

                    Text("메뉴")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.black)

                    VStack(spacing: 14) {
                        DrawerMenuButton(
                            title: "고객정보",
                            systemName: "person.text.rectangle"
                        )
                        DrawerMenuButton(
                            title: "예약내역",
                            systemName: "calendar.badge.clock"
                        )

                        HStack(spacing: 14) {
                            Image(systemName: "moon.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(Color(hex: "2F4858"))
                                .frame(width: 22)

                            Text("다크모드 설정")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.black)

                            Spacer()

                            Toggle("", isOn: $isDarkModeEnabled)
                                .labelsHidden()
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 18)
                        .background(Color.white.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .frame(width: min(280, geometry.size.width * 0.74))
                .frame(maxHeight: .infinity)
                .background(Color.white.ignoresSafeArea())
                .shadow(color: .black.opacity(0.14), radius: 18, x: -8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        }
    }
}

private struct DrawerMenuButton: View {
    let title: String
    let systemName: String

    var body: some View {
        Button(action: {}) {
            HStack(spacing: 14) {
                Image(systemName: systemName)
                    .font(.system(size: 18))
                    .foregroundStyle(Color(hex: "2F4858"))
                    .frame(width: 22)

                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(Color.white.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

#Preview {
    MenuDrawerView(
        isPresented: .constant(true),
        isDarkModeEnabled: .constant(false)
    )
}
