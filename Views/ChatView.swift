import SwiftUI

struct ChatView: View {
    @StateObject private var chatService = ChatService()
    @State private var messageText = ""
    @State private var showingSuggestions = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Welcome message
                            if chatService.messages.isEmpty {
                                WelcomeMessageView()
                            }
                            
                            // Messages
                            ForEach(chatService.messages) { message in
                                MessageBubbleView(message: message)
                                    .id(message.id)
                            }
                            
                            // Suggestions
                            if showingSuggestions && chatService.messages.isEmpty {
                                SuggestionsView { suggestion in
                                    chatService.sendMessage(suggestion)
                                    showingSuggestions = false
                                }
                            }
                        }
                        .padding()
                    }
                    .onChange(of: chatService.messages.count) { _ in
                        if let lastMessage = chatService.messages.last {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input area
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack(spacing: 12) {
                        if #available(iOS 16.0, *) {
                            TextField("Tell us what you need...", text: $messageText, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(1...4)
                        } else {
                            TextField("Tell us what you need...", text: $messageText)
                                .textFieldStyle(.roundedBorder)
                            // No axis or ranged lineLimit support before iOS 16
                        }
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .teal)
                        }
                        .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        chatService.sendMessage(trimmedText)
        messageText = ""
        showingSuggestions = false
    }
}

struct WelcomeMessageView: View {
    var body: some View {
        VStack(spacing: 16) {
            // App icon
            ZStack {
                Circle()
                    .fill(Color.teal.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "message.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.teal)
            }
            
            VStack(spacing: 8) {
                Text("Welcome to Gig!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Tell me what you need and I'll find the perfect service provider for you.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct MessageBubbleView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 60)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(18)
                        .cornerRadius(4, corners: .topLeft)
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.teal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(message.content)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .cornerRadius(18)
                                .cornerRadius(4, corners: .topRight)
                            
                            // Show provider suggestions if available
                            if let providers = message.suggestedProviders, !providers.isEmpty {
                                ProviderSuggestionsView(providers: providers)
                            }
                        }
                    }
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.leading, 36)
                }
                
                Spacer(minLength: 60)
            }
        }
    }
}

struct ProviderSuggestionsView: View {
    let providers: [Provider]
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Here are some providers for you:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ForEach(providers.prefix(3)) { provider in
                Button(action: {
                    // Navigate to provider profile
                }) {
                    HStack {
                        AsyncImage(url: URL(string: provider.profileImageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(provider.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text(provider.category)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("$\(provider.hourlyRate)/hr")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.teal)
                            
                            if provider.isAvailable {
                                Text("Available")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.teal.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct SuggestionsView: View {
    let onSuggestionTapped: (String) -> Void
    
    let suggestions = [
        "I need a handyman to fix my kitchen sink",
        "Looking for a math tutor for my 10-year-old",
        "Need house cleaning service this weekend",
        "Want to hire a photographer for a family event",
        "Looking for a personal trainer"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick suggestions:")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button(action: {
                        onSuggestionTapped(suggestion)
                    }) {
                        HStack {
                            Text(suggestion)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.circle")
                                .foregroundColor(.teal)
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    ChatView()
} 