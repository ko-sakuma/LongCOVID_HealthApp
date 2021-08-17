//
//  TrackMe2.swift
//  JsonExperiments
//
//  Created by Ko Sakuma on 16/07/2021.
//
//
//TODO: if raw WatchConnectivity API turns out to be too complicated, look into using https://github.com/mutualmobile/MMWormhole


// WORKING BELOW WITHOUT A SEARCHBAR

import SwiftUI

struct SymptomHistoryView: View {
    
    // MARK: - Environment
    @EnvironmentObject var symptomJSONManager: SymptomJSONManager

    // MARK: - State
    @State var showUpdateMeView = false

    // MARK: - Body
    var body: some View {

        NavigationView {

            ScrollView () {
                VStack (alignment: .leading) {

                VStack (alignment: .leading) {
                    ForEach(symptomJSONManager.symptomDataArray.reversed()) { lineItem in
                        HStack (alignment: .center) {

                            Text(lineItem.symptom ?? "")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemOrange))
                                .padding()

                            Text(symptomJSONManager.displayTimestamp(lineItem.timestamp ?? ""))
                                .font(.caption)
                                .foregroundColor(Color(.systemGray))
                                .padding()

                        }
                        .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white, lineWidth: 1)

                        )

                    }
                }



                }

            }
            .navigationTitle("Symptoms")
            .onAppear(perform: symptomJSONManager.readUserDataFromJSON)

//            .toolbar {
//
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        showUpdateMeView = true
//                    }, label: {
//                        Text("Update")
//                    })
//                    .sheet(isPresented: $showUpdateMeView){
//                        UpdateMeView()
//                    }
//                }
//
//            }

        }

    }
}




struct SymptomHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        SymptomHistoryView()
            .environmentObject(SymptomJSONManager())
    }
}


//        List(symptomJSONManager.symptomDataArray.reversed() ){ lineItem in
//
//              /*  HStack {
//                    Text(lineItem.symptom ?? "")
//                        .font(.caption)
//
//                    Text(symptomJSONManager.displayTimestamp(lineItem.timestamp ?? ""))
//                        .font(.caption)
//                        .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
//                }
//            */
//            }




//                ZStack {
//                             Rectangle()
//                                .foregroundColor(Color(.systemGray))
//                             HStack {
//                                 Image(systemName: "magnifyingglass")
//                                 TextField("Search for a symptom", text: $searchText)
//                             }
//                             .foregroundColor(.white)
//                             .padding(.leading, 13)
//                         }
//                             .frame(height: 40)
//                             .cornerRadius(13)
//                             .padding()







// TRYING with a searchbar (work in progress)

//import SwiftUI
//
//struct SymptomHistoryView: View {
//
//    @EnvironmentObject var symptomJSONManager: SymptomJSONManager
//
//    @State var showUpdateMeView = false
//
//    @State var searchText = ""
//    @State var searching = false
//
//
//
////    let myFruits = [
////        "Apple 🍏", "Banana 🍌", "Blueberry 🫐", "Strawberry 🍓", "Avocado 🥑", "Cherries 🍒", "Mango 🥭", "Watermelon 🍉", "Grapes 🍇", "Lemon 🍋"
////    ]
//
//    let myFruits = self.symptomJSONManager
//    var array = myFruits.symptomDataArray.reversed()
//
////       mySyptoms = ["Physically Well", "Fatigue", "Dizzy", "Chest Pain", "Breathlessness", "Palpitation" ]
////
//    var body: some View {
//
//        NavigationView {
//
////            ScrollView () {
////
//                VStack (alignment: .leading) {
//                SearchBar(searchText: $searchText, searching: $searching)
//
////                List {
////                VStack (alignment: .leading) {
////                    ForEach(symptomJSONManager.symptomDataArray.reversed()) { lineItem in
////                        HStack (alignment: .center) {
////
////                            Text(lineItem.symptom ?? "")
////                                .font(.title3)
////                                .fontWeight(.bold)
////                                .foregroundColor(Color(.systemOrange))
////                                .padding()
////
////                            Text(symptomJSONManager.displayTimestamp(lineItem.timestamp ?? ""))
////                                .font(.caption)
////                                .foregroundColor(Color(.systemGray))
////                                .padding()
////
////                        }
////                        .overlay(RoundedRectangle(cornerRadius: 8)
////                                    .stroke(Color.white, lineWidth: 1)
////
////                        )
////
////                    }
////                }
//
//
//
//                List {
//                    ForEach(myFruits.filter({ (fruit: String) -> Bool in
//                        return fruit.hasPrefix(searchText) || searchText == ""
//                    }), id: \.self) { fruit in
//                        Text(fruit)
//                    }
//                }
//                .listStyle(GroupedListStyle())
//                .navigationTitle(searching ? "Searching" : "Symptoms")
//                .toolbar {
//                    if searching {
//                        Button("Cancel") {
//                            searchText = ""
//                            withAnimation {
//                               searching = false
//                               UIApplication.shared.dismissKeyboard()
//                            }
//                        }
//                    }
//                }
//                .gesture(DragGesture()
//                            .onChanged({ _ in
//                    UIApplication.shared.dismissKeyboard()
//                            })
//                )
//
//
//
//
//                }
//
//            }
//            .navigationTitle("Symptoms")
//            .onAppear(perform: symptomJSONManager.readUserDataFromJSON)
//
////            .toolbar {
////
////                ToolbarItem(placement: .navigationBarTrailing) {
////                    Button(action: {
////                        showUpdateMeView = true
////                    }, label: {
////                        Text("Update")
////                    })
////                    .sheet(isPresented: $showUpdateMeView){
////                        UpdateMeView()
////                    }
////                }
////
////            }
//
////        }
//
//    }
//}
//
//
//struct SearchBar: View {
//
//    @Binding var searchText: String
//    @Binding var searching: Bool
//
//    var body: some View {
//        ZStack {
//            Rectangle()
//                .foregroundColor(Color("LightGray"))
//            HStack {
//                Image(systemName: "magnifyingglass")
//                TextField("Search ..", text: $searchText) { startedEditing in
//                    if startedEditing {
//                        withAnimation {
//                            searching = true
//                        }
//                    }
//                } onCommit: {
//                    withAnimation {
//                        searching = false
//                    }
//                }
//            }
//            .foregroundColor(.gray)
//            .padding(.leading, 13)
//        }
//            .frame(height: 40)
//            .cornerRadius(13)
//            .padding()
//    }
//}
//
//
//struct SymptomHistoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        SymptomHistoryView()
//            .environmentObject(SymptomJSONManager())
//    }
//}
//
//extension UIApplication {
//      func dismissKeyboard() {
//          sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//      }
//  }
//
//
//
////        List(symptomJSONManager.symptomDataArray.reversed() ){ lineItem in
////
////              /*  HStack {
////                    Text(lineItem.symptom ?? "")
////                        .font(.caption)
////
////                    Text(symptomJSONManager.displayTimestamp(lineItem.timestamp ?? ""))
////                        .font(.caption)
////                        .foregroundColor(Color(#colorLiteral(red: 0.43921568989753723, green: 0.43921568989753723, blue: 0.43921568989753723, alpha: 1)))
////                }
////            */
////            }
//
//
//
//
////                ZStack {
////                             Rectangle()
////                                .foregroundColor(Color(.systemGray))
////                             HStack {
////                                 Image(systemName: "magnifyingglass")
////                                 TextField("Search for a symptom", text: $searchText)
////                             }
////                             .foregroundColor(.white)
////                             .padding(.leading, 13)
////                         }
////                             .frame(height: 40)
////                             .cornerRadius(13)
////                             .padding()
