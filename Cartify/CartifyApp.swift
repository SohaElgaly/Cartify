//
//  CartifyApp.swift
//  Cartify
//
//  Created by Soha Elgaly on 20/07/2026.
//

import SwiftUI

@main
struct CartifyApp: App {
    @AppStorage(AppAppearance.storageKey) private var appearance = AppAppearance.system.rawValue
    var body: some Scene {
        WindowGroup {
            AuthFlowView()
                .preferredColorScheme((AppAppearance(rawValue: appearance) ?? .system).colorScheme)
        }
    }
}
