//
//  ImageModifier.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 4/4/21.
//

import SwiftUI

/// Useful to create `ViewModifiers` for specific views, like `Image`.
///
/// For example, `resizable()` could not be applied to a `View`, so it would be impossible to use it in the body of a `ViewModifier`.
protocol ImageModifier {

    /// The type of view representing the body.
    associatedtype Body : View

    /// Gets the current body of the caller.
    /// - Parameter content: Proxy for the `Image` that will have the modifier represented by `Self` applied to it.
    func body(content: Image) -> Self.Body
}

extension Image {
    /// Applies a modifier to an `Image` and returns a new `Image`.
    /// - Parameter modifier: The modifier to apply to this `Image`.
    func modifier<M>(_ modifier: M) -> some View where M: ImageModifier {
        modifier.body(content: self)
    }
}
