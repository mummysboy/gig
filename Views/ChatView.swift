import SwiftUI

struct ChatView: View {
    @StateObject private var chatService = ChatService()
    @State private var messageText = ""
    @State private var showingSuggestions = true
    @State private var showingError = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var selectedProvider: Provider? = nil
    @State private var showProfileSheet = false
    @State private var activeChatProvider: Provider? = nil
    @State private var showConversation = false
    @State private var showCallSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [AppConstants.Colors.secondaryBackground, AppConstants.Colors.background]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Chat messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: AppConstants.Spacing.md) {
                                // Welcome message
                                if chatService.messages.isEmpty {
                                    CardView {
                                        WelcomeMessageView()
                                    }
                                }
                                
                                // Messages
                                ForEach(chatService.messages) { message in
                                    CardView {
                                        MessageBubbleView(message: message, onProviderTap: { provider in
                                            selectedProvider = provider
                                            showProfileSheet = true
                                        })
                                    }
                                    .id(message.id)
                                }
                                
                                // Loading indicator
                                if chatService.isLoading {
                                    CardView {
                                        HStack {
                                            Image(systemName: "person.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(.teal)
                                            
                                            HStack(spacing: 4) {
                                                Text("AI is analyzing your request")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                
                                                ProgressView()
                                                    .scaleEffect(0.8)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(AppConstants.Colors.secondaryBackground)
                                            .cornerRadius(18)
                                            .shadow(color: Color(.systemGray3), radius: 2, x: 0, y: 1)
                                            
                                            Spacer(minLength: 60)
                                        }
                                    }
                                }
                                
                                // Suggestions
                                if showingSuggestions && chatService.messages.isEmpty {
                                    CardView {
                                        SuggestionsView { suggestion in
                                            chatService.sendMessage(suggestion)
                                            showingSuggestions = false
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 12)
                            .padding(.horizontal, AppConstants.Spacing.md)
                        }
                        .onTapGesture {
                            isTextFieldFocused = false // Dismiss keyboard
                        }
                        .onChange(of: chatService.messages.count) { _ in
                            if let lastMessage = chatService.messages.last {
                                withAnimation(AppConstants.Animation.standard) {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // Input area (modern style)
                    HStack(spacing: 12) {
                        if #available(iOS 16.0, *) {
                            TextField("Tell us what you need...", text: $messageText, axis: .vertical)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(AppConstants.Colors.background)
                                .cornerRadius(AppConstants.CornerRadius.large)
                                .shadow(color: AppConstants.Colors.primary.opacity(0.08), radius: 1, x: 0, y: 1)
                                .focused($isTextFieldFocused)
                        } else {
                            TextField("Tell us what you need...", text: $messageText)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(AppConstants.Colors.background)
                                .cornerRadius(AppConstants.CornerRadius.large)
                                .shadow(color: AppConstants.Colors.primary.opacity(0.08), radius: 1, x: 0, y: 1)
                                .focused($isTextFieldFocused)
                        }
                        
                        ModernButton(title: "Send", icon: "arrow.up.circle.fill", color: messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : AppConstants.Colors.primary) {
                            sendMessage()
                        }
                        .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .frame(maxWidth: 120)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.clear)
                }
                .padding(.bottom, 8)
            }
            .navigationTitle("AI Chat")
            .navigationBarTitleDisplayMode(.large)
            .alert("AI Service Notice", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(chatService.error ?? "An error occurred with the AI service.")
            }
            .onChange(of: chatService.error) { error in
                showingError = error != nil
            }
            .sheet(isPresented: $showProfileSheet) {
                if let provider = selectedProvider {
                    ProviderProfileView(
                        provider: provider,
                        onMessage: {
                            activeChatProvider = provider
                            showConversation = true
                        },
                        onCall: {
                            activeChatProvider = provider
                            showCallSheet = true
                        }
                    )
                }
            }
            .sheet(isPresented: $showConversation) {
                conversationViewForActiveProvider()
            }
            .sheet(isPresented: $showCallSheet) {
                if let provider = activeChatProvider {
                    // Replace with your CallView implementation
                    Text("Calling \(provider.name)...")
                        .font(.title)
                        .padding()
                }
            }
        }
    }
    
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        chatService.sendMessage(trimmedText)
        messageText = ""
        showingSuggestions = false
        isTextFieldFocused = false // Dismiss keyboard after sending
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
        .shadow(color: Color(.systemGray3), radius: 2, x: 0, y: 1)
    }
}

struct MessageBubbleView: View {
    let message: Message
    var onProviderTap: ((Provider) -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isFromUser {
                Spacer(minLength: 60)
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(22)
                        .shadow(color: Color.teal.opacity(0.15), radius: 2, x: 0, y: 1)
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 4)
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
                                .cornerRadius(22)
                                .shadow(color: Color(.systemGray3), radius: 1, x: 0, y: 1)
                            // Show provider suggestions if available
                            if let providers = message.suggestedProviders, !providers.isEmpty {
                                ProviderSuggestionsView(providers: providers, onProviderTap: onProviderTap)
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
        .padding(.horizontal, 2)
    }
}

// AI Recommendations visually distinct
struct ProviderSuggestionsView: View {
    let providers: [Provider]
    var onProviderTap: ((Provider) -> Void)? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("✨ AI Recommendations")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.teal)
                .padding(.bottom, 2)
            ForEach(providers) { provider in
                ProviderSuggestionRow(provider: provider, onTap: {
                    onProviderTap?(provider)
                })
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.teal.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color(.systemGray3), radius: 2, x: 0, y: 1)
        .padding(.top, 4)
    }
}

struct ProviderSuggestionRow: View {
    let provider: Provider
    var onTap: (() -> Void)? = nil
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(spacing: 10) {
                // Defensive image handling
                if let profileURL = provider.profileImageURL.isEmpty ? nil : provider.profileImageURL,
                   let url = URL(string: profileURL),
                   url.scheme != nil {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .onAppear {
                        print("[ProviderSuggestionRow] Loading image for \(provider.name) from: \(url)")
                    }
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        .onAppear {
                            print("[ProviderSuggestionRow] Using fallback image for \(provider.name). URL was: \(provider.profileImageURL)")
                        }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(provider.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(provider.primaryCategory ?? "")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(8)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.teal.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color(.systemGray4).opacity(0.15), radius: 1, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
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

extension ChatView {
    private func conversationViewForActiveProvider() -> AnyView {
        guard let provider = activeChatProvider else { return AnyView(EmptyView()) }
        let conversationService = ConversationService()
        let conversation: Conversation
        if let existing = conversationService.conversations.first(where: { $0.participantId == provider.id }) {
            conversation = existing
        } else {
            let conversationId = conversationService.createNewConversation(with: provider)
            conversation = Conversation(
                id: conversationId,
                participantId: provider.id,
                participantName: provider.name,
                participantImageURL: provider.profileImageURL,
                lastMessage: "",
                lastMessageTime: Date(),
                unreadCount: 0,
                isProvider: true
            )
        }
        return AnyView(
            ConversationView(
                conversation: conversation,
                conversationService: conversationService
            )
        )
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
