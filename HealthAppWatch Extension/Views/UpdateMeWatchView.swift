//
//  UpdateMeView2.swift
//  JsonExperiments
//
//  Created by Ko Sakuma on 16/07/2021.
//

import SwiftUI
import WatchKit  // required for haptic feedback: WKInterfaceDevice

struct UpdateMeWatchView: View {
    
    @EnvironmentObject var symptomJSONManager: SymptomJSONManager
    
    var body: some View {
        
        VStack {
            
        Text("How are you feeling?")
            .foregroundColor(Color.purple)
        
        List {

            Button("Physically Well") {
                print("physically Well")
                WKInterfaceDevice.current().play(.success)
                symptomJSONManager.writeJSONToFileManager("Physically Well", andTimeStamp: Date())
            }

            
            Button("Fatigue") {
                print("fatigue")
                WKInterfaceDevice.current().play(.success)
                symptomJSONManager.writeJSONToFileManager("Fatigue", andTimeStamp: Date())
            }
                

            Button("Dizzy") {
                print("dizzy")
                WKInterfaceDevice.current().play(.success)
                symptomJSONManager.writeJSONToFileManager("Dizzy", andTimeStamp: Date())
            }
                

            Button("Chest Pain") {
                print("chest Pain")
                WKInterfaceDevice.current().play(.success)
                symptomJSONManager.writeJSONToFileManager("Chest Pain", andTimeStamp: Date())
            }
                

            Button("Breathlessness") {
                print("breathlessness")
                WKInterfaceDevice.current().play(.success)
                symptomJSONManager.writeJSONToFileManager("Breathlessness", andTimeStamp: Date())
            }
                

            Button("Palpitation") {
                print("Palpitation")
                WKInterfaceDevice.current().play(.success)
                symptomJSONManager.writeJSONToFileManager("Palpitation", andTimeStamp: Date())
            }

        }
            
        }
    }
}

struct UpdateMeWatchView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateMeWatchView()
    }
}

