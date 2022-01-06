//
//  ViewBlueprint.swift
//  DoubleCheck_2
//
//  Created by Phlippie Bosman on 2022/01/06.
//

import SwiftUI

/// View/edit existing blueprint
struct ViewBlueprintView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        NavigationView {
            BlueprintView(appState: appState)
                .navigationTitle("Blueprint")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button("Start task") {
                    appState.startTask(from: appState.viewingBlueprint ?? .init(name: "", items: []))
                })
        }
    }
}
