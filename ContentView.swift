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
                    
                    NavigationView {
                        VStack(spacing: 24) {
                            // Defensive profile image handling
                            if let profileURL = user.profileImageURL,
                               !profileURL.isEmpty,
                               let url = URL(string: profileURL),
                               url.scheme != nil {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .clipped()
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .onAppear {
                                    print("[ContentView] Loading profile image from: \(url)")
                                }
                                .onDisappear {
                                    print("[ContentView] Profile image disappeared")
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.gray)
                                    .frame(width: 120, height: 120)
                                    .onAppear {
                                        print("[ContentView] Using fallback profile image. URL was: \(user.profileImageURL ?? "nil")")
                                    }
                            }
                            Text(user.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            if !user.categories.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Services you provide:")
                                        .font(.headline)
                                    ForEach(user.categories, id: \.self) { category in
                                        Text("• " + category)
                                            .font(.subheadline)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                            }
                            Button("Edit Profile") {
                                showEditProfile = true
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top, 16)
                            Spacer()
                        }
                        .padding()
                        .navigationTitle("Profile")
                    }
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    .sheet(isPresented: $showEditProfile) {
                        UserProfileView(user: $user)
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