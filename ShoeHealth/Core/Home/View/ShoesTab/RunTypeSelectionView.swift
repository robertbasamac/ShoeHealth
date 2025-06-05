//
//  RunTypeSelectionView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 04.01.2025.
//

import SwiftUI

struct RunTypeSelectionView: View {
    
    @EnvironmentObject private var storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss
    
    @State var selectedDefaultRunTypes: [RunType]
    @State var selectedSuitableRunTypes: [RunType]
    
    var preventDeselectingDaily: Bool = false
    var onDone: ([RunType], [RunType]) -> Void
    
    var body: some View {
        List {
            Section {
                HStack(spacing: 4) {
                    ForEach(RunType.allCases, id: \.self) { runType in
                        let colors = CapsuleStyleHelper.colorStyle(
                            isDefault: selectedDefaultRunTypes.contains(runType),
                            isSuitable: selectedSuitableRunTypes.contains(runType),
                            isDisabled: isFeatureDisabled(for: runType)
                        )

                        RunTypeCapsule(
                            runType: runType,
                            foregroundColor: colors.foreground,
                            backgroundColor: colors.background,
                            onTap: {
                                if !isFeatureDisabled(for: runType) {
                                    if selectedDefaultRunTypes.contains(runType) {
                                        selectedDefaultRunTypes.removeAll { $0 == runType }
                                        selectedSuitableRunTypes.removeAll { $0 == runType }
                                    } else if selectedSuitableRunTypes.contains(runType) {
                                        selectedDefaultRunTypes.append(runType)
                                    } else {
                                        selectedSuitableRunTypes.append(runType)
                                    }
                                }
                            }
                        )
                    }
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .dynamicTypeSize(...DynamicTypeSize.large)
            } header: {
                Text("Run Type Assignment")
            } footer: {
                VStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Text("Default").foregroundStyle(.accent)
                        Text(" - ")
                        Text("Also used").foregroundStyle(.white)
                        Text(" - ")
                        Text("Not used").foregroundStyle(.gray)
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    if !StoreManager.shared.hasFullAccess {
                        Text("Only 'Daily' run type is available for free users. To unlock other run types, please consider upgrading to a premium plan.")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .listRowBackground(Color.clear)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    onDone(selectedDefaultRunTypes, selectedSuitableRunTypes)
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
    
    private func isFeatureDisabled(for runType: RunType) -> Bool {
        return runType != .daily && !storeManager.hasFullAccess
    }
    
    private func getRestrictedColor(_ runType: RunType, _ color: Color) -> Color {
        return storeManager.hasFullAccess ? color : (runType == .daily ? color : .secondary)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var defaultRunTypeSelections: [RunType] = [.daily]
    @Previewable @State var suitableRunTypeSelections: [RunType] = [.tempo]
    
    NavigationStack {
        RunTypeSelectionView(selectedDefaultRunTypes: defaultRunTypeSelections, selectedSuitableRunTypes: suitableRunTypeSelections, preventDeselectingDaily: false) { defaultTypes, suitableTypes in
            defaultRunTypeSelections = defaultTypes
            suitableRunTypeSelections = suitableTypes
        }
        .environmentObject(StoreManager.shared)
        .navigationTitle("Set Run Types")
    }
}
