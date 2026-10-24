// Copyright (c) 2026 Nicklas Roelfs
// Licensed under the PolyForm Shield License 1.0.0

//
//  ClipboardPanelService.swift
//  Paste
//
//  Created by Nicklas Roelfs on 20.09.26.
//

import AppKit
import SwiftUI

@MainActor
final class ClipboardPanelService {
    private let store: ClipboardStore
    private var panel: NSPanel?
    private var hostingView: NSHostingView<ClipboardHistory>?
    private var globalMouseMonitor: Any?

    init(store: ClipboardStore) {
        self.store = store
    }

    func show() {
        let contentView = ClipboardHistory(
            store: store,
            hideAction: { [weak self] in self?.hide() }
        )

        if let panel, let hostingView {
            hostingView.rootView = contentView
            positionPanel(panel)
            panel.orderFrontRegardless()
            return
        }

        let mouseLocation = NSEvent.mouseLocation
        let newPanel = NSPanel(
            contentRect: NSRect(
                x: mouseLocation.x,
                y: mouseLocation.y,
                width: 350,
                height: 450
            ),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        let newHostingView = NSHostingView(rootView: contentView)
        newPanel.contentView = newHostingView

        newPanel.isOpaque = false
        newPanel.backgroundColor = .clear
        newPanel.hasShadow = true
        newPanel.isFloatingPanel = true
        newPanel.level = .floating
        newPanel.hidesOnDeactivate = false

        self.panel = newPanel
        self.hostingView = newHostingView

        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] event in
            Task { @MainActor in
                guard let self, let panel = self.panel else { return }
                let mouseLocation = NSEvent.mouseLocation
                if !panel.frame.contains(mouseLocation) {
                    self.hide()
                }
            }
        }

        newPanel.orderFrontRegardless()
    }

    private func positionPanel(_ panel: NSPanel) {
        let mouseLocation = NSEvent.mouseLocation
        panel.setFrameOrigin(NSPoint(x: mouseLocation.x, y: mouseLocation.y))
    }

    func hide() {
        panel?.orderOut(nil)
    }
}
