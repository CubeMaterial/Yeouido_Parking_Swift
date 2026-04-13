//
//  ReservationCardView.swift
//  Yeouido_Parking_Swift
//
//  Created by 유다원 on 4/13/26.
//

import SwiftUI

struct ReservationCardView: View {
    
    let reservation: Reservation
    let onCancel: (Int) -> Void
    
    @State private var showAlert = false
    
    var body: some View {
        let state = computedState(reservation)
        
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text("예약번호 \(reservation.id)")
                    .font(.headline)
                
                Spacer()
                
                if state == 1 { // 🔥 예약 중일 때만 버튼
                    Button {
                        showAlert = true
                    } label: {
                        Text("취소")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.15))
                            .foregroundColor(.red)
                            .cornerRadius(10)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("시작: \(reservation.startDate)")
                Text("종료: \(reservation.endDate)")
                
                Text(stateText(state))
                    .font(.caption)
                    .foregroundColor(colorForState(state))
            }
            .font(.subheadline)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 6)
        
        // 🔥 Alert
        .alert("예약 취소", isPresented: $showAlert) {
            Button("취소하기", role: .destructive) {
                onCancel(reservation.id)
            }
            Button("닫기", role: .cancel) { }
        } message: {
            Text("정말 취소하시겠습니까?")
        }
    }
    
    private func computedState(_ reservation: Reservation) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let endDate = formatter.date(from: reservation.endDate) else {
            return reservation.state
        }
        
        if reservation.state == 1 && endDate < Date() {
            return 2
        }
        
        return reservation.state
    }
    
    private func stateText(_ state: Int) -> String {
        switch state {
        case 0: return "예약 취소"
        case 1: return "예약 중"
        case 2: return "이용 완료"
        default: return "알 수 없음"
        }
    }
    
    private func colorForState(_ state: Int) -> Color {
        switch state {
        case 0: return Color(hex: "ED9781")
        case 1: return Color(hex: "63C9F2")
        case 2: return .gray
        default: return .black
        }
    }
}
