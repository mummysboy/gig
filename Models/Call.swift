import Foundation

struct Call: Identifiable, Codable {
    let id: String
    let providerName: String
    let providerId: String
    let date: Date
    let duration: String
    let status: CallStatus
    let cost: Double?
    
    init(id: String = UUID().uuidString,
         providerName: String,
         providerId: String,
         date: Date = Date(),
         duration: String = "0:00",
         status: CallStatus = .missed,
         cost: Double? = nil) {
        self.id = id
        self.providerName = providerName
        self.providerId = providerId
        self.date = date
        self.duration = duration
        self.status = status
        self.cost = cost
    }
}

enum CallStatus: String, Codable, CaseIterable {
    case completed = "completed"
    case missed = "missed"
    case declined = "declined"
    case ongoing = "ongoing"
    
    var displayName: String {
        switch self {
        case .completed:
            return "Completed"
        case .missed:
            return "Missed"
        case .declined:
            return "Declined"
        case .ongoing:
            return "Ongoing"
        }
    }
}

// MARK: - Sample Data
extension Call {
    static let sampleData: [Call] = [
        Call(
            providerName: "Mike Johnson",
            providerId: "1",
            date: Date().addingTimeInterval(-3600),
            duration: "15:32",
            status: .completed,
            cost: 12.50
        ),
        Call(
            providerName: "Sarah Chen",
            providerId: "2",
            date: Date().addingTimeInterval(-7200),
            duration: "0:00",
            status: .missed
        ),
        Call(
            providerName: "Maria Rodriguez",
            providerId: "3",
            date: Date().addingTimeInterval(-10800),
            duration: "8:45",
            status: .completed,
            cost: 7.50
        ),
        Call(
            providerName: "David Kim",
            providerId: "4",
            date: Date().addingTimeInterval(-14400),
            duration: "0:00",
            status: .declined
        ),
        Call(
            providerName: "Lisa Thompson",
            providerId: "5",
            date: Date().addingTimeInterval(-18000),
            duration: "22:10",
            status: .completed,
            cost: 22.00
        )
    ]
} 