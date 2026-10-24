// Copyright (c) 2026 Nicklas Roelfs
// Licensed under the PolyForm Shield License 1.0.0

//
//  ContextMenuButton.swift
//  Paste
//
//  Created by Nicklas Roelfs on 10.10.26.
//

import SwiftUI

struct ContextMenuButton: View {
    let title: LocalizedStringKey
    let systemImage: String
    var role: ButtonRole? = nil
    let action: () -> Void
    
    var body: some View {
        Button(role: role, action: action) {
            Label(title, systemImage: systemImage)
        }
        .labelStyle(.titleAndIcon)
    }
}
    
