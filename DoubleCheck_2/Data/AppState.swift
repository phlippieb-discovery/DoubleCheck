import Foundation

final class AppState: ObservableObject {
    // MARK: Home state
    
    enum Route {
        case viewChecklist(id: UUID)
        case viewAllChecklists
        case createTemplate
        case viewTemplate(id: UUID)
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
    
    @Published var checkLists: [Checklist] = []
    @Published var templates: [Template] = []
    @Published var creatingTemplate: Template?
    
    /// Only the 5 most recent checklists that were updated within the last day
    var activeChecklists: [Checklist] {
        self.checkLists
            .filter { !$0.isArchived && $0.lastUpdated.timeIntervalSinceNow < 86400 } // 24H TODO doesn't seem to work
        // TODO update lastUpdated when things change!
            .sorted(by: { $0.lastUpdated > $1.lastUpdated })
            .prefix(5)
            .map { $0 }
    }
    
    /// True if there are more checklists to be viewed than the current recent checklist.
    var hasArchivedChecklists: Bool {
        self.activeChecklists.count != self.checkLists.count
    }
    
    func startChecklist(from template: Template) {
        let newChecklist = Checklist(
            name: template.name + " 5 Jan", // TODO correct date; also deduplicate names with (1) if needed
            items: template.items.map { .init(text: $0.text) })
        self.checkLists.append(newChecklist)
        self.route = .viewChecklist(id: newChecklist.id)
    }
    
    func startChecklist(from checklist: Checklist, mode: DuplicateChecklistMode) {
        let newItems: [ChecklistItem]
        switch mode {
        case .copyAllItems: newItems = checklist.items.map { .init(text: $0.text, checked: false) }
        case .copyDueItemsOnly: newItems = checklist.items.filter { $0.checked == false }
        }
        let newChecklist = Checklist(
            name: checklist.name + " (copy)",
            items: newItems)
        self.checkLists.append(newChecklist)
        self.route = .viewChecklist(id: newChecklist.id)
    }
    
    enum DuplicateChecklistMode {
        case copyAllItems, copyDueItemsOnly
    }
    
    func createTemplateTapped() {
        self.creatingTemplate = .init(name: "", items: [])
        self.route = .createTemplate
    }
    
    func viewTemplateTapped(id: UUID) {
        self.route = .viewChecklist(id: id)
    }
    
    // MARK: checklist view state
    
    /// A bindable view the checklist being viewed,
    /// which binds to the correct element of the `checklist` array.
    var viewingChecklist: Checklist? {
        get {
            guard case .viewChecklist(let id) = self.route else { return nil }
            return self.checkLists[id]
        } set {
            guard case .viewChecklist(let id) = self.route,
                  newValue?.id == id
            else { return }
            self.checkLists.update(with: newValue)
        }
    }
    
    @Published var isAddingChecklistDueItem = false
    @Published var isAddingChecklistCompletedItem = false
    @Published var addingChecklistItemText = ""
    
    // MARK: create/edit tempalte view state
    
    /// A bindable view of the template being viewed, either for the create or view screen,
    /// which binds to either the scratch `creatingTemplate` value,
    /// or the correct element in the `templates` array.
    var viewingTemplate: Template? {
        get {
            switch self.route {
            case .createTemplate: return self.creatingTemplate
            case .viewTemplate(let id): return self.templates[id]
            default: return nil
            }
        } set {
            switch self.route {
            case .createTemplate: self.creatingTemplate = newValue
            case .viewTemplate(let id) where newValue?.id == id: self.templates.update(with: newValue)
            default: break
            }
        }
    }
    
    @Published var isAddingTemplateItem = false
    @Published var addingTemplateItemText = ""
    @Published var isTemplateValid = false
    
    func revalidateTemplate() {
        guard let template = viewingTemplate else { return }
        isTemplateValid = !template.name.isEmpty && !template.items.isEmpty
    }
}

struct Checklist: Identifiable {
    let id = UUID()
    var name: String
    var items: [ChecklistItem]
    var lastUpdated = Date()
    var isArchived = false
    
    // Convenience:
    var dueItems: [ChecklistItem] {
        get { items.filter { !$0.checked }}
        set { newValue.forEach { items.update(with: $0) }}
    }
    var completedItems: [ChecklistItem] {
        get { items.filter { $0.checked }}
        set { newValue.forEach { items.update(with: $0) }}
    }
}

struct ChecklistItem: Identifiable {
    let id = UUID()
    var text: String
    var checked: Bool = false
}

struct Template: Identifiable {
    let id = UUID()
    var name: String
    var items: [TemplateItem]
}

struct TemplateItem: Identifiable {
    let id = UUID()
    var text: String
}

extension AppState {
    static let demo: AppState = {
        let result = AppState()
        
        var olderChecklist = Checklist(name: "Groceries 2019", items: [
            .init(text: "Milk")
        ])
        olderChecklist.lastUpdated = Date().addingTimeInterval(-90000) // more than 24H
        result.checkLists = [
            olderChecklist,
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
        
        result.templates = [
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
