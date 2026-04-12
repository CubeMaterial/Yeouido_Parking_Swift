//
//  FacilityMarker.swift
//  Yeouido_Parking_Swift
//

import SwiftUI

struct FacilityMarker: View {
    let title: String
    let isSelected: Bool
    let isReservable: Bool

    var body: some View {
        VStack(spacing: 0) {
            if isSelected {
                HStack(spacing: 6) {
                    if isReservable {
                        badge
                    }

                    Text(title)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.black)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white, in: Capsule())
                .shadow(color: .black.opacity(0.12), radius: 6, y: 4)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(markerBackgroundColor)
                    .frame(width: isSelected ? 42 : 36, height: isSelected ? 42 : 36)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(markerBorderColor, lineWidth: isSelected ? 2 : 1.5)
                    )

                Image(systemName: isReservable ? "ticket.fill" : "mappin.circle.fill")
                    .font(.system(size: isSelected ? 20 : 17, weight: .bold))
                    .foregroundStyle(isSelected ? .white : markerAccentColor)
            }
            .shadow(color: .black.opacity(0.14), radius: 8, y: 4)

            Rectangle()
                .fill(isSelected ? markerAccentColor : Color.black.opacity(0.25))
                .frame(width: 2, height: isSelected ? 12 : 10)
        }
    }

    private var markerAccentColor: Color {
        isReservable ? Color.orange : Color.teal
    }

    private var markerBackgroundColor: Color {
        isSelected ? markerAccentColor : Color.white.opacity(0.96)
    }

    private var markerBorderColor: Color {
        isSelected ? markerAccentColor : Color.black.opacity(0.16)
    }

    private var badge: some View {
        Text("예약시설")
            .font(.caption2.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.orange, in: Capsule())
    }
}
