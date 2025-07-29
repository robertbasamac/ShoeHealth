//
//  RunTypeSelectionView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 04.01.2025.
//

import SwiftUI

struct RunTypeSelectionView: View {
    
    @Environment(StoreManager.self) private var storeManager
    @Environment(\.dismiss) private var dismiss
    
    @State var selectedRunTypes: [RunType]
    
    var preventDeselectingDaily: Bool = false
    var onDone: ([RunType]) -> Void
    
    var body: some View {
        List {
            Section {
                ForEach(RunType.allCases, id: \.self) { runType in
                    HStack {
                        Text(runType.rawValue.capitalized)
                            .foregroundStyle(disableFeature(for: runType) ? .secondary : .primary)
                        
                        Spacer()
                        
                        if selectedRunTypes.contains(runType) {
                            Image(systemName: "checkmark")
                                .foregroundColor(disableFeature(for: runType) ? .secondary : Color.theme.accent)
                        }
                    }
                    .contentShape(.rect)
                    .onTapGesture {
                        if selectedRunTypes.contains(runType) {
                            if runType == .daily && preventDeselectingDaily {
                                return
                            }
                            selectedRunTypes.removeAll { $0 == runType }
                        } else {
                            selectedRunTypes.append(runType)
                        }
                    }
                    .allowsHitTesting(!disableFeature(for: runType))
                }
            } footer: {
                if !storeManager.hasFullAccess {
                    Text("Only 'Daily' run type is available for free users. To unlock other run types, please consider upgrading to a premium plan.")
                }
            }
        }
        .navigationTitle("Default Run Types")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    onDone(selectedRunTypes)
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Helper Methods

extension RunTypeSelectionView {
    
    private func disableFeature(for runType: RunType) -> Bool {
        return runType != .daily && !storeManager.hasFullAccess
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var runTypeSelections: [RunType] = [.daily]
    
    RunTypeSelectionView(selectedRunTypes: runTypeSelections, preventDeselectingDaily: false) { _ in }
}
