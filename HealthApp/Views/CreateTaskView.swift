
// TODO: "Save" button saves the Goal, but does not dismiss the view/sheet. Potentially due to @Environment(\.presentationMode) var presentationMode. Try the alternative approach: https://www.hackingwithswift.com/quick-start/swiftui/how-to-make-a-view-dismiss-itself

import SwiftUI
import MapKit
import HealthKit

struct CreateTaskView: View {
    
    // MARK: - Environment
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - State
    @State var taskName: String = ""
    @State var reminderEnabled = false
    @State var selectedTrigger = ReminderType.time
    
    @State var timeDurationIndex: Int = 0
    @State var heartRateCeiling: Int = 60
    
    @State private var dateTrigger = Date()
    @State private var shouldRepeat = false

    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var radius: String = ""
    

    // MARK: - Type definitions
    let triggers = ["Time", "Calendar", "Location", "HeartRateCeiling"] // Heart Rate
    let timeDurations: [Int] = Array(1...59)
    
    // MARK: - Body
    var body: some View {
        NavigationView {
          Form {
            Section {
              HStack {
    
                Spacer()
                
                Button("Save") {
                    TaskManager.shared.addNewTask(taskName, makeReminder())
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(taskName.isEmpty ? true : false)
                .padding()
              }
                
              VStack {
                TextField("Type the name of your new target...", text: $taskName)
                  .padding(.vertical)
                Toggle(isOn: $reminderEnabled) {
                  Text("Set a smart reminder")
                }
                .padding(.vertical)

                if reminderEnabled {
                  ReminderView(
                    selectedTrigger: $selectedTrigger,
                    timeDurationIndex: $timeDurationIndex,
                    heartRateCeiling: $heartRateCeiling,      // HEART RATE
                    triggerDate: $dateTrigger,
                    shouldRepeat: $shouldRepeat,
                    latitude: $latitude,
                    longitude: $longitude,
                    radius: $radius)
                    .navigationBarHidden(true)
                    .navigationTitle("")
                }
              }
              .padding()
            }
          }
            // Potentially usable
//          .navigationTitle("Create a goal")
//          .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: {
//                    TaskManager.shared.addNewTask(taskName, makeReminder())
//                    presentationMode.wrappedValue.dismiss()
//                }, label: {
//                    Text("Close")
//                        .fontWeight(.bold)
//                })
//            }
//          }
            
          .navigationBarHidden(true)
        
        }
       
    }

    
  func makeReminder() -> Reminder? {
    guard reminderEnabled else {
      return nil
    }
    
    var reminder = Reminder()
    reminder.reminderType = selectedTrigger

    switch selectedTrigger {
    
        case .time:
          reminder.timeInterval = TimeInterval(timeDurations[timeDurationIndex] * 60) // TODO: Change this to every DAY AND WEEK?
    
        case .calendar:
          reminder.date = dateTrigger

        case .location:
          if let latitude = Double(latitude),
            let longitude = Double(longitude),
            let radius = Double(radius) {
            reminder.location = LocationReminder(
              latitude: latitude,
              longitude: longitude,
              radius: radius)
            }

        case .heartRateCeiling:
//            reminder.heartRateCeiling = 100 //
            break

    }
    reminder.repeats = shouldRepeat
    return reminder
  }
}

    struct CreateTaskView_Previews: PreviewProvider {
      static var previews: some View {
        CreateTaskView()
      }
    }















// NOTE: Below was moved to ReminderView


//    struct ReminderView: View {
//        @Binding var selectedTrigger: ReminderType
//        @Binding var timeDurationIndex: Int
//        @Binding var heartRateCeiling: Int       // HEART RATE CEILING
//        @Binding var triggerDate: Date
//        @Binding var shouldRepeat: Bool
//        @Binding var latitude: String
//        @Binding var longitude: String
//        @Binding var radius: String
//        @StateObject var locationManager = LocationManager()
//
//    var mainPicker: some View {
//
//        Picker("Notification Trigger", selection: $selectedTrigger) {
//            Text("Time").tag(ReminderType.time)
//            Text("Date").tag(ReminderType.calendar)
//            Text("Location").tag(ReminderType.location)
//            Text("Heart Rate").tag(ReminderType.heartRateCeiling)     // Heart Rate NOTIF
//        }
//        .pickerStyle(SegmentedPickerStyle())
//        .padding(.vertical)
//    }
//
//    var body: some View {
//        VStack {
//            mainPicker
//
//            pickerForSelectedTrigger()
//
//            Toggle(isOn: $shouldRepeat) {
//                Text("Make this a daily routine")
//            }
//        }
//    }
//
//        
//    var timePicker: some View {
//        Picker("Time Interval", selection: $timeDurationIndex) {
//            ForEach(1 ..< 59) { interval in
//                if interval == 1 {
//                    Text("\(interval) minute").tag(interval)
//                } else {
//                    Text("\(interval) minutes").tag(interval)
//                }
//            }
//            .navigationBarHidden(true)
//            .padding(.vertical)
//        }
//    }
//
//    var calendarPicker: some View {
//        DatePicker("Please enter a date", selection: $triggerDate)
//            .labelsHidden()
//            .padding(.vertical)
//    }
//
//    var locationPicker: some View {
//        VStack {
//            if !locationManager.authorized {
//                Button(
//                    action: {
//                        locationManager.requestAuthorization()
//                    },
//                    label: {
//                        Text("Request Location Authorization")
//                    })
//            } else { // geocoding CLGeoCoder CoreLocation
//                TextField("Enter Latitude", text: $latitude)
//                TextField("Enter Longitude", text: $longitude)
//                TextField("Enter Radius", text: $radius)
//            }
//        }
//        .padding(.vertical)
//    }
//
//    var heartRatePicker: some View {
//        Picker("Heart Rate Ceiling", selection: $heartRateCeiling) {
//            ForEach(40 ..< 160) { heartRateCeiling in
//                if heartRateCeiling == 1 {
//                    Text("\(heartRateCeiling) BPM").tag(heartRateCeiling)
//                } else {
//                    Text("\(heartRateCeiling) BPM").tag(heartRateCeiling)
//                }
//            }
//        }
//        .navigationBarTitle("", displayMode: .inline)
//        .onChange(of: heartRateCeiling) { limit in
//            HealthStore.shared.maximumBPM = limit
//
//        }
//    }
//
//    @ViewBuilder
//    func pickerForSelectedTrigger() -> some View {
//
//        // TIME
//        switch selectedTrigger {
//        case .time:
//            timePicker
//        case .calendar:
//            calendarPicker
//        case .location:
//            locationPicker
//        default:
//            heartRatePicker
//        }
//    }
//}
