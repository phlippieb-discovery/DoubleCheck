import SwiftUI

struct HomeView {
    @ObservedObject var appState: AppState
}

extension HomeView: View {
    var body: some View {
        List {
            // "Checklists" section
            Section(
                content: {
                    if appState.activeChecklists.isEmpty {
                        Text("No checklists are currently active")
                            .font(.footnote)
                            .italic()
                            .opacity(0.5)
                    } else {
                        ForEach(appState.activeChecklists) { list in
                            ChecklistRow(list)
                                .onTapGesture { appState.route = .viewChecklist(id: list.id) }
                        }
                    }
                }, header: {
                    HStack {
                        Text("Checklists").font(.title2)
                        Spacer()
                        Menu.init {
                            Button("New empty checklist") {
                                appState.startChecklist(from: .init(name: "", items: []))
                            }
                            ForEach(appState.templates) { template in
                                Button(template.name) {
                                    appState.startChecklist(from: template)
                                }
                            }
                        } label: {
                            ButtonAndIcon("Start", .addCreate) {}
                        }
                    }
                }, footer: {
                    VStack(alignment: .leading) {
                        Text("Checklists are lists of items that can be marked as completed. Create a new checklist whenever you start a new task, e.g. when you go shopping or pack for a trip.")
                        if appState.hasArchivedChecklists {
                            NavigationLink("View all checklists") {
                                AllChecklistsView(appState: appState)
                            }.padding(1)
                        }
                    }
                })
            
            // "Tempaltes" section
            Section(
                content: {
                    if appState.templates.isEmpty {
                        Text("You don't have any templates yet")
                            .font(.footnote)
                            .italic()
                            .opacity(0.5)
                    } else {
                        ForEach(appState.templates) { list in
                            TemplateRow(list)
                                .onTapGesture { appState.route = .viewTemplate(id: list.id) }
                        }
                    }
                }, header: {
                    HStack {
                        Text("Templates").font(.title2)
                        Spacer()
                        ButtonAndIcon("Create", .addCreate, appState.createTemplateTapped)
                    }
                }, footer: {
                    Text("Templates are reusable blueprints for checklists. When you start a new checklist, you can pick a template to base it on; the new checklist will be pre-filled with the items from the template.")
                })
        }
        .navigationTitle("Double Check")
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
