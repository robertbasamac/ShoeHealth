//
//  ShoeStatsWidgetBundle.swift
//  ShoeStatsWidget
//
//  Created by Robert Basamac on 12.02.2024.
//

import WidgetKit
import SwiftUI

@main
struct ShoeStatsWidgetBundle: WidgetBundle {
    var body: some Widget {
        DefaultShoeStatsWidget()
        ShoeStatsWidget()
    }
}
