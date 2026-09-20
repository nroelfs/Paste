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
    let store : ClipboardStore
    let clipboardMonitoringService : ClipboardMonitoringService = ClipboardMonitoringService()
    
    private func selectItem(_ id: UUID) {
        let oldActiveId = store.clipboard.activeItemId

        guard store.clipboard.activate(id: id), let active = store.clipboard.active else {
            if let oldActiveId {
                store.clipboard.activate(id: oldActiveId)
            }
            return
        }

        clipboardMonitoringService.setClipboard(active.value)
    }
    
    
    @MainActor private func removeItem(id: UUID){
        store.clipboard.remove(id: id)
    }
    
    
    var body: some View {
        ZStack{
            if store.clipboard.isEmpty {
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
                    ForEach(store.clipboard.items, id: \.id) { item in
                        ClipboardItemRow(item: item,
                                         selectAction: selectItem,
                                         active: item.id == store.clipboard.activeItemId)
                            .contextMenu {
                                Button("Remove",systemImage: "trash", role: .destructive, action: {removeItem(id: item.id)})
                            }
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
    ClipboardHistory(store: ClipboardStore(capacity: 10))
}


#Preview("Items Loaded") {
    let container = try! ModelContainer(
        for: ClipboardItem.self,
        configurations: ModelConfiguration(
            isStoredInMemoryOnly: true
        )
    )
    
    let context = container.mainContext
    let store = ClipboardStore(capacity: 10)

    let item1 = ClipboardItem.create(input: "Hello World")
    let item2 = ClipboardItem.create(input: "SwiftData")
    let item3 = ClipboardItem.create(input: "Clipboard Test")

    store.clipboard.push(item1, into: context)
    store.clipboard.push(item2, into: context)
    store.clipboard.push(item3, into: context)

    return ClipboardHistory(store: store)
        .modelContainer(container)
}




