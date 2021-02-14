//
//  ResizeFitbImageModifier.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 4/4/21.
//

import SwiftUI

/// Makes any `Image` resizable and scaled to fit into a determined size.
struct ResizeFitImageModifier: ImageModifier {

    /// Resulting height after image resize.
    private let height: CGFloat
    /// Resulting width after image resize.
    private let width: CGFloat

    // MARK: - Init

    init(height: CGFloat, width: CGFloat) {
        self.height = height
        self.width = width
    }

    // MARK: - ImageModifier methods

    func body(content: Image) -> some View {
        content
            .resizable()
            .scaledToFit()
            .frame(width: width, height: height)
    }
}

extension Image {
    /// Makes any `Image` resizable and scaled to fit into a determined
    /// - Parameter height: Resulting height after image resize.
    /// - Parameter width: Resulting width after image resize.
    /// - Returns: The `Image` modified.
    func resizeFit(height: CGFloat,  width: CGFloat) -> some View {
        self.modifier(ResizeFitImageModifier(height: height, width: width))
    }
}
