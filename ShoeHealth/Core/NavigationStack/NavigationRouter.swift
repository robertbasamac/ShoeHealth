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
    @Published var showShoeDetails: Shoe?
}

extension NavigationRouter {
    
    enum SheetType: Identifiable {
        case addShoe
        case setDefaultShoe
        case addWorkoutToShoe(workoutID: UUID)
        case addMultipleWorkoutsToShoe(workoutIDs: [UUID])

        
        var id: UUID {
            switch self {
            case .addShoe:
                return UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
            case .setDefaultShoe:
                return UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
            case .addWorkoutToShoe(let workoutID):
                return workoutID
            case .addMultipleWorkoutsToShoe(let workoutIDs):
                return workoutIDs.last!
            }
        }
        
        static func == (lhs: SheetType, rhs: SheetType) -> Bool {
            switch (lhs, rhs) {
            case (.addShoe, .addShoe), (.setDefaultShoe, .setDefaultShoe):
                return true
            case let (.addWorkoutToShoe(workout1), .addWorkoutToShoe(workout2)):
                return workout1 == workout2
            case let (.addMultipleWorkoutsToShoe(workouts1), .addMultipleWorkoutsToShoe(workouts2)):
                return workouts1 == workouts2
            default:
                return false
            }
        }
    }
}
