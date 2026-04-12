//
//  ContentView.swift
//  Yeouido_Parking_Swift
//
//  Created by MAC on 4/8/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var globalState: GlobalState

    var body: some View {
        Group {
            if globalState.userLoginStatus {
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill.badge.checkmark")
                        .font(.system(size: 52))
                        .foregroundStyle(.blue)

                    Text("로그인 완료")
                        .font(.title2.bold())

                    Text(globalState.currentUserEmail)
                        .foregroundStyle(.secondary)

                    Button("로그아웃") {
                        globalState.logout()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else {
                LoginView()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(GlobalState())
    }
}
