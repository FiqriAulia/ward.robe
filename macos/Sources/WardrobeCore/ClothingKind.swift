/// Jenis pakaian di lemari.
public enum ClothingKind: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case baju
    case celana
    case aksesoris

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .baju: return "Baju"
        case .celana: return "Celana"
        case .aksesoris: return "Aksesoris"
        }
    }
}
