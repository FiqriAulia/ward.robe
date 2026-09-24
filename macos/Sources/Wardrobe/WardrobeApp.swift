import AppKit
import SwiftData
import SwiftUI

@main
struct WardrobeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let store: Result<ModelContainer, Error>

    init() {
        store = Result { try WardrobeStore.makeContainer() }
    }

    var body: some Scene {
        WindowGroup("Wardrobe") {
            Group {
                switch store {
                case .success(let container):
                    RootView().modelContainer(container)
                case .failure(let error):
                    ContentUnavailableView(
                        "Database tidak bisa dibuka",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error.localizedDescription)
                    )
                }
            }
            .frame(minWidth: 1000, minHeight: 700)
        }
        .windowResizability(.contentMinSize)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Perlu saat dijalankan lewat `swift run` (tanpa .app bundle) supaya
        // jendelanya muncul di depan dan app punya ikon di Dock.
        NSApp.setActivationPolicy(.regular)
        NSApp.activate()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
