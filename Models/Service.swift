import Foundation

struct Service: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let hourlyRate: Double
    let flatRate: Double?
    let isAvailable: Bool
    let category: String
    
    init(id: String = UUID().uuidString,
         name: String,
         description: String = "",
         hourlyRate: Double,
         flatRate: Double? = nil,
         isAvailable: Bool = true,
         category: String = "") {
        self.id = id
        self.name = name
        self.description = description
        self.hourlyRate = hourlyRate
        self.flatRate = flatRate
        self.isAvailable = isAvailable
        self.category = category
    }
}

// MARK: - Sample Services
extension Service {
    static func sampleServices(for category: String) -> [Service] {
        switch category {
        case "Handyman":
            return [
                Service(name: "Plumbing Repair", description: "Fix leaks, unclog drains, repair fixtures", hourlyRate: 45.0, flatRate: 75.0),
                Service(name: "Electrical Work", description: "Install outlets, fix wiring, replace fixtures", hourlyRate: 50.0, flatRate: 100.0),
                Service(name: "General Repairs", description: "Minor repairs and maintenance", hourlyRate: 40.0)
            ]
        case "Tutor":
            return [
                Service(name: "Math Tutoring", description: "Algebra, geometry, calculus", hourlyRate: 35.0),
                Service(name: "Science Tutoring", description: "Physics, chemistry, biology", hourlyRate: 35.0),
                Service(name: "Test Prep", description: "SAT, ACT, GRE preparation", hourlyRate: 40.0)
            ]
        case "Cleaner":
            return [
                Service(name: "House Cleaning", description: "Complete house cleaning service", hourlyRate: 25.0, flatRate: 150.0),
                Service(name: "Deep Cleaning", description: "Thorough deep cleaning", hourlyRate: 30.0, flatRate: 200.0),
                Service(name: "Move-in/Move-out", description: "Cleaning for moving", hourlyRate: 35.0, flatRate: 250.0)
            ]
        case "Creative":
            return [
                Service(name: "Photography", description: "Portrait and event photography", hourlyRate: 75.0, flatRate: 300.0),
                Service(name: "Videography", description: "Event and commercial video", hourlyRate: 100.0, flatRate: 500.0),
                Service(name: "Photo Editing", description: "Professional photo editing", hourlyRate: 50.0)
            ]
        case "Coach":
            return [
                Service(name: "Personal Training", description: "One-on-one fitness training", hourlyRate: 60.0),
                Service(name: "Nutrition Coaching", description: "Diet and nutrition guidance", hourlyRate: 45.0),
                Service(name: "Group Classes", description: "Small group fitness sessions", hourlyRate: 25.0)
            ]
        default:
            return [
                Service(name: "General Service", description: "Professional service in this category", hourlyRate: 40.0)
            ]
        }
    }
} 