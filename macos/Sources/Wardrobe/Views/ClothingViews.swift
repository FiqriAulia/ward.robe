import AppKit
import SwiftData
import SwiftUI
import WardrobeCore

/// Thumbnail pakaian, atau placeholder bila belum ada foto.
struct Thumbnail: View {
    let data: Data?

    var body: some View {
        if let data, let image = NSImage(data: data) {
            Image(nsImage: image)
                .resizable()
                .scaledToFill()
        } else {
            Rectangle()
                .fill(Color.wardrobeCard)
                .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
        }
    }
}

/// Tabel pakaian dengan multi-select (klik, ⌘-klik, ⇧-klik).
struct ClothingTable: View {
    let items: [Clothing]
    @Binding var selection: Set<PersistentIdentifier>
    let emptyMessage: String
    /// Dipanggil saat baris diklik dua kali / Enter.
    var onOpen: ((Set<PersistentIdentifier>) -> Void)?

    var body: some View {
        Table(items, selection: $selection) {
            TableColumn("Foto") { item in
                Thumbnail(data: item.thumbnail)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .width(60)

            TableColumn("Jenis") { item in
                Text(item.kind.label)
            }
            .width(90)

            TableColumn("Nama", value: \.name)

            TableColumn("Deskripsi") { item in
                Text(item.notes)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
            }
        }
        .contextMenu(forSelectionType: PersistentIdentifier.self) { _ in
            EmptyView()
        } primaryAction: { ids in
            onOpen?(ids)
        }
        .overlay {
            if items.isEmpty {
                Text(emptyMessage)
                    .italic()
                    .foregroundStyle(.secondary)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Kartu pakaian untuk grid Wardrobe & Dress Me.
struct ClothingCard: View {
    let item: Clothing
    var imageHeight: CGFloat = 180

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Thumbnail(data: item.thumbnail)
                .frame(maxWidth: .infinity)
                .frame(height: imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(item.name)
                .font(.headline)
                .lineLimit(1)

            HStack(spacing: 6) {
                Text(item.kind.label)
                if item.isInLaundry {
                    Label("Laundry", systemImage: "washer")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.wardrobePanel))
        .help(item.notes.isEmpty ? item.name : item.notes)
    }
}

/// Filter jenis: Semua / Baju / Celana / Aksesoris.
struct KindFilter: View {
    @Binding var selection: ClothingKind?

    var body: some View {
        Picker("Jenis", selection: $selection) {
            Text("Semua").tag(ClothingKind?.none)
            ForEach(ClothingKind.allCases) { kind in
                Text(kind.label).tag(ClothingKind?.some(kind))
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .frame(width: 420)
    }
}
