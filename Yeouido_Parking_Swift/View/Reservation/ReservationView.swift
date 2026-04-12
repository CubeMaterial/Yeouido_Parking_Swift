import SwiftUI

struct ReservationView: View {
    
    @StateObject private var vm = FacilityViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if vm.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(vm.facilities) { facility in
                                NavigationLink {
                                    ReservationFormView(facility: facility)
                                } label: {
                                    FacilityCardView(facility: facility)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("예약하기")
            .task {
                await vm.fetchReservableFacilities()
            }
        }
    }
}
