//
//  OnboardingPage.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 12.06.2024.
//

import SwiftUI

struct OnboardingPage: View {
    
    private let image: String
    private let title: String
    private let description: String
    private let note: String
    
    init(image: String, title: String, description: String, note: String = "") {
        self.image = image
        self.title = title
        self.description = description
        self.note = note
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let _ = UIImage(named: image) {
                Image(image)
                    .resizable()
                    .frame(width: 84, height: 84)
            } else {
                Image(systemName: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.red, .white)
                    .frame(width: 84, height: 84)
            }
            
            Text(title)
                .font(.title)
                .fontWeight(.semibold)
                .lineLimit(2, reservesSpace: true)
            
            Text(description)
                .font(.body)
            
            if !note.isEmpty {
                Text(note)
                    .font(.footnote)
                    .foregroundStyle(.pink)
            }
            
            Spacer(minLength: 0)
        }
        .fontDesign(.rounded)
        .padding(.vertical, 20)
        .padding(.bottom, 30)
        .padding(.horizontal, 40)
    }
}

// MARK: - Preview

#Preview {
    OnboardingScreen()
}
