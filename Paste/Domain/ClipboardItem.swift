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
    var id = UUID()
    var value: String
    var isActive: Bool = false
    var createdAt: Date
    
    private init(value: String){
        self.value = value
        self.isActive = true
        self.createdAt = Date()
    }
    
    static func create(input: String) -> ClipboardItem {
        ClipboardItem(value: input)
    }
    
    func toggleActive() {
        isActive = !isActive
    }
    
}

