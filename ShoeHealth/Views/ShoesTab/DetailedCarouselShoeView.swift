//
//  DetailedCarouselShoeView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 26.12.2023.
//

import SwiftUI
import HealthKit

struct DetailedCarouselShoeView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State var shoes: [Shoe]
    @State var selectedShoeID: UUID?
    @State var workouts: [HKWorkout] = []
    
    private var selectedID: UUID
    
    /// Customization Properties
    @State private var showPagingControl: Bool = false
    @State private var disablePagingInteraction: Bool = false
    @State private var pagingSpacing: CGFloat = 20
    @State private var titleScrollSpeed: CGFloat = 0.75
    @State private var stretchContent: Bool = true
    
    init(shoes: [Shoe], selectedShoeID: UUID) {
        self._shoes = State(wrappedValue: shoes)
        self.selectedID = selectedShoeID
        UITableViewHeaderFooterView.appearance().tintColor = UIColor.clear
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CarouselSlider(activeID: $selectedShoeID,
                               data: shoes,
                               showPagingControl: showPagingControl,
                               disablePagingInteraction: disablePagingInteraction,
                               titleScrollSpeed: titleScrollSpeed,
                               pagingControlSpacing: pagingSpacing
            ) { shoe in
                RoundedRectangle(cornerRadius: 15)
                    .fill(.red)
                    .frame(width: stretchContent ? nil : 150, height: stretchContent ? 220 : 120)
            } titleContent: { shoe in
                VStack(spacing: 5) {
                    Text(shoe.model)
                        .font(.largeTitle.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                        .frame(height: 45)
                    
                    Text(shoe.brand)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .frame(height: 25)
                }
                .padding(.bottom, 15)
            }
            .safeAreaPadding([.horizontal], 35)
            
            Divider()
                .padding(.top)
            
            List {
                Section {
                    ForEach(workouts) { workout in
                        WorkoutListItem(workout: workout)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                } header: {
                    HStack {
                        Text("Workouts")
                        Spacer()
                        Menu {
                            Button {
                                workouts.shuffle()
                            } label: {
                                Text("Shuffle")
                            }
                            .buttonStyle(.plain)
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        }
                    }
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                }
                .listRowInsets(.init(top: 2, leading: 12, bottom: 2, trailing: 12))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
        }
        .navigationBarTitle("Shoes", displayMode: .inline)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemGroupedBackground))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if selectedShoeID == nil {
                    selectedShoeID = selectedID
                }
                
                workouts = getWorkouts(of: selectedShoeID!)
            }
        }
        .onChange(of: selectedShoeID ?? UUID()) { oldValue, newValue in
            withAnimation(.snappy) {
                workouts = getWorkouts(of: newValue)
            }
        }
    }
}

// MARK: - Helper Methods
extension DetailedCarouselShoeView {
    private func getWorkouts(of id: UUID) -> [HKWorkout] {
        guard let selectedShoe = shoes.first(where: { $0.id == selectedShoeID } ) else { return [] }
        
        let workouts = HealthKitManager.shared.getWorkouts(forShoe: selectedShoe)
        
        return workouts
    }
    
    private func scrollOffset(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.bounds(of: .scrollView)?.minX ?? 0
        
        return -minX * 0.75
    }
}

// MARK: - Previews
#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            DetailedCarouselShoeView(shoes: Shoe.previewShoes, selectedShoeID: Shoe.previewShoes[2].id)
        }
    }
}
