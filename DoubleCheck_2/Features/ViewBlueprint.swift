import SwiftUI

/// View/edit existing template
struct ViewTemplateView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        NavigationView {
            TemplateView(appState: appState)
                .navigationTitle("Tempalte")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button("Start checklist") {
                    appState.startChecklist(from: appState.viewingTemplate ?? .init(name: "", items: []))
                })
        }
    }
}
