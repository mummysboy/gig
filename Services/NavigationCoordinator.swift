import Foundation
import SwiftUI

class NavigationCoordinator: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var showingNewConversation: Bool = false
    @Published var selectedProviderForMessage: Provider?
    
    static let shared = NavigationCoordinator()
    
    private init() {}
    
    func navigateToMessages() {
        selectedTab = 1 // Messages tab
    }
    
    func startConversation(with provider: Provider) {
        selectedProviderForMessage = provider
        selectedTab = 1 // Messages tab
        showingNewConversation = true
    }
    
    func navigateToCalls() {
        selectedTab = 3 // Calls tab
    }
    
    func navigateToProfile() {
        selectedTab = 4 // Profile tab
    }
    
    func navigateToProviders() {
        selectedTab = 0 // Providers tab
    }
    
    func navigateToAIChat() {
        selectedTab = 2 // AI Chat tab
    }
} 