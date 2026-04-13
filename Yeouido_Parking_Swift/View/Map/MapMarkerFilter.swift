//
//  MapMarkerFilter.swift
//  Yeouido_Parking_Swift
//

import Foundation
import SwiftUI

enum MapMarkerFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case parking = "주차장"
    case reservableFacility = "예약 시설"
    case otherFacility = "그 외"

    var id: String { rawValue }

    var accentColor: Color {
        switch self {
        case .all:
            return Color.green
        case .parking:
            return Color.red
        case .reservableFacility:
            return Color.orange
        case .otherFacility:
            return Color(hex: "63C9F2")
        }
    }
}
