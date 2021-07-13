//
//  HeartRate.swift
//  HealthApp
//
//  Created by Ko Sakuma on 28/06/2021.
//

import Foundation
import HealthKit

struct HeartRate: Identifiable, Codable {
    var id = UUID()
    let count: Int
    let date: Date
}

extension HeartRate {

    init?(sample: HKSample) {
        if let heartRateSample = sample as? HKQuantitySample {
            let bpm = Int(heartRateSample.quantity.doubleValue(for: .heartRate))
            self.init(count: bpm, date: heartRateSample.startDate)
        } else {
            return nil
        }
    }

}

extension HKUnit {

    static let heartRate = HKUnit(from: "count/min")

}
