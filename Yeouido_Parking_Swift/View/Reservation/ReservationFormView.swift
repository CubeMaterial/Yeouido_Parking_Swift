//
//  ReservationFormView.swift
//  Yeouido_Parking_Swift
//
//  Created by 유다원 on 4/12/26.
//

import SwiftUI

struct ReservationFormView: View {
    
    @EnvironmentObject private var globalState: GlobalState
    
    let facility: Facility
    
    @StateObject private var vm = ReservationViewModel()
    
    @State private var selectedDate = Date()
    @State private var selectedStartHour: Int?
    @State private var selectedEndHour: Int?
    @State private var goToDetail = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(facility.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(facility.info ?? "시설 설명 없음")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                DatePicker(
                    "예약 날짜",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .onChange(of: selectedDate) { _, _ in
                    selectedStartHour = nil
                    selectedEndHour = nil
                    Task {
                        await loadDailyReservations()
                    }
                }
                
                HourBlockGridView(
                    selectedDate: selectedDate,
                    reservedHours: vm.reservedHours,
                    selectedStartHour: $selectedStartHour,
                    selectedEndHour: $selectedEndHour
                )
                
                if let start = selectedStartHour {
                    if let end = selectedEndHour {
                        Text("선택 시간: \(String(format: "%02d:00", start)) ~ \(String(format: "%02d:00", end + 1))")
                    } else {
                        Text("시작 시간 선택됨: \(String(format: "%02d:00", start))")
                    }
                }
                
                Button("예약하기") {
                    submitReservation()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("예약하기")
        .task {
            await loadDailyReservations()
        }
        .navigationDestination(isPresented: $goToDetail) {
            if let created = vm.createdReservation {
                ReservationDetailView(reservationId: created.id)
            } else {
                EmptyView()
            }
        }
        .alert("예약 불가", isPresented: $showAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func loadDailyReservations() async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        await vm.fetchDailyReservations(facilityId: facility.id, date: dateString)
    }
    
    private func submitReservation() {
        let now = Date()
        let calendar = Calendar.current
        
        guard let startHour = selectedStartHour, let endHour = selectedEndHour else {
            alertMessage = "시작 시간과 종료 시간을 선택해주세요."
            showAlert = true
            return
        }
        
        guard let startDate = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: selectedDate),
              let endDate = calendar.date(bySettingHour: endHour + 1, minute: 0, second: 0, of: selectedDate) else {
            alertMessage = "시간 계산에 실패했습니다."
            showAlert = true
            return
        }
        
        if startDate <= now {
            alertMessage = "현재 시간 이후만 선택할 수 있습니다."
            showAlert = true
            return
        }
        
        guard let userID = globalState.currentUserID else {
            alertMessage = "로그인 사용자 정보를 확인할 수 없습니다."
            showAlert = true
            return
        }

        Task {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let startString = formatter.string(from: startDate)
            let endString = formatter.string(from: endDate)
            
            let result = await vm.createReservation(
                userId: userID,
                facilityId: facility.id,
                startDate: startString,
                endDate: endString
            )
            
            if result != nil {
                goToDetail = true
            } else {
                alertMessage = vm.errorMessage ?? "예약에 실패했습니다."
                showAlert = true
            }
        }
    }
}
