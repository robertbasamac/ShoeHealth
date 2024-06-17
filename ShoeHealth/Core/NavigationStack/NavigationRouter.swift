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
    
    @Published var workout: HKWorkout?
}
