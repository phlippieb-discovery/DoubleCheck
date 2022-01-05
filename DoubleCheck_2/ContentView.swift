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
//        NavigationView {
//            BlueprintView(appState: appState)
//        }
        TaskView(appState: appState)
        
        ContentView(appState: appState)
        
        ContentView(appState: appState)
            .environment(\.colorScheme, .dark)
    }
    
    private static var appState: AppState = {
        let appState = AppState()
                appState.activeTasks = [
                    .init(
                        name: "Shopping 3 Jan",
                        items: [
                            .init(text: "Milk"),
                            .init(text: "Bread"),
                            .init(text: "Eggs"),
                        ]
                    )
                ]
                appState.blueprints = [
                    .init(
                        name: "Groceries",
                        items: [
                            .init(text: "Milk"),
                            .init(text: "Bread"),
                            .init(text: "Eggs"),
                        ]
                    ),
                    .init(
                        name: "Short trip",
                        items: [
                            .init(text: "Shirts")
                        ])
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
    
    // MARK: create/edit blueprint view state
    
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
    
    // MARK: task view state
    
    @Published var taskName = ""
    @Published var taskItems: [TaskItem] = []
    var taskDueItems: [TaskItem] { taskItems.filter { !$0.checked }}
    var taskCompletedItems: [TaskItem] { taskItems.filter { $0.checked }}
    @Published var isAddingTaskDueItem = false
    @Published var isAddingTaskCompletedItem = false
    @Published var addingTaskItemText = ""
    
    func clearTaskState() {
        taskName = ""
        taskItems = []
        isAddingTaskDueItem = false
        isAddingTaskCompletedItem = false
        addingTaskItemText = ""
    }
    
    func toggleTaskItem(id: UUID) {
        guard let index = taskItems.firstIndex(where: { $0.id == id }) else { return }
        var item = taskItems[index]
        item.checked.toggle()
        taskItems[index] = item
    }
}

struct TaskListInfo: Identifiable {
    let id = UUID()
    var name: String
    var items: [TaskItem]
}

struct BlueprintListInfo: Identifiable {
    let id = UUID()
    var name: String
    var items: [BlueprintItem]
}

struct BlueprintItem: Identifiable {
    let id = UUID()
    var text: String
}

struct TaskItem: Identifiable {
    let id = UUID()
    var text: String
    var checked: Bool = false
}


// MARK: - Home screen -


struct HomeView {
    @ObservedObject var appState: AppState
    @State private var viewingTask: TaskListInfo? = nil
    @State private var isAddingBlueprint = false
    @State private var viewingBlueprint: BlueprintListInfo? = nil
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
                            .onTapGesture {
                                appState.taskName = list.name
                                appState.taskItems = list.items
                                viewingTask = list
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
                            .onTapGesture {
                                withAnimation {
                                    viewingBlueprint = list
                                    appState.blueprintName = list.name
                                    appState.blueprintItems = list.items
                                    
                                }
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
        
        // View a task:
        .sheet(
            item: $viewingTask,
            onDismiss: { appState.clearTaskState() },
            content: { _ in TaskView(appState: appState) })
        
        // Create new blueprint:
        .sheet(
            isPresented: $isAddingBlueprint,
            onDismiss: { appState.clearBlueprintState() },
            content: { CreateBlueprintView(appState: appState) })
        
        // View existing blueprint:
        .sheet(
            item: $viewingBlueprint,
            onDismiss: { appState.clearBlueprintState() },
            content: { _ in ViewBlueprintView(appState: appState) })
    }
}


// MARK: - Task screens -


struct TaskView {
    @ObservedObject var appState: AppState
    
    private enum FocusItem {
        case taskName, addDueItem, addCompletedItem
    }
    
    @FocusState private var focusItem: FocusItem?
    @State private var isOptionsAlertPresented = false
}

extension TaskView: View {
    var body: some View {
        NavigationView {
            Form {
                TextField.init("Task name", text: $appState.taskName)
                    .font(.title)
                    .focused($focusItem, equals: .taskName)
                // TODO save to original list as well (in home/tasks)
                
                List {
                    // Due items
                    Section {
                        ForEach(appState.taskDueItems.map(\.id), id: \.self) { id in
                            let item = appState.taskItems.first(where: { $0.id == id })!
                            HStack {
                                // TODO
//                                TextField("Item text", text: item.text)
                                Text(item.text)
                                Spacer()
                                Image(systemName: "circle")
                            }
                            .onTapGesture {
                                appState.toggleTaskItem(id: id)
                            }
                        }
                        
                        if appState.isAddingTaskDueItem {
                            TextField(
                                "Item text",
                                text: $appState.addingTaskItemText,
                                onCommit: {
                                    if appState.addingTaskItemText.isEmpty {
                                        appState.isAddingTaskDueItem = false
                                        focusItem = nil
                                    } else {
                                        appState.taskItems.append(
                                            .init(text: appState.addingTaskItemText))
                                        appState.addingTaskItemText = ""
                                        focusItem = .addDueItem
                                    }
                                })
                                .focused($focusItem, equals: .addDueItem)
                        } else {
                            Button {
                                appState.isAddingTaskDueItem = true
                                appState.isAddingTaskCompletedItem = false
                                focusItem = .addDueItem
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle")
                                    Text("Add items")
                                }
                            }
                        }
                        
                    } header: {
                        HStack {
                            if appState.taskDueItems.count == 0 {
                                Text("Due")
                            } else {
                                // TODO nicer UX that makes you feel good here?
                                Text("Due (\(appState.taskDueItems.count) of \(appState.taskItems.count))")
                            }
                            Spacer()
                            // TODO add "edit"?
                        }
                    } footer: {
                        Text("Tap an item to mark it as completed.")
                    }
                }
                
                // Completed items
                // TODO idea - make it so you have to scroll down to "snap" to the completed section?
                if !appState.taskCompletedItems.isEmpty {
                    Section {
                        ForEach(appState.taskCompletedItems.map(\.id), id: \.self) { id in
                            let item = appState.taskItems.first(where: { $0.id == id })!
                            HStack {
                                Text(item.text) // TODO editable
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                            }
                            .onTapGesture {
                                appState.toggleTaskItem(id: id)
                            }
                        }
                    } header: {
                        HStack {
                            Text("Completed (\(appState.taskCompletedItems.count) of \(appState.taskItems.count))")
                            Spacer()
                            // TODO add "edit"?
                        }
                    } footer: {
                        Text("Tap an item to mark it as due.")
                    }
                }
            }
            .navigationTitle("Task")
            .navigationBarTitleDisplayMode(.inline)
            // Options button
            .navigationBarItems(trailing: Menu.init(content: {
                // TODO implement all actions
                
                // Check/uncheck all (uncheck only when all are checked)
                if !appState.taskItems.isEmpty {
                    if !appState.taskDueItems.isEmpty {
                        Button("Check all items") {}
                    } else {
                        Button("Uncheck all items") {}
                    }
                }
                
                Menu("Duplicate task") {
                    Button("Copy all items") {}
                    Button("Copy due items") {}
                }
                
                Button("Archive") {}
                
                Button.init("Delete", role: .destructive) {}
                
            }, label: {
                Image(systemName: "ellipsis.circle")
            }))
            
        }
    }
}


// MARK: - Blueprint screens -


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
                        appState.blueprints.append(.init(
                            name: appState.blueprintName,
                            items: appState.blueprintItems))
                        dismiss()
                    }.disabled(!appState.isBlueprintValid)
                )
        }
    }
}

/// View/edit existing blueprint
struct ViewBlueprintView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            BlueprintView(appState: appState)
                .navigationTitle("Blueprint")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button("Start task") {
                    // TODO
                })
        }
    }
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
