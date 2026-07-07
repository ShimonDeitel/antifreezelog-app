import Foundation

struct CheckEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var vehicle: String
    var ratio: String
    var tempRating: String
    var date: Date
    var notes: String

    init(id: UUID = UUID(), vehicle: String = "", ratio: String = "", tempRating: String = "", date: Date = Date(), notes: String = "") {
        self.id = id
        self.vehicle = vehicle
        self.ratio = ratio
        self.tempRating = tempRating
        self.date = date
        self.notes = notes
    }
}
