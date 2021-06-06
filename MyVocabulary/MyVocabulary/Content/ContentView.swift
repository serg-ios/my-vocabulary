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
            QuizView(
                translations: $viewModel.translations,
                appAction: $viewModel.appAction,
                viewModel: .init(dataController: viewModel.dataController)
            )
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
        .onChange(of: viewModel.appAction, perform: handleAppAction)
        .onAppear(perform: handleOnAppear)
        .accentColor(Color("Light Blue"))
    }
}

// MARK: - Private methods

private extension ContentView {
    
    /// Call this when a quiz is started, so the action is registered to be eligible as a Siri shortcut.
    func registerSiriShortcut() {
        activity = NSUserActivity(activityType: SiriShortcuts.startQuiz.rawValue)
        activity?.title = NSLocalizedString("Start quiz", comment: "")
        activity?.isEligibleForSearch = true
        activity?.isEligibleForPrediction = true
        activity?.becomeCurrent()
    }
    
    /// Code that will run when a new `AppAction` has been launched from outside the app: Siri shortcut, Spotlight, Widget, Quick Action...
    /// - Parameter appAction: The action performed.
    func handleAppAction( _ appAction: AppAction? = nil) {
        switch appAction {
        case .startQuiz:
            selectedView = String(describing: QuizView.self)
        default:
            break
        }
    }
    
    /// This method handles all the actions that are run in the appearance of the view.
    func handleOnAppear() {
        handleAppAction(viewModel.appAction)
        registerSiriShortcut()
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let googleController = (UIApplication.shared.delegate as! AppDelegate).googleSignDelegate
        ContentView(viewModel: .init(dataController: .preview, appAction: nil))
            .environmentObject(googleController)
    }
}
