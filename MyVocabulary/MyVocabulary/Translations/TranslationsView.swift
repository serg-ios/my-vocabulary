//
//  TranslationsView.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 14/2/21.
//

import SwiftUI

struct TranslationsView: View {
    
    @StateObject private var viewModel: ViewModel
    @Binding var translations: [Translation]
    
    init(translations: Binding<[Translation]>, viewModel: ViewModel) {
        self._translations = translations
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        UIScrollView.appearance().keyboardDismissMode = .onDrag
        return NavigationView {
            Group {
                if case .loaded(let filteredTranslations) = viewModel.status {
                    VStack {
                        SearchBarView(searchString: $viewModel.searchString.onChange {
                            viewModel.updateStatus(for: translations)
                        }, error: {
                            filteredTranslations.isEmpty ? "Not found." : nil
                        })
                        ForEach(filteredTranslations, id: \.self) { translation in
                            TranslationView(translation: translation)
                        }
                        .scrollableLazyVStack
                    }
                    .accentColor(Color("Light Blue"))
                    .toolbar {
                        ToolbarItem {
                            Button {
                                viewModel.deleteAll()
                                UIApplication.shared.sendAction(
                                    #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
                                )
                            } label: {
                                Image(systemName: "xmark.bin")
                            }
                            .disabled(!viewModel.searchString.isEmpty)
                        }
                    }
                } else {
                    PlaceholderView(
                        image: Image(systemName: "externaldrive.badge.plus"),
                        text: Text("First, export your Google Translate favorite translations into a Google Drive spreadsheet.")
                    )
                }
            }
            .navigationTitle(Text("Translations"))
        }
        .accentColor(Color("Red"))
        .onAppear { viewModel.updateStatus(for: translations) }
        .onChange(of: translations, perform: viewModel.updateStatus)
    }
}


// MARK: - Preview

struct TranslationsView_Previews: PreviewProvider {
    static var previews: some View {
        let dataController = DataController.preview
        TranslationsView(
            translations: .constant(
                [
                    .example(viewContext: dataController.container.viewContext),
                    .example(viewContext: dataController.container.viewContext),
                    .example(viewContext: dataController.container.viewContext)
                ]
            ),
            viewModel: .init(dataController: dataController)
        )
    }
}
