//
//  RunTypeSelectionView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 04.01.2025.
//

import SwiftUI

struct RunTypeSelectionView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedRunTypes: [RunType]
    
    var isEditing: Bool
    var hasShoes: Bool
    
    var body: some View {
        List(RunType.allCases, id: \.self) { runType in
            HStack {
                Text(runType.rawValue.capitalized)
                
                Spacer()
                
                if selectedRunTypes.contains(runType) {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color.theme.accent)
                }
            }
            .contentShape(.rect)
            .onTapGesture {
                if selectedRunTypes.contains(runType) {
                    // Prevent deselecting .daily if the condition applies
                    if runType == .daily && !isEditing && !hasShoes {
                        return // Do nothing
                    }
                    selectedRunTypes.removeAll { $0 == runType }
                } else {
                    selectedRunTypes.append(runType)
                }
            }
        }
        .navigationTitle("Default Run Types")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}


// MARK: - Preview

#Preview {
    @Previewable @State var runTypeSelections: [RunType] = [.daily]
    
    RunTypeSelectionView(selectedRunTypes: $runTypeSelections, isEditing: false, hasShoes: false)
}
