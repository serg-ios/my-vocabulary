//
//  Binding+.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 14/3/21.
//

import SwiftUI

extension Binding {
    
    /// Attaches some code to a binding, that will run after a change in its value.
    /// - Parameter handler: The block that will be run after a change in the binded value.
    /// - Returns: The binding.
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler()
            }
        )
    }
}
