/// Aturan isian pakaian (nama & deskripsi), sama dengan versi web.
public enum ClothingValidation {
    public static let maxNameLength = 255
    public static let maxNotesLength = 5000

    /// Nama & deskripsi yang sudah di-trim, siap disimpan.
    public struct Input: Equatable, Sendable {
        public let name: String
        public let notes: String
    }

    /// Validasi isian. Mengembalikan input yang sudah dibersihkan, atau daftar pesan error.
    public static func validate(name: String, notes: String) -> Result<Input, Errors> {
        let name = name.trimmingWhitespace()
        let notes = notes.trimmingWhitespace()
        var messages: [String] = []

        if name.isEmpty {
            messages.append("Nama wajib diisi.")
        } else if name.count > maxNameLength {
            messages.append("Nama maksimal \(maxNameLength) karakter.")
        }
        if notes.count > maxNotesLength {
            messages.append("Deskripsi maksimal \(maxNotesLength) karakter.")
        }

        return messages.isEmpty ? .success(Input(name: name, notes: notes)) : .failure(Errors(messages: messages))
    }

    public struct Errors: Error, Equatable, Sendable {
        public let messages: [String]
    }
}

extension String {
    func trimmingWhitespace() -> String {
        var scalars = Substring(self)
        while let first = scalars.first, first.isWhitespace { scalars.removeFirst() }
        while let last = scalars.last, last.isWhitespace { scalars.removeLast() }
        return String(scalars)
    }
}
