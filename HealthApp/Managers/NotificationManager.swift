
// REFERENCE: The author followed this tutorial to implement some of the notification flows: https://www.raywenderlich.com/21458686-local-notifications-getting-started

import Foundation
import UserNotifications
import CoreLocation
import HealthKit

enum NotificationManagerConstants {
    // GROUPING NOTIF BASED ON TRIGGER TYPE

    // NOTIFICATION TRIGGERS WHEN ...
    static let timeBasedNotificationThreadId = "TimeBasedNotificationThreadId"

    // NOTIFICATION TRIGGERS WHEN A DEFINED TIME IN THE CALENDAR ARRIVES
    static let calendarBasedNotificationThreadId = "CalendarBasedNotificationThreadId"

    // NOTIFICATION TRIGGERS WHEN A USER ENTER/EXIST A DEFINED LOCATION
    static let locationBasedNotificationThreadId = "LocationBasedNotificationThreadId"

    // NOTIFICATION TRIGGERS WHEN A USER'S HEART RATE EXCEEDS ITS THRESHHOLD
    static let HeartRateCeilingBasedNotificationThreadId = "HeartRateCeilingBasedNotificationThreadId"
}

class NotificationManager: ObservableObject {
  static let shared = NotificationManager()
  @Published var settings: UNNotificationSettings?

  func requestAuthorization(completion: @escaping  (Bool) -> Void) {
    // REQUEST USER AUTHORISATION TO SHOW NOTIFICATIONS
    UNUserNotificationCenter.current()
      .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _  in
        self.fetchNotificationSettings()
        completion(granted)
      }
  }

  func fetchNotificationSettings() {
    // 1
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      // 2
      DispatchQueue.main.async {
        self.settings = settings
      }
    }
  }

  func removeScheduledNotification(task: Task) {
    // REMOVES ANY PENDING NOTIF UPON TASK COMPLETION
    UNUserNotificationCenter.current()
      .removePendingNotificationRequests(withIdentifiers: [task.id])
  }

  // 1
  func scheduleNotification(task: Task) {
    // 2 : HOLDS ALL THE DATA RELATED TO ANY TASK (as defined in Task.swift)
    let content = UNMutableNotificationContent()

    // content.title = title text of the notification
    content.title = task.name
    // content.body = body text of the notification
    content.body = "Hi there! I hope you are doing well😊"
    // TODO: can add badge, sound, attachments as content.sound as well.

    content.categoryIdentifier = "HealthApp"  // This should match with AppDelegate
    let taskData = try? JSONEncoder().encode(task)
    if let taskData = taskData {
      content.userInfo = ["Task": taskData]
    }

    // 3 : TRIGGERS THE DELIVERY OF THE NOTIFICATION
    var trigger: UNNotificationTrigger?

    switch task.reminder.reminderType {

        // TIME
        case .time:
          if let timeInterval = task.reminder.timeInterval {
            trigger = UNTimeIntervalNotificationTrigger(
              timeInterval: timeInterval,
              repeats: task.reminder.repeats)
          }
          content.threadIdentifier =
            NotificationManagerConstants.timeBasedNotificationThreadId

        // CALENDAR
        case .calendar:
          if let date = task.reminder.date {
            trigger = UNCalendarNotificationTrigger(
              dateMatching: Calendar.current.dateComponents(
                [.day, .month, .year, .hour, .minute],
                from: date),
              repeats: task.reminder.repeats)
          }
          content.threadIdentifier =
            NotificationManagerConstants.calendarBasedNotificationThreadId

        // LOCATION
        case .location:
          // 1: CHECK AUTHORISATION STATUS. SETTING TO CAN USE AT LEAST WHEN APP IS IN USE.
          guard CLLocationManager().authorizationStatus == .authorizedWhenInUse else {
            return
          }
          // 2: CHECK IF LOCATION DATA EXISTS IN THE REMINDER
          if let location = task.reminder.location {
            // 3: DEFINE THE LOCATION COORDINATE
            let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = CLCircularRegion(center: center, radius: location.radius, identifier: task.id)
            trigger = UNLocationNotificationTrigger(region: region, repeats: task.reminder.repeats)
          }
          content.threadIdentifier =
            NotificationManagerConstants.locationBasedNotificationThreadId

        // HEART RATE
        case .heartRateCeiling:

            if HKHealthStore.isHealthDataAvailable() {

                let date = Date().addingTimeInterval(20) // 20 seconds
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents(
                        [.day, .month, .year, .hour, .minute],
                        from: date),
                    repeats: false)

                content.threadIdentifier =
                    NotificationManagerConstants.HeartRateCeilingBasedNotificationThreadId
            }

    }

    // 4 : CREATING A NOTIFICATION REQUEST
    if let trigger = trigger {
        let request = UNNotificationRequest(
            identifier: task.id,
            content: content,
            trigger: trigger)
        // 5 : adding the request to UNUserNotificationCenter
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error)
            }
        }
    }
  }
}
