//
//  ContentView.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 25/3/21.
//

import SwiftUI

struct ContentView: View {
    
    @State var selectedView: String = String(describing: TranslationsView.self)
    @StateObject private var viewModel: ViewModel
    @EnvironmentObject private var googleController: GoogleController
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        TabView(selection: $selectedView) {
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
        .onChange(of: viewModel.openURL, perform: handleURL)
        .onAppear(perform: handleOnAppear)
        .accentColor(Color("Light Blue"))
    }
    
    // MARK: - Private methods
    
    private func handleURL( _ url: URL? = nil) {
        if url?.absoluteString == "MyVocabulary://startQuiz" {
            selectedView = String(describing: QuizView.self)
        }
        viewModel.cleanOpenURL()
    }
    
    private func handleOnAppear() {
        handleURL(viewModel.openURL)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let googleController = (UIApplication.shared.delegate as! AppDelegate).googleSignDelegate
        ContentView(viewModel: .init(dataController: .preview))
            .environmentObject(googleController)
    }
}
