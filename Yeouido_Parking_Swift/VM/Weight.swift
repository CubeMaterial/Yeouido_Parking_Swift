//
//  Weight.swift
//  Yeouido_Parking_Swift
//
//  Created by Restitutor on 4/12/26.
//

import Foundation

let hours = (7...22).map { String(format: "%02d", $0) }

struct TrafficRow {
    let date: Date
    let traffic: [String: Double] // keys: "07"..."22"
}

func isoWeekday(_ date: Date, calendar: Calendar = .current) -> Int {
    let w = calendar.component(.weekday, from: date) // Sun=1...Sat=7
    return w == 1 ? 7 : w - 1                  // Mon=1...Sun=7
}

func median(_ values: [Double]) -> Double {
    let s = values.sorted()
    let m = s.count / 2
    return s.count.isMultiple(of: 2) ? (s[m - 1] + s[m]) / 2 : s[m]
}

// Preprocess: 2025 traffic -> weekday/hour weights
func buildWeekdayWeights(_ rows: [TrafficRow], calendar: Calendar = .current) -> [Int: [String: Double]] {
    var buckets = [Int: [String: [Double]]]()

    for row in rows where calendar.component(.year, from: row.date) == 2025 {
        let day = isoWeekday(row.date, calendar: calendar)
        for h in hours {
            if let v = row.traffic[h] {
                buckets[day, default: [:]][h, default: []].append(v)
            }
        }
    }

    var result = [Int: [String: Double]]()
    for day in 1...7 {
        guard let byHour = buckets[day],
              hours.allSatisfy({ !(byHour[$0]?.isEmpty ?? true) }) else { continue }

        let med = Dictionary(uniqueKeysWithValues: hours.map { ($0, median(byHour[$0]!)) })
        let minV = med.values.min()!
        let maxV = med.values.max()!

        let scaled = Dictionary(uniqueKeysWithValues: hours.map { h in
            (h, maxV == minV ? 1.0 : (med[h]! - minV) / (maxV - minV))
        })

        let sum = scaled.values.reduce(0, +)
        result[day] = Dictionary(uniqueKeysWithValues: hours.map { h in
            (h, sum > 0 ? scaled[h]! / sum : 1.0 / Double(hours.count))
        })
    }
    return result
}

// Runtime: one anchor count -> all hours
func estimateParking(
    target: [String: Int],
    maxCapacity: Int,
    weekday: Int,
    weightsByWeekday: [Int: [String: Double]]
) -> [String: Int] {
    let eps = 1e-9
    guard let anchor = target.first,
          hours.contains(anchor.key),
          let weights = weightsByWeekday[weekday] else { return [:] }

    let anchorWeight = Swift.max(weights[anchor.key] ?? 0, eps)

    return Dictionary(uniqueKeysWithValues: hours.map { h in
        let raw = Double(anchor.value) * Swift.max(weights[h] ?? 0, eps) / anchorWeight
        let clamped = Swift.min(Double(maxCapacity), Swift.max(0, raw))
        return (h, Int(clamped.rounded()))
    })
}

// Example
//let weightsByWeekday = buildWeekdayWeights(rows2025)
//let result = estimateParking(
//    target: ["13": 125],
//    maxCapacity: 670,
//    weekday: 1, // Monday
//    weightsByWeekday: weightsByWeekday
//)
