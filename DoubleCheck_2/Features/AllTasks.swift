//
//  AllTasksFeature.swift
//  DoubleCheck_2
//
//  Created by Phlippie Bosman on 2022/01/06.
//

import SwiftUI

struct AllTasksView {
    @ObservedObject var appState: AppState
}

extension AllTasksView: View {
    var body: some View {
        List(appState.tasks.sorted(by: { $0.lastUpdated > $1.lastUpdated })) { list in
            ChecklistRow(list)
                .onTapGesture { appState.route = .viewTask(id: list.id) }
        }
        
        .navigationTitle("All tasks")
        .navigationBarTitleDisplayMode(.inline)
        
        .sheet(
            isPresented: $appState.isRouting,
            onDismiss: {},
            content: {
                switch appState.route {
                case .viewTask: TaskView(appState: appState)
                case .createBlueprint: CreateBlueprintView(appState: appState)
                case .viewBlueprint: ViewBlueprintView(appState: appState)
                case .viewAllTasks, .none: EmptyView() // N/A
                }
            })
    }
}
