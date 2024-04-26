//
//  ShoeCardView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 28.11.2023.
//

import SwiftUI

struct ShoeListItem: View {
    
    var shoe: Shoe
    var width: CGFloat = 140
    
    var body: some View {
        HStack(spacing: 0) {
            ShoeImage(imageData: shoe.image)
                .frame(width: width, height: width)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangleProgressView(progress: shoe.wearPercentage, color: shoe.wearColor)
                }
            
            detailsSection
        }
    }
}

// MARK: - View Components

extension ShoeListItem {
    
    @ViewBuilder
    private var detailsSection: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("\(shoe.brand)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                
                Text("\(shoe.model)")
                    .font(.headline)
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.4)
            }
            .frame(maxHeight: .infinity, alignment: .topLeading)
            
            ProgressView(value: shoe.currentDistance, total: shoe.lifespanDistance) {
                HStack {
                    Text("\(distanceFormatter.string(fromValue: shoe.currentDistance, unit: .kilometer))")
                    Spacer()
                    Text("\(distanceFormatter.string(fromValue: shoe.lifespanDistance, unit: .kilometer))")
                }
                .font(.footnote)
                .overlay(alignment: .center) {
                    Text("\(shoe.wearPercentageAsString)")
                        .font(.footnote)
                }
            }
            .tint(shoe.wearColor)
        }
        .frame(maxWidth: .infinity,  maxHeight: .infinity, alignment: .leading)
        .padding(12)
    }
}

// MARK: - Previews

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            List {
                ForEach(Shoe.previewShoes) { shoe in
                    Section {
                        ShoeListItem(shoe: shoe)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .listRowInsets(.init(top: 2, leading: 20, bottom: 2, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Shoes")
        }
    }
}
