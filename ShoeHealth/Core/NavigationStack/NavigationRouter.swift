//
//  NavigationRouter.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 04.01.2024.
//

import SwiftUI
import HealthKit

/// A `NavigationRouter` that manages the navigation state of the app's tabbed and sheet-based UI components.
///
/// The `NavigationRouter` is an `ObservableObject` that holds the state for the selected tab and various sheet
/// presentations within the app. It allows for dynamic navigation control, enabling the app to handle multiple
/// navigation scenarios such as showing detailed views or presenting sheets with specific content.
///
/// This class exposes the following properties:
/// - `selectedTab`: The currently selected tab in the tab-based navigation.
/// - `shoesNavigationPath`: A `NavigationPath` that tracks the navigation history and current state of views related to shoes. It manages the stack of views for navigating between categories, shoe details, and other shoe-related screens.
/// - `showSheet`: An optional `SheetType` enum instance representing the sheet that should be displayed.
/// - `showShoeDetails`: An optional `Shoe` model representing the shoe details to be shown.
/// - `showLimitAlert`: A boolean that is being used to show an alert if 3 shoes limit has been reached without having unlimited access
/// - `showPaywall`: A boolean that is being used to display the Paywall for in-app purchases.
///
final class NavigationRouter: ObservableObject {
    
    @Published var selectedTab: TabItem = .shoes
    
    @Published var shoesNavigationPath: NavigationPath = NavigationPath()
    
    @Published var showSheet: SheetType?
    @Published var showShoeDetails: Shoe?
    @Published var showLimitAlert: Bool = false
    @Published var showPaywall: Bool = false
}

// MARK: - Navigation Destination

extension NavigationRouter {
    
    enum Destination {
        case category(ShoeCategory)
        case shoe(Shoe)
    }
    
    func navigate(to destination: Destination) {
        switch destination {
        case .category(let category):
            shoesNavigationPath.append(category)
        case .shoe(let shoe):
            shoesNavigationPath.append(shoe)
        }
    }
    
    func navigateBack() {
        if !shoesNavigationPath.isEmpty {
            shoesNavigationPath.removeLast()
        }
    }
    
    func navigateToRoot() {
        shoesNavigationPath = NavigationPath()
    }
}

// MARK: - Sheet Type

extension NavigationRouter {
    
    /// The `SheetType` enum supports various sheet presentations:
    /// - `.addShoe`: A sheet for adding a new shoe.
    /// - `.setDefaultShoe`: A sheet for setting the default shoe.
    /// - `.addWorkoutToShoe(workoutID: UUID)`: A sheet for adding a specific workout to a shoe.
    /// - `.addMultipleWorkoutsToShoe(workoutIDs: [UUID])`: A sheet for adding multiple workouts to a shoe.
    ///
    /// The `SheetType` enum conforms to `Identifiable` by providing a unique `id` for each case, which is used to
    /// identify the sheet currently being presented. Additionally, it conforms to `Equatable` to facilitate comparison
    /// of different sheet types, enabling smooth transitions and updates to the UI.
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
