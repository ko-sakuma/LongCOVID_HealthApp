
import Foundation

struct HeartRateDateGroup: Identifiable {
    var id = UUID()
    let date: Date
    let heartRates: [HeartRate]
    // let ranges: [HeartRateTimeRange]
}

struct HeartRateTimeRange: Identifiable {
    var id = UUID()
    let minHR: HeartRate
    let maxHR: HeartRate
}
