import XCTest
@testable import WardrobeCore

private struct Item: Wearable, Equatable {
    let name: String
    let kind: ClothingKind
    var isInLaundry = false
}

/// RNG deterministik supaya hasil acak bisa dites.
private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

final class OutfitPickerTests: XCTestCase {
    private let wardrobe = [
        Item(name: "Kemeja", kind: .baju),
        Item(name: "Batik", kind: .baju),
        Item(name: "Kaos", kind: .baju),
        Item(name: "Jeans", kind: .celana),
        Item(name: "Chino", kind: .celana),
        Item(name: "Jam", kind: .aksesoris),
    ]

    func testPicksTwoTopsOneBottomOneAccessoryInOrder() {
        var rng = SeededGenerator(state: 1)
        let outfit = OutfitPicker.pick(from: wardrobe, using: &rng)
        XCTAssertEqual(outfit.map(\.kind), [.baju, .baju, .celana, .aksesoris])
        XCTAssertEqual(Set(outfit.map(\.name)).count, 4, "tidak boleh ada pakaian dobel")
    }

    func testSkipsClothesInLaundry() {
        var items = wardrobe
        items[0].isInLaundry = true  // Kemeja
        items[3].isInLaundry = true  // Jeans
        for seed in 0..<50 {
            var rng = SeededGenerator(state: UInt64(seed))
            let names = OutfitPicker.pick(from: items, using: &rng).map(\.name)
            XCTAssertFalse(names.contains("Kemeja"))
            XCTAssertFalse(names.contains("Jeans"))
            XCTAssertEqual(names.count, 4)
        }
    }

    func testFillsWhatIsAvailable() {
        let items = [Item(name: "Kaos", kind: .baju), Item(name: "Jam", kind: .aksesoris, isInLaundry: true)]
        XCTAssertEqual(OutfitPicker.pick(from: items).map(\.name), ["Kaos"])
        XCTAssertTrue(OutfitPicker.pick(from: [Item]()).isEmpty)
    }

    func testRandomisesAcrossRuns() {
        var seen = Set<[String]>()
        for seed in 0..<30 {
            var rng = SeededGenerator(state: UInt64(seed))
            seen.insert(OutfitPicker.pick(from: wardrobe, using: &rng).map(\.name))
        }
        XCTAssertGreaterThan(seen.count, 1)
    }
}

final class ClothingValidationTests: XCTestCase {
    func testTrimsAndAccepts() {
        let result = ClothingValidation.validate(name: "  Kemeja Katun \n", notes: " Uniqlo ")
        XCTAssertEqual(try result.get(), .init(name: "Kemeja Katun", notes: "Uniqlo"))
    }

    func testNotesAreOptional() {
        XCTAssertEqual(try ClothingValidation.validate(name: "Jeans", notes: "   ").get().notes, "")
    }

    func testRejectsEmptyName() {
        guard case .failure(let errors) = ClothingValidation.validate(name: " \t ", notes: "x") else {
            return XCTFail("nama kosong harus ditolak")
        }
        XCTAssertEqual(errors.messages, ["Nama wajib diisi."])
    }

    func testRejectsTooLong() {
        let name = String(repeating: "a", count: 256)
        let notes = String(repeating: "b", count: 5001)
        guard case .failure(let errors) = ClothingValidation.validate(name: name, notes: notes) else {
            return XCTFail("isian terlalu panjang harus ditolak")
        }
        XCTAssertEqual(errors.messages.count, 2)
    }

    func testKindLabels() {
        XCTAssertEqual(ClothingKind.allCases.map(\.label), ["Baju", "Celana", "Aksesoris"])
        XCTAssertEqual(ClothingKind(rawValue: "celana"), .celana)
    }
}
