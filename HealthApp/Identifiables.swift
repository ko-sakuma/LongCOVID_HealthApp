//
//  Identifiables.swift
//  HealthApp
//
//  Created by Ko Sakuma on 18/08/2021.
//

import Foundation

extension Int: Identifiable {
    public var id: Int { self }
}

extension Date: Identifiable {
    public var id: TimeInterval { timeIntervalSince1970 }
}
