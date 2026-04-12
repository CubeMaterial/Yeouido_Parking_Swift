//
//  MapFacility.swift
//  Yeouido_Parking_Swift
//

import MapKit
import Foundation

struct MapFacility: Identifiable, Decodable {
    let facilityID: Int
    let latitude: Double
    let longitude: Double
    let name: String
    let info: String?
    let imageURL: String?
    let isReservable: Bool

    var id: Int { facilityID }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    enum CodingKeys: String, CodingKey {
        case facilityID = "f_id"
        case latitude = "f_lat"
        case longitude = "f_long"
        case name = "f_name"
        case info = "f_info"
        case imageURL = "f_image"
        case isReservable = "f_possible"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        facilityID = try Self.decodeInt(for: .facilityID, from: container)
        latitude = try Self.decodeDouble(for: .latitude, from: container)
        longitude = try Self.decodeDouble(for: .longitude, from: container)
        name = try container.decode(String.self, forKey: .name)
        info = try container.decodeIfPresent(String.self, forKey: .info)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        isReservable = try Self.decodeInt(for: .isReservable, from: container) == 1
    }

    private static func decodeInt(
        for key: CodingKeys,
        from container: KeyedDecodingContainer<CodingKeys>
    ) throws -> Int {
        if let intValue = try? container.decode(Int.self, forKey: key) {
            return intValue
        }

        if
            let stringValue = try? container.decode(String.self, forKey: key),
            let intValue = Int(stringValue.trimmingCharacters(in: .whitespacesAndNewlines))
        {
            return intValue
        }

        throw DecodingError.dataCorruptedError(
            forKey: key,
            in: container,
            debugDescription: "Expected Int-compatible value."
        )
    }

    private static func decodeDouble(
        for key: CodingKeys,
        from container: KeyedDecodingContainer<CodingKeys>
    ) throws -> Double {
        if let doubleValue = try? container.decode(Double.self, forKey: key) {
            return doubleValue
        }

        if let intValue = try? container.decode(Int.self, forKey: key) {
            return Double(intValue)
        }

        if
            let stringValue = try? container.decode(String.self, forKey: key),
            let doubleValue = Double(stringValue.trimmingCharacters(in: .whitespacesAndNewlines))
        {
            return doubleValue
        }

        throw DecodingError.dataCorruptedError(
            forKey: key,
            in: container,
            debugDescription: "Expected Double-compatible value."
        )
    }
}
