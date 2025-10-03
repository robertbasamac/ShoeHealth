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
        VStack(spacing: 12) {
            HStack {
                ToolbarActionButton(.cancel) {
                    dismiss()
                }
                Spacer()
                ToolbarActionButton(.confirm) {
                    onDone(selectedDefaultRunTypes, selectedSuitableRunTypes)
                    dismiss()
                }
            }
            
            Group {
                if #available(iOS 26, *) {
                    Text("Run Type Assignment")
                        .font(.headline)
                    
                } else {
                    Text("Run Type Assignment")
                        .font(.footnote)
                        .textCase(.uppercase)
                }
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            
            HStack(spacing: RunTypeCapsule.capsuleSpace) {
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
            .dynamicTypeSize(...DynamicTypeSize.large)
            
            VStack(spacing: 12) {
                HStack(spacing: 4) {
                    Text("Default").foregroundStyle(.accent)
                    Text(" - ")
                    Text("Also used").foregroundStyle(.white)
                    Text(" - ")
                    Text("Not used").foregroundStyle(.gray)
                }
                .font(.caption)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)
                
                if !storeManager.hasFullAccess {
                    Text("Only 'Daily' run type is available for free users. To unlock other run types, please consider upgrading to a premium plan.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 20)
                }
            }
        }
        .padding([.horizontal, .top], 20)
        .padding(.bottom, storeManager.hasFullAccess ? 30 : 20)
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
    
    RunTypeSelectionView(selectedDefaultRunTypes: defaultRunTypeSelections, selectedSuitableRunTypes: suitableRunTypeSelections, preventDeselectingDaily: false) { defaultTypes, suitableTypes in
        defaultRunTypeSelections = defaultTypes
        suitableRunTypeSelections = suitableTypes
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .environmentObject(StoreManager.shared)
}
