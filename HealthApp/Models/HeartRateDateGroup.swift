
import Foundation

struct HeartRateDateGroup: Identifiable {
    var id = UUID()
    let date: Date
    let heartRates: [HeartRate]
}
