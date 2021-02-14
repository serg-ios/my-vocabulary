//
//  ContentView.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 25/3/21.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel: ViewModel
    @EnvironmentObject private var googleController: GoogleController
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        TabView {
            TranslationsView(translations: $viewModel.translations, viewModel: .init(dataController: viewModel.dataController))
                .tag(String(describing: TranslationsView.self))
                .tabItem {
                    Image(systemName: "text.book.closed")
                    Text("Translations")
                }
            QuizView(translations: $viewModel.translations, viewModel: .init(dataController: viewModel.dataController))
                .tag(String(describing: QuizView.self))
                .tabItem {
                    Image(systemName: "gamecontroller")
                    Text("Quiz")
                }
            ImportView(
                translations: $viewModel.translations,
                viewModel: .init(
                    dataController: viewModel.dataController,
                    googleController: googleController
                )
            )
            .tag(String(describing: ImportView.self))
            .tabItem {
                Image(systemName: "externaldrive.badge.plus")
                Text("Import")
            }
        }
        .accentColor(Color("Light Blue"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let googleController = (UIApplication.shared.delegate as! AppDelegate).googleSignDelegate
        ContentView(viewModel: .init(dataController: .preview))
            .environmentObject(googleController)
    }
}
