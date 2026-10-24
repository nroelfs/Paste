// Copyright (c) 2026 Nicklas Roelfs
// Licensed under the PolyForm Shield License 1.0.0

//
//  ClipboardMonitoringService.swift
//  Paste
//
//  Created by Nicklas Roelfs on 19.09.26.
//

import AppKit

@MainActor
final class ClipboardMonitoringService {

    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int
    private var monitoringTask: Task<Void, Never>?

    var onClipboardChangeString: ((String) -> Void)?
    var onClipboardChangeData: ((Data, String) -> Void)?

    init() {
        lastChangeCount = pasteboard.changeCount
    }

    func start(onClipboardChangeString: @escaping (String) -> Void, onClipboardChangeData: @escaping (Data, String) -> Void) {
        guard monitoringTask == nil else { return }

        self.onClipboardChangeString = onClipboardChangeString
        self.onClipboardChangeData = onClipboardChangeData
        
        notify() // setzt den aktuellen eintrag aus der zwischen ablage ein
        
        monitoringTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(250))

                guard !Task.isCancelled else {
                    return
                }

                self?.checkClipboard()
            }
        }
    }
    func stop() {
        monitoringTask?.cancel()
        monitoringTask = nil
    }

    private func checkClipboard() {
        guard pasteboard.changeCount != lastChangeCount else {
            return
        }

        notify()
    }
    
    private func notify(){
        lastChangeCount = pasteboard.changeCount
        if let value = pasteboard.string(forType: .string) {
            onClipboardChangeString?(value)
        }
        
        if let (data, ext) = imageData() {
            onClipboardChangeData?(data, ext)
        }
    }
    
    private func imageData() -> (Data, String)? {
        if let data = pasteboard.data(forType: .png) {
            return (data, "png")
        }
        if let data = pasteboard.data(forType: .tiff) {
            return (data, "tiff")
        }

        if let fileURL = pasteboard.readObjects(
            forClasses: [NSURL.self],
            options: nil
        )?.first as? URL,
           fileURL.isFileURL,
           let data = try? Data(contentsOf: fileURL),
           NSImage(data: data) != nil {
            return (
                data,
                fileURL.pathExtension.isEmpty ? "png" : fileURL.pathExtension
            )
        }

        return nil
    }
    
    func setClipboard(_ item: ClipboardItem) {
        pasteboard.clearContents()
        switch item.kind {
        case .string :
            pasteboard.setString(item.asString ?? "" , forType: .string)
        case .data :
            if let data = item.asData, let nsImage = NSImage(data: data) {
                pasteboard.writeObjects([nsImage])
            }
        }

        lastChangeCount = pasteboard.changeCount
        print("Trusted: \(AXIsProcessTrusted())")
        ClipboardMonitoringService.paste()
    }
    
    private static func paste(){
        let source = CGEventSource(stateID: .hidSystemState)
        let commandDown = CGEvent(
            keyboardEventSource: source,
            virtualKey: 0x09, // V
            keyDown: true
        )

        let commandUp = CGEvent(
            keyboardEventSource: source,
            virtualKey: 0x09,
            keyDown: false
        )

        commandDown?.flags = .maskCommand
        commandUp?.flags = .maskCommand

        commandDown?.post(tap: .cghidEventTap)
        commandUp?.post(tap: .cghidEventTap)
    }
}
