//
//  HomeFeature.swift
//  DoubleCheck_2
//
//  Created by Phlippie Bosman on 2022/01/06.
//

import SwiftUI

struct HomeView {
    @ObservedObject var appState: AppState
}

extension HomeView: View {
    var body: some View {
        List {
            // "Tasks" section
            Section(
                content: {
                    if appState.recentTasks.isEmpty {
                        Text("No tasks are currently active")
                            .font(.footnote)
                            .italic()
                            .opacity(0.5)
                    } else {
                        ForEach(appState.recentTasks) { list in
                            ChecklistRow(list)
                                .onTapGesture { appState.route = .viewTask(id: list.id) }
                        }
                    }
                }, header: {
                    HStack {
                        Text("Tasks").font(.title2)
                        Spacer()
                        Menu.init {
                            Button("New empty task") {
                                appState.startTask(from: .init(name: "", items: []))
                            }
                            ForEach(appState.blueprints) { blueprint in
                                Button(blueprint.name) {
                                    appState.startTask(from: blueprint)
                                }
                            }
                        } label: {
                            ButtonAndIcon("Start", .addCreate) {}
                        }
                    }
                }, footer: {
                    VStack(alignment: .leading) {
                        Text("Tasks are once-off checklists. Use these when you go shopping or pack for a trip.")
                        if appState.hasArchivedTasks {
                            NavigationLink("View all tasks") {
                                AllTasksView(appState: appState)
                            }.padding(1)
                        }
                    }
                })
            
            // "Blueprints" section
            Section(
                content: {
                    if appState.blueprints.isEmpty {
                        Text("You don't have any blueprints yet")
                            .font(.footnote)
                            .italic()
                            .opacity(0.5)
                    } else {
                        ForEach(appState.blueprints) { list in
                            TemplateRow(list)
                                .onTapGesture { appState.route = .viewBlueprint(id: list.id) }
                        }
                    }
                }, header: {
                    HStack {
                        Text("Blueprints").font(.title2)
                        Spacer()
                        ButtonAndIcon("Create", .addCreate, appState.createBlueprintTapped)
                    }
                }, footer: {
                    Text("Blueprints are reusable templates for task lists. When you start a new task, you can pick a blueprint to base it on; the new task will be pre-filled with the items from the blueprint.")
                })
        }
        .navigationTitle("Double Check")
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
