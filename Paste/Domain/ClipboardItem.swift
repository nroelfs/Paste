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


@Model
final class ClipboardItem: Identifiable {
    
    // ##############
    // #   Props    #
    // ##############
    private(set) var id = UUID()
    private(set) var createdAt = Date()
    private(set) var kind: ClipboardItemKind

    private var stringValue: String?
    
    private(set) var fileName: String?
    private(set) var thumbnailFileName: String?
    private(set) var contentHash: String?
    
    @Relationship(deleteRule: .cascade, inverse: \PinInfo.item) var pinInfo: PinInfo?
    
    // #############
    // #   Ctor    #
    // #############
    init(text: String) {
        self.kind = .string
        self.stringValue = text
    }

    init(data: Data, fileExtension: String) throws {
        let stored = try ClipboardFileStorage.store(
            data, fileExtension: fileExtension, in: StorageLocation.temp
        )
        self.kind = .data
        self.fileName = stored.fileName
        self.thumbnailFileName = stored.thumbnailFileName
        self.contentHash = stored.contentHash
    }
 
    convenience init(value: ClipboardItemValue, fileExtension: String = "bin") throws {
        switch value {
        case .string(let text):
            self.init(text: text)
        case .data(let data):
            try self.init(data: data, fileExtension: fileExtension)
        }
    }


    // #################
    // #   Computed    #
    // #################
    var isPinned: Bool { pinInfo != nil }
    
   var storageDirectory: URL { isPinned ? StorageLocation.persistent : StorageLocation.temp }

   var fileURL: URL? { fileName.map { storageDirectory.appending(path: $0) } }
   var thumbnailFileURL: URL? { thumbnailFileName.map { storageDirectory.appending(path: $0) } }

   var asString: String? { stringValue }

   var asData: Data? {
       guard kind == .data, let fileURL else { return nil }
       return try? Data(contentsOf: fileURL)
   }

   var cachedThumbnail: NSImage? {
       guard let thumbnailFileURL else { return nil }
       return NSImage(contentsOf: thumbnailFileURL)
   }

   var fileNames: [String] { [fileName, thumbnailFileName].compactMap { $0 } }

    // ##############
    // #   Funcs    #
    // ##############
    
    
    func pin(sortOrder: Int = 0) throws {
        guard !isPinned else { return }
        try ClipboardFileStorage.move(
            fileNames, from: StorageLocation.temp, to: StorageLocation.persistent
        )
        pinInfo = PinInfo(sortOrder: sortOrder)
    }
    func unpin(in context: ModelContext) throws {
        guard let info = pinInfo else { return }
        try ClipboardFileStorage.move(
            fileNames, from: StorageLocation.persistent, to: StorageLocation.temp
        )
        pinInfo = nil
        context.delete(info)
    }
    
    func remove(from context: ModelContext) {
        deleteAssociatedFiles()
        context.delete(self)
    }
 
    func deleteAssociatedFiles() {
        if let fileURL { try? FileManager.default.removeItem(at: fileURL) }
        if let thumbnailFileURL { try? FileManager.default.removeItem(at: thumbnailFileURL) }
    }
    
    @MainActor static func startupCleanup(in context: ModelContext) throws {
            let unpinned = try context.fetch(
                FetchDescriptor<ClipboardItem>(predicate: #Predicate { $0.pinInfo == nil })
            )
     
            var validNames = Set<String>()
            for item in unpinned {
                if item.kind == .data, let url = item.fileURL,
                   !FileManager.default.fileExists(atPath: url.path) {
                    item.remove(from: context)
                } else {
                    validNames.formUnion(item.fileNames)
                }
            }
            try context.save()
     
            guard let files = try? FileManager.default.contentsOfDirectory(
                at: StorageLocation.temp, includingPropertiesForKeys: nil
            ) else { return }
     
            for file in files where !validNames.contains(file.lastPathComponent) {
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



