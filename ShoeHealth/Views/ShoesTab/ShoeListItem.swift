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
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("\(shoe.brand)")
                    Text("\(shoe.model)")
                }
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .topTrailing) {
                    VStack(alignment: .trailing) {
                        Text("\(shoe.aquisitionDate, formatter: dateFormatter)")
                            .font(.subheadline)
                            .padding(.vertical, 3)
                        
                        Image(systemName: "circle.fill")
                            .foregroundStyle(.green)
                            .opacity(shoe.isDefaultShoe ? 1 : 0)
                    }
                }
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
            .tint(getProgressViewTint())
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Helper Methods
extension ShoeListItem {
    private func getProgressViewTint() -> Color {
        let wear = shoe.currentDistance / shoe.lifespanDistance
        if wear < 0.6 {
            return .green
        } else if wear < 0.8 {
            return .orange
        } else {
            return .red
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
