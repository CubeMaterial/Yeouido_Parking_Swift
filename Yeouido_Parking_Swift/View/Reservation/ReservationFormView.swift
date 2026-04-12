//
//  ReservationFormView.swift
//  Yeouido_Parking_Swift
//
//  Created by 유다원 on 4/12/26.
//

import SwiftUI

struct ReservationFormView: View {
    
    let facility: Facility
    
    @StateObject private var vm = ReservationViewModel()
    
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(60 * 60)
    @State private var goToDetail = false
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(facility.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(facility.info ?? "시설 설명 없음")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            DatePicker("시작 일시", selection: $startDate)
                .datePickerStyle(.compact)
            
            DatePicker("종료 일시", selection: $endDate)
                .datePickerStyle(.compact)
            
            Button {
                Task {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    let startString = formatter.string(from: startDate)
                    let endString = formatter.string(from: endDate)
                    
                    let result = await vm.createReservation(
                        userId: 1,
                        facilityId: facility.id,
                        startDate: startString,
                        endDate: endString
                    )
                    
                    if result != nil {
                        goToDetail = true
                    }
                }
            } label: {
                Text("예약하기")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("예약하기")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $goToDetail) {
            if let created = vm.createdReservation {
                ReservationDetailView(reservationId: created.id)
            } else {
                EmptyView()
            }
        }
    }
}
