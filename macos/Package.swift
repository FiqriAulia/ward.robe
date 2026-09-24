// swift-tools-version: 5.10
import PackageDescription

// WardrobeCore berisi logika murni (tanpa framework Apple) sehingga bisa
// di-build & dites di mana saja. Target app SwiftUI hanya ada di macOS.
var products: [Product] = [
    .library(name: "WardrobeCore", targets: ["WardrobeCore"]),
]

var targets: [Target] = [
    .target(name: "WardrobeCore"),
    .testTarget(name: "WardrobeCoreTests", dependencies: ["WardrobeCore"]),
]

#if os(macOS)
products.append(.executable(name: "Wardrobe", targets: ["Wardrobe"]))
targets.append(
    .executableTarget(
        name: "Wardrobe",
        dependencies: ["WardrobeCore"],
        resources: [.process("Resources")]
    )
)
#endif

let package = Package(
    name: "Wardrobe",
    platforms: [.macOS(.v14)],
    products: products,
    targets: targets
)
