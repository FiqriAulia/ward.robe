import AppKit
import SwiftUI

enum Screen: Hashable {
    case input, laundry, edit, sold, wardrobe, dressMe, easterEgg
}

/// Alur sama dengan versi web: splash → wizard tidur → menu → fitur.
struct RootView: View {
    private enum Stage {
        case splash, asleep, awake
    }

    @State private var stage: Stage = .splash
    @State private var path: [Screen] = []
    @State private var cursor = CursorTracker()
    @State private var flash = FlashCenter()

    var body: some View {
        Group {
            switch stage {
            case .splash:
                SplashView { withAnimation { stage = .asleep } }
            case .asleep:
                HomeView(
                    onWake: {
                        path = []
                        withAnimation { stage = .awake }
                    },
                    onEasterEgg: {
                        path = [.easterEgg]
                        stage = .awake
                    }
                )
            case .awake:
                NavigationStack(path: $path) {
                    MenuView(onSleep: { withAnimation { stage = .asleep } })
                        .navigationDestination(for: Screen.self, destination: destination)
                }
            }
        }
        .overlay(alignment: .top) { FlashBanner() }
        .onContinuousHover(coordinateSpace: .global) { phase in
            switch phase {
            case .active(let location):
                cursor.location = location
            case .ended:
                cursor.location = nil
            }
        }
        .preferredColorScheme(.light)
        .environment(cursor)
        .environment(flash)
    }

    @ViewBuilder
    private func destination(_ screen: Screen) -> some View {
        switch screen {
        case .input: InputView()
        case .laundry: LaundryView()
        case .edit: EditView()
        case .sold: SoldView()
        case .wardrobe: WardrobeView()
        case .dressMe: DressMeView()
        case .easterEgg: EasterEggView()
        }
    }
}

/// Rizzard muncul 3 detik lalu menghilang (klik untuk lewati).
struct SplashView: View {
    let onFinish: () -> Void
    @State private var visible = true

    var body: some View {
        ZStack {
            Color.wardrobeDark
            Image(nsImage: AppResources.rizzard)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(height: 350)
                .opacity(visible ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture(perform: onFinish)
        .task {
            do {
                try await Task.sleep(for: .seconds(3))
                withAnimation(.easeOut(duration: 0.6)) { visible = false }
                try await Task.sleep(for: .seconds(0.6))
                onFinish()
            } catch {
                // Dibatalkan karena user sudah klik untuk lewati.
            }
        }
    }
}

/// Wizard tidur. Klik judul "Wardrobe" 3x untuk easter egg.
struct HomeView: View {
    let onWake: () -> Void
    let onEasterEgg: () -> Void

    var body: some View {
        HStack(spacing: 40) {
            Text("Wardrobe")
                .font(.system(size: 51, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .onTapGesture(count: 3, perform: onEasterEgg)

            WizardCard(mood: .asleep)

            Button("Wake the Wizard", action: onWake)
                .buttonStyle(PillButtonStyle())
                .keyboardShortcut(.defaultAction)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 40)
        .wardrobeScreen()
    }
}

/// Menu utama: 6 fitur mengelilingi wizard. Klik wizard 3x untuk menidurkannya.
struct MenuView: View {
    let onSleep: () -> Void

    var body: some View {
        HStack(spacing: 50) {
            VStack(alignment: .trailing, spacing: 90) {
                link("Input", .input)
                link("Laundri[ed]", .laundry)
                link("Edit", .edit)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            WizardCard(mood: .awake)
                .onTapGesture(count: 3, perform: onSleep)

            VStack(alignment: .leading, spacing: 90) {
                link("Sold", .sold)
                link("Wardrobe", .wardrobe)
                link("Dress Me", .dressMe)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .wardrobeScreen()
        .navigationTitle("Wardrobe")
    }

    private func link(_ title: String, _ screen: Screen) -> some View {
        NavigationLink(value: screen) { Text(title) }
            .buttonStyle(WordButtonStyle())
    }
}

/// Easter egg: changelog + berang-berang.
struct EasterEggView: View {
    var body: some View {
        ScrollView {
            Text(AppResources.changelog)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
        }
        .scrollIndicators(.hidden)
        .wardrobeScreen()
        .navigationTitle("Wardrobe")
    }
}
