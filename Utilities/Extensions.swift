import SwiftUI
import Foundation

// MARK: - Color Extensions
extension Color {
    static let customTeal = Color(red: 0.2, green: 0.6, blue: 0.6)
    static let customBackground = Color(red: 0.98, green: 0.98, blue: 0.98)
}

// MARK: - String Extensions
extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    var isValidPhone: Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: self)
    }
    
    func truncate(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        } else {
            return self
        }
    }
}

// MARK: - Date Extensions
extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func formattedString(format: String = "MMM dd, yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

// MARK: - Double Extensions
extension Double {
    func formatAsCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: self)) ?? "$\(self)"
    }
    
    func formatAsRating() -> String {
        return String(format: "%.1f", self)
    }
}

// MARK: - Array Extensions
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Bundle Extensions
extension Bundle {
    var appName: String {
        return infoDictionary?["CFBundleName"] as? String ?? "Gig"
    }
    
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

// MARK: - UIDevice Extensions
extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
    
    var isIPad: Bool {
        return userInterfaceIdiom == .pad
    }
    
    var isIPhone: Bool {
        return userInterfaceIdiom == .phone
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
    static let callDidStart = Notification.Name("callDidStart")
    static let callDidEnd = Notification.Name("callDidEnd")
    static let locationDidUpdate = Notification.Name("locationDidUpdate")
}

// MARK: - UserDefaults Extensions
extension UserDefaults {
    enum Keys {
        static let isAuthenticated = "isAuthenticated"
        static let userID = "userID"
        static let userName = "userName"
        static let userEmail = "userEmail"
        static let lastLocation = "lastLocation"
        static let notificationSettings = "notificationSettings"
        static let appLaunchCount = "appLaunchCount"
    }
    
    var isAuthenticated: Bool {
        get { bool(forKey: Keys.isAuthenticated) }
        set { set(newValue, forKey: Keys.isAuthenticated) }
    }
    
    var userID: String? {
        get { string(forKey: Keys.userID) }
        set { set(newValue, forKey: Keys.userID) }
    }
    
    var userName: String? {
        get { string(forKey: Keys.userName) }
        set { set(newValue, forKey: Keys.userName) }
    }
    
    var userEmail: String? {
        get { string(forKey: Keys.userEmail) }
        set { set(newValue, forKey: Keys.userEmail) }
    }
    
    var appLaunchCount: Int {
        get { integer(forKey: Keys.appLaunchCount) }
        set { set(newValue, forKey: Keys.appLaunchCount) }
    }
} 
