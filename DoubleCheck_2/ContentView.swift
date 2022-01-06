//
//  ContentView.swift
//  DoubleCheck_2
//
//  Created by Phlippie Bosman on 2022/01/04.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        NavigationView {
            HomeView(appState: appState)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(appState: .demo)
        
        ContentView(appState: .demo)
            .environment(\.colorScheme, .dark)
    }
}
