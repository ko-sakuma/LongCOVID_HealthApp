//
//  SettingsView.swift
//  HealthApp
//
//  Created by Ko Sakuma on 19/08/2021.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Observed Object
    @ObservedObject var notificationManager = NotificationManager.shared

    
    var body: some View {
        NavigationView{
            Form {
                
                    Section(header: Text("iPhone Notifications")) {
                      SettingRowView(
                        setting: "Authorization Status",
                        enabled: notificationManager.settings?.authorizationStatus == UNAuthorizationStatus.authorized)
                      SettingRowView(
                        setting: "Show in Notification Center",
                        enabled: notificationManager.settings?.notificationCenterSetting == .enabled)
                      SettingRowView(
                        setting: "Notification Sounds",
                        enabled: notificationManager.settings?.soundSetting == .enabled)
                      SettingRowView(
                        setting: "Notification Badges",
                        enabled: notificationManager.settings?.badgeSetting == .enabled)
                      SettingRowView(
                        setting: "Alerts",
                        enabled: notificationManager.settings?.alertSetting == .enabled)
                      SettingRowView(
                        setting: "Show on lock screen",
                        enabled: notificationManager.settings?.lockScreenSetting == .enabled)
                      SettingRowView(
                        setting: "Alert banners",
                        enabled: notificationManager.settings?.alertStyle == .banner)
                      SettingRowView(
                        setting: "Critical Alerts",
                        enabled: notificationManager.settings?.criticalAlertSetting == .enabled)
                      SettingRowView(
                        setting: "Siri",
                        enabled: notificationManager.settings?.announcementSetting == .enabled)
                    }
                
                Section(header: Text("Apple Watch Notifications")) {
                  SettingRowView(
                    setting: "Authorization Status",
                    enabled: notificationManager.settings?.authorizationStatus == UNAuthorizationStatus.authorized)
                  SettingRowView(
                    setting: "Show in Notification Center",
                    enabled: notificationManager.settings?.notificationCenterSetting == .enabled)
                  SettingRowView(
                    setting: "Notification Sounds",
                    enabled: notificationManager.settings?.soundSetting == .enabled)
                  SettingRowView(
                    setting: "Notification Badges",
                    enabled: notificationManager.settings?.badgeSetting == .enabled)
                  SettingRowView(
                    setting: "Alerts",
                    enabled: notificationManager.settings?.alertSetting == .enabled)
                  SettingRowView(
                    setting: "Show on lock screen",
                    enabled: notificationManager.settings?.lockScreenSetting == .enabled)
                  SettingRowView(
                    setting: "Alert banners",
                    enabled: notificationManager.settings?.alertStyle == .banner)
                  SettingRowView(
                    setting: "Critical Alerts",
                    enabled: notificationManager.settings?.criticalAlertSetting == .enabled)
                  SettingRowView(
                    setting: "Siri",
                    enabled: notificationManager.settings?.announcementSetting == .enabled)
                }
                
            }
            .navigationTitle("Settings")
            .background(Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all))
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

