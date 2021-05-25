//
//  ScrollableLazyVStackModifier.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 13/5/21.
//

import Foundation
import SwiftUI

struct ScrollableLazyVStackModifier: ViewModifier {
    
    var showsIndicators: Bool

    // MARK: - ViewModifier methods

    func body(content: Content) -> some View {
        ScrollView(showsIndicators: showsIndicators) {
            LazyVStack {
                content
            }
        }
    }
}

extension View {
    /// Wraps any view inside a vertically scrollable lazy stack.
    func scrollableLazyVStack(showIndicators: Bool) -> some View {
        self.modifier(ScrollableLazyVStackModifier(showsIndicators: showIndicators))
    }
}
