//
//  ClipboardItem.swift
//  Paste
//
//  Created by Nicklas Roelfs on 18.09.26.
//

import SwiftData
import Foundation

@Model
final class ClipboardItem : Identifiable {
    private(set) var id = UUID()
    private(set) var value: String
    private(set) var createdAt: Date
    
    private init(value: String){
        self.value = value
        self.createdAt = Date()
    }
    
    static func create(input: String) -> ClipboardItem {
        ClipboardItem(value: input)
    }
    
    
}

