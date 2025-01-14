//
//  NavigationRouter.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 04.01.2024.
//

import SwiftUI
import HealthKit
import OSLog

private let logger = Logger(subsystem: "Shoe Health", category: "NavigationRouter")

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
    private var shoesStack: [AnyHashable] = []

    @Published var workoutsNavigationPath: NavigationPath = NavigationPath()
    private var workoutsStack: [AnyHashable] = []
    
    @Published var showSheet: SheetType?
    @Published var showShoeDetails: Shoe?
    @Published var showLimitAlert: Bool = false
    @Published var showPaywall: Bool = false
}

// MARK: - Navigation Handling

extension NavigationRouter {
    
    enum Destination {
        case category(ShoeCategory)
        case shoe(Shoe)
    }
    
    func navigate(to destination: Destination) {
        switch destination {
        case .category(let category):
            switch selectedTab {
            case .shoes:
                shoesNavigationPath.append(category)
                shoesStack.append(category)
            case .workouts:
                return
            case .settings:
                return
            }
        case .shoe(let shoe):
            switch selectedTab {
            case .shoes:
                shoesNavigationPath.append(shoe)
                shoesStack.append(shoe)
            case .workouts:
                workoutsNavigationPath.append(shoe)
                workoutsStack.append(shoe)
            case .settings:
                return
            }
        }
    }
    
    func navigateBack() {
        switch selectedTab {
        case .shoes:
            if !shoesNavigationPath.isEmpty {
                shoesNavigationPath.removeLast()
                shoesStack.removeLast()
            }
        case .workouts:
            if !workoutsNavigationPath.isEmpty {
                workoutsNavigationPath.removeLast()
                workoutsStack.removeLast()
            }
        case .settings:
            return
        }
    }
    
    func navigateToRoot() {
        switch selectedTab {
        case .shoes:
            shoesNavigationPath = NavigationPath()
            shoesStack.removeAll()
        case .workouts:
            workoutsNavigationPath = NavigationPath()
            workoutsStack.removeAll()
        case .settings:
            return
        }
    }
    
    func deleteShoe(_ shoeID: UUID) {
        if showShoeDetails?.id == shoeID {
            showShoeDetails = nil
        }
        
        removeShoe(from: &shoesStack, navigationPath: &shoesNavigationPath, shoeID: shoeID)
        removeShoe(from: &workoutsStack, navigationPath: &workoutsNavigationPath, shoeID: shoeID)
    }
    
    private func removeShoe(from stack: inout [AnyHashable], navigationPath: inout NavigationPath, shoeID: UUID) {
        guard let _ = stack.first(where: { ($0 as? Shoe)?.id == shoeID }) else {
            logger.debug("Shoe not found.")
            return
        }
        
        logger.debug("Shoe found.")
        
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
        
        stack.removeLast()
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
        case setDefaultShoe(forRunType: RunType)
        case addWorkoutToShoe(workoutID: UUID)
        case addMultipleWorkoutsToShoe(workoutIDs: [UUID])
        
        var id: UUID {
            switch self {
            case .addShoe:
                return UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
            case .setDefaultShoe(let runType):
                let paddedHash = String(format: "%032x", runType.hashValue) // Create a 32-character hexadecimal string
                let uuidString = "\(paddedHash.prefix(8))-\(paddedHash.dropFirst(8).prefix(4))-\(paddedHash.dropFirst(12).prefix(4))-\(paddedHash.dropFirst(16).prefix(4))-\(paddedHash.dropFirst(20).prefix(12))"
                return UUID(uuidString: uuidString)!
            case .addWorkoutToShoe(let workoutID):
                return workoutID
            case .addMultipleWorkoutsToShoe(let workoutIDs):
                return workoutIDs.last!
            }
        }
        
        static func == (lhs: SheetType, rhs: SheetType) -> Bool {
            switch (lhs, rhs) {
            case (.addShoe, .addShoe):
                return true
            case let (.setDefaultShoe(runType1), .setDefaultShoe(runType2)):
                return runType1 == runType2
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
