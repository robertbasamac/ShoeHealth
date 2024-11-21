//
//  ShoeFormViewModel.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 08.07.2024.
//

import Foundation
import Observation
import PhotosUI
import SwiftUI

@Observable
final class ShoeFormViewModel {
    
    var selectedPhotoData: Data? = nil
    var selectedPhoto: PhotosPickerItem? = nil
    var showPhotosPicker = false
    
    var aquisitionDate: Date
    var lifespanDistance: Double
    var isDefaultShoe: Bool
    var brand: String
    var model: String
    var nickname: String
    var shoeID: UUID?
    
    // MARK: - Initializer
    
    init(
        selectedPhotoData: Data? = nil,
        aquisitionDate: Date = .init(),
        lifespanDistance: Double = SettingsManager.shared.unitOfMeasure.range.lowerBound,
        isDefaultShoe: Bool = false,
        shoeBrand: String = "",
        shoeModel: String = "",
        shoeNickname: String = "",
        shoeID: UUID = UUID()
    ) {
        self.selectedPhotoData = selectedPhotoData
        self.aquisitionDate = aquisitionDate
        self.lifespanDistance = lifespanDistance
        self.isDefaultShoe = isDefaultShoe
        self.brand = shoeBrand
        self.model = shoeModel
        self.nickname = shoeNickname
        self.shoeID = shoeID
    }
    
    // MARK: - Photo Handling
    
    func loadPhoto() async {
        guard let selectedPhoto = selectedPhoto else { return }
        do {
            if let data = try await selectedPhoto.loadTransferable(type: Data.self) {
                await MainActor.run {
                    self.selectedPhotoData = data
                }
            }
        } catch {
            print("Error loading photo: \(error)")
        }
    }
    
    // MARK: - Lifespan Distance Conversion
    
    func convertLifespanDistance(toUnit targetUnit: UnitOfMeasure) {
        self.lifespanDistance = UnitOfMeasure.convert(distance: lifespanDistance, toUnit: targetUnit)
    }
}
