//
//  CreateBlueprintFeature.swift
//  DoubleCheck_2
//
//  Created by Phlippie Bosman on 2022/01/06.
//

import SwiftUI

/// Popup shell for adding a new blueprint
struct CreateBlueprintView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        NavigationView {
            IfLet($appState.viewingBlueprint) { $blueprint in
                BlueprintView(appState: appState)
                    .navigationTitle("New Blueprint")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(
                        trailing: Button("Save") {
                            appState.blueprints.append(blueprint)
                            appState.route = .viewBlueprint(id: blueprint.id)
                        }.disabled(!appState.isBlueprintValid))
            }
        }
    }
}
