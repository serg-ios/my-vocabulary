//
//  ContentView.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 25/3/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var activity: NSUserActivity?
    @State private var selectedView: String = String(describing: TranslationsView.self)
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
        .onChange(of: viewModel.externalLauncher, perform: handleExternalLauncher)
        .onAppear(perform: handleOnAppear)
        .accentColor(Color("Light Blue"))
    }
}

// MARK: - Private methods

private extension ContentView {
    func registerSiriShortcut() {
        activity = NSUserActivity(activityType: ExternalLauncher.siriShortcut.rawValue)
        activity?.title = NSLocalizedString("Start quiz", comment: "")
        activity?.isEligibleForSearch = true
        activity?.isEligibleForPrediction = true
        activity?.becomeCurrent()
    }
    
    func handleExternalLauncher( _ externalLauncher: ExternalLauncher? = nil) {
        switch externalLauncher {
        case .siriShortcut, .quickAction, .spotlight, .multipleTranslationsWidget, .randomTranslationWidget:
            selectedView = String(describing: QuizView.self)
        default:
            break
        }
        viewModel.cleanExternalLauncher()
    }
    
    func handleOnAppear() {
        handleExternalLauncher(viewModel.externalLauncher)
        registerSiriShortcut()
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
