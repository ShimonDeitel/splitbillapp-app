import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    static let freeLimit = 10

    @Published var items: [GroupBill] = []
    @Published var isPro: Bool = false

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("splitbill_items.json")
        load()
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    func add(_ item: GroupBill) {
        items.insert(item, at: 0)
        save()
    }

    func update(_ item: GroupBill) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx] = item
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: GroupBill) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([GroupBill].self, from: data) else {
            items = Store.seedData()
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func seedData() -> [GroupBill] {
        [
        GroupBill(date: Date().addingTimeInterval(-86400), restaurant: "Sushi Night", total: "128.40", peopleNote: "4 people - team dinner"),
        GroupBill(date: Date().addingTimeInterval(-172800), restaurant: "Pizza Place", total: "56.00", peopleNote: "3 people - hangout"),
        GroupBill(date: Date().addingTimeInterval(-259200), restaurant: "Brunch Spot", total: "74.20", peopleNote: "2 people - birthday")
        ]
    }
}
