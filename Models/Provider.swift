import Foundation
import CoreLocation

struct Provider: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var categories: [String]
    var bio: String
    var profileImageURL: String
    var hourlyRate: Int
    var rating: Double
    var reviewCount: Int
    var isAvailable: Bool
    var location: CLLocationCoordinate2D?
    var skills: [String]
    var services: [Service]
    var voiceNoteURL: String?
    var photos: [String]
    var isVerified: Bool
    var joinDate: Date
    
    init(id: String = UUID().uuidString,
         name: String,
         categories: [String],
         bio: String = "",
         profileImageURL: String = "",
         hourlyRate: Int,
         rating: Double = 0.0,
         reviewCount: Int = 0,
         isAvailable: Bool = true,
         location: CLLocationCoordinate2D? = nil,
         skills: [String] = [],
         services: [Service] = [],
         voiceNoteURL: String? = nil,
         photos: [String] = [],
         isVerified: Bool = false,
         joinDate: Date = Date()) {
        self.id = id
        self.name = name
        self.categories = categories
        self.bio = bio
        self.profileImageURL = profileImageURL
        self.hourlyRate = hourlyRate
        self.rating = rating
        self.reviewCount = reviewCount
        self.isAvailable = isAvailable
        self.location = location
        self.skills = skills
        self.services = services
        self.voiceNoteURL = voiceNoteURL
        self.photos = photos
        self.isVerified = isVerified
        self.joinDate = joinDate
    }
    /// For backward compatibility: returns the first category if available
    var primaryCategory: String? {
        return categories.first
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Provider, rhs: Provider) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Categories
extension Provider {
    static let categories = [
        "Handyman",
        "Tutor", 
        "Cleaner",
        "Creative",
        "Coach",
        "Photographer",
        "Personal Trainer",
        "Plumber",
        "Electrician",
        "Carpenter",
        "Painter",
        "Landscaper"
    ]
    
    /// Dynamically extracts all available categories from the sample data
    /// This ensures the AI system always uses the current categories
    static var availableCategories: [String] {
        let categories = Set(sampleData.flatMap { $0.categories })
        return Array(categories).sorted()
    }
    
    /// Gets a formatted string of all available categories for AI prompts
    static var categoriesForAIPrompt: String {
        return availableCategories.map { "- \($0)" }.joined(separator: "\n           ")
    }
    
    /// Gets a comma-separated list of categories for quick reference
    static var categoriesList: String {
        return availableCategories.joined(separator: ", ")
    }
    
    /// Checks if a category exists in the available categories
    static func isValidCategory(_ category: String) -> Bool {
        return availableCategories.contains(category)
    }
    
    /// Gets providers for a specific category
    static func providers(for category: String) -> [Provider] {
        return sampleData.filter { $0.categories.contains(category) }
    }
    
    /// Gets all unique categories with their provider counts
    static var categoryStats: [(category: String, count: Int)] {
        let allCategories = sampleData.flatMap { $0.categories }
        let statsDict = Dictionary(grouping: allCategories, by: { $0 })
            .mapValues { catArr in catArr.count }
        let stats = statsDict.map { (category: $0.key, count: $0.value) }
            .sorted { $0.category < $1.category }
        return stats
    }
    
    /// Prints category statistics for debugging
    static func printCategoryStats() {
        print("📊 Category Statistics:")
        for stat in categoryStats {
            print("   \(stat.category): \(stat.count) providers")
        }
        print("   Total categories: \(availableCategories.count)")
        print("   Total providers: \(sampleData.count)")
    }
}

