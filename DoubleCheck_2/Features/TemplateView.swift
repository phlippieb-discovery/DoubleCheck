import SwiftUI

struct TemplateView {
    @ObservedObject var appState: AppState
    @FocusState private var isAddItemFocused: Bool?
}

extension TemplateView: View {
    var body: some View {
        IfLet($appState.viewingTemplate) { $template in
            Form {
                TextField.init("List name", text: $template.name)
                    .font(.title)
                    .onChange(of: template.name) { _ in
                        appState.revalidateTemplate()
                    }
                
                List {
                    Section.init(
                        content: {
                            ForEach($template.items.indices, id: \.self) { index in
                                TextField("Item text", text: .init(
                                    get: { template.items[index].text },
                                    set: { template.items[index].text = $0 }))
                            }
                            .onDelete(perform: {
                                template.items.remove(atOffsets: $0)
                                appState.revalidateTemplate()
                            })
                            .onMove(perform: { template.items.move(fromOffsets: $0, toOffset: $1) })
                            
                            if appState.isAddingTemplateItem {
                                TextField(
                                    "Item text",
                                    text: $appState.addingTemplateItemText,
                                    onCommit: {
                                        if appState.addingTemplateItemText.isEmpty {
                                            appState.isAddingTemplateItem = false
                                            isAddItemFocused = false
                                        } else {
                                            template.items.append(
                                                .init(text: appState.addingTemplateItemText))
                                            appState.addingTemplateItemText = ""
                                            isAddItemFocused = true
                                        }
                                        appState.revalidateTemplate()
                                    })
                                    .focused($isAddItemFocused, equals: true)
                                
                            } else {
                                IconAndButton(.addCreate, "Add items") {
                                    appState.isAddingTemplateItem = true
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
