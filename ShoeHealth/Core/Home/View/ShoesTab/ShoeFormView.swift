//
//  ShoeFormView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 30.10.2024.
//

import SwiftUI

struct ShoeFormView: View {
    
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(SettingsManager.self) private var settingsManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var addViewModel: ShoeFormViewModel
    @State private var unitOfMeasure: UnitOfMeasure = SettingsManager.shared.unitOfMeasure
    
    @FocusState private var focusField: FocusField?
    
    private var isEditing: Bool
    
    enum FocusField: Hashable {
        case brand
        case model
        case nickname
    }
    
    init(shoe: Shoe? = nil) {
        self.isEditing = shoe != nil
        self._addViewModel = State(wrappedValue: ShoeFormViewModel(
            selectedPhotoData: shoe?.image,
            aquisitionDate: shoe?.aquisitionDate ?? .init(),
            lifespanDistance: shoe?.lifespanDistance ?? SettingsManager.shared.unitOfMeasure.range.lowerBound,
            isDefaultShoe: shoe?.isDefaultShoe ?? false,
            shoeBrand: shoe?.brand ?? "",
            shoeModel: shoe?.model ?? "",
            shoeNickname: shoe?.nickname ?? "",
            shoeID: shoe?.id ?? UUID()
        ))
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
            
            if isEditing {
                Button {
                   deleteShoe()
                } label: {
                    Text("Delete Shoe")
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle(isEditing ? "Edit Shoe" : "Add Shoe")
        .navigationBarTitleDisplayMode(.inline)
        .listSectionSpacing(.compact)
        .contentMargins(.bottom, 40, for: .automatic)
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
            if !isEditing {
                addViewModel.isDefaultShoe = shoesViewModel.shoes.isEmpty
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.focusField = .brand
                }
            }            
        }
        .onChange(of: unitOfMeasure) { _, newValue in
            addViewModel.convertLifespanDistance(toUnit: newValue)
        }
    }
}

// MARK: - View Components

extension ShoeFormView {
    
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
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        Image(systemName: "square.fill")
                            .resizable()
                            .foregroundStyle(.secondary)
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Image(systemName: "shoe.2.fill")
                            .resizable()
                            .foregroundStyle(.primary)
                            .aspectRatio(contentMode: .fit)
                            .padding()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
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
            .photosPicker(isPresented: $addViewModel.showPhotosPicker, selection: $addViewModel.selectedPhoto, matching: .images)
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
                .tint(Color.theme.accent)
                .disabled(!isEditing && shoesViewModel.shoes.isEmpty)
        }
    }
    
    @ViewBuilder
    private var lifespanSection: some View {
        Section {
            HStack {
                Text("Unit of Measure")
                Spacer()
                Picker("Unit of Measure", selection: $unitOfMeasure) {
                    ForEach(UnitOfMeasure.allCases, id: \.self) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
            }
                
            VStack(spacing: 2) {
                Text(String(format: "%.0f\(unitOfMeasure.symbol)", addViewModel.lifespanDistance))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Slider(value: $addViewModel.lifespanDistance, in: unitOfMeasure.range, step: 50) {
                    Text("Lifespan distance")
                } minimumValueLabel: {
                    Text(String(format: "%.0f \(unitOfMeasure.symbol)", unitOfMeasure.range.lowerBound))
                        .font(.caption)
                } maximumValueLabel: {
                    Text(String(format: "%.0f \(unitOfMeasure.symbol)", unitOfMeasure.range.upperBound))
                        .font(.caption)
                }
            }
        } header: {
            Text("Lifespan distance")
        } footer: {
            Text("The standard lifespan of road running shoes is \(unitOfMeasure == .metric ? "500-800 kilometers" : "300-500 miles"), depending on factors like running surface, owner's bodyweight and other.")
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
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button {
                let settingsUnitOfMeasure = settingsManager.unitOfMeasure
                if settingsUnitOfMeasure != unitOfMeasure {
                    addViewModel.lifespanDistance = settingsUnitOfMeasure == .metric ? addViewModel.lifespanDistance * 1.60934 : addViewModel.lifespanDistance / 1.60934
                }
                
                if isEditing {
                    shoesViewModel.updateShoe(
                        shoeID: addViewModel.shoeID ?? UUID(),
                        nickname: addViewModel.shoeNickname,
                        brand: addViewModel.shoeBrand,
                        model: addViewModel.shoeModel,
                        setDefaultShoe: addViewModel.isDefaultShoe,
                        lifespanDistance: addViewModel.lifespanDistance,
                        aquisitionDate: addViewModel.aquisitionDate,
                        image: addViewModel.selectedPhotoData
                    )
                } else {
                    shoesViewModel.addShoe(
                        nickname: addViewModel.shoeNickname,
                        brand: addViewModel.shoeBrand,
                        model: addViewModel.shoeModel,
                        lifespanDistance: addViewModel.lifespanDistance,
                        aquisitionDate: addViewModel.aquisitionDate,
                        isDefaultShoe: addViewModel.isDefaultShoe,
                        image: addViewModel.selectedPhotoData
                    )
                }
                
                settingsManager.setUnitOfMeasure(to: unitOfMeasure)
                dismiss()
            } label: {
                Text("Save")
            }
            .disabled(addViewModel.shoeBrand.isEmpty || addViewModel.shoeModel.isEmpty || addViewModel.shoeNickname.isEmpty)
        }
    }
}

// MARK: - Helper Methods

extension ShoeFormView {
    
    private func deleteShoe() {
        withAnimation {
            shoesViewModel.deleteShoe(addViewModel.shoeID ?? UUID())
        }
        
        dismiss()        
        navigationRouter.navigateBack()
    }
}

// MARK: - Previews

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoeFormView()
                .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
                .environment(SettingsManager.shared)
        }
    }
}
