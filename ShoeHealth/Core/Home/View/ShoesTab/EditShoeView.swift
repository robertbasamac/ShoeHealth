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
    @State private var aquisitionDate: Date
    @State private var lifespanDistance: Double
    @State private var isDefaultShoe: Bool = false
    
    @State private var vm: AddShoeViewModel

    init(shoe: Shoe) {
        self.shoe = shoe
        self._aquisitionDate = State(wrappedValue: shoe.aquisitionDate)
        self._lifespanDistance = State(wrappedValue: shoe.lifespanDistance)
        self._isDefaultShoe = State(wrappedValue: shoe.isDefaultShoe)
        self._vm = State(initialValue: AddShoeViewModel(selectedPhotoData: shoe.image))
    }
    
    var body: some View {
        Form {
            photoSection
                .task(id: vm.selectedPhoto) {
                    await vm.loadPhoto()
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
    }
}

// MARK: - View Components

extension EditShoeView {
    
    @ViewBuilder
    private var photoSection: some View {
        Section {
            VStack(spacing: 12) {
                ZStack {
                    if let data = vm.selectedPhotoData, let uiImage = UIImage(data: data) {
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
            .photosPicker(isPresented: $vm.showPhotosPicker, selection: $vm.selectedPhoto, photoLibrary: .shared())
            .onTapGesture {
                vm.showPhotosPicker.toggle()
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        Section {
            TextField(shoe.brand.isEmpty ? "Enter brand here..." : shoe.brand, text: $shoeBrand)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
            TextField(shoe.model.isEmpty ? "Enter model here..." : shoe.model, text: $shoeModel)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
        } header: {
            Text("Details")
        }
    }
    
    @ViewBuilder
    private var nicknameSection: some View {
        Section {
            TextField(shoe.nickname.isEmpty ? "Enter nickname here..." : shoe.nickname, text: $shoeNickname)
                .textInputAutocapitalization(.words)
        }
    }
    
    @ViewBuilder
    private var setDefaultSection: some View {
        Section {
            Toggle("Set as default shoe", isOn: $isDefaultShoe)
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
                shoesViewModel.updateShoe(shoeID: shoe.id, nickname: shoeNickname, brand: shoeBrand, model: shoeModel, setDefaultShoe: isDefaultShoe, lifespanDistance: lifespanDistance, aquisitionDate: aquisitionDate, image: vm.selectedPhotoData)
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
