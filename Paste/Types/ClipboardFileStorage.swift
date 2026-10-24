// Copyright (c) 2026 Nicklas Roelfs
// Licensed under the PolyForm Shield License 1.0.0

//
//  ClipboardFileStorage.swift
//  Paste
//
//  Created by Nicklas Roelfs on 10.10.26.
//
import Foundation
import AppKit
import ImageIO
import CryptoKit

struct StoredFile {
    let fileName: String
    let thumbnailFileName: String?
    let contentHash: String
}

enum ClipboardFileStorage {
 
    static func store(_ data: Data, fileExtension: String, in directory: URL) throws -> StoredFile {
        let name = "\(UUID().uuidString).\(fileExtension)"
        try data.write(to: directory.appending(path: name), options: .atomic)
 
        var thumbName: String?
        if let png = thumbnailPNG(from: data) {
            let candidate = "\(UUID().uuidString)-thumb.png"
            if (try? png.write(to: directory.appending(path: candidate), options: .atomic)) != nil {
                thumbName = candidate
            }
        }
 
        return StoredFile(fileName: name, thumbnailFileName: thumbName, contentHash: sha256(of: data))
    }
 
    static func move(_ names: [String], from source: URL, to destination: URL) throws {
        let fm = FileManager.default
        var moved: [(from: URL, to: URL)] = []
 
        do {
            for name in names {
                let src = source.appending(path: name)
                let dst = destination.appending(path: name)
                try fm.moveItem(at: src, to: dst)
                moved.append((src, dst))
            }
        } catch {
            for entry in moved { try? fm.moveItem(at: entry.to, to: entry.from) }
            throw error
        }
    }
 
    static func sha256(of data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
 
    static func thumbnailPNG(from data: Data, maxDimension: CGFloat = 120) -> Data? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
 
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension,
            kCGImageSourceCreateThumbnailWithTransform: true
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        return NSBitmapImageRep(cgImage: cgImage).representation(using: .png, properties: [:])
    }
}
