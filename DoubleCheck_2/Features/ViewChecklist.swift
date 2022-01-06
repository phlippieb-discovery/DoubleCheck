import SwiftUI

struct ChecklistView {
    @ObservedObject var appState: AppState
    
    private enum FocusItem {
        case checklistName, addDueItem, addCompletedItem
    }
    
    @FocusState private var focusItem: FocusItem?
    @State private var isConfirmDeletePresented = false
}

extension ChecklistView: View {
    var body: some View {
        NavigationView {
            IfLet($appState.viewingChecklist) { $checklist in
                Form {
                    TextField.init("Checklist name", text: $checklist.name)
                        .font(.title)
                        .focused($focusItem, equals: .checklistName)
                    
                    List {
                        // Due items
                        Section {
                            ForEach($checklist.dueItems) { $item in
                                HStack {
                                    TextField("Item text", text: $item.text)
                                    Spacer()
                                    ButtonAndIcon("", .dueItem) { withAnimation { item.checked.toggle() }}
                                }
                            }
                            
                            if appState.isAddingChecklistDueItem {
                                TextField(
                                    "Item text",
                                    text: $appState.addingChecklistItemText,
                                    onCommit: {
                                        if appState.addingChecklistItemText.isEmpty {
                                            appState.isAddingChecklistDueItem = false
                                            focusItem = nil
                                        } else {
                                            checklist.items.append(
                                                .init(text: appState.addingChecklistItemText))
                                            appState.addingChecklistItemText = ""
                                            focusItem = .addDueItem
                                        }
                                    })
                                    .focused($focusItem, equals: .addDueItem)
                            } else {
                                IconAndButton(.addCreate, "Add items") {
                                    appState.isAddingChecklistDueItem = true
                                    appState.isAddingChecklistCompletedItem = false
                                    focusItem = .addDueItem
                                }
                            }
                            
                        } header: {
                            Text("Due")
                        } footer: {
                            Text("Tap an item to mark it as completed.")
                        }
                    }
                    
                    // Completed items
                    if !checklist.completedItems.isEmpty {
                        Section {
                            ForEach($checklist.completedItems) { $item in
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
                
                .navigationTitle("Checklist")
                .navigationBarTitleDisplayMode(.inline)
                
                // Options button
                .navigationBarItems(trailing: Menu.init(content: {
                    Menu("Duplicate") {
                        Text("Start a new checklist, using this one as a basis")
                        Button("Copy all this checklist's items") {
                            appState.startChecklist(from: checklist, mode: .copyAllItems)
                        }
                        Button("Copy only the due items") {
                            appState.startChecklist(from: checklist, mode: .copyDueItemsOnly)
                        }
                    }
                    Button("Archive") {
                        checklist.isArchived = true
                        appState.route = nil
                    }
                    Button("Delete", role: .destructive) {
                        isConfirmDeletePresented = true
                    }
                    
                }, label: {
                    Image(systemName: "ellipsis.circle")
                }))
                
                // Confirm delete
                .alert("Delete checklist?", isPresented: $isConfirmDeletePresented, actions: {
                    Button("Delete", role: .destructive) {
                        appState.checkLists[checklist.id] = nil
                        appState.route = nil
                    }
                    Button("Archive") {
                        checklist.isArchived = true
                        appState.route = nil
                    }
                    Button("Cancel", role: .cancel) {}
                }, message: {
                    Text("If you're done with this checklist, you can archive it to remove it from the active checklists view instead")
                })
            }
        }
    }
}

