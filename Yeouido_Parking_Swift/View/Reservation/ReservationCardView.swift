//
//  ReservationCardView.swift
//  Yeouido_Parking_Swift
//
//  Created by 유다원 on 4/13/26.
//

import SwiftUI

struct ReservationCardView: View {
    
    let reservation: Reservation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("예약번호 \(reservation.id)")
                .font(.headline)
            
            Text("시작: \(reservation.startDate)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("종료: \(reservation.endDate)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(stateText(reservation.state))
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(radius: 3)
    }
    
    private func stateText(_ state: Int) -> String {
        switch state {
        case 0: return "취소"
        case 1: return "완료"
        default: return "알 수 없음"
        }
    }
}
