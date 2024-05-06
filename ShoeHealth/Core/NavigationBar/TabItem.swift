//
//  TabItem.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 08.01.2024.
//

import Foundation

enum TabItem: String, Hashable, Identifiable, CaseIterable {
    var id: Self { self }
    
    case shoes = "Shoes"
    case workouts = "Workouts"
    case settings = "Settings"
    
    var systemImageName: String {
        switch self {
        case .shoes:
            return "shoe.2.fill"
        case .workouts:
            return "figure.run.square.stack.fill"
        case .settings:
            return "gearshape.fill"
        }
    }
}
