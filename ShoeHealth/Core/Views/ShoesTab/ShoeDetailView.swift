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
            
            if let imageData = shoe.image {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        StretchyHeaderCell(height: 250, title: shoe.model, subtitle: shoe.brand, imageData: imageData)
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
                                .frame(width: 200, height: 200)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.stretchyHeader)
                .contentMargins(.top, 44)
            } else {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        StaticHeaderCell(title: shoe.model, subtitle: shoe.brand)
                            .frame(height: 75)
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
                                .frame(width: 200, height: 200)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.staticHeader)
                .contentMargins(.top, 44)
            }
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
        HStack(spacing: 8) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .asHeaderImageButton()
                    .background(.bar.opacity(Double(1 - opacity)), in: .circle)
            }
            
            Spacer(minLength: 0)

            Button {
                showEditShoe.toggle()
            } label: {
                Text("Edit")
                    .asHeaderTextButton()
                    .background(.bar.opacity(Double(1 - opacity)), in: .capsule(style: .circular))
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.bar.opacity(headerOpacity))
        .overlay(alignment: .bottom, content: {
            Divider()
                .opacity(headerOpacity)
        })
        .overlay {
            Text(shoe.model)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .opacity(opacity)
                .padding(.horizontal, 90)
                .frame(maxWidth: .infinity)
        }
    }
    
}

// MARK: - Helpers

extension ShoeDetailView {
    
    private func readFrame(_ frame: CGRect) {
        let topPadding = UIApplication.topSafeAreaInsets + 44
        
        opacity = interpolateOpacity(position: frame.maxY, minPosition: topPadding + 30, maxPosition: topPadding + 75, reversed: true)
        headerOpacity = interpolateOpacity(position: frame.maxY, minPosition: topPadding, maxPosition: topPadding + 4, reversed: true)
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
