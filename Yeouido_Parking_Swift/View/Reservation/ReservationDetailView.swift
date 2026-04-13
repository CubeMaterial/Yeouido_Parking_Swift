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
    @State private var goToMain = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "63C9F2"),
                    Color(hex: "75B992")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 18) {
                    
                    if vm.isLoading {
                        VStack {
                            Spacer().frame(height: 120)
                            ProgressView()
                            Spacer()
                        }
                    } else if let detail = vm.reservationDetail {
                        
                        // 상단 타이틀 카드
                        VStack(alignment: .leading, spacing: 12) {
                            Text("시설 이용 내역 상세")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Text(stateText(detail.state))
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(statusBackgroundColor(detail.state))
                                .foregroundColor(statusTextColor(detail.state))
                                .cornerRadius(20)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color.white.opacity(0.88))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                        
                        // 시설 정보 카드
                        VStack(alignment: .leading, spacing: 14) {
                            Text(detail.facilityName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("시설 정보")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Text(detail.facilityInfo ?? "시설 설명 없음")
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.75))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color.white.opacity(0.88))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                        
                        // 예약 정보 카드
                        VStack(alignment: .leading, spacing: 14) {
                            Label("예약 정보", systemImage: "doc.text.fill")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            detailRow(title: "예약번호", value: "\(detail.id)")
                            detailRow(title: "시작", value: detail.startDate)
                            detailRow(title: "종료", value: detail.endDate)
                            detailRow(title: "예약일", value: detail.reservationDate)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color.white.opacity(0.88))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                        
                        // 메인화면 버튼
                        Button {
                            goToMain = true
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "house.fill")
                                Text("메인화면으로")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding(.vertical, 16)
                            .background(Color(hex: "ED9781"))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 50)
                    } else {
                        VStack {
                            Spacer().frame(height: 120)
                            Text("상세 정보를 불러오지 못했습니다.")
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 30)
            }
            .navigationTitle("예약 상세")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await vm.fetchReservationDetail(reservationId: reservationId)
            }
            .navigationDestination(isPresented: $goToMain) {
                MainView()
            }
        }
    }
    
    @ViewBuilder
    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.black.opacity(0.55))
            
            Text(value)
                .font(.body)
                .foregroundColor(.black)
        }
    }
    
    private func stateText(_ state: Int) -> String {
        switch state {
        case 0: return "취소"
        case 1: return "완료"
        default: return "알 수 없음"
        }
    }
    
    private func statusBackgroundColor(_ state: Int) -> Color {
        switch state {
        case 0:
            return Color.red.opacity(0.15)
        case 1:
            return Color.blue.opacity(0.15)
        default:
            return Color.gray.opacity(0.15)
        }
    }
    
    private func statusTextColor(_ state: Int) -> Color {
        switch state {
        case 0:
            return .red
        case 1:
            return .blue
        default:
            return .gray
        }
    }
}
