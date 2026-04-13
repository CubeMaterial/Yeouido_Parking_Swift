//
//  Facility.swift
//  Yeouido_Parking_Swift
//
//  Created by Codex on 8/18/25.
//

import SwiftUI

struct FacilityView: View {
    private enum FacilityFilter: String, CaseIterable, Identifiable {
        case all = "전체"
        case reservable = "예약 가능"
        case favorite = "즐겨찾기"

        var id: String { rawValue }
    }

    @EnvironmentObject private var globalState: GlobalState
    @StateObject private var vm = FacilityViewModel()
    @State private var searchText = ""
    @State private var selectedFilter: FacilityFilter = .all

    private var filteredFacilities: [Facility] {
        let baseFacilities: [Facility]

        switch selectedFilter {
        case .all:
            baseFacilities = vm.facilities
        case .reservable:
            baseFacilities = vm.facilities.filter { $0.possible > 0 }
        case .favorite:
            baseFacilities = vm.facilities.filter { globalState.favoriteFacilityIDs.contains($0.id) }
        }

        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return baseFacilities
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return baseFacilities.filter { facility in
            facility.name.localizedCaseInsensitiveContains(query) ||
            (facility.info?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }

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
                
                VStack(spacing: 16) {
                    filterHeader

                    if vm.isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                if filteredFacilities.isEmpty {
                                    FacilityEmptyStateView(
                                        isSearching: !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedFilter != .all
                                    )
                                    .padding(.top, 48)
                                } else {
                                    ForEach(filteredFacilities) { facility in
                                        NavigationLink {
                                            FacilityDetailView(facility: facility)
                                        } label: {
                                            FacilityCardView(
                                                facility: facility,
                                                isFavorite: globalState.isFavoriteFacility(facility.id),
                                                onFavoriteTap: {
                                                    globalState.toggleFavoriteFacility(facility.id)
                                                }
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
                .navigationTitle("시설 목록")
                .task {
                    await vm.fetchFacilities()
                }
            }
        }
    }

    private var filterHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(hex: "167A8C"))

                TextField("시설명 또는 설명 검색", text: $searchText)
                    .font(.system(size: 15))
                    .textInputAutocapitalization(.never)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(Color.white.opacity(0.94))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(FacilityFilter.allCases) { filter in
                        Button {
                            selectedFilter = filter
                        } label: {
                            Text(filter.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(selectedFilter == filter ? .white : Color(hex: "1F3F38"))
                                .padding(.horizontal, 14)
                                .frame(height: 34)
                                .background(
                                    Group {
                                        if selectedFilter == filter {
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "63C9F2"),
                                                    Color(hex: "75B992")
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        } else {
                                            Color.white.opacity(0.9)
                                        }
                                    }
                                )
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
}

private struct FacilityEmptyStateView: View {
    let isSearching: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: isSearching ? "magnifyingglass.circle" : "building.2.crop.circle")
                .font(.system(size: 42))
                .foregroundStyle(Color.white.opacity(0.95))

            Text(isSearching ? "조건에 맞는 시설이 없습니다" : "등록된 시설이 없습니다")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            Text(isSearching ? "검색어나 필터를 바꿔 다시 확인해 주세요." : "잠시 후 다시 시도해 주세요.")
                .font(.system(size: 14))
                .foregroundStyle(Color.white.opacity(0.82))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }
}
