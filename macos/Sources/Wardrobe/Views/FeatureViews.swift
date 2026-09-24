import SwiftData
import SwiftUI
import WardrobeCore

/// Semua isi lemari dalam bentuk grid, bisa difilter & dicari.
struct WardrobeView: View {
    @Query(sort: clothingSort) private var items: [Clothing]
    @State private var filter: ClothingKind?
    @State private var search = ""

    private var visible: [Clothing] {
        items.filter { item in
            (filter == nil || item.kind == filter)
                && (search.isEmpty
                    || item.name.localizedCaseInsensitiveContains(search)
                    || item.notes.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            KindFilter(selection: $filter)

            if visible.isEmpty {
                ContentUnavailableView(
                    items.isEmpty ? "Lemari masih kosong" : "Tidak ditemukan",
                    systemImage: "tshirt",
                    description: Text(items.isEmpty ? "Tambahkan pakaian lewat menu Input." : "Coba kata kunci atau filter lain.")
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 16)], spacing: 16) {
                        ForEach(visible) { ClothingCard(item: $0) }
                    }
                }
            }
        }
        .padding(24)
        .wardrobeScreen()
        .navigationTitle("Wardrobe")
        .searchable(text: $search, prompt: "Cari nama atau deskripsi")
    }
}

/// Pilih pakaian lalu edit (klik dua kali, atau tombol Edit).
struct EditView: View {
    @Environment(FlashCenter.self) private var flash
    @Query(sort: clothingSort) private var items: [Clothing]
    @State private var selection = Set<Clothing.ID>()
    @State private var editing: Clothing?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Klik dua kali pakaian untuk mengedit.")
                .font(.headline)

            ClothingTable(
                items: items,
                selection: $selection,
                emptyMessage: "Belum ada pakaian untuk diedit.",
                onOpen: edit
            )

            HStack {
                Spacer()
                Button("Edit") { edit(selection) }
                    .buttonStyle(PillButtonStyle())
                    .disabled(selection.count != 1)
            }
        }
        .padding(24)
        .wardrobeScreen()
        .navigationTitle("Edit")
        .sheet(item: $editing) { item in
            EditSheet(item: item)
                .environment(flash)
        }
    }

    private func edit(_ ids: Set<Clothing.ID>) {
        guard ids.count == 1, let id = ids.first else { return }
        editing = items.first { $0.id == id }
    }
}

/// Pakaian yang sedang di laundry: tandai selesai, atau masukkan yang baru.
struct LaundryView: View {
    @Environment(\.modelContext) private var context
    @Environment(FlashCenter.self) private var flash
    @Query(sort: clothingSort) private var items: [Clothing]
    @State private var selection = Set<Clothing.ID>()
    @State private var showAdd = false

    private var inLaundry: [Clothing] { items.filter(\.isInLaundry) }
    private var selectedInLaundry: [Clothing] { inLaundry.filter { selection.contains($0.id) } }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Berikut pakaian yang sedang di laundry")
                .font(.headline)

            ClothingTable(items: inLaundry, selection: $selection, emptyMessage: "Tidak ada pakaian di laundry.")

            HStack {
                Button("Masukkan Laundry-an Baru") { showAdd = true }
                Spacer()
                Button("Sudah Selesai (\(selectedInLaundry.count))", action: finish)
                    .disabled(selectedInLaundry.isEmpty)
            }
            .buttonStyle(PillButtonStyle())
        }
        .padding(24)
        .wardrobeScreen()
        .navigationTitle("Laundri[ed]")
        .sheet(isPresented: $showAdd) {
            AddToLaundrySheet(candidates: items.filter { !$0.isInLaundry })
                .environment(flash)
        }
    }

    private func finish() {
        let done = selectedInLaundry
        done.forEach { $0.laundrySince = nil }
        guard saveOrRollback(context, flash) else { return }
        flash.show("\(done.count) pakaian selesai di laundry.")
        selection = []
    }
}

