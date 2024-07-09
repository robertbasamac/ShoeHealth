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

    init(selectedPhoto: PhotosPickerItem? = nil, selectedPhotoData: Data? = nil) {
        self.showPhotosPicker = showPhotosPicker
        self.selectedPhoto = selectedPhoto
        self.selectedPhotoData = selectedPhotoData
    }

    func loadPhoto() async {
        if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
            await MainActor.run {
                selectedPhotoData = data
            }
        }
    }
}
