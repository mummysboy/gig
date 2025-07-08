import SwiftUI
import Foundation

// MARK: - App Constants
struct AppConstants {
    static let appName = "Gig"
    static let appTagline = "The smart phonebook for the gig economy"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"
    
    // Colors
    struct Colors {
        static let primary = Color.teal
        static let secondary = Color.orange
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.systemGray6)
        static let text = Color(.label)
        static let secondaryText = Color(.secondaryLabel)
        static let accent = Color.teal
    }
    
    // Fonts
    struct Fonts {
        static let largeTitle = Font.largeTitle
        static let title = Font.title
        static let title2 = Font.title2
        static let title3 = Font.title3
        static let headline = Font.headline
        static let subheadline = Font.subheadline
        static let body = Font.body
        static let callout = Font.callout
        static let caption = Font.caption
        static let caption2 = Font.caption2
    }
    
    // Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }
    
    // Animation
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
    }
}

// MARK: - API Constants
struct APIConstants {
    static let baseURL = "https://api.gig.app"
    static let timeout: TimeInterval = 30
    static let retryCount = 3
    
    // Endpoints
    struct Endpoints {
        static let auth = "/auth"
        static let users = "/users"
        static let providers = "/providers"
        static let calls = "/calls"
        static let messages = "/messages"
        static let feedback = "/feedback"
    }
}

// MARK: - User Defaults Keys
struct UserDefaultsKeys {
    static let isAuthenticated = "isAuthenticated"
    static let userID = "userID"
    static let userName = "userName"
    static let userEmail = "userEmail"
    static let userProfile = "userProfile"
    static let lastLocation = "lastLocation"
    static let notificationSettings = "notificationSettings"
    static let appLaunchCount = "appLaunchCount"
    static let onboardingCompleted = "onboardingCompleted"
    static let themePreference = "themePreference"
}

// MARK: - Notification Names
struct NotificationNames {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
    static let callDidStart = Notification.Name("callDidStart")
    static let callDidEnd = Notification.Name("callDidEnd")
    static let locationDidUpdate = Notification.Name("locationDidUpdate")
    static let messageReceived = Notification.Name("messageReceived")
    static let providerStatusChanged = Notification.Name("providerStatusChanged")
}

// MARK: - Service Categories
struct ServiceCategories {
    static let all = [
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
    
    static let popular = [
        "Handyman",
        "Tutor",
        "Cleaner",
        "Creative",
        "Coach"
    ]
}

// MARK: - Call Constants
struct CallConstants {
    static let maxCallDuration: TimeInterval = 3600 // 1 hour
    static let minCallDuration: TimeInterval = 60 // 1 minute
    static let callTimeout: TimeInterval = 30 // 30 seconds
    static let retryAttempts = 3
}

// MARK: - Location Constants
struct LocationConstants {
    static let defaultRadius: Double = 50 // 50km
    static let maxRadius: Double = 100 // 100km
    static let minRadius: Double = 5 // 5km
    static let updateInterval: TimeInterval = 300 // 5 minutes
    static let accuracy: Double = 100 // 100 meters
}

// MARK: - Chat Constants
struct ChatConstants {
    static let maxMessageLength = 1000
    static let typingTimeout: TimeInterval = 3
    static let messageRetentionDays = 30
    static let maxSuggestions = 5
}

// MARK: - Feedback Constants
struct FeedbackConstants {
    static let minRating = 1
    static let maxRating = 5
    static let requiredRating = true
    static let maxReviewLength = 500
    static let categories = [
        "Professionalism",
        "Quality of Work", 
        "Communication",
        "Punctuality",
        "Value for Money",
        "Overall Experience"
    ]
}

// MARK: - Error Messages
struct ErrorMessages {
    static let networkError = "Network connection error. Please check your internet connection and try again."
    static let authenticationError = "Authentication failed. Please try logging in again."
    static let locationError = "Unable to access location. Please enable location services in Settings."
    static let callError = "Call failed. Please try again."
    static let generalError = "Something went wrong. Please try again."
    static let noProvidersFound = "No providers found in your area. Try expanding your search radius."
}

// MARK: - Success Messages
struct SuccessMessages {
    static let callConnected = "Call connected successfully!"
    static let feedbackSubmitted = "Thank you for your feedback!"
    static let profileUpdated = "Profile updated successfully!"
    static let messageSent = "Message sent!"
}

// MARK: - Validation Rules
struct ValidationRules {
    static let minPasswordLength = 8
    static let maxPasswordLength = 128
    static let minNameLength = 2
    static let maxNameLength = 50
    static let maxBioLength = 500
    static let maxSkillsCount = 10
}

// MARK: - Feature Flags
struct FeatureFlags {
    static let enableVoiceNotes = true
    static let enableVideoCalls = false
    static let enablePushNotifications = true
    static let enableLocationServices = true
    static let enableAnalytics = true
    static let enableCrashReporting = true
} 