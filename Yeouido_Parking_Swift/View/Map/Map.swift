//
//  Map.swift
//  Yeouido_Parking_Swift
//
//  Created by Codex on 8/18/25.
//

import SwiftUI

struct MapView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "map")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)

                Text("지도 화면")
                    .font(.title.bold())

                Text("주차장 위치와 지도가 표시될 화면입니다.")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("지도")
        }
    }
}

#Preview {
    MapView()
}
