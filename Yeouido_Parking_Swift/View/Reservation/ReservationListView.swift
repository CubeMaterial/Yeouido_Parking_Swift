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
            ZStack {
                // 🔥 배경
                LinearGradient(
                    colors: [
                        Color(hex: "63C9F2"),
                        Color(hex: "75B992")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    if vm.isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                        
                    } else if vm.reservations.isEmpty {
                        Spacer()
                        Text("예약 내역이 없습니다.")
                            .foregroundColor(.gray)
                        Spacer()
                        
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(vm.reservations) { reservation in
                                    
                                    NavigationLink {
                                        ReservationDetailView(reservationId: reservation.id)
                                    } label: {
                                        ReservationCardView(reservation: reservation)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding()
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    }
                }
            }
            .navigationTitle("예약 내역")
            
            // 🔥 우상단 취소 버튼
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        cancelLatestReservation()
                    } label: {
                        Text("예약 취소")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }
            }
            
            .toolbarBackground(.hidden, for: .navigationBar)
            .background(Color.clear)
            
            .task {
                guard let userID = globalState.currentUserID else { return }
                await vm.fetchReservations(userId: userID)
            }
        }
    }
    
    // 🔥 간단 예시: 가장 최근 예약 취소
    private func cancelLatestReservation() {
        guard let last = vm.reservations.first else { return }
        
        Task {
            await vm.cancelReservation(reservationId: last.id)
            guard let userID = globalState.currentUserID else { return }
            await vm.fetchReservations(userId: userID)
        }
    }
}
