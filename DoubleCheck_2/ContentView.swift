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
        appState.tasks = [
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
    
    @Published var tasks: [TaskList] = []
    @Published var blueprints: [BlueprintList] = []
    // TODO - only show "active" tasks (that were recently created or interacted with); show "view archived tasks" button and have a list of all tasks
    
    // MARK: task view state
    
    var viewingTask: TaskList? {
        get {
            guard let id = self.viewingTaskId else { return nil }
            return self.tasks.first(where: { $0.id == id })
        } set {
            self.viewingTaskId = newValue?.id
            if let updated = newValue,
               let index = self.tasks.firstIndex(where: { $0.id == updated.id }) {
                self.tasks[index] = updated
            }
        }
    }
    private var viewingTaskId: UUID?
    @Published var isAddingTaskDueItem = false
    @Published var isAddingTaskCompletedItem = false
    @Published var addingTaskItemText = ""
    
    func clearTaskState() {
        viewingTask = nil
        isAddingTaskDueItem = false
        isAddingTaskCompletedItem = false
        addingTaskItemText = ""
    }
    
    // MARK: create/edit blueprint view state
    
    var viewingBlueprint: BlueprintList? {
        get {
            guard let id = self.viewingBlueprintId else { return nil }
            return self.blueprints.first(where: { $0.id == id })
        } set {
            self.viewingBlueprintId = newValue?.id
            if let updated = newValue,
               let index = self.blueprints.firstIndex(where: { $0.id == updated.id }) {
                self.blueprints[index] = updated
            }
        }
    }
    private var viewingBlueprintId: UUID?
    @Published var blueprintItems: [BlueprintItem] = []
    @Published var isAddingBlueprintItem = false
    @Published var addingBlueprintItemText = ""
    @Published var isBlueprintValid = false
    
    func revalidateBlueprint() {
        guard let blueprint = viewingBlueprint else { return }
        isBlueprintValid = !blueprint.name.isEmpty && !blueprint.items.isEmpty
    }
    
    func clearBlueprintState() {
        viewingBlueprint = nil
        blueprintItems = []
        isAddingBlueprintItem = false
        addingBlueprintItemText = ""
    }
}

struct TaskList: Identifiable {
    let id = UUID()
    var name: String
    var items: [TaskItem]
    
    // Convenience:
    var dueItems: [TaskItem] { items.filter { !$0.checked }}
    var completedItems: [TaskItem] { items.filter { $0.checked }}
    
    mutating func toggleItem(id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        var item = items[index]
        item.checked.toggle()
        items[index] = item
    }
}

struct TaskItem: Identifiable {
    let id = UUID()
    var text: String
    var checked: Bool = false
}

struct BlueprintList: Identifiable {
    let id = UUID()
    var name: String
    var items: [BlueprintItem]
}

struct BlueprintItem: Identifiable {
    let id = UUID()
    var text: String
}

extension AppState {
    static let demo: AppState = {
        let result = AppState()
        
        result.tasks = [
            .init(name: "Groceries 5 Jan", items: [
                .init(text: "Milk"),
                .init(text: "Bread"),
            ])
        ]
        
        result.blueprints = [
            .init(name: "Groceries", items: [
                .init(text: "Milk"),
                .init(text: "Bread"),
            ])
        ]
        
        return result
    }()
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
                    if appState.tasks.isEmpty {
                        Text("No tasks are currently active")
                            .font(.footnote)
                            .italic()
                            .opacity(0.5)
                    } else {
                        ForEach(appState.tasks) { list in
                            HStack {
                                Image(systemName: "checklist")
                                    .foregroundColor(.yellow)
                                Text(list.name)
                            }
                            .onTapGesture {
                                appState.viewingTask = list
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
                    Text("Tasks are once-off checklists. Use these when you go shopping or pack for a trip.")
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
                                appState.viewingBlueprint = list
                                appState.blueprintItems = list.items
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
            item: $appState.viewingTask,
            onDismiss: { appState.clearTaskState() },
            content: { _ in TaskView(appState: appState) })
        
        // Create new blueprint:
        .sheet(
            isPresented: $isAddingBlueprint,
            onDismiss: { appState.clearBlueprintState() },
            content: { CreateBlueprintView(appState: appState) })
        
        // View existing blueprint:
        .sheet(
            item: $appState.viewingBlueprint,
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
            IfLet($appState.viewingTask) { $task in
                Form {
                    TextField.init("Task name", text: $task.name)
                        .font(.title)
                        .focused($focusItem, equals: .taskName)
                    
                    List {
                        // Due items
                        Section {
                            ForEach(task.dueItems.map(\.id), id: \.self) { id in
                                let item = task.items.first(where: { $0.id == id })!
                                HStack {
                                    // TODO
                                    //                                TextField("Item text", text: item.text)
                                    Text(item.text)
                                    Spacer()
                                    Image(systemName: "circle")
                                }
                                .onTapGesture { task.toggleItem(id: id) }
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
                                            task.items.append(
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
                            Text("Due")
                        } footer: {
                            Text("Tap an item to mark it as completed.")
                        }
                    }
                    
                    // Completed items
                    // TODO idea - make it so you have to scroll down to "snap" to the completed section?
                    if !task.completedItems.isEmpty {
                        Section {
                            ForEach(task.completedItems.map(\.id), id: \.self) { id in
                                let item = task.items.first(where: { $0.id == id })!
                                HStack {
                                    Text(item.text) // TODO editable
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                }
                                .onTapGesture { task.toggleItem(id: id) }
                            }
                        } header: {
                            Text("Completed")
                        } footer: {
                            Text("Tap an item to mark it as due.")
                        }
                    }
                }
                .navigationTitle("Task")
                .navigationBarTitleDisplayMode(.inline)
                // Options button
                .navigationBarItems(trailing: Menu.init(content: {
                    // TODO add and implement all actions
                    Button.init("Delete", role: .destructive) {}
                    
                }, label: {
                    Image(systemName: "ellipsis.circle")
                }))
            }
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
                            name: appState.viewingBlueprint?.name ?? "",
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
        IfLet($appState.viewingBlueprint) { $blueprint in
            Form {
                TextField.init("List name", text: $blueprint.name)
                    .font(.title)
                    .onChange(of: blueprint.name) { _ in
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
}


// MARK: - SwiftUI helpers -


struct IfLet<Value, Content>: View where Content: View {
    init(
        _ binding: Binding<Value?>,
        @ViewBuilder content: @escaping (Binding<Value>) -> Content
    ) {
        self.binding = binding
        self.content = content
    }
    
    let binding: Binding<Value?>
    let content: (Binding<Value>) -> Content
    
    var body: some View {
        if let value = self.binding.wrappedValue {
            content(.init(
                get: { value },
                set: { self.binding.wrappedValue = $0 }))
        }
    }
}
