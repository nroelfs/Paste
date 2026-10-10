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
    let hideAction : () -> Void
    
    
    private func selectItem(_ id: UUID) {
        let oldActiveId = store.activeItemId

        guard store.activate(id: id), let active = store.active else {
            if let oldActiveId {
                store.activate(id: oldActiveId)
            }
            return
        }

        clipboardMonitoringService.setClipboard(active)
        hideAction()
    }
    
    
    @MainActor private func removeItem(id: UUID){
        store.remove(id: id)
    }
    
    @MainActor private func pinItem(id: UUID){
        store.pinItem(id: id)
    }
    
    
    var body: some View {
        ZStack{
            if store.isEmpty && store.pinned.count <= 0{
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
                    Section {
                        ForEach(store.items, id: \.id) { item in
                            ClipboardItemRow(item: item,
                                             selectAction: selectItem,
                                             active: item.id == store.activeItemId)
                            .contextMenu {
                                ContextMenuButton(title: "Remove", systemImage: "trash", role: .destructive) {
                                    removeItem(id: item.id)
                                }
                                ContextMenuButton(title: "Pin", systemImage: "pin") {
                                    pinItem(id: item.id)
                                }
                            }
                        }
                    }
                    
                    if !store.pinned.isEmpty {
                        Section(header: Text("Pins")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))) {
                                ForEach(store.pinned, id: \.id) { pin in
                                    ClipboardItemRow(item: pin,
                                                     selectAction: selectItem,
                                                     active: pin.id == store.activeItemId)
                                }
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



#if DEBUG
@MainActor
private enum PreviewData {
    /// static let hält den Container für die gesamte Lebenszeit der Preview am Leben
    static let container = try! ModelContainer(
        for: ClipboardItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    static func makeStore(withItems: Bool) -> ClipboardStore {
        let context = container.mainContext
        let store = ClipboardStore(capacity: 10, postDeleteAction: { _ in })

        if withItems {
            for text in ["Hello World", "SwiftData", "Clipboard Test"] {
                let item = ClipboardItem(text: text)
                context.insert(item)
                store.push(item, into: context)
            }
        }
        return store
    }
}

#Preview("Items Not Loaded") {
    ClipboardHistory(store: PreviewData.makeStore(withItems: false), hideAction: { })
        .modelContainer(PreviewData.container)
}

#Preview("Items Loaded") {
    ClipboardHistory(store: PreviewData.makeStore(withItems: true), hideAction: { })
        .modelContainer(PreviewData.container)
}
#endif





