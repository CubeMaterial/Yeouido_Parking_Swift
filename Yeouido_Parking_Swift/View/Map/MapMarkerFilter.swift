//
//  MapMarkerFilter.swift
//  Yeouido_Parking_Swift
//

import Foundation

enum MapMarkerFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case parking = "주차장"
    case reservableFacility = "예약 시설"
    case otherFacility = "그 외"

    var id: String { rawValue }
}
