//
//  SwiftUIView.swift
//  HealthAppWatch Extension
//
//  Created by Ko Sakuma on 05/07/2021.
//
// NOTE: This is for experiments. 

import SwiftUI
import CoreGraphics   // may or may not needed.. CG stuff

struct UpdateMeWatchExperimentsView: View {
    var body: some View {

        TabView {
            NavigationView {

                // FACE: 1st from the left - 0
                ZStack {
                    //  RECTANGULAR FRAME: .red
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.cyan))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    VStack {  // WRAP THE EYE, MOUTH, AND BUTTON

                        HStack { // WRAP THE EYES
                        // Left Eye
                            ZStack {
                                Circle()
                                    .fill(Color(.cyan))

                                Circle()
                                    .strokeBorder(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), lineWidth: 8)

                            }
                            .frame(width: 44, height: 44)

                        // Right Eye
                            ZStack {
                                Circle()
                                    .fill(Color(.cyan))

                                Circle()
                                    .strokeBorder(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), lineWidth: 8)
                            }
                            .frame(width: 44, height: 44)
                        }

                        // MOUTH CODE SNIPPET HERE

                        // BUTTON
                        Button(action: {
                            print("Button clicked")
                        }) {
                                Image(systemName: "checkmark")
                                    .frame(width: 100)
                                    .foregroundColor(Color.white)
                                    .padding()
                                    .background(Color.gray)
                                    .opacity(0.7)
                                    .cornerRadius(11)
                            }

                    }

                }
                .navigationBarTitle("1st")
                }
                .tabItem {
                    Image(systemName: "1.circle")
                    Text("1st")
                }.tag(0)

                // 2
                NavigationView {
                    Text("Sad Face here")
                    .navigationBarTitle("Second")
                }
                .tabItem {
                    Image(systemName: "2.circle")
                    Text("Second")
                }.tag(1)

                // 3
                NavigationView {
                    Text("Okay Face here")
                    .navigationBarTitle("3rd")
                }
                .tabItem {
                    Image(systemName: "3.circle")
                    Text("3rd")
                }.tag(3)

                // 4
                NavigationView {
                    Text("I'm good Face here")
                    .navigationBarTitle("4th")
                }
                .tabItem {
                    Image(systemName: "4.circle")
                    Text("4th")
                }.tag(4)

                // 5
                NavigationView {
                    Text("I'm feeling great face here")
                    .navigationBarTitle("5th")
                }
                .tabItem {
                    Image(systemName: "5.circle")
                    Text("5th")
                }.tag(5)

                // 6
                NavigationView {
                    Text("I feel the best face here")
                    .navigationBarTitle("6th")
                }
                .tabItem {
                    Image(systemName: "6.circle")
                    Text("6th")
                }.tag(6)

    }

//                List {
//
//                    Text("Physically Well")
//                        .padding()
//
//                    Text("Fatigue")
//                        .padding()
//
//                    Text("Dizzy")
//                        .padding()
//
//                    Text("Chest Pain")
//                        .padding()
//
//                    Text("Breathlessness")
//                        .padding()
//
//                    Text("Palpitation")
//                        .padding()
//
//                }

    }
}

struct UpdateMeWatchExperimentsView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateMeWatchExperimentsView()
    }
}
