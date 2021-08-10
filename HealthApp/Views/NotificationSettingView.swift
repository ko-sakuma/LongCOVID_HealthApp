
import SwiftUI

// TODO: refacotor 

// VIEW
struct NotificationSettingsView: View {
  @ObservedObject var notificationManager = NotificationManager.shared

  var body: some View {

        NavigationView {

                Form {
                    Section(header: Text("iPhone")) {
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
                .navigationBarTitle("Notifications Status")
//                .navigationBarTitle("Notifications Status", displayMode: .inline)
        }

  }

}

struct SettingRowView: View {
  var setting: String
  var enabled: Bool
  var body: some View {
    HStack {
      Text(setting)
      Spacer()
      if enabled {
        Image(systemName: "checkmark")
          .foregroundColor(.green)
      } else {
        Image(systemName: "xmark")
          .foregroundColor(.red)
      }
    }
    .padding()
  }
}




struct NotificationSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    NotificationSettingsView()
  }
}

