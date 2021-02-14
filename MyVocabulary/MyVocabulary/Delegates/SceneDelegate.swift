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

    var window: UIWindow?
    let dataController = DataController()
    let googleController = (UIApplication.shared.delegate as! AppDelegate).googleSignDelegate
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        let contentView = ContentView(viewModel: .init(dataController: dataController))
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
}

