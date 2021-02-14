//
//  Bundle+.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 21/2/21.
//

import Foundation

extension Bundle {

    /// Obtains the value of a URl Scheme from the `.plist` file.
    /// - Parameter urlTypeId: The identifier of the URL Type.
    /// - Returns: The value of the URL Scheme of the URL Type, can be `nil` if there isn't.
    static func urlScheme(urlTypeId: String) -> String? {
        (((main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]])?
            .first(where: { $0["CFBundleURLName"] as? String == urlTypeId}))?["CFBundleURLSchemes"] as? [String])?.first
    }
}
