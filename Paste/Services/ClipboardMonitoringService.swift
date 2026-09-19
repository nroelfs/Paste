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

    var onClipboardChange: ((String) -> Void)?

    init() {
        lastChangeCount = pasteboard.changeCount
    }

    func start(onClipboardChange: @escaping (String) -> Void) {
        guard monitoringTask == nil else { return }

        self.onClipboardChange = onClipboardChange
        
        
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

        guard let value = pasteboard.string(forType: .string) else {
            return
        }

        onClipboardChange?(value)
    }
}
