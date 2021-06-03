//
//  SceneDelegate.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 14/2/21.
//

import UIKit
import SwiftUI
import GoogleSignIn
import CoreSpotlight

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    /// View model of the content view, is necessary because the external launcher must be setted.
    private lazy var contentViewModel: ContentView.ViewModel = {
        .init(dataController: dataController, externalLauncher: externalLauncher)
    }()
    
    var externalLauncher: ExternalLauncher = .quickAction
    
    /// Handles iCloud data.
    let dataController = DataController()
    /// Handles Google Sign In, spreadsheets' download and parsing.
    let googleController = (UIApplication.shared.delegate as! AppDelegate).googleSignDelegate
    
    // MARK: - Scene
    
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let shortcutItem = connectionOptions.shortcutItem {
            externalLauncher = ExternalLauncher(shortcutItem.type)!
        } else if let userActivity = connectionOptions.userActivities.first {
            externalLauncher = ExternalLauncher(
                userActivity.activityType,
                translation: translation(from: userActivity)
            )!
        }
        let contentView = ContentView(viewModel: contentViewModel)
            .environmentObject(googleController)
            .onReceive(
                NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
                perform: save
            )
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            // Set the presentingViewController of the Google Sign In singleton.
            GIDSignIn.sharedInstance().presentingViewController = window.rootViewController
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func save(_ note: Notification) {
        dataController.save()
    }
    
    // MARK: - UIWindowSceneDelegate methods
    
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        contentViewModel.externalLauncher = ExternalLauncher(shortcutItem.type)!
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        contentViewModel.externalLauncher = ExternalLauncher(
            userActivity.activityType,
            translation: translation(from: userActivity)
        )!
    }
}

// MARK: - Private methods

private extension SceneDelegate {
    func translation(from userActivity: NSUserActivity) -> Translation? {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            return dataController.translation(with: uniqueIdentifier)
        }
        return nil
    }
}

