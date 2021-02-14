//
//  PlaceholderView.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 13/5/21.
//

import SwiftUI

struct PlaceholderView: View {
    
    var image: Image
    var text: Text
    
    var body: some View {
        VStack {
            image
                .resizable()
                .scaledToFit()
                .padding()
                .frame(width: 150, height: 150)
                .foregroundColor(Color("Gray"))
            text
                .multilineTextAlignment(.center)
                .foregroundColor(Color("Dark Gray"))
                .padding(.top)
                .fixedSize(horizontal: false, vertical: true)
        }
        .scrollableLazyVStack
        .padding()
    }
}

struct PlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderView(
            image: Image(systemName: "die.face.4"),
            text: Text("You must have at least 4 translations to start the quiz.")
        )
    }
}
