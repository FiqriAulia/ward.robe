/// Sesuatu yang bisa dipilih Dress Me.
public protocol Wearable {
    var kind: ClothingKind { get }
    var isInLaundry: Bool { get }
}

/// Logika Dress Me: kombinasi acak dari pakaian yang tidak sedang di laundry.
public enum OutfitPicker {
    /// 2 baju + 1 celana + 1 aksesoris, sama seperti versi web.
    public static let standardRecipe: [(kind: ClothingKind, count: Int)] = [
        (.baju, 2),
        (.celana, 1),
        (.aksesoris, 1),
    ]

    /// Pilih outfit acak. Hasil diurutkan mengikuti resep (baju dulu, lalu celana,
    /// lalu aksesoris). Jenis yang stoknya kurang diisi seadanya.
    public static func pick<Item: Wearable, Generator: RandomNumberGenerator>(
        from items: [Item],
        recipe: [(kind: ClothingKind, count: Int)] = standardRecipe,
        using generator: inout Generator
    ) -> [Item] {
        var outfit: [Item] = []
        for (kind, count) in recipe {
            let available = items.filter { $0.kind == kind && !$0.isInLaundry }
            outfit.append(contentsOf: available.shuffled(using: &generator).prefix(count))
        }
        return outfit
    }

    public static func pick<Item: Wearable>(from items: [Item]) -> [Item] {
        var generator = SystemRandomNumberGenerator()
        return pick(from: items, using: &generator)
    }
}
