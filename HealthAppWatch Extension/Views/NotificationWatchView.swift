
// NOTE: DONT TOUCH THIS FILE UNLESS PAIRING WITH NotificationController.swift!

import SwiftUI
import UserNotifications

struct NotificationWatchView: View {
    var body: some View {

        VStack {

            Button("Request permission") {
                // PRESS THIS BUTTON -> Request persmission menu pops up
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {success, error in
                    if success {
                        print("All set!")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }

            Button("Schedule Notification") {
                // PRESS THIS BUTTON -> Notification will pop up based on defined logic
                let content = UNMutableNotificationContent()
                content.title = "This is your first notification!"
                content.subtitle = "Nice Work!"
                content.sound = UNNotificationSound.default

                // Show this notification 2 seconds from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

                // Choose a random identifier
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                // add our notification request
                UNUserNotificationCenter.current().add(request)
            }
        }

//        List {
//
//            Text("Physically Well")
//                .padding()
//
//            Text("Fatigue")
//                .padding()
//
//            Text("Dizzy")
//                .padding()
//
//            Text("Chest Pain")
//                .padding()
//
//            Text("Breathlessness")
//                .padding()
//
//            Text("Palpitation")
//                .padding()
//
//        }

    }
}

struct NotificationWatchView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationWatchView()
    }
}
