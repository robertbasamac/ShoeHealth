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

    @State private var shoeFormViewModel: ShoeFormViewModel?
    @State private var unitOfMeasure: UnitOfMeasure = .metric
    @State private var showDeletionConfirmation: Bool = false
    @State private var showRunTypeSelection: Bool = false
    @FocusState private var focusField: FocusField?

    private var wasDailyDefaultShoe: Bool = false
    private var isEditing: Bool
    private var hideCancelButton: Bool
    private var onSave: ((Shoe) -> Void)?
    private var shoe: Shoe?
    enum FocusField: Hashable {
        case brand
        case model
        case nickname
    }

    init(
        shoe: Shoe? = nil,
        hideCancelButton: Bool = false,
        onSave: ((Shoe) -> Void)? = nil
    ) {
        self.isEditing = shoe != nil
        self.hideCancelButton = hideCancelButton
        self.wasDailyDefaultShoe = shoe?.isDefaultShoe ?? false && shoe?.defaultRunTypes.contains(.daily) ?? false
        self.shoe = shoe
        self.onSave = onSave
    }

    var body: some View {
        Group {
            if let shoeFormViewModel {
                ShoeFormContent(
                    viewModel: shoeFormViewModel,
                    unitOfMeasure: $unitOfMeasure,
                    focusField: $focusField,
                    isEditing: isEditing,
                    wasDailyDefaultShoe: wasDailyDefaultShoe,
                    hideCancelButton: hideCancelButton,
                    onSave: onSave,
                    showDeletionConfirmation: $showDeletionConfirmation,
                    showRunTypeSelection: $showRunTypeSelection,
                    navigationRouter: navigationRouter,
                    shoesViewModel: shoesViewModel,
                    settingsManager: settingsManager,
                    shoe: shoe,
                    dismiss: dismiss
                )
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if shoeFormViewModel == nil {
                let defaultLifespan = shoe?.lifespanDistance ?? settingsManager.unitOfMeasure.range.lowerBound
                shoeFormViewModel = ShoeFormViewModel(
                    settingsManager: settingsManager,
                    selectedPhotoData: shoe?.image,
                    aquisitionDate: shoe?.aquisitionDate ?? .init(),
                    lifespanDistance: defaultLifespan,
                    isDefaultShoe: shoe?.isDefaultShoe ?? false,
                    defaultRunTypes: shoe?.defaultRunTypes ?? [],
                    shoeBrand: shoe?.brand ?? "",
                    shoeModel: shoe?.model ?? "",
                    shoeNickname: shoe?.nickname ?? "",
                    shoeID: shoe?.id ?? UUID()
                )
                unitOfMeasure = settingsManager.unitOfMeasure
            }
        }
    }
}

// MARK: - Proxy subview cu @Bindable

struct ShoeFormContent: View {
    @Bindable var viewModel: ShoeFormViewModel
    @Binding var unitOfMeasure: UnitOfMeasure
    @FocusState.Binding var focusField: ShoeFormView.FocusField?
    var isEditing: Bool
    var wasDailyDefaultShoe: Bool
    var hideCancelButton: Bool
    var onSave: ((Shoe) -> Void)?
    @Binding var showDeletionConfirmation: Bool
    @Binding var showRunTypeSelection: Bool
    var navigationRouter: NavigationRouter
    var shoesViewModel: ShoesViewModel
    var settingsManager: SettingsManager
    var shoe: Shoe?
    var dismiss: DismissAction

