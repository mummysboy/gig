import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthenticationService()
    @StateObject private var chatService = ChatService()
    @StateObject private var callService = CallService()
    @StateObject private var navigationCoordinator = NavigationCoordinator.shared
    @State private var user = User(
        name: "Your Name",
        email: "your@email.com",
        isProvider: true,
        categories: ["Handyman", "Tutor"]
    )
    @State private var showEditProfile = false
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                modernTabView
            } else {
                LoginView()
                    .environmentObject(authService)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity.combined(with: .scale(scale: 1.05))
                    ))
            }
        }
        .environmentObject(callService)
        .animation(AppConstants.Animation.smooth, value: authService.isAuthenticated)
    }
    
    private var modernTabView: some View {
        TabView(selection: $selectedTab) {
            // Chat Tab
            ChatView()
                .environmentObject(chatService)
                .environmentObject(navigationCoordinator)
                .tabItem {
                    TabItemView(
                        icon: "sparkles",
                        title: "AI Chat",
                        isSelected: selectedTab == 0
                    )
                }
                .tag(0)
            
            // Messages Tab
            MessagesView()
                .environmentObject(navigationCoordinator)
                .tabItem {
                    TabItemView(
                        icon: "message.fill",
                        title: "Messages",
                        isSelected: selectedTab == 1
                    )
                }
                .tag(1)
            
            // Profile Tab
            ProviderProfileEditView()
                .tabItem {
                    TabItemView(
                        icon: "person.crop.circle.fill",
                        title: "Profile",
                        isSelected: selectedTab == 2
                    )
                }
                .tag(2)
        }
        .accentColor(AppConstants.Colors.primary)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        // Modern blur effect
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        
        // Remove separator line
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        
        // Style unselected items
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Style selected items
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppConstants.Colors.primary)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(AppConstants.Colors.primary),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Modern Tab Item Component
struct TabItemView: View {
    let icon: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? AppConstants.Colors.primary : AppConstants.Colors.textSecondary)
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(AppConstants.Animation.smooth, value: isSelected)
            
            Text(title)
                .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? AppConstants.Colors.primary : AppConstants.Colors.textSecondary)
        }
    }
}

#Preview {
    ContentView()
}