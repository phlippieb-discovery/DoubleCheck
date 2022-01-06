//
//  Design.swift
//  DoubleCheck_2
//
//  Created by Phlippie Bosman on 2022/01/06.
//

import SwiftUI

enum ImageIcon: String {
    case checklist = "checklist"
    case addCreate = "plus.circle.fill"
    case template = "line.3.horizontal"
    case dueItem = "circle"
    case completedItem = "checkmark.circle.fill"
    case menu = "ellipsis.circle"
}

enum RowBackgroundColor {
    static let checklist = Color.yellow.opacity(0.3)
    static let archived = Color.gray.opacity(0.1)
    static let template = Color.blue.opacity(0.2)
}

struct IconImage: View {
    init(_ icon: ImageIcon) {
        self.icon = icon
    }
    
    let icon: ImageIcon
    
    var body: some View {
        Image(systemName: self.icon.rawValue)
    }
}

struct IconAndText: View {
    init(_ icon: ImageIcon, _ text: String) {
        self.icon = icon
        self.text = text
    }
    
    let icon: ImageIcon
    let text: String
    
    var body: some View {
        HStack {
            IconImage(icon)
            Text(text)
        }
    }
}

struct ChecklistRow: View {
    init(_ list: TaskList) {
        self.list = list
    }
    
    let list: TaskList
    
    var body: some View {
        IconAndText(.checklist, list.name)
            .listRowBackground(
                list.isArchived
                ? RowBackgroundColor.archived
                : RowBackgroundColor.checklist)
    }
}

struct TemplateRow: View {
    init(_ list: BlueprintList) {
        self.list = list
    }
    
    let list: BlueprintList
    
    var body: some View {
        IconAndText(.template, list.name)
            .listRowBackground(RowBackgroundColor.template)
    }
}

struct IconAndButton: View {
    init(_ icon: ImageIcon, _ text: String, _ action: @escaping () -> Void) {
        self.icon = icon
        self.text = text
        self.action = action
    }
    
    let icon: ImageIcon
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                IconImage(icon)
                Text(text)
            }
        }
    }
}

struct ButtonAndIcon: View {
    init(_ text: String, _ icon: ImageIcon, _ action: @escaping () -> Void) {
        self.text = text
        self.icon = icon
        self.action = action
    }
    
    let text: String
    let icon: ImageIcon
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Text(text)
                IconImage(icon)
            }
        }

    }
}
