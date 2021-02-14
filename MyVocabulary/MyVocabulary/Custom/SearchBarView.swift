//
//  SearchBarView.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 13/5/21.
//

import SwiftUI

struct SearchBarView: View {
    
    @Binding var searchString: String
    
    var error: () -> String?
    
    init(searchString: Binding<String>, error: @escaping () -> String?) {
        self._searchString = searchString
        self.error = error
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Filter", text: $searchString)
                    .font(.title2)
                    .padding(.leading)
                Button {
                    searchString = ""
                } label: {
                    Image(systemName: "delete.left")
                        .frame(minWidth: 44, minHeight: 44)
                }
                .padding(.trailing, 8)
            }
            .padding([.top, .bottom], 2)
            .foregroundColor(Color("Dark Gray"))
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("Gray").opacity(0.3))
            )
            if let error = error() {
                Text(error)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("Red"))
                    .padding(.leading)
            }
        }
        .padding()
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(searchString: .constant("")) {
            "Error"
        }
    }
}
