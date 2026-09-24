import AppKit
import SwiftUI

/// Posisi kursor di jendela (koordinat global), untuk mata wizard.
@Observable
final class CursorTracker {
    var location: CGPoint?
}

/// Kartu wizard. Ukuran & posisi mengikuti CSS versi web (kartu 350×402,
/// gambar 350×350 mulai y=52, mata 17×17), diskalakan dengan `height`.
struct WizardCard: View {
    enum Mood {
        case asleep, awake
    }

    let mood: Mood
    var height: CGFloat = 402

    @Environment(CursorTracker.self) private var cursor

    private var scale: CGFloat { height / 402 }

    var body: some View {
        let k = scale
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 48 * k)
                .fill(Color.wardrobeCard.shadow(.inner(color: .black.opacity(0.25), radius: 4 * k, y: 4 * k)))
                .frame(width: 312 * k, height: 402 * k)
                .offset(x: 13 * k)

            pixelImage(mood == .awake ? AppResources.wake : AppResources.sleep)
                .frame(width: 350 * k, height: 350 * k)
                .offset(y: 52 * k)

            if mood == .awake {
                eyes(scale: k)
            }
        }
        .frame(width: 350 * k, height: 402 * k, alignment: .topLeading)
        .accessibilityElement()
        .accessibilityLabel(mood == .awake ? "Wizard" : "Wizard sedang tidur")
    }

    private func eyes(scale k: CGFloat) -> some View {
        GeometryReader { proxy in
            let frame = proxy.frame(in: .global)
            // Titik acuan = tengah gambar wizard (sama seperti #anchor di versi web).
            let anchor = CGPoint(x: frame.minX + 175 * k, y: frame.minY + 227 * k)
            let rotation = eyeRotation(anchor: anchor)

            ForEach([131.5, 218.5] as [CGFloat], id: \.self) { x in
                pixelImage(AppResources.eye)
                    .frame(width: 17 * k, height: 17 * k)
                    .rotationEffect(rotation)
                    .position(x: x * k, y: 248.5 * k)
            }
        }
        .frame(width: 350 * k, height: 402 * k)
        .allowsHitTesting(false)
    }

    private func eyeRotation(anchor: CGPoint) -> Angle {
        guard let pointer = cursor.location else { return .zero }
        let degrees = atan2(anchor.y - pointer.y, anchor.x - pointer.x) * 180 / .pi
        return .degrees(90 + degrees)
    }

    private func pixelImage(_ image: NSImage) -> some View {
        Image(nsImage: image)
            .resizable()
            .interpolation(.none)
    }
}
