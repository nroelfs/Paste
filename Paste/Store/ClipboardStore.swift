//
//  ClipboardStore.swift
//  Paste
//
//  Created by Nicklas Roelfs on 20.09.26.
//

import SwiftData
import Observation
import Foundation

@MainActor
@Observable
final class ClipboardStore {

    // ##############
    // #   Props    #
    // ##############
    private(set) var items: [ClipboardItem] = []
    private(set) var pinned: [ClipboardItem] = []
    private(set) var capacity: Int
    private(set) var activeItemId: UUID? = nil
    var postDeleteAction:(UUID) -> Void
    
    
    // #############
    // #   Ctor    #
    // #############
    init(capacity: Int = 10, postDeleteAction: @escaping (UUID) -> Void) {
        self.capacity = capacity
        self.postDeleteAction = postDeleteAction
    }
    
    init(configuration: Configuration, postDeleteAction: @escaping (UUID) -> Void) {
        self.capacity = configuration.general.capacity
        self.postDeleteAction = postDeleteAction
    }
    
    // #################
    // #   Computed    #
    // #################
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
    
    // ##############
    // #   Funcs    #
    // ##############
    func push(_ item: ClipboardItem, into context: ModelContext) {
        if let existingIndex = items.firstIndex(where: { $0 == item }) {
            let existing = items.remove(at: existingIndex)
            items.insert(existing, at: 0)
            activeItemId = existing.id

            item.deleteAssociatedFiles()

            try? context.save()
            return
        }
        context.insert(item)  
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
        postDeleteAction(id)
        return removedItem
    }
    
    func updateCapacity(newCapacity: Int) {
        guard newCapacity != capacity else { return }

        if newCapacity < items.count {
            let removeCount = items.count - newCapacity
            let removedItems = items.suffix(removeCount)

            items.removeLast(removeCount)
            removedItems.forEach {
                $0.deleteAssociatedFiles()
                postDeleteAction($0.id)
            }

            if let activeItemId, removedItems.contains(where: { $0.id == activeItemId }) {
                self.activeItemId = items.first?.id
            }
        }

        capacity = newCapacity
    }
    
    @discardableResult
    func removePinnedItem(id:  UUID) -> ClipboardItem? {
        guard let index = pinned.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        let removedItem = pinned.remove(at: index)
        removedItem.deleteAssociatedFiles()

        if activeItemId == id {
            activeItemId = pinned.first?.id
        }
        return removedItem
    }
    
    func unPinItem(id: UUID) {
        guard let index = pinned.firstIndex(where: { $0.id == id }) else { return }
        let item = pinned.remove(at: index)
        items.insert(item, at: 0)
    }
    
    
    @discardableResult
    func activate(id: UUID) -> Bool {
        guard items.contains(where: { $0.id == id }) else { return false }
        activeItemId = id
        return true
    }
    
    func pinItem(id: UUID, in context: ModelContext) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        let item = items[index]
        do {
            try item.pin()
            items.remove(at: index)
            pinned.insert(item, at: 0)
            if activeItemId == id {
                activeItemId = items.first?.id
            }
            try context.save()
            let count = (try? context.fetchCount(
                FetchDescriptor<ClipboardItem>(predicate: #Predicate { $0.pinInfo != nil }))) ?? -1
            print("Gespeicherte Pins:", count)
        } catch {
            print("Pin fehlgeschlagen:", error)
        }
    }
    
    func loadPinned(from context: ModelContext) {
        print("loadPinned aufgerufen")
        let descriptor = FetchDescriptor<ClipboardItem>(
            predicate: #Predicate { $0.pinInfo != nil }
        )
        guard let result = try? context.fetch(descriptor) else { return }

        // Defekte Pins (Datei fehlt) aufräumen
        let valid = result.filter { item in
            guard item.kind == .data else { return true }
            guard let url = item.fileURL else { return false }
            return FileManager.default.fileExists(atPath: url.path)
        }
        print("Pins in DB beim Start:", result.count)
        for item in result where !valid.contains(where: { $0.id == item.id }) {
            context.delete(item)
        }
        try? context.save()

        pinned = valid.sorted {
            ($0.pinInfo?.sortOrder ?? 0) < ($1.pinInfo?.sortOrder ?? 0)
        }
    }

}
