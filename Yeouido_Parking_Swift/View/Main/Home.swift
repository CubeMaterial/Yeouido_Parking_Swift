//
//  Home.swift
//  Yeouido_Parking_Swift
//
//  Created by Codex on 8/18/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "car.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)

                Text("홈 화면")
                    .font(.title.bold())

                Text("여의도 주차 서비스 메인 화면입니다.")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("홈")
        }
    }
}

#Preview {
    HomeView()
}
