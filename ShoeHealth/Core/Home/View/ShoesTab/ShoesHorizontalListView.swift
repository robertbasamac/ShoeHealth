//
//  ShoesHorizontalListView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 14.08.2025.
//

import SwiftUI

// MARK: - Carousel View

struct ShoesHorizontalListView: View {
    
    @Environment(ShoesViewModel.self) private var shoesViewModel
    @EnvironmentObject private var storeManager: StoreManager

    let shoes: [Shoe]
    let width: CGFloat

    let onTap: (Shoe) -> Void
    let onSetDefault: (Shoe) -> Void
    let onRetireToggle: (Shoe) -> Void
    let onDeleteRequest: (Shoe) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 6) {
                ForEach(shoes) { shoe in
                    ShoeCell(shoe: shoe, width: width, cornerRadius: Constants.cornerRadius)
                        .id(shoe.id)
                        .disabled(shoesViewModel.shouldRestrictShoe(shoe.id))
                        .contextMenu {
                            if storeManager.hasFullAccess ||
                                (!storeManager.hasFullAccess &&
                                 !shoe.defaultRunTypes.contains(.daily) &&
                                 !shoesViewModel.shouldRestrictShoe(shoe.id)) {
                                Button {
                                    onSetDefault(shoe)
                                } label: {
                                    Label("Set Default", systemImage: "figure.run")
                                }
                            }

                            Button {
                                onRetireToggle(shoe)
                            } label: {
                                if shoe.isRetired {
                                    Label("Reinstate", systemImage: "bolt.fill")
                                } else {
                                    Label("Retire", systemImage: "bolt.slash.fill")
                                }
                            }

                            Button(role: .destructive) {
                                onDeleteRequest(shoe)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } preview: {
                            if shoe.image == nil {
                                ShoeCell(
                                    shoe: shoe,
                                    width: 150,
                                    cornerRadius: Constants.defaultCornerRadius,
                                    hideImage: true,
                                    displayProgress: false,
                                    reserveSpace: false
                                )
                                .padding(10)
                            } else {
                                ShoeCell(
                                    shoe: shoe,
                                    width: 300,
                                    cornerRadius: Constants.defaultCornerRadius,
                                    displayProgress: false,
                                    reserveSpace: false
                                )
                                .padding(10)
                            }
                        }
                        .onTapGesture {
                            onTap(shoe)
                        }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, Constants.horizontalMargin)
        .contentMargins(.vertical, 8)
    }
}
