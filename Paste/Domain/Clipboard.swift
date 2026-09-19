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
        
        activeItemId = item.id
        items.insert(item, at: 0)

        if items.count > capacity {
            items.removeLast()
        }
        
        try? context.save()
    }

    @discardableResult
    func pop() -> ClipboardItem? {
        guard !items.isEmpty else { return nil }
        return items.removeFirst()
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
    
    func activate(id: UUID) {
        guard items.contains(where: { $0.id == id }) else { return }
        activeItemId = id
    }
}
