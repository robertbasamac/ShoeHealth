//
//  SFSafariViewController.swift
//  ShoeHealth
//
//  Created by Robert Basamac on 11.11.2024.
//

import UIKit
import SwiftUI
import SafariServices

// MARK: - UIViewControllerRepresentable

struct SFSafariView: UIViewControllerRepresentable {
    
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariView>) {
        // No need to do anything here
    }
}

// MARK: - View Modifier

private struct SafariViewControllerViewModifier: ViewModifier {
    
    @State private var urlToOpen: URL?

    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                /// Catch any URLs that are about to be opened in an external browser.
                /// Instead, handle them here and store the URL to reopen in our sheet.
                urlToOpen = url
                return .handled
            })
            .sheet(isPresented: $urlToOpen.mappedToBool(), onDismiss: {
                urlToOpen = nil
            }, content: {
                SFSafariView(url: urlToOpen!)
            })
    }
}

extension View {
    
    /// Monitor the `openURL` environment variable and handle them in-app instead of via
    /// the external web browser.
    /// Uses the `SafariViewWrapper` which will present the URL in a `SFSafariViewController`.
    func handleOpenURLInApp() -> some View {
        modifier(SafariViewControllerViewModifier())
    }
}

// MARK: - Binding extensions

@MainActor
extension Binding where Value == Bool {
    
    init(binding: Binding<(some Any)?>) {
        self.init(
            get: {
                binding.wrappedValue != nil
            },
            set: { newValue in
                guard newValue == false else { return }
                binding.wrappedValue = nil
            }
        )
    }
}

extension Binding {
    
    /// Maps an optional binding to a `Binding<Bool>`.
    /// This can be used to, for example, use an `Error?` object to decide whether or not to show an
    /// alert, without needing to rely on a separately handled `Binding<Bool>`.
    @MainActor func mappedToBool<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        Binding<Bool>(binding: self)
    }
}
