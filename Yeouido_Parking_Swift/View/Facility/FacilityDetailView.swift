//
//  FacilityDetailView.swift
//  Yeouido_Parking_Swift
//
//  Created by 유다원 on 4/12/26.
//

import SwiftUI

struct FacilityDetailView: View {
    
    let facility: Facility
    
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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 이미지
                    if let urlString = facility.image,
                       let url = URL(string: urlString) {
                        
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 220)
                                
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 220)
                                    .clipped()
                                
                            case .failure:
                                Color.gray.opacity(0.3)
                                    .frame(height: 220)
                                
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text(facility.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Divider()
                        
                        Text("시설 정보")
                            .font(.headline)
                        
                        Text(facility.info ?? "시설 정보가 없습니다.")
                            .foregroundColor(.black)
                        
                        Divider()
                        
                        Text("위치")
                            .font(.headline)
                        
                        MiniMapView(
                            lat: facility.lat,
                            long: facility.long
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("시설 상세")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