// MARK: - Sample Data
extension Provider {
    static var sampleData: [Provider] = [
        Provider(
            name: "Mike Johnson",
            categories: ["Handyman"],
            bio: "Experienced handyman with 10+ years in home repairs. Specializing in plumbing, electrical, and general maintenance.",
            profileImageURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
            hourlyRate: 45,
            rating: 4.8,
            reviewCount: 127,
            skills: ["Plumbing", "Electrical", "Carpentry", "Painting"],
            services: Service.sampleServices(for: "Handyman"),
            isVerified: true
        ),
        Provider(
            name: "Sarah Chen",
            categories: ["Tutor"],
            bio: "Certified math and science tutor with a Master's degree in Education. Patient and experienced with students of all ages.",
            profileImageURL: "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face",
            hourlyRate: 35,
            rating: 4.9,
            reviewCount: 89,
            skills: ["Mathematics", "Physics", "Chemistry", "Test Prep"],
            services: Service.sampleServices(for: "Tutor"),
            isVerified: true
        ),
        Provider(
            name: "Maria Rodriguez",
            categories: ["Cleaner"],
            bio: "Professional house cleaner with attention to detail. Eco-friendly cleaning products available upon request.",
            profileImageURL: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face",
            hourlyRate: 25,
            rating: 4.7,
            reviewCount: 203,
            skills: ["Deep Cleaning", "Window Cleaning", "Laundry", "Organization"],
            services: Service.sampleServices(for: "Cleaner"),
            isVerified: true
        ),
        Provider(
            name: "David Kim",
            categories: ["Creative"],
            bio: "Professional photographer and videographer. Specializing in portraits, events, and commercial photography.",
            profileImageURL: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
            hourlyRate: 75,
            rating: 4.9,
            reviewCount: 156,
            skills: ["Photography", "Videography", "Photo Editing", "Event Coverage"],
            services: Service.sampleServices(for: "Creative"),
            isVerified: true
        ),
        Provider(
            name: "Lisa Thompson",
            categories: ["Coach"],
            bio: "Certified personal trainer and nutrition coach. Helping clients achieve their fitness goals through personalized programs.",
            profileImageURL: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face",
            hourlyRate: 60,
            rating: 4.8,
            reviewCount: 94,
            skills: ["Personal Training", "Nutrition", "Weight Loss", "Strength Training"],
            services: Service.sampleServices(for: "Coach"),
            isVerified: true
        ),
        Provider(
            name: "James Wilson",
            categories: ["Handyman"],
            bio: "Skilled carpenter and general contractor. Quality workmanship guaranteed on all projects.",
            profileImageURL: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face",
            hourlyRate: 50,
            rating: 4.6,
            reviewCount: 78,
            skills: ["Carpentry", "Furniture Assembly", "Home Repairs", "Installation"],
            services: Service.sampleServices(for: "Handyman"),
            isVerified: true
        ),
        Provider(
            name: "Emma Davis",
            categories: ["Tutor"],
            bio: "English and literature tutor with a passion for helping students improve their writing and reading skills.",
            profileImageURL: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&h=150&fit=crop&crop=face",
            hourlyRate: 30,
            rating: 4.7,
            reviewCount: 112,
            skills: ["English", "Literature", "Essay Writing", "Reading Comprehension"],
            services: Service.sampleServices(for: "Tutor"),
            isVerified: true
        ),
        Provider(
            name: "Carlos Mendez",
            categories: ["Cleaner"],
            bio: "Reliable and thorough cleaning service. Available for regular and one-time cleaning appointments.",
            profileImageURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
            hourlyRate: 22,
            rating: 4.5,
            reviewCount: 167,
            skills: ["House Cleaning", "Kitchen Cleaning", "Bathroom Cleaning", "Vacuuming"],
            services: Service.sampleServices(for: "Cleaner"),
            isVerified: true
        ),
        Provider(
            name: "Alex Rodriguez",
            categories: ["Plumber"],
            bio: "Licensed plumber with 15+ years experience. Specializing in emergency repairs, installations, and maintenance.",
            profileImageURL: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face",
            hourlyRate: 65,
            rating: 4.9,
            reviewCount: 234,
            skills: ["Plumbing Repairs", "Pipe Installation", "Drain Cleaning", "Water Heater Service"],
            services: Service.sampleServices(for: "Plumber"),
            isVerified: true
        ),
        Provider(
            name: "Jennifer Park",
            categories: ["Electrician"],
            bio: "Certified electrician providing safe and reliable electrical services. Licensed and insured for your peace of mind.",
            profileImageURL: "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face",
            hourlyRate: 70,
            rating: 4.8,
            reviewCount: 189,
            skills: ["Electrical Repairs", "Wiring Installation", "Panel Upgrades", "Safety Inspections"],
            services: Service.sampleServices(for: "Electrician"),
            isVerified: true
        ),
        Provider(
            name: "Marcus Johnson",
            categories: ["Personal Trainer"],
            bio: "Certified personal trainer helping clients achieve their fitness goals through personalized workout plans and nutrition guidance.",
            profileImageURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
            hourlyRate: 55,
            rating: 4.9,
            reviewCount: 156,
            skills: ["Strength Training", "Cardio Fitness", "Weight Loss", "Muscle Building"],
            services: Service.sampleServices(for: "Personal Trainer"),
            isVerified: true
        ),
        Provider(
            name: "Sophie Chen",
            categories: ["Photographer"],
            bio: "Professional photographer specializing in portraits, events, and commercial photography. Creating beautiful memories through the lens.",
            profileImageURL: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&h=150&fit=crop&crop=face",
            hourlyRate: 85,
            rating: 4.9,
            reviewCount: 203,
            skills: ["Portrait Photography", "Event Coverage", "Commercial Photography", "Photo Editing"],
            services: Service.sampleServices(for: "Photographer"),
            isVerified: true
        ),
        Provider(
            name: "Robert Martinez",
            categories: ["Carpenter"],
            bio: "Skilled carpenter with expertise in custom woodworking, furniture making, and home renovations.",
            profileImageURL: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face",
            hourlyRate: 45,
            rating: 4.7,
            reviewCount: 98,
            skills: ["Custom Woodworking", "Furniture Making", "Home Renovations", "Cabinet Making"],
            services: Service.sampleServices(for: "Carpenter"),
            isVerified: true
        ),
        Provider(
            name: "Amanda Foster",
            categories: ["Painter"],
            bio: "Professional painter providing quality interior and exterior painting services. Attention to detail and clean work guaranteed.",
            profileImageURL: "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face",
            hourlyRate: 35,
            rating: 4.6,
            reviewCount: 145,
            skills: ["Interior Painting", "Exterior Painting", "Color Consultation", "Surface Preparation"],
            services: Service.sampleServices(for: "Painter"),
            isVerified: true
        ),
        Provider(
            name: "Tom Anderson",
            categories: ["Landscaper"],
            bio: "Experienced landscaper creating beautiful outdoor spaces. From garden design to lawn maintenance, I bring your vision to life.",
            profileImageURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
            hourlyRate: 30,
            rating: 4.5,
            reviewCount: 112,
            skills: ["Garden Design", "Lawn Maintenance", "Tree Care", "Irrigation Systems"],
            services: Service.sampleServices(for: "Landscaper"),
            isVerified: true
        )
    ]
} 