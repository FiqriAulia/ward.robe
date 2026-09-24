import AppKit

/// Gambar & teks bawaan app (wizard, changelog easter egg).
enum AppResources {
    static let wake = image("Wake")
    static let sleep = image("Sleep")
    static let eye = image("Mata")
    static let rizzard = image("Rizzard")
    static let changelog = text("changelog")

    private static func url(_ name: String, _ ext: String) -> URL? {
        // Di dalam Wardrobe.app file ada di Contents/Resources (lihat
        // scripts/build-app.sh); saat `swift run`/Xcode, di resource bundle SwiftPM.
        Bundle.main.url(forResource: name, withExtension: ext)
            ?? Bundle.module.url(forResource: name, withExtension: ext)
    }

    private static func image(_ name: String) -> NSImage {
        url(name, "png").flatMap { NSImage(contentsOf: $0) } ?? NSImage()
    }

    private static func text(_ name: String) -> String {
        url(name, "txt").flatMap { try? String(contentsOf: $0, encoding: .utf8) } ?? ""
    }
}
