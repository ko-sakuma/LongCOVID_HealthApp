//
//  UpdateMeWatchView2.swift
//  JsonExperiments
//
//  Created by Ko Sakuma on 16/07/2021.
//

import SwiftUI

struct UpdateMeView: View {
    
    // MARK: - State
    @EnvironmentObject var symptomJSONManager: SymptomJSONManager
    
    // MARK: - Type definitions
    let haptic = UISelectionFeedbackGenerator()
    
    // MARK: - Body
    var body: some View {
        
        NavigationView {
        
//        VStack {
            
//            Text("How are you feeling?")
//                .font(.title)
//                .fontWeight(.bold)
//                .foregroundColor(Color(.systemOrange))
        
            VStack {
                
                HStack {
                    Button(action: {
                        self.haptic.selectionChanged()
                        symptomJSONManager.writeJSONToFileManager("Physically Well", andTimeStamp: Date())
                    }) {
                        VStack {
                            Text("😊💪🏻")
                                .font(.largeTitle)
                            Text("  Physically Well  ")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(Color.white)
                        .padding()
                        .background(Color(.systemGreen))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        self.haptic.selectionChanged()
                        symptomJSONManager.writeJSONToFileManager("Fatigue", andTimeStamp: Date())
                    }) {
                        VStack {
                            Text("😵")
                                .font(.largeTitle)
                            Text("   Fatigue    ")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(Color.white)
                        .padding()
                        .background(Color(.systemOrange))
                        .cornerRadius(8)
                    }
                
                }
                
                
                HStack {
                    Button(action: {
                        self.haptic.selectionChanged()
                        symptomJSONManager.writeJSONToFileManager("Dizzy", andTimeStamp: Date())
                    }) {
                        VStack {
                            Text("😩")
                                .font(.largeTitle)
                            Text("       Dizzy        ")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(Color.white)
                        .padding()
                        .background(Color(.systemPurple))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        self.haptic.selectionChanged()
                        symptomJSONManager.writeJSONToFileManager("Chest Pain", andTimeStamp: Date())
                    }) {
                        VStack {
                            Text("❤️😖")
                                .font(.largeTitle)
                            Text("    Chest Pain     ")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(Color.white)
                        .padding()
                        .background(Color(.systemRed))
                        .cornerRadius(8)
                    }
                
                }
                
                
                HStack {
                    Button(action: {
                        self.haptic.selectionChanged()
                        symptomJSONManager.writeJSONToFileManager("Breathlessness", andTimeStamp: Date())
                    }) {
                        VStack {
                            Text("😵💭")
                                .font(.largeTitle)
                            Text("Breathlessness")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(Color.white)
                        .padding()
                        .background(Color(.systemGray))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        self.haptic.selectionChanged()
                        symptomJSONManager.writeJSONToFileManager("Palpitation", andTimeStamp: Date())
                    }) {
                        VStack {
                            Text("❤️😫")
                                .font(.largeTitle)
                            Text("  Palpitation  ")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(Color.white)
                        .padding()
                        .background(Color(.systemPink))
                        .cornerRadius(8)
                    }
                
                }
        }
        .navigationTitle("How are you?")
            
        }
        
    }
}

struct UpdateMeView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateMeView()
    }
}







//Button("Physically Well") {
//    print("physically Well")
//    self.haptic.selectionChanged()
//    symptomJSONManager.writeJSONToFileManager("Physically Well", andTimeStamp: Date())
//}
//.padding()
//.background(RoundedRectangle(cornerRadius: 15)
//.opacity(0.2))
//
//
//Button("Fatigue") {
//    print("fatigue")
//    self.haptic.selectionChanged()
//    symptomJSONManager.writeJSONToFileManager("Fatigue", andTimeStamp: Date())
//}
//
//
//Button("Dizzy") {
//    print("dizzy")
//    self.haptic.selectionChanged()
//    symptomJSONManager.writeJSONToFileManager("Dizzy", andTimeStamp: Date())
//}
//
//
//Button("Chest Pain") {
//    print("chest pain")
//    self.haptic.selectionChanged()
//    symptomJSONManager.writeJSONToFileManager("Chest Pain", andTimeStamp: Date())
//}
//
//
//Button("Breathlessness") {
//    print("breathlessness")
//    self.haptic.selectionChanged()
//    symptomJSONManager.writeJSONToFileManager("Breathlessness", andTimeStamp: Date())
//}
//
//
//Button("Palpitation") {
//    print("Palpitation")
//    self.haptic.selectionChanged()
//    symptomJSONManager.writeJSONToFileManager("Palpitation", andTimeStamp: Date())
//}
//
