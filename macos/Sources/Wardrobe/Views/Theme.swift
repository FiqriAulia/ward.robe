import SwiftUI

extension Color {
    static let wardrobeYellow = Color(red: 245 / 255, green: 203 / 255, blue: 92 / 255)  // #F5CB5C
    static let wardrobeDark = Color(red: 51 / 255, green: 53 / 255, blue: 51 / 255)  // #333533
    static let wardrobeCard = Color(red: 217 / 255, green: 217 / 255, blue: 217 / 255)  // #D9D9D9
    static let wardrobePanel = Color(red: 221 / 255, green: 221 / 255, blue: 208 / 255)  // #DDDDD0
}

extension View {
    /// Latar kuning khas Wardrobe, memenuhi seluruh jendela.
    func wardrobeScreen() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.wardrobeYellow)
            .foregroundStyle(.black)
    }
}

/// Tombol berupa tulisan tebal (menu utama, pilihan jenis).
struct WordButtonStyle: ButtonStyle {
    var size: CGFloat = 32

    func makeBody(configuration: Configuration) -> some View {
        WordButton(configuration: configuration, size: size)
    }

    private struct WordButton: View {
        let configuration: ButtonStyleConfiguration
        let size: CGFloat
        @State private var hovering = false

        var body: some View {
            configuration.label
                .font(.system(size: size, weight: .bold))
                .foregroundStyle(hovering || configuration.isPressed ? Color(white: 0.33) : .black)
                .contentShape(Rectangle())
                .onHover { hovering = $0 }
        }
    }
}

/// Tombol kapsul gelap ("Wake the Wizard", Submit, dll).
struct PillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        PillButton(configuration: configuration)
    }

    private struct PillButton: View {
        let configuration: ButtonStyleConfiguration
        @Environment(\.isEnabled) private var isEnabled
        @State private var hovering = false

        var body: some View {
            configuration.label
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(hovering || configuration.isPressed ? Color(white: 0.33) : Color.wardrobeDark)
                )
                .opacity(isEnabled ? 1 : 0.4)
                .contentShape(Capsule())
                .onHover { hovering = $0 }
        }
    }
}

/// Pesan singkat di atas jendela (pengganti flash message versi web).
@Observable
final class FlashCenter {
    private(set) var message: String?
    private var generation = 0

    func show(_ message: String) {
        self.message = message
        generation += 1
        let current = generation
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.5))
            if generation == current {
                self.message = nil
            }
        }
    }
}

struct FlashBanner: View {
    @Environment(FlashCenter.self) private var flash

    var body: some View {
        ZStack {
            if let message = flash.message {
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.wardrobeDark))
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: flash.message)
        .allowsHitTesting(false)
    }
}

/// Daftar pesan error validasi.
struct ErrorList: View {
    let messages: [String]

    var body: some View {
        if !messages.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(messages, id: \.self) { Text("• \($0)") }
            }
            .foregroundStyle(.white)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(red: 0.55, green: 0.12, blue: 0.12)))
        }
    }
}
