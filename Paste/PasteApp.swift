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
    @State private var configurationStore: ConfigurationStore
    
    private let panelController: ClipboardPanelService
    private let sharedModelContainer: ModelContainer

    init() {
        let container = Self.createModelContainer()
        let configStore: ConfigurationStore
        do {
            configStore = try ConfigurationStore()
            let store = ClipboardStore(configuration: try configStore.load())
            let monitor = ClipboardMonitoringService()
            let hotkey = GlobalHotkeyService()
            let panel = ClipboardPanelService(store: store)

            self.sharedModelContainer = container
            self.panelController = panel

            _store = State(initialValue: store)
            _clipboardMonitor = State(initialValue: monitor)
            _hotkeyService = State(initialValue: hotkey)
            _configurationStore = State(initialValue: configStore)

            monitor.start{ value in
                let item = ClipboardItem.create(value: value)

                store.clipboard.push(
                    item,
                    into: container.mainContext
                )
            } onClipboardChangeData: { value in
                let item = ClipboardItem.create(value: value)

                store.clipboard.push(
                    item,
                    into: container.mainContext
                )
            }
            
            hotkey.register {
                panel.show()
            }

        } catch {
            print("Fehler beim Laden der Konfiguration: \(error). Nutze Standardwerte.")
            fatalError("Configuration could not be loaded: \(error)")
        }



    }

    var body: some Scene {
        MenuBarExtra("Paste", systemImage: "doc.on.clipboard") {
            
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
