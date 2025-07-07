# Gig - The Smart Phonebook for the Gig Economy

Gig is a modern iOS app that connects service providers with clients through an intuitive chat-based interface, Face ID authentication, and seamless VoIP calling.

## 🚀 Features

### 🔐 Secure Authentication
- **Face ID Login**: No passwords needed - just use your face to log in securely
- **Biometric Security**: Leverages iOS LocalAuthentication framework
- **Demo Mode**: Skip Face ID for testing purposes

### 💬 Smart Chat Interface
- **AI-Powered Search**: Tell the app what you need in natural language
- **Instant Matching**: Get provider suggestions based on your requirements
- **Quick Suggestions**: Pre-built service requests for common needs
- **Real-time Messaging**: Chat with providers before booking

### 📞 VoIP Calling
- **In-App Calls**: Make voice calls directly within the app
- **CallKit Integration**: Native iOS calling experience
- **Call Controls**: Mute, speaker, and call management
- **Call History**: Track your call history and durations

### 👥 Provider Profiles
- **Rich Profiles**: Photos, voice notes, skills, and availability
- **Verified Providers**: Trusted service providers with ratings
- **Location-Based**: Find providers near you
- **Real-time Status**: See who's available right now

### 📍 Location Services
- **Local Matching**: Find providers in your area
- **Distance Calculation**: See how far providers are from you
- **Location Permissions**: Respectful permission handling

### ⭐ Feedback System
- **Post-Call Reviews**: Rate your experience after each call
- **Detailed Feedback**: Multiple rating categories
- **Quick Ratings**: Simple star ratings for fast feedback

## 🛠 Technical Stack

- **Framework**: SwiftUI
- **Language**: Swift 5.0+
- **iOS Target**: iOS 17.0+
- **Architecture**: MVVM with ObservableObject
- **Key Frameworks**:
  - LocalAuthentication (Face ID)
  - CallKit (VoIP calls)
  - CoreLocation (Location services)
  - AVFoundation (Audio)
  - PushKit (Push notifications)

## 📱 App Structure

```
Gig/
├── GigApp.swift                 # Main app entry point
├── ContentView.swift            # Root view with tab navigation
├── Views/                       # UI Components
│   ├── LoginView.swift         # Face ID authentication
│   ├── ChatView.swift          # AI chat interface
│   ├── ProviderProfileView.swift # Provider details
│   ├── CallView.swift          # VoIP call interface
│   └── FeedbackView.swift      # Rating and reviews
├── Models/                      # Data Models
│   ├── User.swift              # User data model
│   ├── Provider.swift          # Service provider model
│   ├── Message.swift           # Chat message model
│   └── Call.swift              # Call data model
├── Services/                    # Business Logic
│   ├── AuthenticationService.swift # Face ID handling
│   ├── ChatService.swift       # AI chat logic
│   ├── CallService.swift       # VoIP functionality
│   └── LocationService.swift   # Location handling
└── Utilities/                   # Helper Code
    ├── Extensions.swift        # Swift extensions
    └── Constants.swift         # App constants
```

## 🎨 Design Features

- **Modern UI**: Clean, intuitive interface following iOS design guidelines
- **Teal Theme**: Consistent color scheme throughout the app
- **Responsive Design**: Works on all iPhone and iPad sizes
- **Dark Mode Support**: Automatic dark/light mode adaptation
- **Smooth Animations**: Polished transitions and micro-interactions

## 🔧 Setup & Installation

### Prerequisites
- Xcode 15.0+
- iOS 17.0+ device or simulator
- Apple Developer Account (for device testing)

### Installation Steps
1. Clone the repository
2. Open `Gig.xcodeproj` in Xcode
3. Select your development team in project settings
4. Build and run on device or simulator

### Required Permissions
The app requests the following permissions:
- **Face ID**: For secure authentication
- **Location**: To find nearby providers
- **Microphone**: For voice calls and voice notes
- **Camera**: For Face ID and profile photos

## 🚀 Key Features in Detail

### Face ID Authentication
```swift
// Secure biometric authentication
func authenticateWithFaceID() {
    let context = LAContext()
    let reason = "Log in to Gig securely with Face ID"
    
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, 
                          localizedReason: reason) { success, error in
        // Handle authentication result
    }
}
```

### AI Chat Interface
```swift
// Smart service matching
private func generateAIResponse(to userMessage: String) {
    let lowercasedMessage = userMessage.lowercased()
    
    if lowercasedMessage.contains("handyman") {
        // Match handyman providers
        suggestedProviders = Provider.sampleData.filter { $0.category == "Handyman" }
    }
    // More matching logic...
}
```

### VoIP Calling
```swift
// Native iOS calling experience
func startCall(with provider: Provider) {
    let handle = CXHandle(type: .generic, value: provider.id)
    let startCallAction = CXStartCallAction(call: UUID(), handle: handle)
    
    callController.request(CXTransaction(action: startCallAction)) { error in
        // Handle call start
    }
}
```

## 📊 Sample Data

The app includes realistic sample data for testing:
- **8 Service Providers**: Handymen, tutors, cleaners, creatives, coaches
- **Realistic Profiles**: Photos, bios, skills, ratings, and pricing
- **Call History**: Sample completed and missed calls
- **Reviews**: Authentic-looking feedback and ratings

## 🔮 Future Enhancements

- **Video Calls**: Face-to-face video calling
- **Payment Integration**: In-app payments and invoicing
- **Push Notifications**: Real-time updates and alerts
- **Offline Mode**: Basic functionality without internet
- **Multi-language Support**: Internationalization
- **Advanced AI**: More sophisticated provider matching
- **Provider Dashboard**: Tools for service providers

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📞 Support

For support or questions about the Gig app, please contact the development team.

---

**Gig** - Say goodbye to dashboards. Say hello to people. 👋 