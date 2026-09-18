//
//  ClipboardHistory.swift
//  Paste
//
//  Created by Nicklas Roelfs on 18.09.26.
//
import SwiftUI
import SwiftData

struct ClipboardHistory: View {
    @Environment(\.modelContext) private var modelContext
    let clipboard: Clipboard
    var body: some View {
        HStack{
            if clipboard.isEmpty {
                HStack{
                    VStack(spacing: 12) {
                        Image(systemName: "list.clipboard")
                            .font(.system(size: 70))
                            .foregroundStyle(.secondary)

                        Text("Clipboard is empty.")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .foregroundColor(.primary)

            } else {
                List {
                    ForEach(clipboard.items) { item in
                       ClipboardItemRow(item: item)

                    }
                }
            }
        }
        .frame(width: 350)
        .frame(
            minWidth: 300,
            idealWidth: 350,
            minHeight:  450)
    }
}




#Preview("Items Not Loaded") {
    ClipboardHistory(clipboard: Clipboard.create(capacity: 10))
}


#Preview("Items Loaded") {
    let container = try! ModelContainer(
        for: ClipboardItem.self,
        configurations: ModelConfiguration(
            isStoredInMemoryOnly: true
        )
    )

    let context = container.mainContext

    let clipboard = Clipboard.create(capacity: 10)

    let item1 = ClipboardItem.create(input: "Hello World")
    let item2 = ClipboardItem.create(input: "SwiftData")
    let item3 = ClipboardItem.create(input: "Clipboard Test")

    clipboard.push(item1, into: context)
    clipboard.push(item2, into: context)
    clipboard.push(item3, into: context)

    return ClipboardHistory(clipboard: clipboard)
        .modelContainer(container)
}




