//
//  SymptomsDailyView.swift
//  HealthApp
//
//  Created by Ko Sakuma on 18/08/2021.
//

import SwiftUI

struct SymptomsDailyView: View {
    
    // MARK: - Environment
    @EnvironmentObject var symptomJSONManager: SymptomJSONManager
    
    // MARK: - State
    @State var showUpdateMeView = false
    
    @State var searchText = ""
    @State var searching = false
    
    // MARK: - Passed properties
    
    private var symptoms: [SymptomData] {
        let allSymptoms = symptomJSONManager.symptoms(forDay: date)
        if searchText.isEmpty {
            return allSymptoms
        } else {
            return allSymptoms.filter { date in
                guard let name = date.symptom else {
                    return false
                }
                return name.contains(searchText)
            }
        }
    }
    private var date: Date
    
    init(date: Date) {
        self.date = date
    }
    
    // MARK: - Body
    var body: some View {
        
        NavigationView {
            
            ScrollView () {
                
                VStack (alignment: .leading) {
                    // Search Bar
                    searchBar
                    
                    let theSymptoms = symptoms
                    
                    if theSymptoms.isEmpty {
                        Text("No Symptoms for this Date")
                    } else {
                        ForEach(symptoms) { lineItem in
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
                        }//: For Each
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
    
    var searchBar: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color("LightGray"))
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search by symptom name", text: $searchText) { startedEditing in
                    if startedEditing {
                        withAnimation {
                            searching = true
                        }
                    }
                } onCommit: {
                    withAnimation {
                        searching = false
                    }
                }
            }
            .foregroundColor(.gray)
            .padding(.leading, 13)
        }
        .frame(height: 40)
        .cornerRadius(13)
        .padding()
    }
}

struct SymptomsDailyView_Previews: PreviewProvider {
    static var previews: some View {
        SymptomsDailyView(date: Date())
    }
}
