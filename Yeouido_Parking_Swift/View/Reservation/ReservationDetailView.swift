//
//  ReservationDetailView.swift
//  Yeouido_Parking_Swift
//
//  Created by 유다원 on 4/12/26.
//

import SwiftUI

struct ReservationDetailView: View {
    
    let reservationId: Int
    @StateObject private var vm = ReservationViewModel()
    
    var body: some View {
        ZStack{
            LinearGradient(
                colors: [
                    Color(hex: "63C9F2"),
                    Color(hex: "75B992")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            Group {
                if vm.isLoading {
                    ProgressView()
                } else if let detail = vm.reservationDetail {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("시설 이용 내역 상세")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text(stateText(detail.state))
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.15))
                                .foregroundColor(.blue)
                                .cornerRadius(20)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text(detail.facilityName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(detail.facilityInfo ?? "시설 설명 없음")
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("예약번호: \(detail.id)")
                                Text("시작: \(detail.startDate)")
                                Text("종료: \(detail.endDate)")
                                Text("예약일: \(detail.reservationDate)")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.08))
                            .cornerRadius(12)
                        }
                        .padding()
                    }
                } else {
                    Text("상세 정보를 불러오지 못했습니다.")
                }
            }
            .navigationTitle("예약 상세")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await vm.fetchReservationDetail(reservationId: reservationId)
            }
        }
    }
    
    private func stateText(_ state: Int) -> String {
        switch state {
        case 0: return "취소"
        case 1: return "완료"
        default: return "알 수 없음"
        }
    }
}
