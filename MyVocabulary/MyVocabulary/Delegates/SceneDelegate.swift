//
//  SceneDelegate.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 14/2/21.
//

import UIKit
import SwiftUI
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private lazy var contentViewModel: ContentView.ViewModel = {
        .init(dataController: dataController)
    }()
    
    var window: UIWindow?
    let dataController = DataController()
    let googleController = (UIApplication.shared.delegate as! AppDelegate).googleSignDelegate
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let shortcurtItemType = connectionOptions.shortcutItem?.type, let openURL = URL(string: shortcurtItemType) {
            contentViewModel.openURL = openURL
        } else if let activityType = connectionOptions.userActivities.first?.activityType, let url = URL(string: activityType) {
            contentViewModel.openURL = url
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
        contentViewModel.openURL = URL(string: shortcutItem.type)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print(userActivity)
        print(userActivity.activityType)
        contentViewModel.openURL = URL(string: userActivity.activityType)
    }
}

