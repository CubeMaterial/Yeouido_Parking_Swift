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
                                    
                                    ReservationCardView(
                                        reservation: reservation,
                                        onCancel: { id in
                                            cancelReservation(id)
                                        }
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity) // 🔥 핵심
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 30)
                        }
                        .background(Color.clear)
                    }
                }
            }
            .navigationTitle("예약 내역")
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .task {
            guard let userID = globalState.currentUserID else { return }
            await vm.fetchReservations(userId: userID)
        }
    }
    
    private func cancelReservation(_ reservationId: Int) {
        Task {
            await vm.cancelReservation(reservationId: reservationId)
            guard let userID = globalState.currentUserID else { return }
            await vm.fetchReservations(userId: userID)
        }
    }
}
