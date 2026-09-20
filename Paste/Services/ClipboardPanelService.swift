//
//  ClipboardPanelService.swift
//  Paste
//
//  Created by Nicklas Roelfs on 20.09.26.
//

import AppKit
import SwiftUI

@MainActor
final class ClipboardPanelController {
    private let store: ClipboardStore
    private var panel: NSPanel?
    private var globalMouseMonitor: Any?
    init(store: ClipboardStore) {
        self.store = store
    }

    func show() {
        let contentView = ClipboardHistory(
            store: store
        )
        
        if let panel {
               panel.contentView = NSHostingView(
                   rootView: contentView
               )
               panel.orderFrontRegardless()
               return
           }
           var mouseLocation: NSPoint { NSEvent.mouseLocation }
           let panel = NSPanel(
               contentRect: NSRect(
                    x: mouseLocation.x,
                    y: mouseLocation.y,
                   width: 350,
                   height: 450
               ),
               styleMask: [
                   .borderless,
                   .nonactivatingPanel
               ],
               backing: .buffered,
               defer: false
           )

           panel.contentView = NSHostingView(
               rootView: contentView
           )

           panel.isOpaque = false
           panel.backgroundColor = .clear
           panel.hasShadow = true
           panel.isFloatingPanel = true
           panel.level = .floating
           panel.hidesOnDeactivate = false

           self.panel = panel
           globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(
                   matching: [.leftMouseDown, .rightMouseDown]
               ) { [weak self] event in
                   Task { @MainActor in
                       guard let self, let panel = self.panel else {
                           return
                       }

                       let mouseLocation = NSEvent.mouseLocation

                       if !panel.frame.contains(mouseLocation) {
                           self.hide()
                       }
                   }
               }

           panel.orderFrontRegardless()

    }

    func hide() {
        panel?.orderOut(nil)
    }
}
