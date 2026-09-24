import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Foto yang sudah diperkecil & siap disimpan.
struct PreparedPhoto: Sendable {
    let photo: Data
    let thumbnail: Data
}

enum PhotoError: LocalizedError {
    case unreadable

    var errorDescription: String? {
        "File ini bukan gambar yang bisa dibaca."
    }
}

/// Mengubah foto dari user menjadi versi simpan (maks. 2048 px) dan thumbnail
/// (maks. 400 px). Orientasi EXIF diterapkan, transparansi PNG dipertahankan.
enum PhotoProcessor {
    static let maxPhotoPixels = 2048
    static let maxThumbnailPixels = 400

    static func prepare(fileAt url: URL) throws -> PreparedPhoto {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        return try prepare(Data(contentsOf: url))
    }

    static func prepare(_ data: Data) throws -> PreparedPhoto {
        guard
            let source = CGImageSourceCreateWithData(data as CFData, nil),
            let photo = downsample(source, maxPixels: maxPhotoPixels).flatMap(encode),
            let thumbnail = downsample(source, maxPixels: maxThumbnailPixels).flatMap(encode)
        else {
            throw PhotoError.unreadable
        }
        return PreparedPhoto(photo: photo, thumbnail: thumbnail)
    }

    private static func downsample(_ source: CGImageSource, maxPixels: Int) -> CGImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixels,
            kCGImageSourceShouldCacheImmediately: true,
        ]
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }

    /// JPEG untuk foto biasa, PNG kalau gambarnya punya transparansi.
    private static func encode(_ image: CGImage) -> Data? {
        let hasAlpha: Bool
        switch image.alphaInfo {
        case .none, .noneSkipFirst, .noneSkipLast:
            hasAlpha = false
        default:
            hasAlpha = true
        }

        let type = hasAlpha ? UTType.png : UTType.jpeg
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output as CFMutableData, type.identifier as CFString, 1, nil)
        else { return nil }

        let properties: [CFString: Any] = hasAlpha ? [:] : [kCGImageDestinationLossyCompressionQuality: 0.85]
        CGImageDestinationAddImage(destination, image, properties as CFDictionary)
        return CGImageDestinationFinalize(destination) ? output as Data : nil
    }
}
