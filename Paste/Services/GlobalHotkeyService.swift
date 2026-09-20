//
//  GlobalHotkeyService.swift
//  Paste
//
//  Created by Nicklas Roelfs on 20.09.26.
//

import AppKit
import Carbon.HIToolbox

@MainActor
final class GlobalHotkeyService {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?

    private var onTrigger: (() -> Void)?

    func register(onTrigger: @escaping () -> Void) {
        self.onTrigger = onTrigger

        let hotKeyID = EventHotKeyID(
            signature: OSType(0x50415354), // "PAST"
            id: 1
        )

        RegisterEventHotKey(
            UInt32(kVK_ANSI_V),
            UInt32(cmdKey | shiftKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData in
                guard let userData else {
                    return noErr
                }

                let service = Unmanaged<GlobalHotkeyService>
                    .fromOpaque(userData)
                    .takeUnretainedValue()

                service.onTrigger?()

                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }

        onTrigger = nil
    }

    deinit {
        // Die eigentliche Bereinigung erfolgt über unregister(),
        // da die Klasse @MainActor ist.
    }
}
