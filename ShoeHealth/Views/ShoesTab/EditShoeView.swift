//
//  EditShoeView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 05.02.2024.
//

import SwiftUI
import PhotosUI

struct EditShoeView: View {
    
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var shoe: Shoe
    
    @State private var shoeBrand: String = ""
    @State private var shoeModel: String = ""
    @State private var shoeNickname: String = ""
    @State private var aquisitionDate: Date = .init()
    @State private var lifespanDistance: Double = 800
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedPhotoData: Data?
    
    init(shoe: Shoe) {
        self.shoe = shoe
        self._aquisitionDate = State(initialValue: shoe.aquisitionDate)
        self._lifespanDistance = State(initialValue: shoe.lifespanDistance)
        self._selectedPhotoData = State(initialValue: shoe.image)
    }
    
    var body: some View {
        Form {
            Section {
                TextField(shoe.brand.isEmpty ? "Enter brand here..." : shoe.brand, text: $shoeBrand)
                    .textInputAutocapitalization(.words)
                TextField(shoe.model.isEmpty ? "Enter model here..." : shoe.model, text: $shoeModel)
                    .textInputAutocapitalization(.words)
            } header: {
                Text("Details")
            }
            
            Section {
                TextField(shoe.nickname.isEmpty ? "Enter nickname here..." : shoe.nickname, text: $shoeNickname)
                    .textInputAutocapitalization(.words)
            } header: {
                Text("Nickname")
            }
            
            Section {
                VStack(spacing: 2) {
                    Text(String(format: "%.0f Km", lifespanDistance))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Slider(value: $lifespanDistance, in: 400...1200, step: 50) {
                        Text("Lifespan distance")
                    } minimumValueLabel: {
                        VStack {
                            Text("400")
                            Text("Km")
                        }
                        .font(.caption)
                    } maximumValueLabel: {
                        VStack {
                            Text("1200")
                            Text("Km")
                        }
                        .font(.caption)
                    }
                }
            } header: {
                Text("Lifespan distance")
            } footer: {
                Text("It's generally accepted that the standard lifespan of road running shoes is somewhere between 300 and 500 miles. It depends on the running surface, running conditions, owner's bodyweight any other factors.")
            }
            
            Section {
                if let selectedPhotoData, let uiImage = UIImage(data: selectedPhotoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(8)
                }
                
                PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                    HStack {
                        Label("Add Picture", systemImage: "photo")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if selectedPhotoData != nil {
                            Button(role: .destructive) {
                                withAnimation {
                                    selectedPhoto = nil
                                    selectedPhotoData = nil
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                                    .padding(.horizontal, 6)
                                    .contentShape(.rect)
                            }
                        }
                    }
                }
            } header: {
                Text("Shoe Picture")
            } footer: {
                Text("Add a picture in landscape mode (4:3) for better quality.")
            }
            .task(id: selectedPhoto) {
                if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                    selectedPhotoData = data
                }
            }
            
            Section {
                DatePicker("Aquisition Date", selection: $aquisitionDate, in: ...Date.now, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
            } header: {
                Text("Aquisition Date")
            }
        }
        .navigationTitle("Update Shoe")
        .navigationBarTitleDisplayMode(.large)
        .listSectionSpacing(.compact)
        .toolbarRole(.editor)
        .toolbar {
            toolbarItems()
        }
    }
}

// MARK: - View Components

extension EditShoeView {
    
    @ToolbarContentBuilder
    private func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                shoesViewModel.updateShoe(shoeID: shoe.id, nickname: shoeNickname, brand: shoeBrand, model: shoeModel, lifespanDistance: lifespanDistance, aquisitionDate: aquisitionDate, image: selectedPhotoData)
                dismiss()
            } label: {
                Text("Done")
            }
        }
    }
}

// MARK: - Previews

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            EditShoeView(shoe:  Shoe.previewShoe)
                .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
        }
    }
}
