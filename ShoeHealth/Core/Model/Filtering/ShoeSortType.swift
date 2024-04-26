//
//  ShoeSortType.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 16.01.2024.
//

import Foundation

enum ShoeSortType: String, Identifiable, CaseIterable {
    
    var id: Self { self }

    case brand       = "Brand"
    case model       = "Model"
    case distance    = "Distance"
    case wear        = "Wear"
    case lastRunDate = "Recently Used"
}
