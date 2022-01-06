import SwiftUI

struct AllChecklistsView {
    @ObservedObject var appState: AppState
}

extension AllChecklistsView: View {
    var body: some View {
        List(appState.checkLists.sorted(by: { $0.lastUpdated > $1.lastUpdated })) { list in
            ChecklistRow(list)
                .onTapGesture { appState.route = .viewChecklist(id: list.id) }
        }
        
        .navigationTitle("All checklists")
        .navigationBarTitleDisplayMode(.inline)
        
        .sheet(
            isPresented: $appState.isRouting,
            onDismiss: {},
            content: {
                switch appState.route {
                case .viewChecklist: ChecklistView(appState: appState)
                case .createTemplate: CreateTemplateView(appState: appState)
                case .viewTemplate: ViewTemplateView(appState: appState)
                case .viewAllChecklists, .none: EmptyView() // N/A
                }
            })
    }
}
