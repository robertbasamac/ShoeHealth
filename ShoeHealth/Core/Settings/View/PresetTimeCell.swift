//
//  PresetTimeView.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 18.09.2024.
//

import SwiftUI

struct PresetTimeCell: View {
    
    var presetTime: PresetTime
    var selection: PresetTime
    var onTap: () -> Void
    
    var body: some View {
        VStack {
            Text("\(presetTime.duration.value)")
            Text(presetTime.duration.unit.rawValue)
        }
        .font(.system(size: 17, weight: .semibold, design: .default))
        .padding(8)
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemBackground))
        .foregroundColor(selection == presetTime ? Color.theme.accent : .primary)
        .cornerRadius(10)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(selection == presetTime ? Color.theme.accent : Color.clear, lineWidth: 2)
                .padding(1)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selectedPreset: PresetTime = .fiveMinutes
    
    NavigationStack {
        Form {
            Section {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
                    spacing: 16
                ) {
                    ForEach(PresetTime.allCases, id: \.self) { presetTime in
                        PresetTimeCell(
                            presetTime: presetTime,
                            selection: selectedPreset,
                            onTap: {
                                selectedPreset = presetTime
                            }
                        )
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
    }
}
