//
//  TranslationView.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 22/2/21.
//

import SwiftUI

/// Represents a translation stored by the user.
///
/// Indicates its input, output and level.
struct TranslationView: View {

    /// The translation whose information will be rendered.
    private var translation: Translation

    /// If `true`, the output becomes visible, otherwise the output is blurred.
    ///
    /// The output is blurred by default.
    @State private var visible: Bool = false

    // MARK: - Init

    init(translation: Translation) {
        self.translation = translation
    }

    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(translation.translationInput)
                .font(.title2)
                .bold()
                .padding(.bottom, 1)
            Text(translation.translationOutput)
                .blur(radius: visible ? 0 : 8)
            SegmentedProgressBar(level: translation.level)
                .frame(height: 6)
        }
        .solidBackground()
        .padding()
        .onTapGesture { visible.toggle() }
    }
}

// MARK: - Preview

struct TranslationView_Previews: PreviewProvider {
    static var previews: some View {
        TranslationView(translation: Translation.example(viewContext: DataController.preview.container.viewContext))
    }
}

