//
//  MapFilterBar.swift
//  Yeouido_Parking_Swift
//

import SwiftUI

struct MapFilterBar: View {
    let selectedParkingSpot: ParkingSpot?
    let onFilterTap: () -> Void
    let onSelectedSpotTap: (ParkingSpot) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Button(action: onFilterTap) {
                    HStack(spacing: 8) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 17, weight: .semibold))
                        Text("필터")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, 18)
                    .frame(height: 48)
                    .background(Color.white, in: Capsule())
                }
                .buttonStyle(.plain)
                .shadow(color: .black.opacity(0.08), radius: 10, y: 6)

                if let selectedParkingSpot {
                    Button {
                        onSelectedSpotTap(selectedParkingSpot)
                    } label: {
                        HStack(spacing: 6) {
                            Text("주차장")
                                .font(.system(size: 14, weight: .bold))
                            Text(selectedParkingSpot.name)
                                .font(.system(size: 15, weight: .semibold))
                                .lineLimit(1)
                        }
                        .foregroundStyle(Color.red)
                        .padding(.horizontal, 18)
                        .frame(height: 48)
                        .background(Color.white, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .shadow(color: .black.opacity(0.08), radius: 10, y: 6)
                }
            }
            .padding(.vertical, 2)
        }
    }
}
