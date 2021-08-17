
import SwiftUI

@main
struct HealthAppMain: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate // watch extension doesnt like this
    @StateObject var symptomJSONManager = SymptomJSONManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(symptomJSONManager)
                .onAppear(perform: symptomJSONManager.onAppear)
        }
    }
}
