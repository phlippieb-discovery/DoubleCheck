//
//  DoubleCheck_2App.swift
//  DoubleCheck_2
//
//  Created by Phlippie Bosman on 2022/01/04.
//

import SwiftUI

@main
struct DoubleCheck_2App: App {
    var body: some Scene {
        WindowGroup {
            ContentView(appState: .demo)
        }
    }
}

extension AppState {
    static var demo: AppState = {
        var result = AppState()
        
        result.activeTasks = [
            .init(
                name: "Shopping trip",
                items: [
                    .init(text: "Milk")
                ])
        ]
        
        return result
    }()
}
