import SwiftUI

struct MessagesView: View {
    @StateObject private var conversationService = ConversationService()
    @State private var searchText = ""
    @State private var showingNewMessage = false
    @State private var selectedConversation: Conversation?
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Modern Search Bar
                modernSearchBar
                    .padding(.horizontal, AppConstants.Spacing.screenPadding)
                    .padding(.top, AppConstants.Spacing.sm)
                
                // Content
                contentView
            }
            .background(AppConstants.Colors.background)
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ModernButton(
                        title: "New",
                        icon: "square.and.pencil",
                        style: .primary,
                        size: .small
                    ) {
                        showingNewMessage = true
                    }
                    .frame(width: 80)
                }
            }
            .sheet(isPresented: $showingNewMessage) {
                NewMessageView(conversationService: conversationService)
            }
            .onReceive(navigationCoordinator.$showingNewConversation) { showing in
                if showing {
                    showingNewMessage = true
                    navigationCoordinator.showingNewConversation = false
                }
            }
            .sheet(item: $selectedConversation) { conversation in
                ConversationView(
                    conversation: conversation,
                    conversationService: conversationService
                )
            }
        }
    }
    
    private var modernSearchBar: some View {
        HStack(spacing: AppConstants.Spacing.sm) {
            HStack(spacing: AppConstants.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppConstants.Colors.textSecondary)
                    .font(.system(size: 16, weight: .medium))
                
                TextField("Search conversations...", text: $searchText)
                    .font(AppConstants.Typography.bodyMedium)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppConstants.Colors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, AppConstants.Spacing.md)
            .padding(.vertical, AppConstants.Spacing.sm)
            .background(AppConstants.Colors.secondaryBackground)
            .cornerRadius(AppConstants.CornerRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.large)
                    .stroke(AppConstants.Colors.primary.opacity(searchText.isEmpty ? 0 : 0.3), lineWidth: 1)
            )
            .animation(AppConstants.Animation.quick, value: searchText.isEmpty)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if conversationService.isLoading {
            loadingStateView
        } else if filteredConversations.isEmpty {
            emptyStateView
        } else {
            conversationsList
        }
    }
    
    private var loadingStateView: some View {
        VStack(spacing: AppConstants.Spacing.lg) {
            LoadingView(style: .spinner)
            Text("Loading conversations...")
                .font(AppConstants.Typography.bodyMedium)
                .foregroundColor(AppConstants.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        EmptyStateView(
            icon: "message.circle",
            title: "No Messages Yet",
            description: "Start a conversation with a service provider to get help with your needs.",
            actionTitle: "Start New Conversation"
        ) {
            showingNewMessage = true
        }
    }
    
    private var conversationsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: AppConstants.Spacing.sm) {
                ForEach(filteredConversations) { conversation in
                    ConversationRowView(conversation: conversation)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedConversation = conversation
                        }
                        .contextMenu {
                            contextMenuItems(for: conversation)
                        }
                }
            }
            .padding(.horizontal, AppConstants.Spacing.screenPadding)
            .padding(.top, AppConstants.Spacing.md)
            .padding(.bottom, AppConstants.Spacing.xxxl)
        }
    }
    
    @ViewBuilder
    private func contextMenuItems(for conversation: Conversation) -> some View {
        Button(action: {
            selectedConversation = conversation
        }) {
            Label("Open", systemImage: "message")
        }
        
        Button(role: .destructive, action: {
            conversationService.deleteConversation(conversation.id)
        }) {
            Label("Delete", systemImage: "trash")
        }
    }
    
    private var filteredConversations: [Conversation] {
        if searchText.isEmpty {
            return conversationService.conversations
        } else {
            return conversationService.searchConversations(query: searchText)
        }
    }
}

// MARK: - Modern Conversation Row
struct ConversationRowView: View {
    let conversation: Conversation
    
    var body: some View {
        CardView(style: .elevated, padding: AppConstants.Spacing.md) {
            HStack(spacing: AppConstants.Spacing.md) {
                // Avatar with status
                AvatarView(
                    imageURL: conversation.participantImageURL,
                    name: conversation.participantName,
                    size: .medium,
                    status: conversation.isProvider ? .online : nil
                )
                
                // Conversation details
                VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
                    HStack {
                        Text(conversation.participantName)
                            .font(AppConstants.Typography.titleMedium)
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.text)
                        
                        Spacer()
                        
                        Text(conversation.lastMessageTime.timeAgoDisplay())
                            .font(AppConstants.Typography.labelSmall)
                            .foregroundColor(AppConstants.Colors.textSecondary)
                    }
                    
                    HStack {
                        Text(conversation.lastMessage.isEmpty ? "No messages yet" : conversation.lastMessage)
                            .font(AppConstants.Typography.bodyMedium)
                            .foregroundColor(conversation.lastMessage.isEmpty ? AppConstants.Colors.textTertiary : AppConstants.Colors.textSecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        if conversation.unreadCount > 0 {
                            BadgeView(
                                text: "\(conversation.unreadCount)",
                                style: .primary
                            )
                        }
                    }
                }
            }
        }
        .animation(AppConstants.Animation.cardAppear, value: conversation.unreadCount)
    }
}

