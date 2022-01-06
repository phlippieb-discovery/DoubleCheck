//
//  TaskFeature.swift
//  DoubleCheck_2
//
//  Created by Phlippie Bosman on 2022/01/06.
//

import SwiftUI

struct TaskView {
    @ObservedObject var appState: AppState
    
    private enum FocusItem {
        case taskName, addDueItem, addCompletedItem
    }
    
    @FocusState private var focusItem: FocusItem?
    @State private var isConfirmDeletePresented = false
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
                                    ButtonAndIcon("", .dueItem) { withAnimation { item.checked.toggle() }}
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
                                IconAndButton(.addCreate, "Add items") {
                                    appState.isAddingTaskDueItem = true
                                    appState.isAddingTaskCompletedItem = false
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
                    Menu("Duplicate") {
                        Text("Start a new task, using this task as a basis")
                        Button("Copy all this task's items") {
                            appState.startTask(from: task, mode: .copyAllItems)
                        }
                        Button("Copy only the due items") {
                            appState.startTask(from: task, mode: .copyDueItemsOnly)
                        }
                    }
                    Button("Archive") {
                        task.isArchived = true
                        appState.route = nil
                    }
                    Button("Delete", role: .destructive) {
                        isConfirmDeletePresented = true
                    }
                    
                }, label: {
                    Image(systemName: "ellipsis.circle")
                }))
                
                // Confirm delete
                .alert("Delete task?", isPresented: $isConfirmDeletePresented, actions: {
                    Button("Delete", role: .destructive) {
                        appState.tasks[task.id] = nil
                        appState.route = nil
                    }
                    Button("Archive") {
                        task.isArchived = true
                        appState.route = nil
                    }
                    Button("Cancel", role: .cancel) {}
                }, message: {
                    Text("If you're done with this task, you can archive it to remove it from the active tasks view instead")
                })
            }
        }
    }
}

