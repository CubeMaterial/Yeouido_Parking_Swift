//
//  NotificationOverlayView.swift
//  Yeouido_Parking_Swift
//
//  Created by Codex on 8/18/25.
//

import SwiftUI

struct NotificationOverlayView: View {
    @Binding var isPresented: Bool

    let notifications: [String]

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    Text("알림")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.black)

                    if notifications.isEmpty {
                        VStack(spacing: 14) {
                            Image(systemName: "bell.slash")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundStyle(.gray)

                            Text("알림 내용이 없습니다.")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.black.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 36)
                    } else {
                        ForEach(notifications, id: \.self) { notification in
                            Text(notification)
                                .font(.system(size: 16))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(Color.black.opacity(0.04))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
            }
            .frame(maxWidth: .infinity)
            .frame(height: min(340, geometry.size.height * 0.38), alignment: .top)
            .background(
                Color.white
                    .ignoresSafeArea(edges: .top)
            )
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 24,
                    bottomTrailingRadius: 24,
                    topTrailingRadius: 0
                )
            )
            .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private var header: some View {
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
        .frame(height: 44)
    }
}

#Preview {
    NotificationOverlayView(
        isPresented: .constant(true),
        notifications: []
    )
}
