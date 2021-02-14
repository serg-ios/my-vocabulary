//
//  SegmentedProgressBar.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 4/4/21.
//

import SwiftUI

/// Progress bar compoused of N segments, each one represents a fraction of the total .
///
/// Each segment can be ON or OFF.
struct SegmentedProgressBar: View {

    /// Number of segments that will be ON.
    private var onSegments: Int
    /// Total number of segments.
    private var nSegments: Int

    // MARK: - Init

    /// Create a progress bar to express the level of knowlege of a `Translation`.
    /// - Parameters:
    ///   - level: The current level of knowledge of a translation.
    ///   - maxLevel: The highest achievable level for that translation. By default is `Translation.maxLevel`.
    init(level: Int16, maxLevel: Int16 = Translation.maxLevel) {
        self.onSegments = Int(level)
        self.nSegments = Int(maxLevel)
    }

    // MARK: - Body

    var body: some View {
        HStack {
            ForEach(0..<nSegments) { level in
                Rectangle()
                    .foregroundColor(
                        onSegments > level
                            ? Color.green
                            : Color.secondary.opacity(0.5)
                    )
            }
        }
    }
}

// MARK: - Preview

struct SegmentedProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedProgressBar(level: 8, maxLevel: 12)
            .frame(height: 23)
    }
}
