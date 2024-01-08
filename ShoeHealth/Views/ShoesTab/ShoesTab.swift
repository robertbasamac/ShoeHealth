//
//  ShoesTab.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.11.2023.
//

import SwiftUI
import SwiftData

struct ShoesTab: View {
    @Environment(ShoesViewModel.self) private var shoesViewModel
    
    @Query private var shoes: [Shoe]
    @State private var showAddShoe: Bool = false
    
    var body: some View {
        List {
            ForEach(shoes) { shoe in
                NavigationLink(value: shoe, label: {
                    ShoeListItem(shoe: shoe)
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                })
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button {
                        shoe.retired.toggle()
                    } label: {
                        if shoe.retired {
                            Label("Reinstate", systemImage: "bolt.fill")
                        } else {
                            Label("Retire", systemImage: "bolt.slash.fill")
                        }
                    }
                    .tint(shoe.retired ? .green : .orange)
                    
                    if !shoe.isDefaultShoe {
                        Button {
                            shoesViewModel.setAsDefaultShoe(shoe)
                        } label: {
                            Label("Make Default", systemImage: "shoe.2")
                        }
                        .tint(Color.blue)
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        shoesViewModel.deleteShoe(shoe)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .listRowInsets(.init(top: 2, leading: 20, bottom: 2, trailing: 20))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .background(Color(uiColor: .systemGroupedBackground))
        .overlay {
            emptyShoesView()
        }
        .toolbar {
            toolbarItems()
        }
        .navigationDestination(for: Shoe.self) { shoe in
            ShoeDetailCarouselView(shoes: shoesViewModel.shoes, selectedShoeID: shoe.id)
        }
        .sheet(isPresented: $showAddShoe) {
            NavigationStack {
                AddShoeView()
                    .environment(shoesViewModel)
            }
            .presentationCornerRadius(20)
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - View Components
extension ShoesTab {
    @ViewBuilder
    private func emptyShoesView() -> some View {
        if shoesViewModel.shoes.isEmpty && shoes.isEmpty {
            ContentUnavailableView {
                Label("No Shoes in your collection.", systemImage: "shoe.circle")
            } description: {
                Text("New shoes you add will appear here.\nTap the button below to add a new shoe.")
            } actions: {
                Button {
                    showAddShoe.toggle()
                } label: {
                    Text("Add Shoe")
                        .padding(4)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Button {
                showAddShoe = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

// MARK: - Preview
#Preview("Filled") {
    NavigationStack {
        ShoesTab()
            .navigationTitle("Shoes")
            .modelContainer(PreviewSampleData.container)
            .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
    }
}

#Preview("Empty") {
    NavigationStack {
        ShoesTab()
            .navigationTitle("Shoes")
            .modelContainer(PreviewSampleData.emptyContainer)
            .environment(ShoesViewModel(modelContext: PreviewSampleData.emptyContainer.mainContext))
    }
}
