//
//  Facility.swift
//  Yeouido_Parking_Swift
//
//  Created by Codex on 8/18/25.
//

import SwiftUI

struct FacilityView: View {
    
    @StateObject private var vm = FacilityViewModel()
    
    var body: some View {
        NavigationStack {
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
                                        FacilityDetailView(facility: facility)
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
                .navigationTitle("시설 목록")
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    await vm.fetchFacilities()
                }
            }
        }
    }
}
