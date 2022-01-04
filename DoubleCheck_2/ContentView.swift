//
//  ContentView.swift
//  DoubleCheck_2
//
//  Created by Phlippie Bosman on 2022/01/04.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        NavigationView {
            HomeView(appState: appState)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BlueprintView(appState: appState)
        }
        
        ContentView(appState: appState)
        
        ContentView(appState: appState)
            .environment(\.colorScheme, .dark)
    }
    
    private static var appState: AppState = {
        let appState = AppState()
                appState.activeTasks = [
                    .init(name: "Shopping 3 Jan")
                ]
                appState.blueprints = [
                    .init(name: "Groceries"),
                    .init(name: "Short trip")
                ]
        return appState
    }()
}


// MARK: - App state -


final class AppState: ObservableObject {
    // MARK: Home state
    
    /// Task lists for "currently active" tasks (that were recently started or used)
    @Published var activeTasks: [TaskListInfo] = []
    @Published var hasOlderTasks = true
    @Published var blueprints: [BlueprintListInfo] = []
    @Published var focusedBlueprint: BlueprintListInfo? = nil
    
    // MARK: blueprint view state
    
    @Published var blueprintName = ""
    @Published var blueprintItems: [BlueprintItem] = []
    @Published var isAddingBlueprintItem = false
    @Published var addingBlueprintItemText = ""
    @Published var isBlueprintValid = false
    
    func revalidateBlueprint() {
        isBlueprintValid = !blueprintName.isEmpty && !blueprintItems.isEmpty
    }
    
    func clearBlueprintState() {
        blueprintName = ""
        blueprintItems = []
        isAddingBlueprintItem = false
        addingBlueprintItemText = ""
    }
}

struct TaskListInfo: Identifiable {
    let id = UUID()
    var name: String
}

struct BlueprintListInfo: Identifiable {
    let id = UUID()
    var name: String
}

struct BlueprintItem: Identifiable {
    let id = UUID()
    var text: String
}

// MARK: - Home screen -

struct HomeView {
    @ObservedObject var appState: AppState
    @State private var isAddingBlueprint = false
}

extension HomeView: View {
    var body: some View {
        List {
            // "Tasks" section
            Section(
                content: {
                    if appState.activeTasks.isEmpty {
                        Text("No tasks are currently active")
                            .font(.footnote)
                            .italic()
                            .opacity(0.5)
                    } else {
                        ForEach(appState.activeTasks) { list in
                            HStack {
                                Image(systemName: "checklist")
                                    .foregroundColor(.yellow)
                                Text(list.name)
                            }
                        }
                    }
                }, header: {
                    HStack {
                        Text("Tasks").font(.title2)
                        Spacer()
                        Button {
                            // Action:
                            // TODO
                        } label: {
                            HStack {
                                Text("Start")
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                    }
                }, footer: {
                    if appState.hasOlderTasks {
                        VStack(alignment: .leading) {
                            Text("Tasks are once-off checklists. Use these when you go shopping or pack for a trip.")
                            Button("View all tasks") {
                                // TODO - action
                            }
                            .padding(1)
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
                            HStack {
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(.blue)
                                Text(list.name)
                            }
                        }
                    }
                }, header: {
                    HStack {
                        Text("Blueprints").font(.title2)
                        Spacer()
                        Button(action: {
                            isAddingBlueprint = true
                        }, label: {
                            HStack {
                                Text("Create")
                                Image(systemName: "plus.circle.fill")
                            }
                        })
                    }
                }, footer: {
                    VStack(alignment: .leading) {
                        Text("Blueprints are reusable templates for task lists. When you start a new task, you can pick a blueprint to base it on; the new task will be pre-filled with the items from the blueprint.")
                        
                        if !appState.blueprints.isEmpty {
                            Button("View all blueprints") {
                                // TODO action
                            }.padding(1)
                        }
                    }
                })
        }
        .navigationTitle("Double Check")
        .navigationBarTitleDisplayMode(.inline)
        
        // Settings button
        // TODO this changes the list style!
        //        .navigationBarItems(leading: Button(
        //            action: {}, // TODO
        //            label: { Image(systemName: "gearshape") })
        //            .buttonStyle(.plain))
        
        .sheet(
            isPresented: $isAddingBlueprint,
            onDismiss: { appState.clearBlueprintState() },
            content: { CreateBlueprintView(appState: appState) })
    }
}


// MARK: - Edit blueprint screens -


/// Popup shell for adding a new blueprint
struct CreateBlueprintView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            BlueprintView(appState: appState)
                .navigationTitle("New Blueprint")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: Button("Save") {
                        appState.blueprints.append(.init(name: appState.blueprintName))
                        // TODO save items as well
                        dismiss()
                    }.disabled(!appState.isBlueprintValid)
                )
        }
    }
}

/// View/edit existing blueprint
struct ViewBlueprintView {
    
}

struct BlueprintView {
    @ObservedObject var appState: AppState
    @FocusState private var isAddItemFocused: Bool?
}

extension BlueprintView: View {
    var body: some View {
        Form {
            TextField.init("List name", text: $appState.blueprintName)
                .font(.title)
                .onChange(of: appState.blueprintName) { _ in
                    appState.revalidateBlueprint()
                }
            
            List {
                Section.init(
                    content: {
                        ForEach(appState.blueprintItems.indices, id: \.self) { index in
                            TextField("Item text", text: .init(
                                get: { appState.blueprintItems[index].text },
                                set: { appState.blueprintItems[index].text = $0 }))
                        }
                        .onDelete(perform: {
                            appState.blueprintItems.remove(atOffsets: $0)
                            appState.revalidateBlueprint()
                        })
                        .onMove(perform: { appState.blueprintItems.move(fromOffsets: $0, toOffset: $1) })
                        
                        if appState.isAddingBlueprintItem {
                            TextField(
                                "Item text",
                                text: $appState.addingBlueprintItemText,
                                onCommit: {
                                    if appState.addingBlueprintItemText.isEmpty {
                                        appState.isAddingBlueprintItem = false
                                        isAddItemFocused = false
                                    } else {
                                        appState.blueprintItems.append(
                                            .init(text: appState.addingBlueprintItemText))
                                        appState.addingBlueprintItemText = ""
                                        isAddItemFocused = true
                                    }
                                    appState.revalidateBlueprint()
                                })
                                .focused($isAddItemFocused, equals: true)
                            
                        } else {
                            Button {
                                appState.isAddingBlueprintItem = true
                                isAddItemFocused = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle")
                                    Text("Add items")
                                }
                            }
                        }
                    }, header: {
                        HStack {
                            Text("Items")
                            Spacer()
                            EditButton() // TODO doesn't work
                        }
                    })
            }
        }
    }
}
