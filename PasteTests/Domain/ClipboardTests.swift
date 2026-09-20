//
//  ClipboardTests.swift
//  Paste
//
//  Created by Nicklas Roelfs on 20.09.26.
//

import Testing
import SwiftData
import Foundation
@testable import Paste

@MainActor
struct ClipboardTests {

    // MARK: - Helper

    /// Erstellt einen frischen In-Memory-Context für jeden Test,
    /// damit Tests sich nicht gegenseitig beeinflussen.
    private func makeContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: Clipboard.self, ClipboardItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return container.mainContext
    }

    // MARK: - push

    @Test("push fügt ein Item hinzu und aktiviert es")
    func pushAddsItemAndActivates() throws {
        let context = try makeContext()
        let clipboard = Clipboard.create(capacity: 5)
        let item = ClipboardItem.create(input: "Hallo")

        clipboard.push(item, into: context)

        #expect(clipboard.count == 1)
        #expect(clipboard.active?.id == item.id)
        #expect(clipboard.items.first?.value == "Hallo")
    }

    @Test("push fügt neue Items oben ein (LIFO-Reihenfolge)")
    func pushInsertsAtTop() throws {
        let context = try makeContext()
        let clipboard = Clipboard.create(capacity: 5)

        clipboard.push(ClipboardItem.create(input: "Erstes"), into: context)
        clipboard.push(ClipboardItem.create(input: "Zweites"), into: context)

        #expect(clipboard.items.map(\.value) == ["Zweites", "Erstes"])
    }

    @Test("push entfernt das älteste Item, wenn die Kapazität überschritten wird")
    func pushRemovesOldestWhenOverCapacity() throws {
        let context = try makeContext()
        let clipboard = Clipboard.create(capacity: 2)

        clipboard.push(ClipboardItem.create(input: "A"), into: context)
        clipboard.push(ClipboardItem.create(input: "B"), into: context)
        clipboard.push(ClipboardItem.create(input: "C"), into: context)

        #expect(clipboard.count == 2)
        #expect(clipboard.items.map(\.value) == ["C", "B"])
        #expect(clipboard.isFull)
    }

    @Test("push bei bereits vorhandenem Wert aktiviert das bestehende Item, fügt kein Duplikat hinzu")
    func pushWithDuplicateValueActivatesExisting() throws {
        let context = try makeContext()
        let clipboard = Clipboard.create(capacity: 5)
        let original = ClipboardItem.create(input: "Duplikat")

        clipboard.push(original, into: context)
        clipboard.push(ClipboardItem.create(input: "Anderes"), into: context)
        clipboard.push(ClipboardItem.create(input: "Duplikat"), into: context) // gleicher Wert, neue Instanz

        #expect(clipboard.count == 2, "Es darf kein zusätzliches Item entstehen")
        #expect(clipboard.active?.id == original.id, "Das ORIGINAL-Item sollte aktiv sein, nicht die neue Instanz")
    }

    // MARK: - pop

    @Test("pop entfernt und liefert das oberste Item")
    func popRemovesTopItem() throws {
        let context = try makeContext()
        let clipboard = Clipboard.create(capacity: 5)
        let item = ClipboardItem.create(input: "Nur ich")
        clipboard.push(item, into: context)

        let popped = clipboard.pop()

        #expect(popped?.id == item.id)
        #expect(clipboard.isEmpty)
    }

    @Test("pop liefert nil bei leerer Clipboard")
    func popOnEmptyReturnsNil() throws {
        let clipboard = Clipboard.create(capacity: 5)

        #expect(clipboard.pop() == nil)
    }

    // MARK: - remove

    @Test("remove entfernt ein Item anhand der ID")
    func removeById() throws {
        let context = try makeContext()
        let clipboard = Clipboard.create(capacity: 5)
        let item = ClipboardItem.create(input: "Weg damit")
        clipboard.push(item, into: context)

        let removed = clipboard.remove(id: item.id)

        #expect(removed?.id == item.id)
        #expect(clipboard.isEmpty)
    }

    @Test("remove liefert nil, wenn die ID nicht existiert")
    func removeWithUnknownIdReturnsNil() throws {
        let clipboard = Clipboard.create(capacity: 5)

        #expect(clipboard.remove(id: UUID()) == nil)
    }

    @Test("remove des aktiven Items aktiviert automatisch das neue oberste Item")
    func removeActiveItemActivatesNextTop() throws {
        let context = try makeContext()
        let clipboard = Clipboard.create(capacity: 5)
        let first = ClipboardItem.create(input: "Erstes")
        let second = ClipboardItem.create(input: "Zweites")
        clipboard.push(first, into: context)
        clipboard.push(second, into: context) // second ist jetzt aktiv (oben)

        clipboard.remove(id: second.id)

        #expect(clipboard.activeItemId == first.id)
    }

    @Test("remove des letzten verbleibenden Items setzt activeItemId auf nil")
    func removeLastItemClearsActiveId() throws {
        let context = try makeContext()
        let clipboard = Clipboard.create(capacity: 5)
        let item = ClipboardItem.create(input: "Einziges")
        clipboard.push(item, into: context)

        clipboard.remove(id: item.id)

        #expect(clipboard.activeItemId == nil)
        #expect(clipboard.active == nil)
    }

    @Test("remove eines inaktiven Items lässt activeItemId unverändert")
    func removeInactiveItemKeepsActiveIdUnchanged() throws {
        let context = try makeContext()
        let clipboard = Clipboard.create(capacity: 5)
        let first = ClipboardItem.create(input: "Erstes")
        let second = ClipboardItem.create(input: "Zweites")
        clipboard.push(first, into: context)
        clipboard.push(second, into: context) // second aktiv

        clipboard.remove(id: first.id) // inaktives Item entfernen

        #expect(clipboard.activeItemId == second.id)
    }

    // MARK: - activate

    @Test("activate setzt eine existierende ID als aktiv und liefert true")
    func activateExistingIdReturnsTrue() throws {
        let context = try makeContext()
        let clipboard = Clipboard.create(capacity: 5)
        let first = ClipboardItem.create(input: "Erstes")
        let second = ClipboardItem.create(input: "Zweites")
        clipboard.push(first, into: context)
        clipboard.push(second, into: context) // second aktiv

        let result = clipboard.activate(id: first.id)

        #expect(result == true)
        #expect(clipboard.activeItemId == first.id)
    }

    @Test("activate mit unbekannter ID liefert false und ändert nichts")
    func activateUnknownIdReturnsFalse() throws {
        let context = try makeContext()
        let clipboard = Clipboard.create(capacity: 5)
        let item = ClipboardItem.create(input: "Vorhanden")
        clipboard.push(item, into: context)

        let result = clipboard.activate(id: UUID())

        #expect(result == false)
        #expect(clipboard.activeItemId == item.id, "activeItemId darf sich bei fehlgeschlagener Aktivierung nicht ändern")
    }

    // MARK: - Zustände (isEmpty, isFull, count)

    @Test("isEmpty ist true für eine neue Clipboard")
    func newClipboardIsEmpty() throws {
        let clipboard = Clipboard.create(capacity: 3)

        #expect(clipboard.isEmpty)
        #expect(clipboard.count == 0)
        #expect(clipboard.isFull == false)
    }

    @Test("isFull wird true, sobald Kapazität erreicht ist")
    func isFullReflectsCapacity() throws {
        let context = try makeContext()
        let clipboard = Clipboard.create(capacity: 2)

        clipboard.push(ClipboardItem.create(input: "A"), into: context)
        #expect(clipboard.isFull == false)

        clipboard.push(ClipboardItem.create(input: "B"), into: context)
        #expect(clipboard.isFull == true)
    }
}
