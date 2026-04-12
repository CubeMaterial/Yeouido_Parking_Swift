//
//  ReservationListView.swift
//  Yeouido_Parking_Swift
//
//  Created by 유다원 on 4/12/26.
//

import SwiftUI

struct ReservationListView: View {
    
    @EnvironmentObject private var globalState: GlobalState
    @StateObject private var vm = ReservationViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView()
                } else if vm.reservations.isEmpty {
                    VStack {
                        Spacer()
                        Text("예약 내역이 없습니다.")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    List(vm.reservations) { reservation in
                        NavigationLink {
                            ReservationDetailView(reservationId: reservation.id)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("예약번호 \(reservation.id)")
                                    .font(.headline)
                                
                                Text("\(reservation.startDate)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text(stateText(reservation.state))
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("예약 내역")
            .task {
                await vm.fetchReservations(userId: globalState.currentUserId)
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
