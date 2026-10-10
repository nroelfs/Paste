//
//  StorageLocation.swift
//  Paste
//
//  Created by Nicklas Roelfs on 10.10.26.
//

import Foundation
import SwiftUI

enum StorageLocation {
    static var temp: URL {
        directory(URL.temporaryDirectory
            .appending(path: "PasteClipboardData", directoryHint: .isDirectory))
    }
    
    static var persistent: URL {
        directory(URL.applicationSupportDirectory
            .appending(path: Bundle.main.bundleIdentifier ?? "PasteClipboardData", directoryHint: .isDirectory)
            .appending(path: "Pinned", directoryHint: .isDirectory))
    }
 
    private static func directory(_ url: URL) -> URL {
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
