//
//  ShoeSelectionView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 27.11.2023.
//

import SwiftUI
import SwiftData
import HealthKit

struct ShoeSelectionView: View {
    
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @EnvironmentObject private var storeManager: StoreManager
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedShoe: Shoe?
    
    @State private var showAddShoe: Bool = false
    @State private var showPaywall: Bool = false
    @State private var showFeatureRestrictedAlert: Bool = false
    
    @State private var isExpandedActive: Bool = true
    @State private var isExpandedRetire: Bool = false
    
    @ScaledMetric(relativeTo: .largeTitle) private var size: CGFloat = 84
    
    private let title: String
    private let description: String
    private let systemImage: String
    private let showCancelButton: Bool
    private let onDone: (UUID) -> Void
    
    init (
        selectedShoe: Shoe? = nil,
        title: String,
        description: String,
        systemImage: String,
        showCancelButton: Bool = true,
        onDone: @escaping (
            UUID
        ) -> Void
    ) {
        self.selectedShoe = selectedShoe
        self.title = title
        self.description = description
        self.systemImage = systemImage
        self.showCancelButton = showCancelButton
        self.onDone = onDone
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            Divider()
            
            List {
                activeShoesSection
                retiredShoesSection
            }
            .listStyle(.sidebar)
            .listRowSpacing(4)
        }
        .toolbar {
            toolbarItems
        }
        .navigationDestination(isPresented: $showAddShoe) {
            ShoeFormView(hideCancelButton: true) { shoe in
                self.selectedShoe = shoe
            }
        }
        .navigationDestination(isPresented: $showPaywall) {
            PaywallView(showDismissButton: false, navigationBarVisibility: .automatic)
        }
    }
}

// MARK: - View Components

extension ShoeSelectionView {
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size, alignment: .center)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.title2.bold())
            
            Text(description)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding(.bottom)
        .padding(.horizontal)
    }
    
    private var activeShoesSection: some View {
        Section(isExpanded: $isExpandedActive, content: {
            shoesList(shoes: shoesViewModel.getShoes(for: .active))
        }, header: {
            Text("Active Shoes")
        })
    }
    
    private var retiredShoesSection: some View {
        Section(isExpanded: $isExpandedRetire, content: {
            shoesList(shoes: shoesViewModel.getShoes(for: .retired))
        }, header: {
            Text("Retired Shoes")
        })
    }
    
    private func shoesList(shoes: [Shoe]) -> some View {
        ForEach(shoes) { shoe in
            HStack(spacing: 4) {
                Image(systemName: shoe.id == selectedShoe?.id ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
                    .foregroundStyle(shoesViewModel.shouldRestrictShoe(shoe.id) ? .gray : Color.theme.accent)
                
                ShoeListItem(
                    shoe: shoe,
                    width: size,
                    cornerRadius: Constants.defaultCornerRadius,
                    imageAlignment: .trailing,
                    infoAlignment: .leading,
                    showStats: false,
                    showNavigationLink: false,
                    reserveSpace: false
                )
                .disabled(shoesViewModel.shouldRestrictShoe(shoe.id))
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
            .contentShape(.rect)
            .onTapGesture {
                if !shoesViewModel.shouldRestrictShoe(shoe.id) {
                    selectedShoe = selectedShoe == shoe ? nil : shoe
                }
            }
        }
    }
    
    private var addNewShoeButton: some View {
        Group {
            if #available(iOS 26, *) {
                Button {
                    if storeManager.hasFullAccess || !shoesViewModel.isShoesLimitReached() {
                        showAddShoe.toggle()
                    } else {
                        showFeatureRestrictedAlert.toggle()
                    }
                } label: {
                    Text("Add New Shoe")
                        .font(.callout)
                        .fontWeight(.medium)
                }
            } else {
                Button {
                    if storeManager.hasFullAccess || !shoesViewModel.isShoesLimitReached() {
                        showAddShoe.toggle()
                    } else {
                        showFeatureRestrictedAlert.toggle()
                    }
                } label: {
                    Text("Add New Shoe")
                        .font(.callout)
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .foregroundStyle(.black)
            }
        }
        .alert(FeatureAlertType.limitReached.title, isPresented: $showFeatureRestrictedAlert, actions: {
            Button(role: .cancel) {
//                dismiss()
            } label: {
                Text("Cancel")
            }
            
            Button {
                showPaywall.toggle()
            } label: {
                Text("Upgrade")
            }
        }, message: {
            Text(FeatureAlertType.limitReached.message)
        })
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        if showCancelButton {
            ToolbarItem(placement: .cancellationAction) {
                CancelButton {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            ConfirmButton {
                if let shoe = selectedShoe {
                    onDone(shoe.id)
                }
                
                dismiss()
            } label: {
                Text("Save")
            }
            .disabled(isSaveButtonDisabled())
        }
        
        ToolbarItem(placement: .status) {
            addNewShoeButton
        }
    }
}

// MARK: - Helper Methods

extension ShoeSelectionView {
    
    private func isSaveButtonDisabled() -> Bool {
        return selectedShoe == nil
    }
}

// MARK: - Previews

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoeSelectionView(selectedShoe: Shoe.previewShoe,
                              title: Prompts.SelectShoe.selectDefaultShoeTitle,
                              description: Prompts.SelectShoe.selectDefaultShoeDescription,
                              systemImage: "shoe.2",
                              onDone: { _ in })
            .environmentObject(NavigationRouter())
            .environmentObject(StoreManager.shared)
            .environment(ShoesViewModel(shoeHandler: ShoeHandler(modelContext: PreviewSampleData.container.mainContext)))
        }
    }
}
