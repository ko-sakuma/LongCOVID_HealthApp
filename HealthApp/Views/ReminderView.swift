
import SwiftUI

struct ReminderView: View {
    
    @Binding var selectedTrigger: ReminderType
    @Binding var timeDurationIndex: Int
    @Binding var heartRateCeiling: Int       // HEART RATE CEILING
    @Binding var triggerDate: Date
    @Binding var shouldRepeat: Bool
    @Binding var latitude: String
    @Binding var longitude: String
    @Binding var radius: String
    @StateObject var locationManager = LocationManager()

    var mainPicker: some View {

        Picker("Notification Trigger", selection: $selectedTrigger) {
            Text("Time").tag(ReminderType.time)
            Text("Date").tag(ReminderType.calendar)
            Text("Location").tag(ReminderType.location)
            Text("Heart Rate").tag(ReminderType.heartRateCeiling)     // Heart Rate NOTIF
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.vertical)
    }

    var body: some View {
        VStack {
            mainPicker

            pickerForSelectedTrigger()

            Toggle(isOn: $shouldRepeat) {
                Text("Make this a daily routine")
            }
        }
    }

        
    var timePicker: some View {
        Picker("Time Interval", selection: $timeDurationIndex) {
            ForEach(1 ..< 59) { interval in
                if interval == 1 {
                    Text("\(interval) minute").tag(interval)
                } else {
                    Text("\(interval) minutes").tag(interval)
                }
            }
            .navigationBarHidden(true)
            .padding(.vertical)
        }
    }

    var calendarPicker: some View {
        DatePicker("Please enter a date", selection: $triggerDate)
            .labelsHidden()
            .padding(.vertical)
    }

    var locationPicker: some View {
        VStack {
            if !locationManager.authorized {
                Button(
                    action: {
                        locationManager.requestAuthorization()
                    },
                    label: {
                        Text("Request Location Authorization")
                    })
            } else { // geocoding CLGeoCoder CoreLocation
                TextField("Enter Latitude", text: $latitude)
                TextField("Enter Longitude", text: $longitude)
                TextField("Enter Radius", text: $radius)
            }
        }
        .padding(.vertical)
    }

    var heartRatePicker: some View {
        Picker("Heart Rate Ceiling", selection: $heartRateCeiling) {
            ForEach(40 ..< 160) { heartRateCeiling in
                if heartRateCeiling == 1 {
                    Text("\(heartRateCeiling) BPM").tag(heartRateCeiling)
                } else {
                    Text("\(heartRateCeiling) BPM").tag(heartRateCeiling)
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .onChange(of: heartRateCeiling) { limit in
            HealthStore.shared.maximumBPM = limit

        }
    }

        @ViewBuilder
    func pickerForSelectedTrigger() -> some View {

        // TIME
        switch selectedTrigger {
        case .time:
            timePicker
        case .calendar:
            calendarPicker
        case .location:
            locationPicker
        default:
            heartRatePicker
        }
    }
}
