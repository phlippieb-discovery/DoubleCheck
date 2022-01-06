//
//  SwiftUIHelpers.swift
//  DoubleCheck_2
//
//  Created by Phlippie Bosman on 2022/01/06.
//

import SwiftUI

struct IfLet<Value, Content>: View where Content: View {
    init(
        _ binding: Binding<Value?>,
        @ViewBuilder content: @escaping (Binding<Value>) -> Content
    ) {
        self.binding = binding
        self.content = content
    }
    
    let binding: Binding<Value?>
    let content: (Binding<Value>) -> Content
    
    var body: some View {
        if let value = self.binding.wrappedValue {
            content(.init(
                get: { value },
                set: { self.binding.wrappedValue = $0 }))
        }
    }
}
