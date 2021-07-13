//
//  AppDelegate.swift
//  NotificationsTest
//
//  Created by Ko Sakuma on 05/07/2021.
//
// TODO: <<IMPORTANT>> CHANGE THE NOTIFICATION CATEGORY IDENTIFIER TO MY REGISTERED APP NAME! (line 52)
// NOTE: UIKit was used to create foreground notification. AppDelegate is called in HelathAppMain.swift

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    configureUserNotifications()
    HealthStore.shared.startBackgroundHeartRateMonitoring()
    return true
  }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    // ASKS THE DELEGATE HOW TO HANDLE A NOTIFICATION WHEN APP IS IN FOREGROUND
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler(.banner)  // set to banner (Alt: sound, badge)
  }

  private func configureUserNotifications() {
    //  MAKE APPDELEGATE THE DELEGATE OF UNUserNotificationCenter
    UNUserNotificationCenter.current().delegate = self

    // 1: DEFINING THE ACTION BUTTONS ON THE NOTIFICATION SCREEN
    let dismissAction = UNNotificationAction(
      identifier: "dismiss",
      title: "Dismiss",
      options: []
    )
    let markAsDone = UNNotificationAction(
      identifier: "markAsDone",
      title: "Mark As Done",
      options: []
    )

    // 2: DEFINE THE CATEGORY OF THE NOTIFICATION
    let category = UNNotificationCategory(
      identifier: "HealthApp", // TODO: CHANGE THE NAME TO MY REGISTERED APP NAME
      actions: [dismissAction, markAsDone],
      intentIdentifiers: [],
      options: []
    )

    // 3: REGISTER A NEW ACTIONABLE NOTIFICATION
    UNUserNotificationCenter.current().setNotificationCategories([category])
  }

  // 1: CALLS THE NOTIFICATION CENTER WHEN USER ACTS ON THE NOTIF
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    // 2: CHECK IF THE RESPONSE IS SET TO MARK AS DONE
    if response.actionIdentifier == "markAsDone" {
      let userInfo = response.notification.request.content.userInfo
      if let taskData = userInfo["Task"] as? Data {
        if let task = try? JSONDecoder().decode(Task.self, from: taskData) {
          // 3: REMOVE THE TASK ONCE TASK IS DONE
          TaskManager.shared.remove(task: task)
        }
      }
    }
    completionHandler()
  }
}
