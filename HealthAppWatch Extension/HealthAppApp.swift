//
//  HealthAppApp.swift
//  HealthAppWatch Extension
//
//  Created by Ko Sakuma on 01/07/2021.
//

import SwiftUI

@main
struct HealthAppApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                NotificationView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
