//
//  AddShoeView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.11.2023.
//

import SwiftUI
import SwiftData

struct AddShoeView: View {
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var shoeBrand: String = ""
    @State private var shoeModel: String = ""
    @State private var aquisitionDate: Date = .init()
    @State private var lifespanDistance: Double = 500
    @State private var isDefaultShoe: Bool = false
    @State private var unit: LengthFormatter.Unit = .kilometer
    
    var body: some View {
        Form {
            Section {
                TextField("Brand", text: $shoeBrand)
                    .textInputAutocapitalization(.words)
                TextField("Model", text: $shoeModel)
                    .textInputAutocapitalization(.words)
            } header: {
                Text("Branding")
            }
            
            Section {
                Toggle("Set as default shoe", isOn: $isDefaultShoe)
            }
            
            Section {
                VStack {
                    Text(String(format: "%.0f Km", lifespanDistance))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Slider(value: $lifespanDistance, in: 200...800, step: 10) {
                        Text("Lifespan distance")
                    } minimumValueLabel: {
                        VStack {
                            Text("200")
                            Text("Km")
                        }
                    } maximumValueLabel: {
                        VStack {
                            Text("800")
                            Text("Km")
                        }
                    }
                }
            } header: {
                Text("Lifespan distance")
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
    }
}

// MARK: - View Components
extension AddShoeView {
    @ToolbarContentBuilder
    private func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                shoesViewModel.addShoe(brand: shoeBrand, model: shoeModel, lifespanDistance: lifespanDistance, aquisitionDate: aquisitionDate, isDefaultShoe: isDefaultShoe)
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
        return shoeBrand.isEmpty || shoeModel.isEmpty
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
