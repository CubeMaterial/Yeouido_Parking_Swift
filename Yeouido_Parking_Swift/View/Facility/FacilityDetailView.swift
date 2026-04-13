//
//  FacilityDetailView.swift
//  Yeouido_Parking_Swift
//
//  Created by 유다원 on 4/12/26.
//

import SwiftUI

struct FacilityDetailView: View {
    @EnvironmentObject private var globalState: GlobalState
    let facility: Facility

    private var imageURL: URL? {
        guard let image = facility.image else {
            return nil
        }
        
        return Self.resolvedImageURL(from: image)
    }
    
    var body: some View {
        ZStack {
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
                VStack(spacing: 18) {
                    
                    // 🔥 이미지 카드
                    if let url = imageURL {
                        
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
                        .frame(height: 220)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
                    }
                    
                    // 🔥 시설 정보 카드
                    VStack(alignment: .leading, spacing: 14) {
                        
                        Text(facility.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("시설 정보")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text(facility.info ?? "시설 정보가 없습니다.")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.75))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Color.white.opacity(0.88))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                    
                    // 🔥 위치 카드
                    VStack(alignment: .leading, spacing: 14) {
                        
                        Label("위치", systemImage: "location.fill")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        MiniMapView(
                            lat: facility.lat,
                            long: facility.long
                        )
                        .frame(height: 180)
                        .cornerRadius(14)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Color.white.opacity(0.88))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 30)
            }
            .navigationTitle("시설 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        globalState.toggleFavoriteFacility(facility.id)
                    } label: {
                        Image(systemName: globalState.isFavoriteFacility(facility.id) ? "heart.fill" : "heart")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(globalState.isFavoriteFacility(facility.id) ? Color(hex: "ED9781") : .white)
                    }
                }
            }
        }
    }
}

private extension FacilityDetailView {
    static func resolvedImageURL(from rawValue: String) -> URL? {
        guard let originalURL = URL(string: rawValue) else {
            return nil
        }
        
        if originalURL.host?.contains("drive.google.com") == true,
           let fileID = googleDriveFileID(from: originalURL) {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "drive.google.com"
            components.path = "/uc"
            components.queryItems = [
                URLQueryItem(name: "export", value: "view"),
                URLQueryItem(name: "id", value: fileID)
            ]
            return components.url
        }
        
        return originalURL
    }
    
    static func googleDriveFileID(from url: URL) -> String? {
        let pathComponents = url.pathComponents
        
        if let fileIndex = pathComponents.firstIndex(of: "d"),
           pathComponents.indices.contains(fileIndex + 1) {
            return pathComponents[fileIndex + 1]
        }
        
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let id = components.queryItems?.first(where: { $0.name == "id" })?.value,
           id.isEmpty == false {
            return id
        }
        
        return nil
    }
}
