//
//  ShoesTab.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.11.2023.
//

import SwiftUI
import SwiftData

struct ShoesTab: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Shoe.aquisitionDate, order: .forward) private var shoes: [Shoe]

    @State private var showAddShoe: Bool = false
    
    var body: some View {
        List {
            ForEach(shoes) { shoe in
                Section {
                    NavigationLink {
                        ShoeDetailedView(shoe: shoe)
                    } label: {
                        ShoeCardView(shoe: shoe)
                    }
                }
                .listSectionSpacing(.compact)
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
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
                }
            }
            .onDelete(perform: deleteShoe)
        }
        .sheet(isPresented: $showAddShoe) {
            NavigationStack {
                AddShoeView()
            }
            .presentationCornerRadius(20)
            .presentationDragIndicator(.visible)
        }
        .overlay {
            emptyShoesView()
        }
        .toolbar {
            toolbarItems()
        }
    }
}

// MARK: - View Components
extension ShoesTab {
    @ViewBuilder
    private func emptyShoesView() -> some View {
        if shoes.isEmpty {
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

// MARK: - Helper Methods
extension ShoesTab {
    private func deleteShoe(at offsets: IndexSet) {
        withAnimation {
            offsets.map { shoes[$0] }.forEach { shoe in
                modelContext.delete(shoe)
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
    }
}

#Preview("Empty") {
    NavigationStack {
        ShoesTab()
            .navigationTitle("Shoes")
            .modelContainer(PreviewSampleData.emptyContainer)
    }
}
