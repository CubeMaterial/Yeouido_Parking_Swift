//
//  ParkingAvailabilityGridSectionView.swift
//  Yeouido_Parking_Swift
//
//  Created by Codex on 8/18/25.
//

import SwiftUI

struct ParkingAvailabilityGridSectionView: View {
    let parkingLots: [ParkingLot]
    let availability: [String: Int]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("주차장별 잔여 대수")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(parkingLots) { parkingLot in
                    parkingLotCard(for: parkingLot)
                }
            }
        }
    }

    private func parkingLotCard(for parkingLot: ParkingLot) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(parkingLot.name)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black)

            Text("잔여 대수")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.black.opacity(0.48))

            Text(countText(for: parkingLot))
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color(hex: "1C6DD0"))

            Text(parkingLot.address)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.black.opacity(0.52))
                .lineLimit(2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .background(Color.white)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func countText(for parkingLot: ParkingLot) -> String {
        guard let count = availability[parkingLot.name] else {
            return "-"
        }

        return "\(count)대"
    }
}

#Preview {
    ParkingAvailabilityGridSectionView(
        parkingLots: ParkingLot.yeouidoLots,
        availability: [
            "여의도1주차장": 0,
            "여의도2주차장": 0,
            "여의도3주차장": 7,
            "여의도4주차장": 142,
            "여의도5주차장": 156
        ]
    )
    .padding(20)
}
