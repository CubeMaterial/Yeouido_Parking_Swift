//
//  Reservation.swift
//  Yeouido_Parking_Swift
//
//  Created by 유다원 on 4/10/26.
//

import SwiftUI

struct ReservationView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 48))
                    .foregroundStyle(.orange)

                Text("예약 화면")
                    .font(.title.bold())

                Text("주차 예약 내역과 예약 기능이 들어갈 화면입니다.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("예약")
        }
    }
}

#Preview {
    ReservationView()
}
