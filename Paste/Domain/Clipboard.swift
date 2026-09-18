//
//  Clipboard.swift
//  Paste
//
//  Created by Nicklas Roelfs on 18.09.26.
//

import SwiftData

@Model
final class Clipboard {
    private(set) var items: [ClipboardItem] = []
    private(set) var capacity: Int

    init(capacity: Int) {
        self.capacity = capacity
    }

    static func create(capacity: Int) -> Clipboard {
        Clipboard(capacity: capacity)
    }

    func push(_ item: ClipboardItem, into context: ModelContext) {
        
        if !isEmpty {
            toggleActive()
        }
            
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

    var top: ClipboardItem? {
        items.first
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
    
    private func toggleActive() {
        items.forEach{ item in
            if item.isActive {
                item.toggleActive()
            }
        }
    }
}
