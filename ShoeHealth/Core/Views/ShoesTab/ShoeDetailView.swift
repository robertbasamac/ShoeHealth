//
//  ShoeDetailView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 18.04.2024.
//

import SwiftUI

struct ShoeDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    private var shoe: Shoe
    
    @State private var showEditShoe: Bool = false

    @State private var showHeader: Bool = false
    @State private var opacity: CGFloat = 0
    @State private var headerOpacity: CGFloat = 0

    init(shoe: Shoe) {
        self.shoe = shoe
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            header
                .frame(maxHeight: .infinity, alignment: .top)
                .zIndex(2)
            
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    Group {
                        if let imageData = shoe.image {
                            StretchyHeaderCell(height: 250, title: shoe.model, subtitle: shoe.brand, imageData: imageData)
                        } else {
                            StaticHeaderCell(title: shoe.model, subtitle: shoe.brand)
                        }
                    }
                    .overlay(content: {
                        Color.black
                            .opacity(Double(opacity))
                    })
                    .readingFrame { frame in
                        readFrame(frame)
                    }
                    
                    ForEach(0..<10, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.red)
                            .padding()
                            .frame(width: 200, height: 200)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showEditShoe) {
            EditShoeView(shoe: shoe)
        }
    }
}

// MARK: - View Components

extension ShoeDetailView {
    
    @ViewBuilder
    private var header: some View {
        ZStack(alignment: .center) {
            VStack {
                Text(shoe.brand)
                    .font(.subheadline)
                Text(shoe.model)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom, content: {
                Divider()
                    .opacity(Double(headerOpacity))
                    .opacity(0.3)
            })
            .opacity(showHeader ? 1 : 0)
            
            Image(systemName: "chevron.left")
                .font(.title3)
                .fontWeight(.semibold)
                .imageScale(.medium)
                .foregroundStyle(.accent)
                .padding(8)
                .background(.bar.opacity(Double(1 - opacity)), in: Circle())
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .onTapGesture {
                    dismiss()
                }
            
            Text("Edit")
                .font(.headline)
                .foregroundStyle(.accent)
                .padding(6)
                .padding(.horizontal, 8)
                .background(.bar.opacity(Double(1 - opacity)), in: Capsule())
                .padding(.vertical, 2)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .onTapGesture {
                    showEditShoe = true
                }
        }
        .frame(height: 66)
        .background(.bar.opacity(Double(headerOpacity)), ignoresSafeAreaEdges: .top)
    }
    
}

// MARK: - Helpers

extension ShoeDetailView {
    
    private func interpolateOpacity(position: CGFloat, minPosition: CGFloat, maxPosition: CGFloat, reversed: Bool) -> Double {
        // Ensure position is within the range
        let clampedPosition = min(max(position, minPosition), maxPosition)
        
        // Calculate normalized position between 0 and 1
        let normalizedPosition = (clampedPosition - minPosition) / (maxPosition - minPosition)
        
        // Interpolate opacity between 0 and 1
        let interpolatedOpacity = reversed ? Double(1 - normalizedPosition) : Double(normalizedPosition)
        
        return interpolatedOpacity
    }
    
    private func readFrame(_ frame: CGRect) {
        showHeader = frame.maxY <= 130
        opacity = interpolateOpacity(position: frame.maxY, minPosition: 130, maxPosition: 198, reversed: true)
        headerOpacity = interpolateOpacity(position: frame.maxY, minPosition: 124, maxPosition: 128, reversed: true)
    }
}

// MARK: - Preview

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoeDetailView(shoe: Shoe.previewShoe)
                .environment(ShoesViewModel(modelContext: PreviewSampleData.container.mainContext))
        }
    }
}
