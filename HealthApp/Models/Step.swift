
import Foundation

struct Step: Identifiable {
    let id = UUID()
    let count: Int
    let date: Date
}

struct StepsWeek: Identifiable {
    var id = UUID()
    let steps: [Step]
    
}
