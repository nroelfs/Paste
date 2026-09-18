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
    var sharedModelContainer: ModelContainer = {
           let schema = Schema([
               Clipboard.self
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
    var capacity : Int = 10;
    
    var body: some Scene {
           WindowGroup {
               ClipboardHistory(
                   clipboard: Clipboard.create(capacity: 10)
               )
           }
           .modelContainer(sharedModelContainer)
       }
   }
