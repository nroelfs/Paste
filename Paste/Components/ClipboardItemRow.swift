//
//  ClipboardItemRow.swift
//  Paste
//
//  Created by Nicklas Roelfs on 18.09.26.
//

import SwiftUI

struct ClipboardItemRow: View {
    
    let item: ClipboardItem

    var body: some View {
        VStack{
            VStack(alignment: .leading, spacing: 3) {
                Text(item.value)
                    .foregroundColor(.primary)
                    .font(.system(size: 14))
                    .bold(item.isActive)

            }
        }
        .frame(height: 35)
    }
}

#Preview("Active") {
    ClipboardItemRow(item: ClipboardItem.create(input: "test"))
}

#Preview("InActive") {
    var item: ClipboardItem = ClipboardItem.create(input: "test")
    item.toggleActive()
    return ClipboardItemRow(item: item)
}
