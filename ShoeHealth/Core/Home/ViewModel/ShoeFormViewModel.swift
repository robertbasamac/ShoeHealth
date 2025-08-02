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
import OSLog

private let logger = Logger(subsystem: "Shoe Health", category: "ShoeFormViewModel")

@MainActor
@Observable
final class ShoeFormViewModel {
    
    private let settingsManager: SettingsManaging
    
    var selectedPhotoData: Data? = nil
    var selectedPhoto: PhotosPickerItem? = nil
    var showPhotosPicker = false
    
    var aquisitionDate: Date
    var lifespanDistance: Double
    var isDefaultShoe: Bool
    var defaultRunTypes: [RunType]
    var brand: String
    var model: String
    var nickname: String
    var shoeID: UUID?
    
    // MARK: - Initializer
    
    init(
        settingsManager: SettingsManaging,
        selectedPhotoData: Data? = nil,
        aquisitionDate: Date = .init(),
        lifespanDistance: Double? = nil,
        isDefaultShoe: Bool = false,
        defaultRunTypes: [RunType] = [],
        shoeBrand: String = "",
        shoeModel: String = "",
        shoeNickname: String = "",
        shoeID: UUID = UUID()
    ) {
        self.settingsManager = settingsManager
        
        self.selectedPhotoData = selectedPhotoData
        self.aquisitionDate = aquisitionDate

        if let lifespanDistance = lifespanDistance {
            self.lifespanDistance = lifespanDistance
        } else {
            self.lifespanDistance = settingsManager.unitOfMeasure.range.lowerBound
        }
        
        self.isDefaultShoe = isDefaultShoe
        self.defaultRunTypes = defaultRunTypes
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
            logger.error("Error loading photo: \(error)")
        }
    }
    
    // MARK: - Lifespan Distance Conversion
    
    func convertLifespanDistance(toUnit targetUnit: UnitOfMeasure) {
        self.lifespanDistance = UnitOfMeasure.convert(distance: lifespanDistance, toUnit: targetUnit)
    }
}
