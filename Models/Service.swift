import Foundation

struct Service: Identifiable, Codable {
    let id: String
    var name: String
    var description: String
    var hourlyRate: Double
    var flatRate: Double?
    var isAvailable: Bool
    var category: String

    // AI Enhancement fields
    var originalDescription: String? // Stores the user's original description for undo
    var enhancedDescription: String? // Stores the AI-enhanced description
    var isShowingEnhanced: Bool = false // Whether the enhanced description is being shown
    var isEnhancing: Bool = false // Whether an AI enhancement is in progress
    var enhancementError: String? = nil // Error message if AI enhancement fails

    init(id: String = UUID().uuidString,
         name: String,
         description: String = "",
         hourlyRate: Double,
         flatRate: Double? = nil,
         isAvailable: Bool = true,
         category: String = "",
         originalDescription: String? = nil,
         enhancedDescription: String? = nil,
         isShowingEnhanced: Bool = false,
         isEnhancing: Bool = false,
         enhancementError: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.hourlyRate = hourlyRate
        self.flatRate = flatRate
        self.isAvailable = isAvailable
        self.category = category
        self.originalDescription = originalDescription
        self.enhancedDescription = enhancedDescription
        self.isShowingEnhanced = isShowingEnhanced
        self.isEnhancing = isEnhancing
        self.enhancementError = enhancementError
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
        case "Plumber":
            return [
                Service(name: "Emergency Repairs", description: "24/7 emergency plumbing repairs", hourlyRate: 65.0, flatRate: 150.0),
                Service(name: "Pipe Installation", description: "New pipe installation and replacement", hourlyRate: 70.0, flatRate: 200.0),
                Service(name: "Drain Cleaning", description: "Professional drain cleaning service", hourlyRate: 60.0, flatRate: 100.0),
                Service(name: "Water Heater Service", description: "Water heater repair and replacement", hourlyRate: 75.0, flatRate: 300.0)
            ]
        case "Electrician":
            return [
                Service(name: "Electrical Repairs", description: "Fix electrical issues and safety concerns", hourlyRate: 70.0, flatRate: 150.0),
                Service(name: "Wiring Installation", description: "New wiring and electrical installations", hourlyRate: 75.0, flatRate: 250.0),
                Service(name: "Panel Upgrades", description: "Electrical panel upgrades and maintenance", hourlyRate: 80.0, flatRate: 500.0),
                Service(name: "Safety Inspections", description: "Electrical safety inspections", hourlyRate: 65.0, flatRate: 100.0)
            ]
        case "Personal Trainer":
            return [
                Service(name: "Strength Training", description: "Personalized strength training programs", hourlyRate: 55.0),
                Service(name: "Cardio Fitness", description: "Cardiovascular fitness training", hourlyRate: 50.0),
                Service(name: "Weight Loss Programs", description: "Specialized weight loss training", hourlyRate: 60.0),
                Service(name: "Nutrition Planning", description: "Fitness nutrition guidance", hourlyRate: 45.0)
            ]
        case "Photographer":
            return [
                Service(name: "Portrait Photography", description: "Professional portrait sessions", hourlyRate: 85.0, flatRate: 200.0),
                Service(name: "Event Photography", description: "Weddings, parties, corporate events", hourlyRate: 100.0, flatRate: 500.0),
                Service(name: "Commercial Photography", description: "Product and commercial photography", hourlyRate: 120.0, flatRate: 800.0),
                Service(name: "Photo Editing", description: "Professional photo editing and retouching", hourlyRate: 60.0)
            ]
        case "Carpenter":
            return [
                Service(name: "Custom Woodworking", description: "Custom furniture and woodwork", hourlyRate: 45.0, flatRate: 300.0),
                Service(name: "Furniture Assembly", description: "Assemble and install furniture", hourlyRate: 40.0, flatRate: 100.0),
                Service(name: "Home Renovations", description: "Carpentry work for home renovations", hourlyRate: 50.0, flatRate: 400.0),
                Service(name: "Cabinet Making", description: "Custom cabinet design and installation", hourlyRate: 55.0, flatRate: 500.0)
            ]
        case "Painter":
            return [
                Service(name: "Interior Painting", description: "Professional interior painting", hourlyRate: 35.0, flatRate: 200.0),
                Service(name: "Exterior Painting", description: "House exterior painting", hourlyRate: 40.0, flatRate: 300.0),
                Service(name: "Color Consultation", description: "Professional color selection", hourlyRate: 30.0, flatRate: 75.0),
                Service(name: "Surface Preparation", description: "Wall preparation and priming", hourlyRate: 25.0, flatRate: 150.0)
            ]
        case "Landscaper":
            return [
                Service(name: "Garden Design", description: "Landscape design and planning", hourlyRate: 30.0, flatRate: 200.0),
                Service(name: "Lawn Maintenance", description: "Regular lawn care and maintenance", hourlyRate: 25.0, flatRate: 100.0),
                Service(name: "Tree Care", description: "Tree trimming and maintenance", hourlyRate: 35.0, flatRate: 150.0),
                Service(name: "Irrigation Systems", description: "Sprinkler system installation and repair", hourlyRate: 40.0, flatRate: 250.0)
            ]
        default:
            return [
                Service(name: "General Service", description: "Professional service in this category", hourlyRate: 40.0)
            ]
        }
    }
} 