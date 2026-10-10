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
    @State private var isHovering = false
    
    private func stringVal(_ text: String) -> some View {
        HStack {
            Text(text)
                .foregroundColor(.primary)
                .font(.system(size: 14))
                .bold(active)
        }
    }

    private func imgVal(_ item: ClipboardItem) -> some View {
        Group {
            if let thumbnail = item.cachedThumbnail {
                Image(nsImage: thumbnail)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 60, maxHeight: 60)
            } else {
                Text("Vorschau nicht verfügbar")
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
                    imgVal(item)
                }
            }
        }
        .padding()
        .frame(width: 350, height: 70, alignment: .leading)
        .onTapGesture {
            selectAction(item.id)
        }
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(isHovering ? Color.primary.opacity(0.08) : .clear)
        )
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
        .animation(.easeOut(duration: 0.12), value: isHovering)
        .onTapGesture { selectAction(item.id) }
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

    static func makeTextItem(_ text: String = "Hello World") -> ClipboardItem {
        let item = ClipboardItem(text: text)
        container.mainContext.insert(item)
        return item
    }

    /// Datei-Eintrag mit Thumbnail
    static func makeImageItem() -> ClipboardItem {
        let image = NSImage(systemSymbolName: "photo", accessibilityDescription: nil)!
        let png = NSBitmapImageRep(data: image.tiffRepresentation!)!
            .representation(using: .png, properties: [:])!
        let item = try! ClipboardItem(data: png, fileExtension: "png")
        container.mainContext.insert(item)
        return item
    }
}

#Preview("Active") {
    ClipboardItemRow(
        item: PreviewData.makeTextItem(),
        selectAction: { _ in },
        active: true
    )
}

#Preview("InActive") {
    ClipboardItemRow(
        item: PreviewData.makeTextItem(),
        selectAction: { _ in },
        active: false
    )
}

#Preview("Bild") {
    ClipboardItemRow(
        item: PreviewData.makeImageItem(),
        selectAction: { _ in },
        active: false
    )
}
#endif

