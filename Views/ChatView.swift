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
                Color(.systemBackground).ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                if chatService.messages.isEmpty {
                                    ChatGPTWelcomeView()
                                }

                                ForEach(chatService.messages) { message in
                                    ChatGPTMessageView(message: message, onProviderTap: { provider in
                                        selectedProvider = provider
                                        showProfileSheet = true
                                    })
                                    .id(message.id)
                                }

                                if chatService.isTyping && !chatService.currentTypingMessage.isEmpty {
                                    ChatGPTTypingView(content: chatService.currentTypingMessage)
                                        .id("typing")
                                }

                                if chatService.isLoading && !chatService.isTyping {
                                    ChatGPTLoadingView()
                                }

                                if showingSuggestions && chatService.messages.isEmpty {
                                    ChatGPTSuggestionsView { suggestion in
                                        chatService.sendMessage(suggestion)
                                        showingSuggestions = false
                                    }
                                }
                            }
                            .padding(.bottom, 100)
                        }
                        .onTapGesture {
                            isTextFieldFocused = false
                        }
                        .onChange(of: chatService.messages.count) { _ in
                            scrollToBottom(proxy)
                        }
                        .onChange(of: chatService.currentTypingMessage) { _ in
                            if !chatService.currentTypingMessage.isEmpty {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    proxy.scrollTo("typing", anchor: .bottom)
                                }
                            }
                        }
                    }

                    ChatGPTInputArea(
                        messageText: $messageText,
                        isTextFieldFocused: _isTextFieldFocused,
                        onSend: sendMessage
                    )
                }
            }
            .navigationTitle("Gig AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        chatService.clearChat()
                        showingSuggestions = true
                    }
                    .foregroundColor(.secondary)
                }
            }
            .alert("AI Service Notice", isPresented: $showingError) {
                Button("OK") {}
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
                    Text("Calling \(provider.name)...")
                        .font(.title)
                        .padding()
                }
            }
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        if let lastMessage = chatService.messages.last {
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }

    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        chatService.sendMessage(trimmedText)
        messageText = ""
        showingSuggestions = false
        isTextFieldFocused = false
    }

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

// MARK: - Modern ChatGPT Style Components

struct ChatGPTWelcomeView: View {
    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.teal.opacity(0.15), Color.teal.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                Image(systemName: "sparkles")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.teal)
            }
            VStack(spacing: 10) {
                Text("Welcome to Gig AI")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text("How can I help you today?")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 48)
    }
}

struct ChatGPTMessageView: View {
    let message: Message
    var onProviderTap: ((Provider) -> Void)? = nil
    var body: some View {
        VStack(spacing: 0) {
            if message.isFromUser {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(message.content)
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.teal.opacity(0.12))
                            )
                        Text(message.timestamp, style: .time)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                            .padding(.trailing, 12)
                    }
                }
                .padding(.vertical, 8)
            } else {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color.teal.opacity(0.15), Color.teal.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 36, height: 36)
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.teal)
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        Text(message.content)
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .foregroundColor(.primary)
                            .padding(.vertical, 8)
                        if let providers = message.suggestedProviders, !providers.isEmpty {
                            ChatGPTProviderSuggestionsView(providers: providers, onProviderTap: onProviderTap)
                        }
                        Text(message.timestamp, style: .time)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 8)
            }
        }
    }
}

struct ChatGPTTypingView: View {
    let content: String
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.teal.opacity(0.15), Color.teal.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 36, height: 36)
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.teal)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(content)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.vertical, 8)
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.teal.opacity(0.7))
                            .frame(width: 7, height: 7)
                            .scaleEffect(1.0)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: UUID()
                            )
                    }
                }
            }
            Spacer(minLength: 40)
        }
        .padding(.vertical, 8)
    }
}

struct ChatGPTLoadingView: View {
    @State private var dotOffset: CGFloat = 0
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.teal.opacity(0.15), Color.teal.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 36, height: 36)
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.teal)
            }
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 7, height: 7)
                        .offset(y: dotOffset)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: dotOffset
                        )
                }
            }
            .onAppear { dotOffset = -3 }
            Spacer(minLength: 40)
        }
        .padding(.vertical, 8)
    }
}

struct ChatGPTInputArea: View {
    @Binding var messageText: String
    @FocusState var isTextFieldFocused: Bool
    let onSend: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            Divider().background(Color(.systemGray4))
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    if #available(iOS 16.0, *) {
                        TextField("Message Gig AI...", text: $messageText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .focused($isTextFieldFocused)
                            .lineLimit(1...6)
                    } else {
                        TextField("Message Gig AI...", text: $messageText)
                            .textFieldStyle(.plain)
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .focused($isTextFieldFocused)
                    }
                    Button(action: onSend) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : .teal)
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
    }
}

struct ChatGPTSuggestionsView: View {
    let onSuggestionTapped: (String) -> Void
    let suggestions = [
        "I need a handyman to fix my kitchen sink",
        "Looking for a math tutor for my 10-year-old",
        "Need house cleaning service this weekend",
        "Want to hire a photographer for a family event",
        "Looking for a personal trainer"
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Try asking about:")
                .font(.system(size: 19, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 10) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button(action: { onSuggestionTapped(suggestion) }) {
                        HStack {
                            Text(suggestion)
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                                .lineSpacing(1)
                            Spacer()
                            Image(systemName: "arrow.up.circle")
                                .foregroundColor(.teal)
                                .font(.system(size: 18))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray4), lineWidth: 0.5)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 18)
    }
}

struct ChatGPTProviderSuggestionsView: View {
    let providers: [Provider]
    var onProviderTap: ((Provider) -> Void)? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.teal)
                    .font(.system(size: 16, weight: .medium))
                Text("Recommended Providers")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.teal)
            }
            .padding(.horizontal, 16)
            ForEach(providers) { provider in
                ChatGPTProviderRow(provider: provider, onTap: { onProviderTap?(provider) })
            }
        }
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.teal.opacity(0.18), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
    }
}

struct ChatGPTProviderRow: View {
    let provider: Provider
    var onTap: (() -> Void)? = nil
    var body: some View {
        Button(action: { onTap?() }) {
            HStack(alignment: .top, spacing: 16) {
                // Profile image with availability
                ZStack(alignment: .bottomTrailing) {
                    if let profileURL = provider.profileImageURL.isEmpty ? nil : provider.profileImageURL,
                       let url = URL(string: profileURL),
                       url.scheme != nil {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                        }
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                            .frame(width: 56, height: 56)
                    }
                    Circle()
                        .fill(provider.isAvailable ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .offset(x: 6, y: 6)
                }
                // Info section
                VStack(alignment: .leading, spacing: 8) {
                    // Main info row (horizontal)
                    HStack(alignment: .center, spacing: 10) {
                        Text(provider.name)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        if provider.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                        }
                        Text("$\(provider.hourlyRate)/hr")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.teal))
                        if let category = provider.primaryCategory {
                            Text(category)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.teal)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(RoundedRectangle(cornerRadius: 6).fill(Color.teal.opacity(0.1)))
                        }
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", provider.rating))
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            Text("(\(provider.reviewCount))")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    // Secondary info (vertical)
                    if !provider.bio.isEmpty {
                        Text(provider.bio)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    if !provider.skills.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(provider.skills.prefix(4), id: \.self) { skill in
                                Text(skill)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(.teal)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.teal.opacity(0.1)))
                            }
                        }
                    }
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Text("Joined \(provider.joinDate, style: .date)")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.secondary)
                        Spacer()
                        HStack(spacing: 4) {
                            Text("View Profile")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.teal)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.teal)
                        }
                    }
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)).shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ChatView()
}
