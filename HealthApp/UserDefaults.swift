//
//  UserDefaults.swift
//  HealthApp
//
//  Created by Ko Sakuma on 12/07/2021.
//

import Foundation

enum UserDefaultsKey: String {
    case heartRateMonitoringNotificationTriggerTimestamp
}

extension UserDefaults {

    func date(key: UserDefaultsKey) -> Date? {
        return Date(timeIntervalSince1970: double(forKey: key.rawValue))
    }

    func setDate(_ date: Date, key: UserDefaultsKey) {
        setValue(date.timeIntervalSince1970, forKey: key.rawValue)
    }

}