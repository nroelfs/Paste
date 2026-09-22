
//
//  ClipboardItemTests.swift
//  Paste
//
//  Created by Nicklas Roelfs on 22.09.26.
//

import Testing
import SwiftData
import Foundation
@testable import Paste

@MainActor
struct ClipboardItemTests {

    // MARK: - Helper

    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: Clipboard.self, ClipboardItem.self,
            configurations: ModelConfiguration(
                isStoredInMemoryOnly: true
            )
        )
    }

    // MARK: - String

    @Test("create erstellt ein String-Item")
    func createStringItem() throws {
        let item = ClipboardItem.create(value: "Hallo Welt")

        #expect(item.kind == .string)
        #expect(item.asString == "Hallo Welt")
        #expect(item.asData == nil)
    }

    @Test("String-Item liefert seinen Wert als ClipboardItemValue")
    func stringItemReturnsStringValue() throws {
        let item = ClipboardItem.create(value: "Hallo Welt")

        switch item.value {
        case .string(let value):
            #expect(value == "Hallo Welt")

        case .data:
            Issue.record("Ein String-Item darf keinen Data-Wert liefern")
        }
    }

    // MARK: - Data

    @Test("create erstellt ein Data-Item")
    func createDataItem() throws {
        let data = Data([1, 2, 3, 4])
        let item = ClipboardItem.create(value: data)

        #expect(item.kind == .data)
        #expect(item.asData == data)
        #expect(item.asString == nil)
    }

    @Test("Data-Item liefert seinen Wert als ClipboardItemValue")
    func dataItemReturnsDataValue() throws {
        let data = Data([1, 2, 3, 4])
        let item = ClipboardItem.create(value: data)

        switch item.value {
        case .string:
            Issue.record("Ein Data-Item darf keinen String-Wert liefern")

        case .data(let value):
            #expect(value == data)
        }
    }

    // MARK: - Identity

    @Test("jedes Item erhält eine eigene ID")
    func itemsHaveUniqueIds() {
        let first = ClipboardItem.create(value: "Hallo")
        let second = ClipboardItem.create(value: "Hallo")

        #expect(first.id != second.id)
    }

    @Test("jedes Item erhält einen Erstellungszeitpunkt")
    func itemHasCreatedAt() {
        let before = Date()
        let item = ClipboardItem.create(value: "Hallo")
        let after = Date()

        #expect(item.createdAt >= before)
        #expect(item.createdAt <= after)
    }

    // MARK: - Equatable

    @Test("zwei String-Items mit gleichem Inhalt sind gleich")
    func equalStringItems() {
        let first = ClipboardItem.create(value: "Hallo")
        let second = ClipboardItem.create(value: "Hallo")

        #expect(first == second)
    }

    @Test("zwei String-Items mit unterschiedlichem Inhalt sind nicht gleich")
    func differentStringItems() {
        let first = ClipboardItem.create(value: "Hallo")
        let second = ClipboardItem.create(value: "Welt")

        #expect(first != second)
    }

    @Test("zwei Data-Items mit gleichem Inhalt sind gleich")
    func equalDataItems() {
        let data = Data([1, 2, 3, 4])

        let first = ClipboardItem.create(value: data)
        let second = ClipboardItem.create(value: data)

        #expect(first == second)
    }

    @Test("zwei Data-Items mit unterschiedlichem Inhalt sind nicht gleich")
    func differentDataItems() {
        let first = ClipboardItem.create(value: Data([1, 2, 3]))
        let second = ClipboardItem.create(value: Data([4, 5, 6]))

        #expect(first != second)
    }

    @Test("String- und Data-Items sind nicht gleich")
    func stringAndDataItemsAreNotEqual() {
        let stringItem = ClipboardItem.create(value: "Hallo")
        let dataItem = ClipboardItem.create(value: Data([1, 2, 3]))

        #expect(stringItem != dataItem)
    }
}
