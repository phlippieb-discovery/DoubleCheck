//
//  IdentifiableArray.swift
//  DoubleCheck_2
//
//  Created by Phlippie Bosman on 2022/01/06.
//

import Foundation

extension Array where Element: Identifiable {
    subscript(id: Element.ID) -> Element? {
        get {
            return self.first(where: { $0.id == id })
        } set {
            switch (firstIndex(where: { $0.id == id }), newValue) {
            case (.some(let index), .some(let value)): self[index] = value
            case (.some(let index), .none): self.remove(at: index)
            case (.none, .some(let value)): self.append(value)
            case (.none, .none): break
            }
        }
    }
    
    mutating func update(with value: Element?) {
        guard let id = value?.id else { return }
        self[id] = value
    }
}
