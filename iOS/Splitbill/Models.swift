import Foundation

struct GroupBill: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var restaurant: String
    var total: String
    var peopleNote: String
}
