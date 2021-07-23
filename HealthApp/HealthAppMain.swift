//
//  HealthAppApp.swift
//  HealthApp
//
//  Created by Ko Sakuma on 21/06/2021.
//

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
