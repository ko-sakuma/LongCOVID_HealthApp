
import Foundation

struct HeartRateDateGroup: Identifiable {
    var id = UUID()
    let date: Date
    let heartRates: [HeartRate]
    let ranges: [HeartRateValueRange]
    let maxHR: Int
    let minHR: Int
}

extension HeartRateDateGroup {
    init(date: Date, heartRates: [HeartRate]) {
        // Threshold is for grouping BPM difference. Change in this number will result in a change in the size/frequency of the blobs.
        let threshold: Int = 40
        
        var ranges = [HeartRateValueRange]()
       
        let sortedHeartRates = heartRates.sorted(by: { $0.count < $1.count })
        
        var firstHeartRateInRange = sortedHeartRates[0]
        var lastHeartRateInRange = sortedHeartRates[0]
        
        var maxHR: Int = 0
        var minHR: Int = Int.max
        
        for heartRate in sortedHeartRates {
            let newRange = (heartRate.count - firstHeartRateInRange.count) > threshold
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
            
            // TODO: MIN
            if heartRate.count < minHR {
                minHR = heartRate.count
            }
            
        }
        // Append the last range
        ranges.append(HeartRateValueRange(minHR: firstHeartRateInRange.count,
                                          maxHR: lastHeartRateInRange.count))
        
        self.init(date: date, heartRates: heartRates, ranges: ranges, maxHR: maxHR, minHR: minHR)
    }
}

struct HeartRateValueRange: Identifiable {
    var id = UUID()
    let minHR: Int
    let maxHR: Int
    let averageHR: Int // In this case it's not the average of all HR values, it's just the middle point between min and max - useful for rendering.
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
