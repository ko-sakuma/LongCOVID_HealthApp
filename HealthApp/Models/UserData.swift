//
//  UserData.swift
//  JsonExperiments
//
//  Created by Ko Sakuma on 16/07/2021.
//

import Foundation

// 1: mapping the list (big)
struct UserInputs: Codable {
    var symptomData: [SymptomData]
}


// 2: mapping each symptom data
struct SymptomData: Codable, Hashable, Identifiable {
    var id: UUID = UUID() //TODO: don't default to a random UUID, create it manually at the callsite
    var symptom: String?
    var timestamp: String?
}

extension SymptomData {
    var date: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let timestampString = timestamp//, let timestamp = TimeInterval(timestampString)
        else { return nil }
//        return Date(timeIntervalSince1970: timestamp)
        return formatter.date(from: timestampString)
    }
}
