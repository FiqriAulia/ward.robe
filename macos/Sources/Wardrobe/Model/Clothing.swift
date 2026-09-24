import Foundation
import SwiftData
import WardrobeCore

/// Satu pakaian di lemari. Pengganti tabel baju/celana/aksesoris + laundry versi web.
@Model
final class Clothing {
    /// Disimpan sebagai string supaya aman dipakai di query SwiftData.
    var kindRaw: String
    var name: String
    var notes: String
    /// Foto (maks. 2048 px), disimpan di luar file database.
    @Attribute(.externalStorage) var photo: Data?
    /// Versi kecil (maks. 400 px) untuk daftar & grid.
    var thumbnail: Data?
    var createdAt: Date
    /// Terisi saat pakaian sedang di laundry.
    var laundrySince: Date?

    init(kind: ClothingKind, name: String, notes: String, photo: PreparedPhoto?) {
        self.kindRaw = kind.rawValue
        self.name = name
        self.notes = notes
        self.photo = photo?.photo
        self.thumbnail = photo?.thumbnail
        self.createdAt = .now
        self.laundrySince = nil
    }

    var kind: ClothingKind {
        get { ClothingKind(rawValue: kindRaw) ?? .baju }
        set { kindRaw = newValue.rawValue }
    }

    var isInLaundry: Bool { laundrySince != nil }
}

extension Clothing: Wearable {}

enum WardrobeStore {
    /// Database di ~/Library/Application Support/Wardrobe/Wardrobe.store.
    static func makeContainer() throws -> ModelContainer {
        let support = try FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let directory = support.appendingPathComponent("Wardrobe", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let configuration = ModelConfiguration(url: directory.appendingPathComponent("Wardrobe.store"))
        return try ModelContainer(for: Clothing.self, configurations: configuration)
    }
}

/// Urutan standar di semua daftar: per jenis, lalu nama.
let clothingSort = [SortDescriptor(\Clothing.kindRaw), SortDescriptor(\Clothing.name)]
