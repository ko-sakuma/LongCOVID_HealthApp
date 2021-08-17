//
//  ContentView.swift
//  JsonExperimentsWatch Extension
//
//  Created by Ko Sakuma on 15/07/2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var symptomJSONManager = SymptomJSONManager()
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                UpdateMeWatchView()
                    .environmentObject(symptomJSONManager)
                
            }
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            
    }
}
