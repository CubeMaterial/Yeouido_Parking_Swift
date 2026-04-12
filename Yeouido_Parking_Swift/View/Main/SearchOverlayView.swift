//
//  SearchOverlayView.swift
//  Yeouido_Parking_Swift
//
//  Created by Codex on 8/18/25.
//

import SwiftUI

struct SearchOverlayView: View {
    @Binding var isPresented: Bool
    @State private var searchText = ""

    let recentKeywords: [String]

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                    searchField
                    keywordSection
                    Divider()
                        .padding(.top, 20)
                    recentSearchSection
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
            }
            .frame(maxWidth: .infinity)
            .frame(height: min(360, geometry.size.height * 0.42), alignment: .top)
            .background(
                Color.white
                    .ignoresSafeArea(edges: .top)
            )
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 24,
                    bottomTrailingRadius: 24,
                    topTrailingRadius: 0
                )
            )
            .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private var header: some View {
        HStack {
            Spacer()

            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                    isPresented = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.black)
            }
        }
        .frame(height: 44)
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            TextField("키워드를 입력해 주세요.", text: $searchText)
                .font(.system(size: 16))

            Image(systemName: "magnifyingglass")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color(hex: "4E44FF"))
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(Color.white)
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "4E44FF"), lineWidth: 2)
        }
        .padding(.top, 18)
    }

    private var keywordSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("인기키워드")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)

            HStack(spacing: 10) {
                ForEach(recentKeywords, id: \.self) { keyword in
                    Text(keyword)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .overlay {
                            Capsule()
                                .stroke(Color.black.opacity(0.18), lineWidth: 1)
                        }
                }

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)
    }

    private var recentSearchSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("최근검색")
                    .font(.system(size: 16, weight: .semibold))

                Spacer()

                Button("전체삭제") {}
                    .font(.system(size: 14))
                    .foregroundStyle(.black)
            }

            Text("최근검색어가 없습니다.")
                .font(.system(size: 16))
                .foregroundStyle(.black.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)
    }
}

#Preview {
    SearchOverlayView(
        isPresented: .constant(true),
        recentKeywords: ["어트랙션", "페스티벌"]
    )
}
