//
//  AppState.swift
//  DoubleCheck_2
//
//  Created by Phlippie Bosman on 2022/01/06.
//

import Foundation

final class AppState: ObservableObject {
    // MARK: Home state
    
    enum Route {
        case viewTask(id: UUID)
        case viewAllTasks
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
    
    @Published var tasks: [TaskList] = []
    @Published var blueprints: [BlueprintList] = []
    @Published var creatingBlueprint: BlueprintList?
    
    /// Only the 5 most recent tasks that were updated within the last day
    var recentTasks: [TaskList] {
        self.tasks
            .filter { !$0.isArchived && $0.lastUpdated.timeIntervalSinceNow < 86400 } // 24H TODO doesn't seem to work
        // TODO update lastUpdated when things change!
            .sorted(by: { $0.lastUpdated > $1.lastUpdated })
            .prefix(5)
            .map { $0 }
    }
    
    /// True if there are more tasks to be viewed than the current recent tasks.
    var hasArchivedTasks: Bool {
        self.recentTasks.count != self.tasks.count
    }
    
    func startTask(from blueprint: BlueprintList) {
        let newTask = TaskList(
            name: blueprint.name + " 5 Jan", // TODO correct date; also deduplicate names with (1) if needed
            items: blueprint.items.map { .init(text: $0.text) })
        self.tasks.append(newTask)
        self.route = .viewTask(id: newTask.id)
    }
    
    func startTask(from task: TaskList, mode: DuplicateTaskMode) {
        let newItems: [TaskItem]
        switch mode {
        case .copyAllItems: newItems = task.items.map { .init(text: $0.text, checked: false) }
        case .copyDueItemsOnly: newItems = task.items.filter { $0.checked == false }
        }
        let newTask = TaskList(
            name: task.name + " (copy)",
            items: newItems)
        self.tasks.append(newTask)
        self.route = .viewTask(id: newTask.id)
    }
    
    enum DuplicateTaskMode {
        case copyAllItems, copyDueItemsOnly
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
    var lastUpdated = Date()
    var isArchived = false
    
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
        
        var olderTask = TaskList(name: "Groceries 2019", items: [
            .init(text: "Milk")
        ])
        olderTask.lastUpdated = Date().addingTimeInterval(-90000) // more than 24H
        result.tasks = [
            olderTask,
            .init(name: "Groceries 2 Jan", items: [
                .init(text: "Milk"),
                .init(text: "Bread"),
            ]),
            .init(name: "Beach trip", items: [
                .init(text: "Trunks etc")
            ]),
            .init(name: "Drinks", items: [
                .init(text: "Beer")
            ]),
            .init(name: "Hardware", items: [
                .init(text: "Nails")
            ]),
            .init(name: "Party supplies", items: [
                .init(text: "Balloons")
            ])
        ]
        
        result.blueprints = [
            .init(name: "Groceries", items: [
                .init(text: "Milk"),
                .init(text: "Bread"),
            ]),
            .init(name: "Short trip", items: [
                .init(text: "Toothbrush"),
                .init(text: "Shirts"),
            ])
        ]
        
        return result
    }()
}
