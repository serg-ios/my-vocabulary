//
//  SolidBackgroundViewModifier.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 4/4/21.
//

import SwiftUI

/// Add a `Rectangle` solid background to any `View`, so it can be tapped anywhere.
struct SolidBackgroundViewModifier: ViewModifier {

    /// The foreground color of the `Rectangle`.
    private var color: Color

    // MARK: - Init

    init(color: Color) {
        self.color = color
    }

    // MARK: - ViewModifier methods

    func body(content: Content) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(color)
            content
        }
    }
}

extension View {
    /// Adds a solid background to the view that calls this method.
    ///
    /// This makes the view tappable.
    /// - Parameter color: The foreground color that will be applied to the background. By default is `systemBackground`.
    /// - Returns: The view modified.
    func solidBackground(color: Color = Color(UIColor.systemBackground)) -> some View {
        self.modifier(SolidBackgroundViewModifier(color: color))
    }
}
