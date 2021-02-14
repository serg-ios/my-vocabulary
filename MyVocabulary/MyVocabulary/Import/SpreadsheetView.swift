//
//  SpreadsheetView.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 2/4/21.
//

import SwiftUI

struct SpreadsheetView: View {

    @Binding private var translations: [Translation]
    @StateObject private var viewModel: ViewModel

    var imageName: String { viewModel.status == .imported ? "checkmark.icloud" : "icloud.and.arrow.down" }
    var imageColor: Color { viewModel.status == .imported ? Color("Gray") : Color("Light Blue") }

    init(translations: Binding<[Translation]>, viewModel: ViewModel) {
        self._translations = translations
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading) {
                Text(viewModel.spreadsheet.name)
                    .font(.title3)
                Text(viewModel.spreadsheet.numberOfTranslationsString)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            .lineLimit(1)
            Spacer()
            Button {
                viewModel.importTranslations()
            } label: {
                if case .loading = viewModel.status {
                    ProgressView()
                } else {
                    Image(systemName: imageName)
                        .foregroundColor(imageColor)
                }
            }
            .frame(minWidth: 44, minHeight: 44)
            .disabled(viewModel.status == .imported)
        }
        .onChange(of: translations, perform: viewModel.checkIfImported)
        .onAppear { viewModel.checkIfImported(translations: translations) }
    }
}

// MARK: - Preview

struct SpreadsheetView_Previews: PreviewProvider {
    static var previews: some View {
        SpreadsheetView(translations: Binding.constant([]), viewModel: .init(spreadsheet: .example))
            .padding()
    }
}
