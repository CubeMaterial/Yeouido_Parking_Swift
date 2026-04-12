//
//  FacilityMarker.swift
//  Yeouido_Parking_Swift
//

import SwiftUI

struct FacilityMarker: View {
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
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? Color.teal : Color.white.opacity(0.96))
                    .frame(width: isSelected ? 34 : 30, height: isSelected ? 34 : 30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(isSelected ? Color.teal : Color.black.opacity(0.16), lineWidth: 1.5)
                    )

                Image(systemName: "building.2.fill")
                    .font(.system(size: isSelected ? 15 : 13, weight: .bold))
                    .foregroundStyle(isSelected ? .white : Color.teal)
            }
            .shadow(color: .black.opacity(0.14), radius: 8, y: 4)

            Rectangle()
                .fill(isSelected ? Color.teal : Color.black.opacity(0.25))
                .frame(width: 2, height: isSelected ? 12 : 10)
        }
    }
}
