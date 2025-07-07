import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthenticationService()
    @StateObject private var chatService = ChatService()
    @StateObject private var callService = CallService()
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    
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
                    
                    // Placeholder for other tabs mentioned in README
                    NavigationView {
                        VStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.teal)
                            Text("Profile")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .navigationTitle("Profile")
                    }
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