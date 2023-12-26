//
//  ShoeDetailedView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 29.11.2023.
//

import SwiftUI
import HealthKit

struct ShoeDetailedView: View {
    var shoes: [Shoe]

    @State var selectedShoeID: UUID?
    @State var workouts: [HKWorkout] = []
    
    init(shoes: [Shoe], selectedShoeID: UUID) {
        self.shoes = shoes
        self._selectedShoeID = State(initialValue: selectedShoeID)
    }
    
    var body: some View {
        VStack {
            GeometryReader {
                let size = $0.size
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(shoes) { shoe in
                            ShoeCardView(shoe: shoe)
                                .padding()
                                .background(Color(uiColor: .tertiarySystemGroupedBackground), in: .rect(cornerRadius: 20))
                                .padding(.horizontal)
                                .frame(width: size.width)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollPosition(id: $selectedShoeID)
                .scrollTargetBehavior(.paging)
            }
            .frame(height: 140)
            
            ScrollView(.vertical) {
                VStack {
                    ForEach(workouts) { workout in
                        WorkoutListItem(workout: workout)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(15)
                            .background(.black, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(15)
            }
            .background(Color(uiColor: .systemGray), in: TopRoundedRectangle(cornerRadius: 20))
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selectedShoeID == nil {
                selectedShoeID = shoes.first?.id
            }
            
            self.workouts = getWorkouts(of: selectedShoeID!)

        }
        .onChange(of: selectedShoeID ?? UUID()) { oldValue, newValue in
            withAnimation(.snappy) {
                workouts = getWorkouts(of: newValue)
            }
        }
    }
}

// MARK: - Helper Methods
extension ShoeDetailedView {
    private func getWorkouts(of id: UUID) -> [HKWorkout] {
        let selectedShoe = shoes.first(where: { $0.id == selectedShoeID } )
        let workouts = HealthKitManager.shared.getWorkouts(forShoe: selectedShoe!)
        
        return workouts
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
