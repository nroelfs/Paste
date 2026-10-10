//
//  ClipboardItem.swift
//  Paste
//
//  Created by Nicklas Roelfs on 18.09.26.
//

import SwiftData
import Foundation
import AppKit
import ImageIO
import CryptoKit

enum ClipboardItemKind: Int, Codable {
    case string
    case data
}

enum ClipboardItemValue {
    case string(String)
    case data(Data)
}

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
@Model
final class ClipboardItem: Identifiable {
    private(set) var id = UUID()
    private(set) var createdAt = Date()
    private(set) var kind: ClipboardItemKind

    private var stringValue: String?
    private(set) var fileURL: URL?
    private(set) var thumbnailFileURL: URL?
    private(set) var contentHash: String?

    private init(
        kind: ClipboardItemKind,
        stringValue: String? = nil,
        fileURL: URL? = nil,
        thumbnailFileURL: URL? = nil,
        contentHash: String? = nil
    ) {
        self.kind = kind
        self.stringValue = stringValue
        self.fileURL = fileURL
        self.thumbnailFileURL = thumbnailFileURL
        self.contentHash = contentHash
    }

    static func create(value: String) -> ClipboardItem {
        ClipboardItem(kind: .string, stringValue: value)
    }

    static func create(value: Data, fileExtension: String) -> ClipboardItem {
        let hash = SHA256.hash(data: value)
            .compactMap { String(format: "%02x", $0) }
            .joined()

        let fileURL = writeToTempFile(value, suffix: fileExtension)

        let item = ClipboardItem(kind: .data, fileURL: fileURL, contentHash: hash)

        if let thumbnail = item.generateThumbnail(),
           let tiffData = thumbnail.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            item.thumbnailFileURL = writeToTempFile(pngData, suffix: fileExtension)
        }

        return item
    }
    
    var asString: String? {
        stringValue
    }
    
    var asData: Data? {
        guard kind == .data, let fileURL else { return nil }
        return try? Data(contentsOf: fileURL)
    }
    
    /// Kleine, gecachte Vorschau — günstig für die Listenanzeige
    var cachedThumbnail: NSImage? {
        guard let thumbnailFileURL else { return nil }
        return NSImage(contentsOf: thumbnailFileURL)
    }
    
    func deleteAssociatedFiles() {
        if let fileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }
        if let thumbnailFileURL {
            try? FileManager.default.removeItem(at: thumbnailFileURL)
        }
    }
    
    private func generateThumbnail(maxDimension: CGFloat = 120) -> NSImage? {
        guard let fileURL,
              let imageSource = CGImageSourceCreateWithURL(fileURL as CFURL, nil) else {
            return nil
        }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension,
            kCGImageSourceCreateThumbnailWithTransform: true
        ]

        guard let cgThumbnail = CGImageSourceCreateThumbnailAtIndex(
            imageSource, 0, options as CFDictionary
        ) else {
            return nil
        }

        return NSImage(cgImage: cgThumbnail, size: .zero)
    }
    
    private static func writeToTempFile(_ data: Data, suffix: String) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("PasteClipboardData", isDirectory: true)

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let fileURL = tempDir.appendingPathComponent("\(UUID().uuidString).\(suffix)")
        try? data.write(to: fileURL)
        return fileURL
    }

    static func cleanupOrphanedFiles(keeping validItems: [ClipboardItem]) {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("PasteClipboardData", isDirectory: true)

        guard let files = try? FileManager.default.contentsOfDirectory(
            at: tempDir, includingPropertiesForKeys: nil
        ) else { return }

        let validPaths = Set(validItems.flatMap { [$0.fileURL, $0.thumbnailFileURL].compactMap { $0 } })

        for file in files where !validPaths.contains(file) {
            try? FileManager.default.removeItem(at: file)
        }
    }
    
}



extension ClipboardItem: Equatable {
    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        lhs.kind == rhs.kind &&
        lhs.stringValue == rhs.stringValue &&
        lhs.contentHash == rhs.contentHash
    }
}