// MARK: - Modern New Message View
struct NewMessageView: View {
    @ObservedObject var conversationService: ConversationService
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedProvider: Provider?
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: AppConstants.Spacing.md) {
                    SectionHeader(
                        title: "New Message",
                        subtitle: "Select a provider to start a conversation"
                    )
                    .padding(.horizontal, AppConstants.Spacing.screenPadding)
                    
                    // Search bar
                    modernSearchBar
                        .padding(.horizontal, AppConstants.Spacing.screenPadding)
                }
                .padding(.top, AppConstants.Spacing.md)
                .background(AppConstants.Colors.background)
                
                // Providers list
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: AppConstants.Spacing.sm) {
                        ForEach(filteredProviders) { provider in
                            ProviderRowView(provider: provider)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedProvider = provider
                                }
                        }
                    }
                    .padding(.horizontal, AppConstants.Spacing.screenPadding)
                    .padding(.top, AppConstants.Spacing.md)
                }
            }
            .background(AppConstants.Colors.background)
            .navigationBarHidden(true)
            .sheet(item: $selectedProvider) { provider in
                let conversationId = conversationService.createNewConversation(with: provider)
                ConversationView(
                    conversation: Conversation(
                        id: conversationId,
                        participantId: provider.id,
                        participantName: provider.name,
                        participantImageURL: provider.profileImageURL,
                        isProvider: true
                    ),
                    conversationService: conversationService
                )
            }
            .onAppear {
                // Pre-select provider if one was selected from navigation
                if let provider = navigationCoordinator.selectedProviderForMessage {
                    selectedProvider = provider
                    navigationCoordinator.selectedProviderForMessage = nil
                }
            }
            .overlay(alignment: .topTrailing) {
                IconButton(icon: "xmark", style: .secondary, size: .medium) {
                    dismiss()
                }
                .padding(AppConstants.Spacing.md)
            }
        }
    }
    
    private var modernSearchBar: some View {
        HStack(spacing: AppConstants.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppConstants.Colors.textSecondary)
                .font(.system(size: 16, weight: .medium))
            
            TextField("Search providers...", text: $searchText)
                .font(AppConstants.Typography.bodyMedium)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppConstants.Colors.textSecondary)
                }
            }
        }
        .padding(.horizontal, AppConstants.Spacing.md)
        .padding(.vertical, AppConstants.Spacing.sm)
        .background(AppConstants.Colors.secondaryBackground)
        .cornerRadius(AppConstants.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.large)
                .stroke(AppConstants.Colors.primary.opacity(searchText.isEmpty ? 0 : 0.3), lineWidth: 1)
        )
        .animation(AppConstants.Animation.quick, value: searchText.isEmpty)
    }
    
    private var filteredProviders: [Provider] {
        if searchText.isEmpty {
            return Provider.sampleData
        } else {
            return Provider.sampleData.filter { provider in
                provider.name.localizedCaseInsensitiveContains(searchText) ||
                (provider.primaryCategory ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

// MARK: - Modern Provider Row
struct ProviderRowView: View {
    let provider: Provider
    
    var body: some View {
        CardView(style: .elevated, padding: AppConstants.Spacing.md) {
            HStack(spacing: AppConstants.Spacing.md) {
                // Avatar with status
                AvatarView(
                    imageURL: provider.profileImageURL,
                    name: provider.name,
                    size: .medium,
                    status: provider.isAvailable ? .online : .offline
                )
                
                // Provider details
                VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
                    HStack {
                        Text(provider.name)
                            .font(AppConstants.Typography.titleMedium)
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.text)
                        
                        Spacer()
                        
                        HStack(spacing: AppConstants.Spacing.xxs) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 12))
                            Text(String(format: "%.1f", provider.rating))
                                .font(AppConstants.Typography.labelMedium)
                                .foregroundColor(AppConstants.Colors.textSecondary)
                        }
                    }
                    
                    if let category = provider.primaryCategory {
                        BadgeView(text: category, style: .secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    MessagesView()
} 
