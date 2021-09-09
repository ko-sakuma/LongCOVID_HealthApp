
import Foundation

struct Step: Identifiable {
    let id = UUID()
    let count: Int
    let date: Date
}

struct StepsWeek: Identifiable {
    var id: Int {
        Int( steps.first?.date.timeIntervalSince1970 ?? 0 )
    }
    let steps: [Step]
}
