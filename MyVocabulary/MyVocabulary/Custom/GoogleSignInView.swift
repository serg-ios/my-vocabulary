//
//  GoogleSignInView.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 14/3/21.
//

import SwiftUI
import GoogleSignIn

/// Google Sign In official button is only available for `UIKit`, so `UIViewRepresentable` is needed.
struct GoogleSignInView: UIViewRepresentable {

    // MARK: - UIViewRepresentable methods

    func makeUIView(context: Context) -> GIDSignInButton {
        GIDSignInButton()
    }
    
    func updateUIView(_ uiView: GIDSignInButton, context: Context) {
        // Do nothing.
    }
}

// MARK: - Preview

struct GoogleSignInView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleSignInView()
    }
}
