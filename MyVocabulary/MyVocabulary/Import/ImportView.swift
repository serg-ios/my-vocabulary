//
//  ImportView.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 14/3/21.
//

import SwiftUI

struct ImportView: View {

    @StateObject private var viewModel: ViewModel
    @Binding private var translations: [Translation]

    init(translations: Binding<[Translation]>, viewModel: ViewModel) {
        self._translations = translations
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            if case .loading = viewModel.status {
                ProgressView()
            } else if case .loaded(let spreadsheets) = viewModel.status {
                ForEach(spreadsheets, id: \.id) { spreadsheet in
                    SpreadsheetView(
                        translations: $translations,
                        viewModel: .init(spreadsheet: spreadsheet) {
                            viewModel.importTranslations(from: spreadsheet, alreadyImported: translations)
                        }
                    )
                    .padding()
                }
                .scrollableLazyVStack(showIndicators: false)
                .navigationTitle("Spreadsheets")
                .toolbar {
                    ToolbarItem {
                        Button {
                            viewModel.signOut()
                        } label: {
                            if UIAccessibility.isVoiceOverRunning {
                                Text("Sign out")
                            } else {
                                Image(systemName: "person.crop.circle.badge.xmark")
                            }
                        }
                    }
                }
            } else {
                GoogleSignInView()
                    .frame(width: UIScreen.main.bounds.width - 32, height: 60)
                    .padding()
            }
        }
        .accentColor(Color("Red"))
        .onChange(of: viewModel.googleController.signInStatus, perform: { _ in
            viewModel.updateStatus()
        })
        .onAppear {
            viewModel.tryToRestoreSession()
        }
    }
}

// MARK: - Preview

struct ImportView_Previews: PreviewProvider {
    static var previews: some View {
        ImportView(
            translations: .constant([]),
            viewModel: ImportView.ViewModelMock(
                status: .loaded(spreadsheets: [
                    .init(id: "0", name: "Book 1", translations: []),
                    .init(id: "1", name: "Book 2", translations: []),
                    .init(id: "2", name: "Book 3", translations: []),
                    .init(id: "3", name: "Book 4", translations: []),
                    .init(id: "4", name: "Book 5", translations: []),
                ])
            )
        )
    }
}
