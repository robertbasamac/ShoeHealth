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
    
    @State private var addViewModel: AddShoeViewModel
    
    @State private var unitOfMeasure: UnitOfMeasure = SettingsManager.shared.unitOfMeasure
    @AppStorage("UNIT_OF_MEASURE", store: UserDefaults(suiteName: "group.com.robertbasamac.ShoeHealth")) private var unitOfMeasureString: String = UnitOfMeasure.metric.rawValue
    
    init(shoe: Shoe) {
        self.shoe = shoe
        self._addViewModel = State(initialValue: AddShoeViewModel(selectedPhotoData: shoe.image,
                                                                  aquisitionDate: shoe.aquisitionDate,
                                                                  lifespanDistance: shoe.lifespanDistance,
                                                                  isDefaultShoe: shoe.isDefaultShoe
                                                                 )
        )
    }
    
    var body: some View {
        Form {
            photoSection
                .task(id: addViewModel.selectedPhoto) {
                    if addViewModel.selectedPhoto != nil {
                        await addViewModel.loadPhoto()
                    }
                }
            
            detailsSection
            
            nicknameSection
            
            setDefaultSection
            
            lifespanSection
            
            aquisitionDateSection
        }
        .navigationTitle("Update Shoe")
        .navigationBarTitleDisplayMode(.inline)
        .listSectionSpacing(.compact)
        .toolbar {
            toolbarItems()
        }
        .onChange(of: self.unitOfMeasure) { _, newValue in
            addViewModel.convertLifespanDistance(unitOfMeasure: newValue)
        }
        .onChange(of: unitOfMeasureString) { _, newValue in
            unitOfMeasure = UnitOfMeasure(rawValue: newValue) ?? .metric
        }
    }
}

// MARK: - View Components

extension EditShoeView {
    
    @ViewBuilder
    private var photoSection: some View {
        Section {
            VStack(spacing: 12) {
                ZStack {
                    if let data = addViewModel.selectedPhotoData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Image(systemName: "square.fill")
                            .resizable()
                            .foregroundStyle(.secondary)
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        Image(systemName: "shoe.2.fill")
                            .resizable()
                            .foregroundStyle(.primary)
                            .aspectRatio(contentMode: .fit)
                            .padding()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                HStack {
                    Text("Add Photo")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(uiColor: .secondarySystemBackground), in: .capsule(style: .circular))
                    
                    if addViewModel.selectedPhotoData != nil {
                        Image(systemName: "xmark")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(.red)
                            .padding(10)
                            .background(Color(uiColor: .secondarySystemBackground), in: .circle)
                            .onTapGesture {
                                addViewModel.selectedPhoto = nil
                                addViewModel.selectedPhotoData = nil
                            }

                    }
                }
                .animation(.smooth, value: addViewModel.selectedPhotoData)
            }
            .frame(maxWidth: .infinity)
            .photosPicker(isPresented: $addViewModel.showPhotosPicker, selection: $addViewModel.selectedPhoto, matching: .images, photoLibrary: .shared())
            .onTapGesture {
                addViewModel.showPhotosPicker.toggle()
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        Section {
            TextField(shoe.brand.isEmpty ? "Enter brand here..." : shoe.brand, text: $addViewModel.shoeBrand)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
            TextField(shoe.model.isEmpty ? "Enter model here..." : shoe.model, text: $addViewModel.shoeModel)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
        } header: {
            Text("Details")
        }
    }
    
    @ViewBuilder
    private var nicknameSection: some View {
        Section {
            TextField(shoe.nickname.isEmpty ? "Enter nickname here..." : shoe.nickname, text: $addViewModel.shoeNickname)
                .textInputAutocapitalization(.words)
        }
    }
    
    @ViewBuilder
    private var setDefaultSection: some View {
        Section {
            Toggle("Set as default shoe", isOn: $addViewModel.isDefaultShoe)
                .tint(Color.accentColor)
        }
    }
    
    @ViewBuilder
    private var lifespanSection: some View {
        Section {
            HStack {
                Text("Unit of Measure")
                Spacer(minLength: 40)
                Picker("Unit", selection: $unitOfMeasure) {
                    Text(UnitOfMeasure.metric.rawValue).tag(UnitOfMeasure.metric)
                    Text(UnitOfMeasure.imperial.rawValue).tag(UnitOfMeasure.imperial)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            VStack(spacing: 2) {
                Text(String(format: "%.0f\(unitOfMeasure.symbol)", addViewModel.lifespanDistance))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Slider(value: $addViewModel.lifespanDistance, in: unitOfMeasure.range, step: 50) {
                    Text("Lifespan distance")
                } minimumValueLabel: {
                    VStack {
                        Text(String(format: "%.0f", unitOfMeasure.range.lowerBound))
                        Text(unitOfMeasure.symbol)
                    }
                    .font(.caption)
                } maximumValueLabel: {
                    VStack {
                        Text(String(format: "%.0f", unitOfMeasure.range.upperBound))
                        Text(unitOfMeasure.symbol)
                    }
                    .font(.caption)
                }
            }
        } header: {
            Text("Lifespan distance")
        } footer: {
            Text("It's generally accepted that the standard lifespan of road running shoes is somewhere between 300 and 500 miles. It depends on the running surface, running conditions, owner's bodyweight any other factors.")
        }
    }
    
    @ViewBuilder
    private var aquisitionDateSection: some View {
        Section {
            DatePicker("Aquisition Date", selection: $addViewModel.aquisitionDate, in: ...Date.now, displayedComponents: [.date])
                .datePickerStyle(.graphical)
        } header: {
            Text("Aquisition Date")
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button {
                let settingsUnitOfMeasure = SettingsManager.shared.unitOfMeasure
                
                if settingsUnitOfMeasure != unitOfMeasure {
                    addViewModel.lifespanDistance = settingsUnitOfMeasure == .metric ? addViewModel.lifespanDistance * 1.60934 : addViewModel.lifespanDistance / 1.60934
                }
                
                shoesViewModel.updateShoe(shoeID: shoe.id, nickname: addViewModel.shoeNickname, brand: addViewModel.shoeBrand, model: addViewModel.shoeModel, setDefaultShoe: addViewModel.isDefaultShoe, lifespanDistance: addViewModel.lifespanDistance, aquisitionDate: addViewModel.aquisitionDate, image: addViewModel.selectedPhotoData)
                SettingsManager.shared.setUnitOfMeasure(to: unitOfMeasure)
                
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
