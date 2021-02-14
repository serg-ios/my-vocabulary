//
//  AppDelegate.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 14/2/21.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let googleSignDelegate = GoogleController()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Set up Google Sign In.
        GIDSignIn.sharedInstance().clientID = Bundle.urlScheme(urlTypeId: "GOOGLE_SIGN_IN_CLIENT_ID")
        GIDSignIn.sharedInstance().delegate = googleSignDelegate
        // This is necessary to request access to Google Drive documents.
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeDriveReadonly]
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

