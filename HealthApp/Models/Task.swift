//
//  Task.swift
//  NotificationsTest
//
//  Created by Ko Sakuma on 04/07/2021.
//

import Foundation

struct Task: Identifiable, Codable {
  var id = UUID().uuidString
  var name: String
  var completed = false
  var reminderEnabled = false
  var reminder: Reminder
}

enum ReminderType: Int, CaseIterable, Identifiable, Codable {
  case time
  case calendar
  case location
  case heartRateCeiling // Heart rate ceiling
  var id: Int { self.rawValue }
}

struct Reminder: Codable {
  var timeInterval: TimeInterval?
  var date: Date?
  var location: LocationReminder?
  var heartRateCeiling: HeartRate?  // Heart rate ceiling
  var reminderType: ReminderType = .time
  var repeats = false
}

struct LocationReminder: Codable {
  var latitude: Double
  var longitude: Double
  var radius: Double
}
