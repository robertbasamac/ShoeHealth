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
    
    @State private var shoeFormViewModel: ShoeFormViewModel
    @State private var unitOfMeasure: UnitOfMeasure = SettingsManager.shared.unitOfMeasure
    
    @State private var showDeletionConfirmation: Bool = false
    
    @FocusState private var focusField: FocusField?
    
    private var wasDefaultShoe: Bool = false
    private var isEditing: Bool
    
    @State private var showRunTypeSelection: Bool = false
    
    enum FocusField: Hashable {
        case brand
        case model
        case nickname
    }
    
    init(shoe: Shoe? = nil) {
        self.isEditing = shoe != nil
        self.wasDefaultShoe = shoe?.isDefaultShoe ?? false
        self._shoeFormViewModel = State(wrappedValue: ShoeFormViewModel(
            selectedPhotoData: shoe?.image,
            aquisitionDate: shoe?.aquisitionDate ?? .init(),
            lifespanDistance: shoe?.lifespanDistance ?? SettingsManager.shared.unitOfMeasure.range.lowerBound,
            isDefaultShoe: shoe?.isDefaultShoe ?? false,
            defaultRunTypes: shoe?.defaultRunTypes ?? [],
            shoeBrand: shoe?.brand ?? "",
            shoeModel: shoe?.model ?? "",
            shoeNickname: shoe?.nickname ?? "",
            shoeID: shoe?.id ?? UUID()
        ))
    }
    
    var body: some View {
        Form {
            photoSection
                .task(id: shoeFormViewModel.selectedPhoto) {
                    await shoeFormViewModel.loadPhoto()
                }
            
            detailsSection
            
            nicknameSection
            
            setDefaultSection
            
            lifespanSection
            
            aquisitionDateSection
            
            if isEditing {
                Button {
                    showDeletionConfirmation.toggle()
                } label: {
                    Text("Delete Shoe")
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .confirmationDialog("Delete this shoe?", isPresented: $showDeletionConfirmation, titleVisibility: .visible) {
                    Button("Cancel", role: .cancel) { }
                    
                    Button("Delete", role: .destructive) {
                        deleteShoe()
                    }
                } message: {
                    Text("Deleting \'\(shoeFormViewModel.brand) \(shoeFormViewModel.model) - \(shoeFormViewModel.nickname)\' shoe is permanent. This action cannot be undone.")
                }
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
                shoeFormViewModel.isDefaultShoe = shoesViewModel.shoes.isEmpty
                shoeFormViewModel.defaultRunTypes = shoesViewModel.shoes.isEmpty ? [.daily] : []
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.focusField = .brand
                }
            }            
        }
        .onChange(of: unitOfMeasure) { _, newValue in
            shoeFormViewModel.convertLifespanDistance(toUnit: newValue)
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
                    if let data = shoeFormViewModel.selectedPhotoData, let uiImage = UIImage(data: data) {
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
                    
                    if shoeFormViewModel.selectedPhotoData != nil {
                        Image(systemName: "xmark")
                            .font(.callout)
                            .foregroundStyle(.red)
                            .padding(10)
                            .background(Color(uiColor: .secondarySystemBackground), in: .circle)
                            .onTapGesture {
                                shoeFormViewModel.selectedPhoto = nil
                                shoeFormViewModel.selectedPhotoData = nil
                            }
                    }
                }
                .animation(.smooth, value: shoeFormViewModel.selectedPhotoData)
            }
            .frame(maxWidth: .infinity)
            .photosPicker(isPresented: $shoeFormViewModel.showPhotosPicker, selection: $shoeFormViewModel.selectedPhoto, matching: .images)
            .onTapGesture {
                shoeFormViewModel.showPhotosPicker.toggle()
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        Section {
            TextField("Brand", text: $shoeFormViewModel.brand)
                .focused($focusField, equals: .brand)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
            
            TextField("Model", text: $shoeFormViewModel.model)
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
            TextField("Nickname", text: $shoeFormViewModel.nickname)
                .focused($focusField, equals: .nickname)
                .textInputAutocapitalization(.words)
        }
    }
    
    @ViewBuilder
    private var setDefaultSection: some View {
        Section {
            Toggle("Set as default shoe", isOn: Binding(
                get: { shoeFormViewModel.isDefaultShoe },
                set: { isOn in
                    if isOn {
                        shoeFormViewModel.isDefaultShoe = true
                        
                        if shoeFormViewModel.defaultRunTypes.isEmpty {
                            shoeFormViewModel.defaultRunTypes = [.daily]
                            showRunTypeSelection = true
                        }
                    } else {
                        shoeFormViewModel.defaultRunTypes.removeAll() // TO_DO maybe do not remove these in order to be saved between toggles and make sure to not save them to persistency if isDefaultSHoe is false
                    }
                }
            ))
            .tint(Color.theme.accent)
            .disabled(!isEditing && shoesViewModel.shoes.isEmpty)
            
            if shoeFormViewModel.isDefaultShoe {
                Button {
                    showRunTypeSelection = true
                } label: {
                    HStack {
                        Text(shoeFormViewModel.defaultRunTypes.map { $0.rawValue.lowercased() }.joined(separator: ", "))
                            .font(.footnote)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .fontWeight(.semibold)
                            .imageScale(.small)
                            .foregroundStyle(.secondary.opacity(0.5))
                    }
                    .font(.body)
                }
                .sheet(isPresented: $showRunTypeSelection) {
                    NavigationStack {
                        RunTypeSelectionView(
                            selectedRunTypes: $shoeFormViewModel.defaultRunTypes
                        )
                    }
                    .presentationDetents([.medium])
                }
            }
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
                Text(String(format: "%.0f\(unitOfMeasure.symbol)", shoeFormViewModel.lifespanDistance))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Slider(value: $shoeFormViewModel.lifespanDistance, in: unitOfMeasure.range, step: 50) {
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
            DatePicker("Aquisition Date", selection: $shoeFormViewModel.aquisitionDate, in: ...Date.now, displayedComponents: [.date])
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
                    shoeFormViewModel.lifespanDistance = settingsUnitOfMeasure == .metric ? shoeFormViewModel.lifespanDistance * 1.60934 : shoeFormViewModel.lifespanDistance / 1.60934
                }
                
                if isEditing {
                    shoesViewModel.updateShoe(
                        shoeID: shoeFormViewModel.shoeID ?? UUID(),
                        nickname: shoeFormViewModel.nickname,
                        brand: shoeFormViewModel.brand,
                        model: shoeFormViewModel.model,
                        isDefaultShoe: shoeFormViewModel.isDefaultShoe,
                        defaultRunTypes: shoeFormViewModel.defaultRunTypes,
                        lifespanDistance: shoeFormViewModel.lifespanDistance,
                        aquisitionDate: shoeFormViewModel.aquisitionDate,
                        image: shoeFormViewModel.selectedPhotoData
                    )
                } else {
                    shoesViewModel.addShoe(
                        nickname: shoeFormViewModel.nickname,
                        brand: shoeFormViewModel.brand,
                        model: shoeFormViewModel.model,
                        lifespanDistance: shoeFormViewModel.lifespanDistance,
                        aquisitionDate: shoeFormViewModel.aquisitionDate,
                        isDefaultShoe: shoeFormViewModel.isDefaultShoe,
                        defaultRunTypes: shoeFormViewModel.defaultRunTypes,
                        image: shoeFormViewModel.selectedPhotoData
                    )
                }
                
                settingsManager.setUnitOfMeasure(to: unitOfMeasure)
                dismiss()
            } label: {
                Text("Save")
            }
            .disabled(shoeFormViewModel.brand.isEmpty || shoeFormViewModel.model.isEmpty || shoeFormViewModel.nickname.isEmpty)
        }
    }
}

// MARK: - Helper Methods

extension ShoeFormView {
    
    private func deleteShoe() {
        withAnimation {
            shoesViewModel.deleteShoe(shoeFormViewModel.shoeID ?? UUID())
        }
        
        dismiss()        
        navigationRouter.deleteShoe(shoeFormViewModel.shoeID ?? UUID())
        
        if wasDefaultShoe && !shoesViewModel.shoes.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                navigationRouter.showSheet = .setDefaultShoe
            }
        }
    }
}

// MARK: - Previews

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoeFormView(shoe: Shoe.previewShoe)
                .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
                .environment(SettingsManager.shared)
        }
    }
}
