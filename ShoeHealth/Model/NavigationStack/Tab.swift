//
//  Tab.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 08.01.2024.
//

import Foundation

enum Tab: String, Identifiable, CaseIterable {
    var id: Self { self }
    
    case shoes = "Shoes"
    case workouts = "Workouts"
    
    var systemImageName: String {
        switch self {
        case .shoes:
            return "shoe.2.fill"
        case .workouts:
            return "figure.run.square.stack"
        }
    }
}
