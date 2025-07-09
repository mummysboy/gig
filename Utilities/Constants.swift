import SwiftUI
import Foundation

// MARK: - App Constants
struct AppConstants {
    static let appName = "Gig"
    static let appTagline = "The smart phonebook for the gig economy"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"
    
    // MARK: - Modern Color System
    struct Colors {
        // Primary Colors with depth
        static let primary = Color.teal
        static let primaryLight = Color.teal.opacity(0.8)
        static let primaryDark = Color(red: 0.0, green: 0.5, blue: 0.5)
        
        // Gradients
        static let primaryGradient = LinearGradient(
            gradient: Gradient(colors: [primary, primaryDark]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let surfaceGradient = LinearGradient(
            gradient: Gradient(colors: [Color.white, Color(.systemGray6)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let glassGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.25),
                Color.white.opacity(0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Semantic Colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue
        
        // Surface Colors
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.systemGray6)
        static let tertiaryBackground = Color(.systemGray5)
        static let cardBackground = Color(.systemBackground)
        
        // Glass Morphism
        static let glassSurface = Color.white.opacity(0.1)
        static let glassStroke = Color.white.opacity(0.2)
        
        // Text Colors with hierarchy
        static let text = Color(.label)
        static let textSecondary = Color(.secondaryLabel)
        static let textTertiary = Color(.tertiaryLabel)
        static let textPlaceholder = Color(.placeholderText)
        
        // Interactive Colors
        static let accent = Color.teal
        static let interactive = Color.teal
        static let interactivePressed = Color.teal.opacity(0.8)
        static let interactiveDisabled = Color.gray.opacity(0.3)
        
        // Status Colors
        static let online = Color.green
        static let offline = Color.gray
        static let busy = Color.red
        static let away = Color.orange
        
        // Overlay Colors
        static let overlay = Color.black.opacity(0.5)
        static let overlayLight = Color.black.opacity(0.2)
    }
    
    // MARK: - Modern Typography
    struct Typography {
        // Display Typography
        static let displayLarge = Font.system(size: 57, weight: .bold, design: .rounded)
        static let displayMedium = Font.system(size: 45, weight: .bold, design: .rounded)
        static let displaySmall = Font.system(size: 36, weight: .bold, design: .rounded)
        
        // Headline Typography
        static let headlineLarge = Font.system(size: 32, weight: .bold, design: .rounded)
        static let headlineMedium = Font.system(size: 28, weight: .semibold, design: .rounded)
        static let headlineSmall = Font.system(size: 24, weight: .semibold, design: .rounded)
        
        // Title Typography
        static let titleLarge = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let titleMedium = Font.system(size: 16, weight: .medium, design: .rounded)
        static let titleSmall = Font.system(size: 14, weight: .medium, design: .rounded)
        
        // Label Typography
        static let labelLarge = Font.system(size: 14, weight: .medium, design: .rounded)
        static let labelMedium = Font.system(size: 12, weight: .medium, design: .rounded)
        static let labelSmall = Font.system(size: 11, weight: .medium, design: .rounded)
        
        // Body Typography
        static let bodyLarge = Font.system(size: 16, weight: .regular, design: .rounded)
        static let bodyMedium = Font.system(size: 14, weight: .regular, design: .rounded)
        static let bodySmall = Font.system(size: 12, weight: .regular, design: .rounded)
        
        // Legacy Support
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.medium)
        static let headline = Font.headline.weight(.semibold)
        static let subheadline = Font.subheadline
        static let body = Font.body
        static let callout = Font.callout
        static let caption = Font.caption
        static let caption2 = Font.caption2
    }
    
    // Legacy Fonts property for backward compatibility
    struct Fonts {
        static let largeTitle = Typography.largeTitle
        static let title = Typography.title
        static let title2 = Typography.title2
        static let title3 = Typography.title3
        static let headline = Typography.headline
        static let subheadline = Typography.subheadline
        static let body = Typography.body
        static let callout = Typography.callout
        static let caption = Typography.caption
        static let caption2 = Typography.caption2
    }
    
    // MARK: - Modern Spacing System
    struct Spacing {
        // Base spacing (4pt grid)
        static let xxxs: CGFloat = 2
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 40
        static let xxxxl: CGFloat = 48
        
        // Semantic spacing
        static let tight = xs
        static let normal = md
        static let loose = xl
        static let section = xxl
        
        // Component specific
        static let buttonPadding = md
        static let cardPadding = lg
        static let screenPadding = xl
    }
    
    // MARK: - Modern Corner Radius
    struct CornerRadius {
        static let none: CGFloat = 0
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
        
        // Semantic radius
        static let small = xs
        static let medium = md
        static let large = lg
        static let extraLarge = xxl
        
        // Component specific
        static let button = md
        static let card = lg
        static let sheet = xl
        static let pill = 999 // Large number for fully rounded
    }
    
    // MARK: - Modern Shadows & Elevation
    struct Shadow {
        static let none = (color: Color.clear, radius: CGFloat(0), x: CGFloat(0), y: CGFloat(0))
        static let sm = (color: Color.black.opacity(0.08), radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))
        static let md = (color: Color.black.opacity(0.1), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let lg = (color: Color.black.opacity(0.15), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let xl = (color: Color.black.opacity(0.2), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
        
        // Colored shadows
        static let primary = (color: Colors.primary.opacity(0.25), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let success = (color: Colors.success.opacity(0.25), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let error = (color: Colors.error.opacity(0.25), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
    }
    
    // MARK: - Modern Animations
    struct Animation {
        static let instant = SwiftUI.Animation.easeInOut(duration: 0.1)
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let smooth = SwiftUI.Animation.interactiveSpring(response: 0.5, dampingFraction: 0.8)
        static let bouncy = SwiftUI.Animation.interactiveSpring(response: 0.4, dampingFraction: 0.6)
        
        // Specific animations
        static let buttonPress = SwiftUI.Animation.easeInOut(duration: 0.1)
        static let cardAppear = SwiftUI.Animation.easeOut(duration: 0.4)
        static let slideIn = SwiftUI.Animation.easeOut(duration: 0.3)
        static let fadeIn = SwiftUI.Animation.easeInOut(duration: 0.2)
    }
    
    // MARK: - Layout Constants
    struct Layout {
        static let minTouchTarget: CGFloat = 44
        static let buttonHeight: CGFloat = 48
        static let cardMinHeight: CGFloat = 60
        static let screenEdgePadding: CGFloat = 20
        static let listRowHeight: CGFloat = 60
        
        // Grid system
        static let gridColumns: Int = 12
        static let gridGutter: CGFloat = 16
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