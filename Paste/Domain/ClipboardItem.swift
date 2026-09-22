//
//  ClipboardItem.swift
//  Paste
//
//  Created by Nicklas Roelfs on 18.09.26.
//

import SwiftData
import Foundation
import SwiftUI

enum ClipboardItemKind: Int, Codable {
    case string
    case data
}

enum ClipboardItemValue {
    case string(String)
    case data(Data)
}

@Model
final class ClipboardItem: Identifiable {
    private(set) var id = UUID()
    private(set) var createdAt = Date()
    private(set) var kind: ClipboardItemKind

    private var stringValue: String?
    private var dataValue: Data?

    private init(kind: ClipboardItemKind, stringValue: String? = nil, dataValue: Data? = nil) {
        self.kind = kind
        self.stringValue = stringValue
        self.dataValue = dataValue
    }

    static func create(value: String) -> ClipboardItem {
        ClipboardItem(kind: .string, stringValue: value)
    }

    static func create(value: Data) -> ClipboardItem {
        ClipboardItem(kind: .data, dataValue: value)
    }

    var value: ClipboardItemValue {
        switch kind {
        case .string:
            return .string(stringValue ?? "")
        case .data:
            return .data(dataValue ?? Data())
        }
    }
    
    var asString: String? {
        stringValue
    }
    
    var asData: Data? {
        dataValue
    }
}



extension ClipboardItem: Equatable {
    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        lhs.kind == rhs.kind &&
        lhs.stringValue == rhs.stringValue &&
        lhs.dataValue == rhs.dataValue
    }
}
