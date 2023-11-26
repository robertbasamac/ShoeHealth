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
                VStack {
                    Text("\(shoe.brand) - \(shoe.model)")
                    Text("\(shoe.aquisitionDate)")
                    Text("\(shoe.currentDistance)")
                }
            }
        }
        .sheet(isPresented: $showAddShoe) {
            NavigationStack {
                AddShoeView()
            }
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