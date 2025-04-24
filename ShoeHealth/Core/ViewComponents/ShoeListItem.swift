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
    var width: CGFloat
    var imageAlignment: HorizontalAlignment = .leading
    var infoAlignment: Alignment = .topLeading
    var showStats: Bool = true
    var showNavigationLink: Bool = true
    var reserveSpace: Bool = true
    
    @State private var unitOfMeasure: UnitOfMeasure = SettingsManager.shared.unitOfMeasure
    @AppStorage("UNIT_OF_MEASURE", store: UserDefaults(suiteName: System.AppGroups.shoeHealth)) private var unitOfMeasureString: String = UnitOfMeasure.metric.rawValue
    
    var body: some View {
        HStack(spacing: 0) {
            if imageAlignment == .leading {
                ShoeImage(imageData: shoe.image, width: width)
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
                ShoeImage(imageData: shoe.image, width: width)
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
        .overlay(alignment: .topTrailing) {
            if showNavigationLink {
                Image(systemName: "chevron.right")
                    .font(.title2.bold())
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 20)
                    .padding(.top, 8)
            }
        }
        .onChange(of: unitOfMeasureString) { _, newValue in
            unitOfMeasure = UnitOfMeasure(rawValue: newValue) ?? .metric
        }
    }
}

// MARK: - View Components

extension ShoeListItem {
    
    @ViewBuilder
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(shoe.nickname)
                .font(.headline)
                .italic()
                .foregroundStyle(Color.theme.accent)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 35)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(shoe.brand)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Text("\(shoe.model)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2, reservesSpace: reserveSpace)
                    .multilineTextAlignment(.leading)
            }
            
            if showStats {
                distanceStat
            }
        }
        .dynamicTypeSize(DynamicTypeSize.large...DynamicTypeSize.xxxLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var distanceStat: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Distance")
                .font(.caption)
                .dynamicTypeSize(DynamicTypeSize.large...DynamicTypeSize.xxLarge)
                .lineLimit(1)
            
            Group {
                Text("\(Int(shoe.totalDistance))")
                    .foregroundStyle(shoe.wearColor) +
                Text("/")
                    .foregroundStyle(.gray) +
                Text("\(Int(shoe.lifespanDistance.rounded(toPlaces: 0)))")
                    .foregroundStyle(.blue) +
                Text("\(unitOfMeasure.symbol.uppercased())")
                    .textScale(.secondary)
                    .foregroundStyle(.blue)
            }
            .font(.headline)
            .fontWeight(.medium)
            .fontDesign(.rounded)
            .dynamicTypeSize(DynamicTypeSize.xLarge...DynamicTypeSize.xxxLarge)
            .lineLimit(1)
            .widgetAccentable(true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
}

// MARK: - Previews

#Preview {
    @Previewable @ScaledMetric(relativeTo: .largeTitle) var width: CGFloat = 140

    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            List {
                ForEach(Shoe.previewShoes) { shoe in
                    ShoeListItem(shoe: shoe, width: width)
                        .listRowInsets(EdgeInsets())
                }
            }
            .listRowSpacing(4)
            .navigationTitle("Shoes")
        }
    }
}
