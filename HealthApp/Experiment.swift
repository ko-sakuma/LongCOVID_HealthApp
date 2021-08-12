//
//  Experiment.swift
//  HealthApp
//
//  Created by Ko Sakuma on 10/08/2021.
//

import SwiftUI

struct Experiment: View {
    let data = (1...100).map { "Item \($0)" }

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(data, id: \.self) { item in
                    Text(item)
                }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: 300)
    }
}

struct Experiment_Previews: PreviewProvider {
    static var previews: some View {
        Experiment()
    }
}
