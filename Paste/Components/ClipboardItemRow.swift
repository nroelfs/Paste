//
//  ClipboardItemRow.swift
//  Paste
//
//  Created by Nicklas Roelfs on 18.09.26.
//

import SwiftUI
import SwiftData

struct ClipboardItemRow: View {
    
    let item: ClipboardItem
    let selectAction: @MainActor (UUID) -> Void
    let active: Bool
    
    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading, spacing: 3) {
                HStack{
                    Text(item.value)
                        .foregroundColor(.primary)
                        .font(.system(size: 14))
                        .bold(active)
                    // Spacer()
                    // Image(systemName: "ellipsis")
                    //    .font(.system(size: 14))
                    //    .foregroundStyle(.primary)
                }
            }		
        }
        .padding()
        .frame(width: 350, height: 35, alignment: .leading)
        .onTapGesture {
            selectAction(item.id)
        }
    }
}

#Preview("Active") {
    let container = try! ModelContainer(
        for: ClipboardItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let item = ClipboardItem.create(input: "Hello World")
    container.mainContext.insert(item)

    return ClipboardItemRow(
        item: item,
        selectAction: { _ in },
        active: true
    )
}

#Preview("InActive") {
    let container = try! ModelContainer(
        for: ClipboardItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let item = ClipboardItem.create(input: "Hello World")
    container.mainContext.insert(item)

    return ClipboardItemRow(
        item: item,
        selectAction: { _ in },
        active: false
    )
}
