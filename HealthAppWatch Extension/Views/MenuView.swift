//
//  Menu.swift
//  HealthAppWatch Extension
//
//  Created by Ko Sakuma on 01/07/2021.
//
// NOTE: This is for experiments. 

import SwiftUI

struct MenuView: View {
    var body: some View {

        Button(action: {
                }) {
                    ZStack {
                        Circle()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        Text("Press me")
                    }
                }

    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
