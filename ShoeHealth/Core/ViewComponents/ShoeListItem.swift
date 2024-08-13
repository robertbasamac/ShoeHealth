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
    var imageAlignment: HorizontalAlignment = .leading
        
    @State private var unitOfMeasure: UnitOfMeasure = SettingsManager.shared.unitOfMeasure
    @AppStorage("UNIT_OF_MEASURE", store: UserDefaults(suiteName: "group.com.robertbasamac.ShoeHealth")) private var unitOfMeasureString: String = UnitOfMeasure.metric.rawValue
    
    var body: some View {
        HStack(spacing: 0) {
            if imageAlignment == .leading {
                ShoeImage(imageData: shoe.image)
                    .frame(width: width, height: width)
                    .overlay {
                        RoundedRectangleProgressView(progress: shoe.wearPercentage, color: shoe.wearColor, width: width)
                    }
                    .clipShape(.rect(cornerRadius: 12))
            }
            
            detailsSection
            
            if imageAlignment == .trailing {
                ShoeImage(imageData: shoe.image)
                    .frame(width: width, height: width)
                    .overlay {
                        RoundedRectangleProgressView(progress: shoe.wearPercentage, color: shoe.wearColor, width: width)
                    }
                    .clipShape(.rect(cornerRadius: 12))
            }
        }
        .frame(height: width)
        .onChange(of: unitOfMeasureString) { _, newValue in
            unitOfMeasure = UnitOfMeasure(rawValue: newValue) ?? .metric
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
            
            HStack {
                StatCell(label: "CURRENT", value: shoe.totalDistance.as2DecimalsString(), unit: unitOfMeasure.symbol, labelFont: .system(size: 12), valueFont: .system(size: 18), color: .blue, textAlignment: .leading, containerAlignment: .leading)
                StatCell(label: "REMAINING", value: (shoe.lifespanDistance - shoe.totalDistance).as2DecimalsString(), unit: unitOfMeasure.symbol, labelFont: .system(size: 12), valueFont: .system(size: 18), color: shoe.wearColor, textAlignment: .leading, containerAlignment: .leading)
            }
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
                    ShoeListItem(shoe: shoe)
                        .listRowInsets(EdgeInsets())
                }
            }
            .listRowSpacing(4)
            .navigationTitle("Shoes")
        }
    }
}
