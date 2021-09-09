
import Foundation

// 1: mapping the list (big)
struct UserInputs: Codable {
    var symptomData: [SymptomData]
}


// 2: mapping each symptom data
struct SymptomData: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var symptom: String?
    var timestamp: String?
}

extension SymptomData {
    var date: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let timestampString = timestamp
        else { return nil }
        
        return formatter.date(from: timestampString)
    }
}
