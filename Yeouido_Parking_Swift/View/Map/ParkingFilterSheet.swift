//
//  ParkingFilterSheet.swift
//  Yeouido_Parking_Swift
//

import SwiftUI

struct ParkingFilterSheet: View {
    @Binding var searchText: String
    @Binding var selectedParkingSpotID: Int?
    @State private var sheetOffset: CGFloat = 0

    let recentParkingSpots: [ParkingSpot]
    let filteredParkingSpots: [ParkingSpot]
    let onClose: () -> Void
    let onFocus: (ParkingSpot) -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Color.black.opacity(0.24)
                    .ignoresSafeArea()
                    .onTapGesture {
                        onClose()
                    }

                VStack(alignment: .leading, spacing: 18) {
                    dragIndicator

                    searchField
                    selectedInfoRow
                    quickFilterRow
                    parkingList
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, max(geometry.safeAreaInsets.bottom, 18))
                .frame(maxWidth: .infinity)
                .frame(height: max(geometry.size.height - 96, 500), alignment: .top)
                .background(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 28,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 28,
                        style: .continuous
                    )
                    .fill(Color.white)
                )
                .offset(y: max(sheetOffset, 0))
                .gesture(sheetDragGesture)
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }

    private var dragIndicator: some View {
        Capsule()
            .fill(Color(.systemGray4))
            .frame(width: 44, height: 5)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(.systemGray2))

            TextField("목적지를 입력해주세요.", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: 16))

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.black.opacity(0.28))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 0.97, green: 0.98, blue: 1.0))
        )
    }

    private var selectedInfoRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                pill(text: "필터", foreground: .black, background: .white)

                if let selectedParkingSpot {
                    pill(
                        text: "주차장 \(selectedParkingSpot.name)",
                        foreground: Color.red,
                        background: .white
                    )
                } else {
                    pill(
                        text: "주차장 선택 전",
                        foreground: Color.black.opacity(0.6),
                        background: Color(red: 0.97, green: 0.97, blue: 0.98)
                    )
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var quickFilterRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("이전 검색 필터")
                .font(.system(size: 15, weight: .bold))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    if recentParkingSpots.isEmpty {
                        Text("아직 선택한 필터가 없습니다.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 2)
                    } else {
                        ForEach(recentParkingSpots) { spot in
                            Button {
                                selectedParkingSpotID = spot.id
                                onFocus(spot)
                            } label: {
                                Text(spot.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(selectedParkingSpotID == spot.id ? .white : .black)
                                    .padding(.horizontal, 14)
                                    .frame(height: 42)
                                    .background(
                                        Capsule()
                                            .fill(
                                                selectedParkingSpotID == spot.id
                                                    ? Color.black
                                                    : Color(red: 0.95, green: 0.95, blue: 0.97)
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var parkingList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("주차장")
                .font(.title3.weight(.bold))

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(filteredParkingSpots) { spot in
                        Button {
                            onFocus(spot)
                            onClose()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("주차장")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.secondary)
                                    Text(spot.name)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(.primary)
                                }

                                Spacer()

                                if selectedParkingSpotID == spot.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.red)
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 62)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color(red: 0.97, green: 0.97, blue: 0.98))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var sheetDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 {
                    sheetOffset = value.translation.height
                } else {
                    sheetOffset = value.translation.height * 0.18
                }
            }
            .onEnded { value in
                if value.translation.height > 120 {
                    onClose()
                } else {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
                        sheetOffset = 0
                    }
                }
            }
    }

    private var selectedParkingSpot: ParkingSpot? {
        recentParkingSpots.first { $0.id == selectedParkingSpotID }
            ?? filteredParkingSpots.first { $0.id == selectedParkingSpotID }
    }

    private func pill(text: String, foreground: Color, background: Color) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 16)
            .frame(height: 42)
            .background(background, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
    }
}
