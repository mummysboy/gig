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
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                TabView {
                    ChatView()
                        .environmentObject(chatService)
                        .environmentObject(navigationCoordinator)
                        .tabItem {
                            Image(systemName: "message.fill")
                            Text("Chat")
                        }
                    
                    MessagesView()
                        .environmentObject(navigationCoordinator)
                        .tabItem {
                            Image(systemName: "envelope.fill")
                            Text("Messages")
                        }
                    
                    ProviderProfileEditView(
                        // Optionally, you can pass an onSave closure to update user/provider data
                    )
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                }
                .accentColor(.teal)
            } else {
                LoginView()
                    .environmentObject(authService)
            }
        }
        .environmentObject(callService)
    }
}

#Preview {
    ContentView()
}