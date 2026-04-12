//
//  Facility.swift
//  Yeouido_Parking_Swift
//
//  Created by Codex on 8/18/25.
//

import SwiftUI

struct FacilityView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "building.2")
                    .font(.system(size: 48))
                    .foregroundStyle(.teal)

                Text("시설 화면")
                    .font(.title.bold())

                Text("주차장 편의시설 정보가 표시될 화면입니다.")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("시설")
        }
    }
}

#Preview {
    FacilityView()
}
