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
    @Previewable @State var runTypeSelections: [RunType] = []
    
    RunTypeSelectionView(selectedRunTypes: $runTypeSelections)
}
