//
//  ParkingMarker.swift
//  Yeouido_Parking_Swift
//

import SwiftUI

struct ParkingMarker: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            if isSelected {
                Text(title)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white, in: Capsule())
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 4)
            }

            ZStack {
                Circle()
                    .stroke(isSelected ? Color.red : Color.black.opacity(0.55), lineWidth: isSelected ? 5 : 3)
                    .frame(width: isSelected ? 30 : 24, height: isSelected ? 30 : 24)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.95))
                    )

                Circle()
                    .fill(isSelected ? Color.red : Color.black.opacity(0.78))
                    .frame(width: isSelected ? 12 : 9, height: isSelected ? 12 : 9)
            }
            .shadow(color: .black.opacity(0.16), radius: 8, y: 4)

            Rectangle()
                .fill(isSelected ? Color.red : Color.black.opacity(0.6))
                .frame(width: 2.5, height: isSelected ? 18 : 14)

            Circle()
                .fill(isSelected ? Color.red.opacity(0.2) : Color.black.opacity(0.14))
                .frame(width: isSelected ? 10 : 8, height: isSelected ? 10 : 8)
                .blur(radius: 1)
                .offset(y: -2)
        }
    }
}
