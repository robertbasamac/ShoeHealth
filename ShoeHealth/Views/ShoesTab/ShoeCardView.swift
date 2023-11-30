//
//  ShoeCardView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 28.11.2023.
//

import SwiftUI

struct ShoeCardView: View {
    var shoe: Shoe
    
    private var distanceFormatter: LengthFormatter {
        let formatter = LengthFormatter()
        formatter.unitStyle = .short
        formatter.numberFormatter.maximumFractionDigits = 2
        return formatter
    }
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("\(shoe.brand)")
                    Text("\(shoe.model)")
                }
                .font(.title3.bold())
                
                Spacer(minLength: 0)
                Text("\(shoe.aquisitionDate, formatter: dateFormatter)")
                    .font(.subheadline)
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
extension ShoeCardView {
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
                        ShoeCardView(shoe: shoe)
                    }
                }
                .listSectionSpacing(.compact)
            }
        }
    }
}
