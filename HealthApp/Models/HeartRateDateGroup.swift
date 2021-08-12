
import Foundation

struct HeartRateDateGroup: Identifiable {
    var id = UUID()
    let date: Date
    let heartRates: [HeartRate] // We might want to display all the data at some point
    let ranges: [HeartRateValueRange]
    let maxHR: Int
}

extension HeartRateDateGroup {
    init(date: Date, heartRates: [HeartRate]) {
        let treshold: Int = 40 // BPM difference
        
        var ranges = [HeartRateValueRange]()
        let sortedHeartRates = heartRates.sorted(by: { $0.count < $1.count })
        var firstHeartRateInRange = sortedHeartRates[0]
        var lastHeartRateInRange = sortedHeartRates[0]
        
        var maxHR: Int = 0
        
        for heartRate in sortedHeartRates {
            let newRange = (heartRate.count - firstHeartRateInRange.count) > treshold
            if newRange {
                ranges.append(HeartRateValueRange(minHR: firstHeartRateInRange.count,
                                                  maxHR: lastHeartRateInRange.count))
                firstHeartRateInRange = heartRate
            }
            
            lastHeartRateInRange = heartRate
            
            // MAX
            if heartRate.count > maxHR {
                maxHR = heartRate.count
            }
        }
        // Append the last range
        ranges.append(HeartRateValueRange(minHR: firstHeartRateInRange.count,
                                          maxHR: lastHeartRateInRange.count))
        
        self.init(date: date, heartRates: heartRates, ranges: ranges, maxHR: maxHR)
    }
}

struct HeartRateValueRange: Identifiable {
    var id = UUID()
    let minHR: Int
    let maxHR: Int
    let averageHR: Int // In this case it's not the average of all HR values, it's just the middle point between min and max - useful for rendering
    let deltaHR: Int
}

extension HeartRateValueRange {
    init(minHR: Int, maxHR: Int) {
        self.minHR = minHR
        self.maxHR = maxHR
        self.averageHR = (minHR + maxHR)/2
        self.deltaHR = maxHR - minHR
    }
}



struct StepsWeek: Identifiable {
    var id = UUID()
    let steps: [Step]
}
