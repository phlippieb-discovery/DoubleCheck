import SwiftUI

/// Popup shell for adding a new checklist
struct CreateTemplateView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        NavigationView {
            IfLet($appState.viewingTemplate) { $template in
                TemplateView(appState: appState)
                    .navigationTitle("New Template")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(
                        trailing: Button("Save") {
                            appState.templates.append(template)
                            appState.route = .viewTemplate(id: template.id)
                        }.disabled(!appState.isTemplateValid))
            }
        }
    }
}
