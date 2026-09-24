import SwiftData
import SwiftUI
import WardrobeCore

/// Tambah pakaian baru.
struct InputView: View {
    @Environment(\.modelContext) private var context
    @Environment(FlashCenter.self) private var flash

    @State private var kind: ClothingKind = .baju
    @State private var name = ""
    @State private var notes = ""
    @State private var photo: PreparedPhoto?
    @State private var errors: [String] = []

    var body: some View {
        HStack(spacing: 60) {
            WizardCard(mood: .awake)

            VStack(alignment: .leading, spacing: 16) {
                KindPicker(kind: $kind)
                ClothingForm(
                    name: $name,
                    notes: $notes,
                    photo: $photo,
                    namePlaceholder: "Dapat berupa merk \(kind.label)",
                    errors: errors,
                    submitTitle: "Submit",
                    onSubmit: save
                )
            }
        }
        .wardrobeScreen()
        .navigationTitle("Input")
    }

    private func save() {
        switch ClothingValidation.validate(name: name, notes: notes) {
        case .failure(let invalid):
            errors = invalid.messages
        case .success(let input):
            guard let photo else {
                errors = ["Foto wajib diisi."]
                return
            }
            context.insert(Clothing(kind: kind, name: input.name, notes: input.notes, photo: photo))
            do {
                try context.save()
            } catch {
                context.rollback()
                errors = ["Gagal menyimpan: \(error.localizedDescription)"]
                return
            }
            flash.show("\(kind.label) \"\(input.name)\" berhasil ditambahkan.")
            name = ""
            notes = ""
            self.photo = nil
            errors = []
        }
    }
}

/// Ubah pakaian yang sudah ada (dibuka dari menu Edit).
struct EditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(FlashCenter.self) private var flash

    let item: Clothing
    @State private var kind: ClothingKind
    @State private var name: String
    @State private var notes: String
    @State private var photo: PreparedPhoto?
    @State private var errors: [String] = []

    init(item: Clothing) {
        self.item = item
        _kind = State(initialValue: item.kind)
        _name = State(initialValue: item.name)
        _notes = State(initialValue: item.notes)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Edit").font(.title2.bold())
                Spacer()
                Button("Batal") { dismiss() }
                    .keyboardShortcut(.cancelAction)
            }
            KindPicker(kind: $kind)
            ClothingForm(
                name: $name,
                notes: $notes,
                photo: $photo,
                existingThumbnail: item.thumbnail,
                errors: errors,
                submitTitle: "Simpan",
                onSubmit: save
            )
        }
        .padding(24)
    }

    private func save() {
        switch ClothingValidation.validate(name: name, notes: notes) {
        case .failure(let invalid):
            errors = invalid.messages
        case .success(let input):
            item.kind = kind
            item.name = input.name
            item.notes = input.notes
            if let photo {
                item.photo = photo.photo
                item.thumbnail = photo.thumbnail
            }
            do {
                try context.save()
            } catch {
                context.rollback()
                errors = ["Gagal menyimpan: \(error.localizedDescription)"]
                return
            }
            flash.show("\"\(input.name)\" berhasil diubah.")
            dismiss()
        }
    }
}
