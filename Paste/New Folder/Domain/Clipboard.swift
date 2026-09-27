//
//  Clipboard.swift
//  Paste
//
//  Created by Nicklas Roelfs on 18.09.26.
//

import SwiftData
import Foundation

@Model
final class Clipboard {
    private(set) var items: [ClipboardItem] = []
    private(set) var capacity: Int
    private(set) var activeItemId: UUID? = nil
    
    init(capacity: Int) {
        self.capacity = capacity
    }

    static func create(capacity: Int) -> Clipboard {
        Clipboard(capacity: capacity)
    }

    func push(_ item: ClipboardItem, into context: ModelContext) {
        if let existingIndex = items.firstIndex(where: { $0 == item }) {
            let existing = items.remove(at: existingIndex)
            items.insert(existing, at: 0)
            activeItemId = existing.id

            item.deleteAssociatedFiles()

            try? context.save()
            return
        }

        activeItemId = item.id
        items.insert(item, at: 0)

        if items.count > capacity {
            let removed = items.removeLast()
            removed.deleteAssociatedFiles()
        }

        try? context.save()
    }

    @discardableResult
    func remove(id: UUID) -> ClipboardItem? {
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        let removedItem = items.remove(at: index)
        removedItem.deleteAssociatedFiles()

        if activeItemId == id {
            activeItemId = items.first?.id
        }

        return removedItem
    }
    
    func updateCapacity(newCapacity: Int) {
        guard newCapacity != capacity else { return }

        if newCapacity < items.count {
            let removeCount = items.count - newCapacity
            let removedItems = items.suffix(removeCount)

            items.removeLast(removeCount)
            removedItems.forEach { $0.deleteAssociatedFiles() }

            if let activeItemId, removedItems.contains(where: { $0.id == activeItemId }) {
                self.activeItemId = items.first?.id
            }
        }

        capacity = newCapacity
    }

    var active: ClipboardItem? {
        items.first(where: {$0.id == activeItemId})
    }

    var count: Int {
        items.count
    }

    var isFull: Bool {
        items.count == capacity
    }

    var isEmpty: Bool {
        items.isEmpty
    }
    
    @discardableResult
    func activate(id: UUID) -> Bool {
        guard items.contains(where: { $0.id == id }) else { return false }
        activeItemId = id
        return true
    }
}
