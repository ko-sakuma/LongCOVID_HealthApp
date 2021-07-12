//
//  Step.swift
//  HealthApp
//
//  Created by Ko Sakuma on 21/06/2021.
//

import Foundation

struct Step: Identifiable {
    let id = UUID()
    let count: Int
    let date: Date
}
