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
    
    @State private var unitOfMeasure: UnitOfMeasure = SettingsManager.shared.unitOfMeasure
    @AppStorage("UNIT_OF_MEASURE", store: UserDefaults(suiteName: "group.com.robertbasamac.ShoeHealth")) private var unitOfMeasureString: String = UnitOfMeasure.metric.rawValue
    
    @FocusState private var focusField: FocusField?
    
    @State private var addViewModel = AddShoeViewModel()
    
    enum FocusField: Hashable {
        case brand
        case model
        case nickname
    }
    
    var body: some View {
        Form {
            photoSection
                .task(id: addViewModel.selectedPhoto) {
                    await addViewModel.loadPhoto()
                }
            
            detailsSection
            
            nicknameSection
            
            setDefaultSection
            
            lifespanSection
            
            aquisitionDateSection
        }
        .navigationTitle("Add New Shoe")
        .navigationBarTitleDisplayMode(.inline)
        .listSectionSpacing(.compact)
        .toolbar {
            toolbarItems
        }
        .onSubmit {
            switch focusField {
            case .brand:
                focusField = .model
            case .model:
                focusField = .nickname
            case .nickname:
                focusField = nil
            case .none:
                focusField = nil
            }
        }
        .onAppear {
            addViewModel.isDefaultShoe = shoesViewModel.shoes.isEmpty ? true : false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusField = .brand
            }
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

extension AddShoeView {
    
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
                focusField = nil
                addViewModel.showPhotosPicker.toggle()
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        Section {
            TextField("Brand", text: $addViewModel.shoeBrand)
                .focused($focusField, equals: .brand)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
            TextField("Model", text: $addViewModel.shoeModel)
                .focused($focusField, equals: .model)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
        } header: {
            Text("Details")
        }
    }
    
    @ViewBuilder
    private var nicknameSection: some View {
        Section {
            TextField("Nickname", text: $addViewModel.shoeNickname)
                .focused($focusField, equals: .nickname)
                .textInputAutocapitalization(.words)
        }
    }
    
    @ViewBuilder
    private var setDefaultSection: some View {
        Section {
            Toggle("Set as default shoe", isOn: $addViewModel.isDefaultShoe)
                .disabled(shoesViewModel.shoes.isEmpty)
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
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                let settingsUnitOfMeasure = SettingsManager.shared.unitOfMeasure
                
                if settingsUnitOfMeasure != unitOfMeasure {
                    addViewModel.lifespanDistance = settingsUnitOfMeasure == .metric ? addViewModel.lifespanDistance * 1.60934 : addViewModel.lifespanDistance / 1.60934
                }
                
                shoesViewModel.addShoe(nickname: addViewModel.shoeNickname, brand: addViewModel.shoeBrand, model: addViewModel.shoeModel, lifespanDistance: addViewModel.lifespanDistance, aquisitionDate: addViewModel.aquisitionDate, isDefaultShoe: addViewModel.isDefaultShoe, image: addViewModel.selectedPhotoData)
                SettingsManager.shared.setUnitOfMeasure(to: unitOfMeasure)
                
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
        return addViewModel.shoeBrand.isEmpty || addViewModel.shoeModel.isEmpty || addViewModel.shoeNickname.isEmpty
    }
    
    func convertLifespanDistance(_ lifespanDistance: Double, unitOfMeasure: UnitOfMeasure) -> Double {
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
        
        return roundToNearest50(convertedDistance)
    }
    
    func roundToNearest50(_ value: Double) -> Double {
        return (value / 50.0).rounded() * 50.0
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
