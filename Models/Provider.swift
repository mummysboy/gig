import Foundation
import CoreLocation

struct Provider: Identifiable, Codable {
    let id: String
    var name: String
    var category: String
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
         category: String,
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
        self.category = category
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
}

// MARK: - Sample Data
extension Provider {
    static let sampleData: [Provider] = [
        Provider(
            name: "Mike Johnson",
            category: "Handyman",
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
            category: "Tutor",
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
            category: "Cleaner",
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
            category: "Creative",
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
            category: "Coach",
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
            category: "Handyman",
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
            category: "Tutor",
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
            category: "Cleaner",
            bio: "Reliable and thorough cleaning service. Available for regular and one-time cleaning appointments.",
            profileImageURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
            hourlyRate: 22,
            rating: 4.5,
            reviewCount: 167,
            skills: ["House Cleaning", "Kitchen Cleaning", "Bathroom Cleaning", "Vacuuming"],
            services: Service.sampleServices(for: "Cleaner"),
            isVerified: true
        )
    ]
} 