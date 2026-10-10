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
    @State private var lifetimeService: LifetimeService
    
    private var directoryWatcher: DirectoryWatcher?
    private let panelController: ClipboardPanelService
    private let sharedModelContainer: ModelContainer

    
    init() {
        let container = Self.createModelContainer()
        let configStore: ConfigurationStore
        do {
            configStore = try ConfigurationStore()
            let configuartion = try configStore.load()
            let store = ClipboardStore(configuration: configuartion)
            let monitor = ClipboardMonitoringService()
            let hotkey = GlobalHotkeyService()
            let panel = ClipboardPanelService(store: store)
            let lifetime = LifetimeService(configuartion.clipboardLifeTime)
            
            let directoryWatcher = DirectoryWatcher(path: configStore.configDir.path()) {
                do {
                    let conf = try configStore.load()
                    try ConfigLoader.Load(conf, store: store, lifetimeService: lifetime)
                } catch {
                    print("failed to reload config \(error)")
                }
            }
            directoryWatcher.start()
            ClipboardItem.cleanupOrphanedFiles(keeping: store.items)
            
            self.sharedModelContainer = container
            self.panelController = panel
            self.directoryWatcher = directoryWatcher
            
            _lifetimeService = State(initialValue: lifetime)
            _store = State(initialValue: store)
            _clipboardMonitor = State(initialValue: monitor)
            _hotkeyService = State(initialValue: hotkey)
            _configurationStore = State(initialValue: configStore)
            
            
            lifetime.start(onEntryExpire: { id in
                store.remove(id: id)
            })
            
            monitor.start{ value in
                let item = ClipboardItem.create(value: value)

                store.push(
                    item,
                    into: container.mainContext
                )
                lifetime.schedule(id: item.id, createdAt: item.createdAt)
                
                
            } onClipboardChangeData: { data, ext in
                let item = ClipboardItem.create(value: data, fileExtension: ext)

                store.push(
                    item,
                    into: container.mainContext
                )
                lifetime.schedule(id: item.id, createdAt: item.createdAt)
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
