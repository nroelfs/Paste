//
//  ClipboardStore.swift
//  Paste
//
//  Created by Nicklas Roelfs on 20.09.26.
//

import SwiftData
import Observation

@MainActor
@Observable
final class ClipboardStore {
    let clipboard: Clipboard

    init(capacity: Int = 10) {
        clipboard = Clipboard.create(capacity: capacity)
    }
}
