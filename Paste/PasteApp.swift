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

    @State private var clipboardMonitor = ClipboardMonitoringService()

    let clipboard = Clipboard.create(capacity: 10)

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Clipboard.self,
            ClipboardItem.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ClipboardHistory(
                clipboard: clipboard
            )
            .onAppear {
                clipboardMonitor.start { value in
                        let item = ClipboardItem.create(input: value)

                        clipboard.push(
                            item,
                            into: sharedModelContainer.mainContext
                        )
                    }
            }
        }
        .modelContainer(sharedModelContainer)
        .windowResizability(.contentSize)
        .defaultSize(width: 350, height: 450)
    }}
