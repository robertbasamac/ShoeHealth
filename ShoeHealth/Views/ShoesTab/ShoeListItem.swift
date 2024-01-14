//
//  ShoeCardView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 28.11.2023.
//

import SwiftUI

struct ShoeListItem: View {
    
    var shoe: Shoe
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 16) {
                ShoeImage(shoe: shoe, width: 350)
                
                VStack(alignment: .leading) {
                    Text("\(shoe.brand)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlay(alignment: .trailing) {
                            Image(systemName: "circle.fill")
                                .foregroundStyle(.green)
                                .opacity(shoe.isDefaultShoe ? 1 : 0)
                        }
                    
                    Text("\(shoe.model)")
                        .font(.title2.bold())
                        .lineLimit(2, reservesSpace: true)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
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
            .tint(shoe.wearColorTint)
        }
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
                    }
                }
                .listSectionSpacing(.compact)
            }
        }
    }
}
