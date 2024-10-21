//
//  ShoeCardView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 28.11.2023.
//

import SwiftUI

struct ShoeListItem: View {
    
    @Environment(\.isEnabled) private var isEnabled: Bool

    var shoe: Shoe
    var width: CGFloat = 140
    var imageAlignment: HorizontalAlignment = .leading
    var showStats: Bool = true
    var showNavigationLink: Bool = true
    
    @State private var unitOfMeasure: UnitOfMeasure = SettingsManager.shared.unitOfMeasure
    @AppStorage("UNIT_OF_MEASURE", store: UserDefaults(suiteName: "group.com.robertbasamac.ShoeHealth")) private var unitOfMeasureString: String = UnitOfMeasure.metric.rawValue
    
    var body: some View {
        HStack(spacing: 0) {
            if imageAlignment == .leading {
                ShoeImage(imageData: shoe.image)
                    .frame(width: width, height: width)
                    .overlay {
                        RoundedRectangleProgressView(progress: shoe.wearPercentage, color: shoe.wearColor, width: width, cornerRadius: 10)
                        
                        if !isEnabled {
                            Color.black.opacity(0.4)
                        }
                    }
                    .clipShape(.rect(cornerRadius: 10))
            }
            
            detailsSection
                .opacity(isEnabled ? 1 : 0.6)
            
            if imageAlignment == .trailing {
                ShoeImage(imageData: shoe.image)
                    .frame(width: width, height: width)
                    .overlay {
                        RoundedRectangleProgressView(progress: shoe.wearPercentage, color: shoe.wearColor, width: width, cornerRadius: 10)
                        
                        if !isEnabled {
                            Color.black.opacity(0.4)
                        }
                    }
                    .clipShape(.rect(cornerRadius: 10))
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
        VStack(alignment: .leading, spacing: 6) {
            Text(shoe.nickname)
                .font(.system(size: 15, weight: .semibold, design: .default))
                .italic()
                .foregroundStyle(Color.theme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .trailing) {
                    if showNavigationLink {
                        Image(systemName: "chevron.right")
                            .font(.title2.bold())
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                    }
                }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(shoe.brand)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Text("\(shoe.model)")
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.7)
            }
            
            if showStats {
                HStack {
                    StatCell(label: "CURRENT", value: shoe.totalDistance.as2DecimalsString(), unit: unitOfMeasure.symbol, labelFont: .system(size: 12), valueFont: .system(size: 18), color: .blue, textAlignment: .leading, containerAlignment: .leading)
                    StatCell(label: "REMAINING", value: (shoe.lifespanDistance - shoe.totalDistance).as2DecimalsString(), unit: unitOfMeasure.symbol, labelFont: .system(size: 12), valueFont: .system(size: 18), color: shoe.wearColor, textAlignment: .leading, containerAlignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 8)
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
