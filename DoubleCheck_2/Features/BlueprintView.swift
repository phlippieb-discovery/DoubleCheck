//
//  BlueprintView.swift
//  DoubleCheck_2
//
//  Created by Phlippie Bosman on 2022/01/06.
//

import SwiftUI

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
                                IconAndButton(.addCreate, "Add items") {
                                    appState.isAddingBlueprintItem = true
                                    isAddItemFocused = true
                                }
                            }
                        }, header: {
                            HStack {
                                Text("Items")
                            }
                        })
                }
            }
        }
    }
}