struct AddToLaundrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(FlashCenter.self) private var flash

    let candidates: [Clothing]
    @State private var selection = Set<Clothing.ID>()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pilih pakaian mana yang di laundry")
                .font(.title3.bold())

            ClothingTable(
                items: candidates,
                selection: $selection,
                emptyMessage: "Semua pakaian sudah di laundry."
            )

            HStack {
                Button("Batal") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Masukkan (\(selection.count))", action: add)
                    .buttonStyle(PillButtonStyle())
                    .keyboardShortcut(.defaultAction)
                    .disabled(selection.isEmpty)
            }
        }
        .padding(24)
        .frame(minWidth: 760, minHeight: 480)
    }

    private func add() {
        let chosen = candidates.filter { selection.contains($0.id) }
        let now = Date.now
        chosen.forEach { $0.laundrySince = now }
        guard saveOrRollback(context, flash) else { return }
        flash.show("\(chosen.count) pakaian masuk laundry.")
        dismiss()
    }
}

/// Hapus pakaian yang sudah dijual (beserta fotonya).
struct SoldView: View {
    @Environment(\.modelContext) private var context
    @Environment(FlashCenter.self) private var flash
    @Query(sort: clothingSort) private var items: [Clothing]
    @State private var kind: ClothingKind = .baju
    @State private var selection = Set<Clothing.ID>()
    @State private var confirming = false

    private var ofKind: [Clothing] { items.filter { $0.kind == kind } }
    private var selected: [Clothing] { ofKind.filter { selection.contains($0.id) } }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            KindPicker(kind: $kind)
            Text("Pilih \(kind.label) mana yang sudah dijual")
                .font(.headline)

            ClothingTable(items: ofKind, selection: $selection, emptyMessage: "Tidak ada \(kind.label).")

            HStack {
                Spacer()
                Button("Sold (\(selected.count))") { confirming = true }
                    .buttonStyle(PillButtonStyle())
                    .disabled(selected.isEmpty)
            }
        }
        .padding(24)
        .wardrobeScreen()
        .navigationTitle("Sold")
        .onChange(of: kind) { selection = [] }
        .confirmationDialog(
            "Hapus \(selected.count) \(kind.label) secara permanen?",
            isPresented: $confirming
        ) {
            Button("Sold", role: .destructive, action: sell)
        } message: {
            Text("Data dan fotonya akan dihapus dari Wardrobe.")
        }
    }

    private func sell() {
        let sold = selected
        sold.forEach { context.delete($0) }
        guard saveOrRollback(context, flash) else { return }
        flash.show("\(sold.count) \(kind.label) terjual.")
        selection = []
    }
}

/// Kombinasi acak: 2 baju + 1 celana + 1 aksesoris, tanpa yang di laundry.
struct DressMeView: View {
    @Query private var items: [Clothing]
    @State private var outfit: [Clothing] = []

    var body: some View {
        HStack(spacing: 60) {
            WizardCard(mood: .awake)

            Group {
                if outfit.isEmpty {
                    Text("Yah kamu gaada pakaian yang bisa dipakai.\nTambah lewat menu Input, atau tunggu laundry-an selesai.")
                        .font(.title3)
                } else {
                    LazyVGrid(columns: [GridItem(.fixed(210), spacing: 16), GridItem(.fixed(210))], spacing: 16) {
                        ForEach(outfit) { ClothingCard(item: $0, imageHeight: 190) }
                    }
                }
            }
            .frame(width: 440)
        }
        .wardrobeScreen()
        .navigationTitle("Dress Me")
        .toolbar {
            ToolbarItem {
                Button(action: regenerate) {
                    Label("Re-generate", systemImage: "shuffle")
                }
                .keyboardShortcut("r")
                .help("Re-generate (⌘R)")
            }
        }
        .onAppear(perform: regenerate)
    }

    private func regenerate() {
        withAnimation {
            outfit = OutfitPicker.pick(from: items)
        }
    }
}

/// Simpan perubahan; bila gagal, batalkan & tampilkan pesan. @return true bila berhasil.
@MainActor
private func saveOrRollback(_ context: ModelContext, _ flash: FlashCenter) -> Bool {
    do {
        try context.save()
        return true
    } catch {
        context.rollback()
        flash.show("Gagal menyimpan: \(error.localizedDescription)")
        return false
    }
}
