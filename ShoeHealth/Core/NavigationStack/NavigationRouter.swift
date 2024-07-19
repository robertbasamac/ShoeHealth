//
//  NavigationRouter.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 04.01.2024.
//

import SwiftUI
import HealthKit

final class NavigationRouter: ObservableObject {
    
    @Published var selectedTab: TabItem = .shoes
    @Published var showSheet: SheetType?
    
    @Published var shoesTabPath = NavigationPath()
}

extension NavigationRouter {
    
    enum SheetType: Identifiable {
        case addShoe
        case setDefaultShoe
        case addToShoe(workoutID: UUID)
        
        var id: UUID {
            switch self {
            case .addShoe:
                return UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
            case .setDefaultShoe:
                return UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
            case .addToShoe(let workoutID):
                return workoutID
            }
        }
        
        static func == (lhs: SheetType, rhs: SheetType) -> Bool {
            switch (lhs, rhs) {
            case (.addShoe, .addShoe), (.setDefaultShoe, .setDefaultShoe):
                return true
            case let (.addToShoe(workout1), .addToShoe(workout2)):
                return workout1 == workout2
            default:
                return false
            }
        }
    }
}
