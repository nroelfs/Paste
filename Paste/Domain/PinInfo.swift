//
//  PinInfo.swift
//  Paste
//
//  Created by Nicklas Roelfs on 10.10.26.
//

import SwiftData
import Foundation
import AppKit


@Model
final class PinInfo {
    // ##############
    // #   Props    #
    // ##############
    private(set) var pinnedAt = Date()
    var sortOrder: Int
    var item: ClipboardItem?
    
    // #############
    // #   Ctor    #
    // #############
    init(sortOrder: Int = 0) {
        self.sortOrder = sortOrder
    }
}
