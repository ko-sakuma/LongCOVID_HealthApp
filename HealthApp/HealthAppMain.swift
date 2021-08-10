
import SwiftUI

@main
struct HealthAppMain: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    @StateObject var symptomJSONManager = SymptomJSONManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
//                .environmentObject(symptomJSONManager)
//                .onAppear(perform: symptomJSONManager.onAppear)
        }
    }
}
