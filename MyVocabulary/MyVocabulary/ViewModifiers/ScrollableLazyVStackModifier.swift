//
//  ScrollableLazyVStackModifier.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 13/5/21.
//

import Foundation
import SwiftUI

struct ScrollableLazyVStackModifier: ViewModifier {

    // MARK: - ViewModifier methods

    func body(content: Content) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                content
            }
        }
    }
}

extension View {
    /// Wraps any view inside a vertically scrollable lazy stack.
    var scrollableLazyVStack: some View {
        self.modifier(ScrollableLazyVStackModifier())
    }
}
