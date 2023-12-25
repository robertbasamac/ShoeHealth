//
//  ShoeDetailedView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 29.11.2023.
//

import SwiftUI
import HealthKit

struct ShoeDetailedView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var shoes: [Shoe]

    @State var selectedShoeID: UUID?
    
    init(shoes: [Shoe], selectedShoeID: UUID) {
        self.shoes = shoes
        self._selectedShoeID = State(initialValue: selectedShoeID)
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 15, content: {
                    Text(shoes[0].model)
                        .font(.largeTitle.bold())
                        .frame(height: 45)
                        .padding(.horizontal, 15)
                    
                    GeometryReader {
                        let rect = $0.frame(in: .scrollView)
                        let minY = rect.minY.rounded()
                        
                        /// Shoe Card Carousel
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 0) {
                                ForEach(shoes) { shoe in
                                    ZStack {
                                        if minY == 60.0 {
                                            /// Not Scrolled - Showing all cards
                                            DetailedShoeCardView(shoe)
                                        } else {
                                            /// Scrolled - Showing only selected card
                                            if selectedShoeID == shoe.id {
                                                DetailedShoeCardView(shoe)
                                            } else {
                                                Rectangle()
                                                    .fill(.clear)
                                            }
                                        }
                                    }
                                    .containerRelativeFrame(.horizontal)
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollPosition(id: $selectedShoeID)
                        .scrollTargetBehavior(.paging)
                        .scrollClipDisabled()
                        .scrollIndicators(.hidden)
                        .scrollDisabled(minY != 60.0)
                    }
                    .frame(height: 125)
                })
                
                LazyVStack(spacing: 15, content: {
                    Menu {
                        // to show filters
                    } label: {
                        HStack(spacing: 4, content: {
                            Text("Filter By")
                            Image(systemName: "chevron.down")
                        })
                        .font(.caption)
                        .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                     
                    /// Shoes's Workouts Card View
                    ForEach(HealthKitManager.shared.workouts) { workout in
                        WorkoutListItem(workout: workout)
                    }
                })
                .padding(15)
                .mask {
                    Rectangle()
                        .visualEffect { content, proxy in
                                content
                                .offset(y: backgroundLimitOffset(proxy))
                        }
                }
                .background {
                    GeometryReader {
                        let rect = $0.frame(in: .scrollView)
                        let minY = min(rect.minY - 125, 0)
                        let progress = max(min(-minY / 25, 1), 0)
                        
                        RoundedRectangle(cornerRadius: 30 * progress, style: .continuous)
                            .fill(colorScheme == .dark ? .black : .white)
                            /// Limiting Background Scroll below the header
                            .visualEffect { content, proxy in
                                    content
                                    .offset(y: backgroundLimitOffset(proxy))
                            }
                    }
                }
            }
        }
        .scrollTargetBehavior(CustomScrollBehaviour())
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selectedShoeID == nil {
                selectedShoeID = shoes.first?.id
            }
        }
        .onChange(of: selectedShoeID) { oldValue, newValue in
            withAnimation(.snappy) {
//                shoeWorkouts = getWorkouts(of: newValue)
            }
        }
    }
    
    /// Background Limit Offset
    func backgroundLimitOffset(_ proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView).minY
        
        return minY < 100 ? -minY + 100 : 0
    }
}

// MARK: - View Components
extension ShoeDetailedView {
    @ViewBuilder
    func DetailedShoeCardView(_ shoe: Shoe) -> some View {
        GeometryReader {
            let rect = $0.frame(in: .scrollView(axis: .vertical))
            let minY = rect.minY
            let topValue: CGFloat = 60
            
            let offset = min(minY - topValue, 0)
            let progress = max(min(-offset / topValue, 1), 0)
            let scale: CGFloat = 1 + progress
            
            ZStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(Color(uiColor: .systemGray6))
                    .scaleEffect(scale, anchor: .bottom)
                
                VStack(spacing: 15) {
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
                    .tint(getProgressViewTint(for: shoe))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: . leading)
                .padding(15)
                .offset(y: progress * -25)
            }
            .offset(y: -offset)
            /// Moving til Top Value
            .offset(y: progress * -topValue)
        }
        .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    func WorkoutCardView(_ workout: HKWorkout) -> some View {
        WorkoutListItem(workout: workout)
    }
}

// MARK: - Helper Methods
extension ShoeDetailedView {
    private func getProgressViewTint(for shoe: Shoe) -> Color {
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

// MARK: - Custom Scroll Target Behaviour
struct CustomScrollBehaviour: ScrollTargetBehavior {
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        if target.rect.minY < 75 {
            target.rect = .zero
        }
    }
}

// MARK: - Previews
#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            ShoeDetailedView(shoes: Shoe.previewShoes, selectedShoeID: Shoe.previewShoes[2].id)
        }
    }
}
