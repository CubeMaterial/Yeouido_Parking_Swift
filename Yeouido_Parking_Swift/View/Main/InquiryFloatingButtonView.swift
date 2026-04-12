//
//  InquiryFloatingButtonView.swift
//  Yeouido_Parking_Swift
//
//  Created by Codex on 8/18/25.
//

import SwiftUI

struct InquiryFloatingButtonView: View {
    @Binding var isExpanded: Bool
    let isCompact: Bool
    let onCallTap: () -> Void
    let onChatTap: () -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            if isExpanded {
                FloatingActionItem(
                    title: "채팅문의",
                    systemName: "message.fill",
                    backgroundColor: Color(hex: "63C9F2"),
                    action: onChatTap
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))

                FloatingActionItem(
                    title: "전화하기",
                    systemName: "phone.fill",
                    backgroundColor: Color(hex: "75B992"),
                    action: onCallTap
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }

            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
                    isExpanded.toggle()
                }
            } label: {
                Group {
                    if isCompact {
                        VStack(spacing: 4) {
                            Image(systemName: isExpanded ? "xmark" : "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 17, weight: .bold))

                            Text("문의")
                                .font(.system(size: 14, weight: .bold))

                            Text("하기")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 72)
                        .background(Color(hex: "ED9781"))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .black.opacity(0.16), radius: 14, y: 8)
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: isExpanded ? "xmark" : "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 16, weight: .bold))

                            Text("문의하기")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .frame(height: 54)
                        .background(Color(hex: "ED9781"))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.16), radius: 14, y: 8)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}

private struct FloatingActionItem: View {
    let title: String
    let systemName: String
    let backgroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemName)
                    .font(.system(size: 14, weight: .bold))

                Text(title)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .frame(height: 46)
            .background(backgroundColor)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.12), radius: 10, y: 6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack(alignment: .bottomTrailing) {
        Color.white.ignoresSafeArea()

        InquiryFloatingButtonView(
            isExpanded: .constant(true),
            isCompact: false,
            onCallTap: {},
            onChatTap: {}
        )
        .padding(20)
    }
}
