import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [CheckEntry] = []
    @Published var isProUnlocked: Bool = false

    /// Free tier limit — deliberately set well above seed data count so a
    /// fresh install never hits the paywall immediately.
    static let freeLimit = 15

    private let fileName = "antifreezelog_entries.json"

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent(fileName)
    }

    init() {
        load()
    }

    var canAddMore: Bool {
        isProUnlocked || entries.count < Store.freeLimit
    }

    func add(_ entry: CheckEntry) {
        guard canAddMore else { return }
        entries.append(entry)
        save()
    }

    func update(_ entry: CheckEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: CheckEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([CheckEntry].self, from: data) else {
            entries = Store.seedData()
            save()
            return
        }
        entries = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func seedData() -> [CheckEntry] {
        [
        CheckEntry(vehicle: "Sedan", ratio: "50/50", tempRating: "-20F", date: Date(), notes: "Checked before frost"),
        CheckEntry(vehicle: "Truck", ratio: "60/40", tempRating: "-30F", date: Date(), notes: "Topped off"),
        CheckEntry(vehicle: "SUV", ratio: "70/30", tempRating: "-10F", date: Date(), notes: "All good")
        ]
    }
}
