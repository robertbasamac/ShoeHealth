//
//  AddShoeViewModel.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 08.07.2024.
//

import Foundation
import Observation
import PhotosUI
import SwiftUI

@Observable
final class AddShoeViewModel {

    var showPhotosPicker: Bool = false
    
    var selectedPhoto: PhotosPickerItem?
    var selectedPhotoData: Data?
    var shoeNickname: String = ""
    var shoeBrand: String = ""
    var shoeModel: String = ""
    var aquisitionDate: Date
    var lifespanDistance: Double
    var isDefaultShoe: Bool
    
    init(selectedPhotoData: Data? = nil,
         aquisitionDate: Date = .init(),
         lifespanDistance: Double = SettingsManager.shared.unitOfMeasure.range.lowerBound,
         isDefaultShoe: Bool = false
    ) {
        self.selectedPhotoData = selectedPhotoData
        self.aquisitionDate = aquisitionDate
        self.lifespanDistance = lifespanDistance
        self.isDefaultShoe = isDefaultShoe
    }

    func loadPhoto() async {
        if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
            await MainActor.run {
                selectedPhotoData = data
            }
        }
    }
    
    func convertLifespanDistance(unitOfMeasure: UnitOfMeasure) {
        var convertedDistance: Double
        
        let distanceRange = unitOfMeasure.range
        
        if unitOfMeasure == .metric {
            convertedDistance = lifespanDistance * 1.60934 // miles to km
            
            if convertedDistance < distanceRange.lowerBound {
                convertedDistance = distanceRange.lowerBound
            } else if convertedDistance > distanceRange.upperBound {
                convertedDistance = distanceRange.upperBound
            }
        } else {
            convertedDistance = lifespanDistance / 1.60934 // km to miles

            if convertedDistance < distanceRange.lowerBound {
                convertedDistance = distanceRange.lowerBound
            } else if convertedDistance > distanceRange.upperBound {
                convertedDistance = distanceRange.upperBound
            }
        }
        
        self.lifespanDistance = roundToNearest50(convertedDistance)
    }
    
    private func roundToNearest50(_ value: Double) -> Double {
        return (value / 50.0).rounded() * 50.0
    }
}
