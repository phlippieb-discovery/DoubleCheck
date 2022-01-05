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
    
    enum Route {
        case viewTask(id: UUID)
        case createBlueprint
        case viewBlueprint(id: UUID)
    }
    
    @Published var route: Route?
    
    var isRouting: Bool {
        get { self.route != nil }
        set {
            if !newValue {
                self.route = nil
            }
        }
    }
    
    // TODO - only show "active" tasks (that were recently created or interacted with); show "view archived tasks" button and have a list of all tasks
    @Published var tasks: [TaskList] = []
    @Published var blueprints: [BlueprintList] = []
    @Published var creatingBlueprint: BlueprintList?
    
    func startTask(from blueprint: BlueprintList) {
        let newTask = TaskList(
            name: blueprint.name + " 5 Jan", // TODO correct date; also deduplicate names with (1) if needed
            items: blueprint.items.map { .init(text: $0.text) })
        self.tasks.append(newTask)
        self.route = .viewTask(id: newTask.id)
    }
    
    func createBlueprintTapped() {
        self.creatingBlueprint = .init(name: "", items: [])
        self.route = .createBlueprint
    }
    
    func viewBlueprintTapped(id: UUID) {
        self.route = .viewTask(id: id)
    }
    
    // MARK: task view state
    
    /// A bindable view the task being viewed,
    /// which binds to the correct element of the `tasks` array.
    var viewingTask: TaskList? {
        get {
            guard case .viewTask(let id) = self.route else { return nil }
            return self.tasks[id]
        } set {
            guard case .viewTask(let id) = self.route,
                  newValue?.id == id
            else { return }
            self.tasks.update(with: newValue)
        }
    }
    
    @Published var isAddingTaskDueItem = false
    @Published var isAddingTaskCompletedItem = false
    @Published var addingTaskItemText = ""
    
    // MARK: create/edit blueprint view state
    
    /// A bindable view of the blueprint being viewed, either for the create or view screen,
    /// which binds to either the scratch `creatingBlueprint` value,
    /// or the correct element in the `blueprints` array.
    var viewingBlueprint: BlueprintList? {
        get {
            switch self.route {
            case .createBlueprint: return self.creatingBlueprint
            case .viewBlueprint(let id): return self.blueprints[id]
            default: return nil
            }
        } set {
            switch self.route {
            case .createBlueprint: self.creatingBlueprint = newValue
            case .viewBlueprint(let id) where newValue?.id == id: self.blueprints.update(with: newValue)
            default: break
            }
        }
    }
    
    @Published var isAddingBlueprintItem = false
    @Published var addingBlueprintItemText = ""
    @Published var isBlueprintValid = false
    
    func revalidateBlueprint() {
        guard let blueprint = viewingBlueprint else { return }
        isBlueprintValid = !blueprint.name.isEmpty && !blueprint.items.isEmpty
    }
}

struct TaskList: Identifiable {
    let id = UUID()
    var name: String
    var items: [TaskItem]
    
    // Convenience:
    var dueItems: [TaskItem] {
        get { items.filter { !$0.checked }}
        set { newValue.forEach { items.update(with: $0) }}
    }
    var completedItems: [TaskItem] {
        get { items.filter { $0.checked }}
        set { newValue.forEach { items.update(with: $0) }}
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
                                appState.route = .viewTask(id: list.id)
                            }
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
                                appState.route = .viewBlueprint(id: list.id)
                            }
                        }
                    }
                }, header: {
                    HStack {
                        Text("Blueprints").font(.title2)
                        Spacer()
                        Button(action: appState.createBlueprintTapped) {
                            HStack {
                                Text("Create")
                                Image(systemName: "plus.circle.fill")
                            }
                        }
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
        
        .sheet(
            isPresented: $appState.isRouting,
            onDismiss: {},
            content: {
                switch appState.route {
                case .viewTask: TaskView(appState: appState)
                case .createBlueprint: CreateBlueprintView(appState: appState)
                case .viewBlueprint: ViewBlueprintView(appState: appState)
                case .none: EmptyView()
                }
            })
        
        // View a task:
//        .sheet(
//            item: $appState.viewingTask,
//            onDismiss: { appState.clearTaskState() },
//            content: { _ in TaskView(appState: appState) })
//
//        // Create new blueprint:
//        .sheet(
//            item: $appState.creatingBlueprint,
//            onDismiss: { appState.clearBlueprintState() },
//            content: { _ in CreateBlueprintView(appState: appState) })
//
//        // View existing blueprint:
//        .sheet(
//            item: $appState.viewingBlueprint,
//            onDismiss: { appState.clearBlueprintState() },
//            content: { _ in ViewBlueprintView(appState: appState) })
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
                            ForEach($task.dueItems) { $item in
                                HStack {
                                    TextField("Item text", text: $item.text)
                                    Spacer()
                                    Button.init(action: { withAnimation { item.checked.toggle() }}) {
                                        Image(systemName: "circle")
                                    }
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
                    if !task.completedItems.isEmpty {
                        Section {
                            ForEach($task.completedItems) { $item in
                                HStack {
                                    TextField("Item text", text: $item.text)
                                    Spacer()
                                    Button.init(action: { withAnimation { item.checked.toggle() }}) {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                }
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
                            ForEach($blueprint.items.indices, id: \.self) { index in
                                TextField("Item text", text: .init(
                                    get: { blueprint.items[index].text },
                                    set: { blueprint.items[index].text = $0 }))
                            }
                            .onDelete(perform: {
                                blueprint.items.remove(atOffsets: $0)
                                appState.revalidateBlueprint()
                            })
                            .onMove(perform: { blueprint.items.move(fromOffsets: $0, toOffset: $1) })
                            
                            if appState.isAddingBlueprintItem {
                                TextField(
                                    "Item text",
                                    text: $appState.addingBlueprintItemText,
                                    onCommit: {
                                        if appState.addingBlueprintItemText.isEmpty {
                                            appState.isAddingBlueprintItem = false
                                            isAddItemFocused = false
                                        } else {
                                            blueprint.items.append(
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


// MARK: - Identifiable Array helpers -


extension Array where Element: Identifiable {
    subscript(id: Element.ID) -> Element? {
        get {
            return self.first(where: { $0.id == id })
        } set {
            switch (firstIndex(where: { $0.id == id }), newValue) {
            case (.some(let index), .some(let value)): self[index] = value
            case (.some(let index), .none): self.remove(at: index)
            case (.none, .some(let value)): self.append(value)
            case (.none, .none): break
            }
        }
    }
    
    mutating func update(with value: Element?) {
        guard let id = value?.id else { return }
        self[id] = value
    }
}
