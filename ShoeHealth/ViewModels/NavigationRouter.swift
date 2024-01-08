//
//  NavigationRouter.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 04.01.2024.
//

import SwiftUI
import HealthKit

final class NavigationRouter: ObservableObject {
    
    @Published var selectedTab: Tab = .shoes
    
    @Published var workout: HKWorkout?
    
    @Published var shoesTabPath = NavigationPath()
    @Published var workoutsTabPath = NavigationPath()
}
