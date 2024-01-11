//
//  AddShoeView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.11.2023.
//

import SwiftUI
import PhotosUI

struct AddShoeView: View {
    
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var shoeNickname: String = ""
    @State private var shoeBrand: String = ""
    @State private var shoeModel: String = ""
    @State private var aquisitionDate: Date = .init()
    @State private var lifespanDistance: Double = 800
    @State private var isDefaultShoe: Bool = false
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedPhotoData: Data?
    
    @State private var unit: LengthFormatter.Unit = .kilometer
    
    var body: some View {
        Form {
            Section {
                TextField("Brand", text: $shoeBrand)
                    .textInputAutocapitalization(.words)
                TextField("Model", text: $shoeModel)
                    .textInputAutocapitalization(.words)
            } header: {
                Text("Details")
            }
            
            Section {
                TextField("Nickname", text: $shoeNickname)
                    .textInputAutocapitalization(.words)
            }
            
            Section {
                Toggle("Set as default shoe", isOn: $isDefaultShoe)
                    .disabled(shoesViewModel.shoes.isEmpty)
                    .tint(Color.accentColor)
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
                Text("Add a picture in landscape mode for better quality.")
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
        .navigationTitle("Add New Shoe")
        .navigationBarTitleDisplayMode(.inline)
        .listSectionSpacing(.compact)
        .toolbar {
            toolbarItems()
        }
        .onAppear {
            isDefaultShoe = shoesViewModel.shoes.isEmpty ? true : false
        }
    }
}

// MARK: - View Components

extension AddShoeView {
    
    @ToolbarContentBuilder
    private func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                shoesViewModel.addShoe(nickname: shoeNickname, brand: shoeBrand, model: shoeModel, lifespanDistance: lifespanDistance, aquisitionDate: aquisitionDate, isDefaultShoe: isDefaultShoe, image: selectedPhotoData)
                dismiss()
            } label: {
                Text("Save")
            }
            .disabled(isSaveButtonDisabled())
        }
    }
}

// MARK: - Helper Methods

extension AddShoeView {
    
    private func isSaveButtonDisabled() -> Bool {
        return shoeBrand.isEmpty || shoeModel.isEmpty || shoeNickname.isEmpty
    }
}

// MARK: - Previews

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            AddShoeView()
                .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
        }
    }
}