    var body: some View {
        Form {
            photoSection
                .task(id: viewModel.selectedPhoto) {
                    await viewModel.loadPhoto()
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
                    Text("Deleting '\(viewModel.brand) \(viewModel.model) - \(viewModel.nickname)' shoe is permanent. This action cannot be undone.")
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
            case .nickname, .none:
                focusField = nil
            }
        }
        .onAppear {
            if !isEditing {
                viewModel.isDefaultShoe = shoesViewModel.shoes.isEmpty
                viewModel.defaultRunTypes = shoesViewModel.shoes.isEmpty ? [.daily] : []

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.focusField = .brand
                }
            } else {
                viewModel.isDefaultShoe = !viewModel.defaultRunTypes.isEmpty
            }
        }
        .onChange(of: unitOfMeasure) { _, newValue in
            viewModel.convertLifespanDistance(toUnit: newValue)
        }
    }

    // MARK: - Section views

    @ViewBuilder
    private var photoSection: some View {
        Section {
            VStack(spacing: 12) {
                ZStack {
                    if let data = viewModel.selectedPhotoData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    } else {
                        Image(systemName: "square.fill")
                            .resizable()
                            .foregroundStyle(.secondary)
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                        Image(systemName: "shoe.2.fill")
                            .resizable()
                            .foregroundStyle(.primary)
                            .aspectRatio(contentMode: .fit)
                            .padding()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }

                HStack {
                    Text("Add Photo")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.theme.containerBackground, in: .capsule(style: .circular))

                    if viewModel.selectedPhotoData != nil {
                        Image(systemName: "xmark")
                            .font(.callout)
                            .foregroundStyle(.red)
                            .padding(10)
                            .background(Color.theme.containerBackground, in: .circle)
                            .onTapGesture {
                                viewModel.selectedPhoto = nil
                                viewModel.selectedPhotoData = nil
                            }
                    }
                }
                .animation(.smooth, value: viewModel.selectedPhotoData)
            }
            .frame(maxWidth: .infinity)
            .photosPicker(isPresented: $viewModel.showPhotosPicker, selection: $viewModel.selectedPhoto, matching: .images)
            .onTapGesture {
                viewModel.showPhotosPicker.toggle()
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }

    @ViewBuilder
    private var detailsSection: some View {
        Section {
            TextField("Brand", text: $viewModel.brand)
                .focused($focusField, equals: .brand)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)

            TextField("Model", text: $viewModel.model)
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
            TextField("Nickname", text: $viewModel.nickname)
                .focused($focusField, equals: .nickname)
                .textInputAutocapitalization(.words)
        }
    }

    @ViewBuilder
    private var setDefaultSection: some View {
        Section {
            Toggle("Set as default shoe", isOn: Binding(
                get: { viewModel.isDefaultShoe },
                set: { isOn in
                    if isOn {
                        withAnimation {
                            viewModel.isDefaultShoe = true
                        }

                        if viewModel.defaultRunTypes.isEmpty {
                            viewModel.defaultRunTypes = [.daily]
                            showRunTypeSelection = true
                        }
                    } else {
                        withAnimation {
                            viewModel.isDefaultShoe = false
                        }
                    }
                }
            ))
            .tint(Color.theme.accent)
            .disabled(shouldPreventDefaultOff())
            .onChange(of: viewModel.defaultRunTypes) { _, newValue in
                withAnimation {
                    viewModel.isDefaultShoe = !newValue.isEmpty
                }
            }

            if viewModel.isDefaultShoe {
                Button {
                    showRunTypeSelection = true
                } label: {
                    HStack {
                        Text(viewModel.defaultRunTypes.map { $0.rawValue.lowercased() }.joined(separator: ", "))
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
                            selectedRunTypes: viewModel.defaultRunTypes,
                            preventDeselectingDaily: shouldPreventDefaultOff()
                        ) { selectedRunTypes in
                            viewModel.defaultRunTypes = selectedRunTypes
                        }
                    }
                    .presentationDetents([.medium])
                    .interactiveDismissDisabled()
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
                Text(String(format: "%.0f\(unitOfMeasure.symbol)", viewModel.lifespanDistance))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)

                Slider(value: $viewModel.lifespanDistance, in: unitOfMeasure.range, step: 50) {
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
            DatePicker("Aquisition Date", selection: $viewModel.aquisitionDate, in: ...Date.now, displayedComponents: [.date])
                .datePickerStyle(.graphical)
        } header: {
            Text("Aquisition Date")
        }
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        if !hideCancelButton {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button {
                let settingsUnitOfMeasure = settingsManager.unitOfMeasure
                if settingsUnitOfMeasure != unitOfMeasure {
                    viewModel.lifespanDistance = settingsUnitOfMeasure == .metric ? viewModel.lifespanDistance * 1.60934 : viewModel.lifespanDistance / 1.60934
                }

                if isEditing {
                    shoesViewModel.updateShoe(
                        shoeID: viewModel.shoeID ?? UUID(),
                        nickname: viewModel.nickname,
                        brand: viewModel.brand,
                        model: viewModel.model,
                        isDefaultShoe: viewModel.isDefaultShoe,
                        defaultRunTypes: viewModel.defaultRunTypes,
                        lifespanDistance: viewModel.lifespanDistance,
                        aquisitionDate: viewModel.aquisitionDate,
                        image: viewModel.selectedPhotoData
                    )

                    if wasDailyDefaultShoe && isNotDailyDefaultShoeAnymore() && !shoesViewModel.shoes.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            navigationRouter.showSheet = .setDefaultShoe(forRunType: .daily)
                        }
                    }
                } else {
                    let newShoe = shoesViewModel.addShoe(
                        nickname: viewModel.nickname,
                        brand: viewModel.brand,
                        model: viewModel.model,
                        lifespanDistance: viewModel.lifespanDistance,
                        aquisitionDate: viewModel.aquisitionDate,
                        isDefaultShoe: viewModel.isDefaultShoe,
                        defaultRunTypes: viewModel.defaultRunTypes,
                        image: viewModel.selectedPhotoData
                    )

                    onSave?(newShoe)
                }

                settingsManager.setUnitOfMeasure(to: unitOfMeasure)
                dismiss()
            } label: {
                Text("Save")
            }
            .disabled(viewModel.brand.isEmpty || viewModel.model.isEmpty || viewModel.nickname.isEmpty)
        }
    }

    // MARK: - Helper Methods

    private func deleteShoe() {
        withAnimation {
            shoesViewModel.deleteShoe(viewModel.shoeID ?? UUID())
        }

        dismiss()
        navigationRouter.deleteShoe(viewModel.shoeID ?? UUID())

        if wasDailyDefaultShoe && !shoesViewModel.shoes.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                navigationRouter.showSheet = .setDefaultShoe(forRunType: .daily)
            }
        }
    }

    private func shouldPreventDefaultOff() -> Bool {
        return (!isEditing && shoesViewModel.shoes.isEmpty) || (isEditing && shoesViewModel.shoes.count == 1)
    }

    private func isNotDailyDefaultShoeAnymore() -> Bool {
        return (viewModel.isDefaultShoe && !viewModel.defaultRunTypes.contains(.daily) || !viewModel.isDefaultShoe)
    }
}

// MARK: - Previews

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoeFormView(shoe: Shoe.previewShoe)
        }
    }
}
