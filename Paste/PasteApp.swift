//
//  PasteApp.swift
//  Paste
//
//  Created by Nicklas Roelfs on 18.09.26.
//

import SwiftUI
import SwiftData

@main
struct PasteApp: App {
    @State private var store: ClipboardStore
    @State private var clipboardMonitor: ClipboardMonitoringService
    @State private var hotkeyService: GlobalHotkeyService

    private let panelController: ClipboardPanelController
    private let sharedModelContainer: ModelContainer

    init() {
        let container = Self.createModelContainer()
        let store = ClipboardStore(capacity: 10)
        let monitor = ClipboardMonitoringService()
        let hotkey = GlobalHotkeyService()
        let panel = ClipboardPanelController(store: store)

        self.sharedModelContainer = container
        self.panelController = panel

        _store = State(initialValue: store)
        _clipboardMonitor = State(initialValue: monitor)
        _hotkeyService = State(initialValue: hotkey)

        monitor.start { value in
            let item = ClipboardItem.create(input: value)

            store.clipboard.push(
                item,
                into: container.mainContext
            )
        }

        hotkey.register {
            panel.show()
        }
    }

    var body: some Scene {
        MenuBarExtra("Paste", systemImage: "doc.on.clipboard") {
            Button("Show Clipboard") {
                panelController.show()
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .menuBarExtraStyle(.menu)
    }

    private static func createModelContainer() -> ModelContainer {
        let schema = Schema([
            Clipboard.self,
            ClipboardItem.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
