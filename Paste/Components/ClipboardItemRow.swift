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
    
    private func stringVal(_ text: String) -> some View {
        HStack {
            Text(text)
                .foregroundColor(.primary)
                .font(.system(size: 14))
                .bold(active)
        }
    }

    private func imgVal(_ data: Data) -> some View {
        Group {
            if let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 60, maxHeight: 60)
            } else {
                Text("Bild konnte nicht geladen werden")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
            }
        }
    }
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 3) {
                switch item.kind {
                case .string:
                    stringVal(item.asString ?? "")
                case .data:
                    imgVal(item.asData ?? Data())
                }
            }
        }
        .padding()
        .frame(width: 350, height: rowHeight, alignment: .leading)
        .onTapGesture {
            selectAction(item.id)
        }
    }

    private var rowHeight: CGFloat {
        switch item.kind {
        case .string:
            return 35
        case .data:
            return 70
        }
    }
}

#if DEBUG
@MainActor
private func makePreviewItem() -> ClipboardItem {
    let container = try! ModelContainer(
        for: ClipboardItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let item = ClipboardItem.create(value: "Hello World")
    container.mainContext.insert(item)
    return item
}
#endif

#Preview("Active") {
    ClipboardItemRow(
        item: makePreviewItem(),
        selectAction: { _ in },
        active: true
    )
}

#Preview("InActive") {
    ClipboardItemRow(
        item: makePreviewItem(),
        selectAction: { _ in },
        active: false
    )
}
