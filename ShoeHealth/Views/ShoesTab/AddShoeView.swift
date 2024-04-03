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
    
    @State private var showPhotosPicker: Bool = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedPhotoData: Data?
    
    @State private var unit: LengthFormatter.Unit = .kilometer
    
    @FocusState private var focusField: FocusField?
    
    enum FocusField: Hashable {
        case brand
        case model
        case nickname
    }
    
    var body: some View {
        Form {
            photoSection
            
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
            isDefaultShoe = shoesViewModel.shoes.isEmpty ? true : false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusField = .brand
            }
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
                    if let selectedPhotoData, let uiImage = UIImage(data: selectedPhotoData) {
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
                
                Text("Add Photo")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(20)
            }
            .frame(maxWidth: .infinity)
            .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhoto, photoLibrary: .shared())
            .onTapGesture {
                focusField = nil
                showPhotosPicker.toggle()
            }
            .task(id: selectedPhoto) {
                if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                    selectedPhotoData = data
                }
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        Section {
            TextField("Brand", text: $shoeBrand)
                .focused($focusField, equals: .brand)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
            TextField("Model", text: $shoeModel)
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
            TextField("Nickname", text: $shoeNickname)
                .focused($focusField, equals: .nickname)
                .textInputAutocapitalization(.words)
        }
    }
    
    @ViewBuilder
    private var setDefaultSection: some View {
        Section {
            Toggle("Set as default shoe", isOn: $isDefaultShoe)
                .disabled(shoesViewModel.shoes.isEmpty)
                .tint(Color.accentColor)
        }
    }
    
    @ViewBuilder
    private var lifespanSection: some View {
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
    }
    
    @ViewBuilder
    private var aquisitionDateSection: some View {
        Section {
            DatePicker("Aquisition Date", selection: $aquisitionDate, in: ...Date.now, displayedComponents: [.date])
                .datePickerStyle(.graphical)
        } header: {
            Text("Aquisition Date")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
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
