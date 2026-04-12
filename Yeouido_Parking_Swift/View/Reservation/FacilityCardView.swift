//
//  FacilityCardView.swift
//  Yeouido_Parking_Swift
//
//  Created by 유다원 on 4/12/26.
//

import SwiftUI

struct FacilityCardView: View {
    
    let facility: Facility
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // 이미지
            AsyncImage(url: URL(string: facility.image ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(height: 160)
            .clipped()
            .cornerRadius(12)
            
            // 텍스트 영역
            VStack(alignment: .leading, spacing: 6) {
                Text(facility.name)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(facility.info ?? "시설 설명 없음")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 3)
    }
}
