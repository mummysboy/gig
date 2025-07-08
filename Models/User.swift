import Foundation
import CoreLocation

struct User: Identifiable, Codable {
    let id: String
    var name: String
    var email: String
    var phoneNumber: String?
    var profileImageURL: String?
    var location: CLLocationCoordinate2D?
    var isProvider: Bool
    var categories: [String]
    var rating: Double
    var reviewCount: Int
    var isVerified: Bool
    var joinDate: Date
    
    init(id: String = UUID().uuidString,
         name: String,
         email: String,
         phoneNumber: String? = nil,
         profileImageURL: String? = nil,
         location: CLLocationCoordinate2D? = nil,
         isProvider: Bool = false,
         categories: [String] = [],
         rating: Double = 0.0,
         reviewCount: Int = 0,
         isVerified: Bool = false,
         joinDate: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.profileImageURL = profileImageURL
        self.location = location
        self.isProvider = isProvider
        self.categories = categories
        self.rating = rating
        self.reviewCount = reviewCount
        self.isVerified = isVerified
        self.joinDate = joinDate
    }
}

// MARK: - Codable conformance for CLLocationCoordinate2D
extension CLLocationCoordinate2D: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
} 