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
                // Search bar
                searchBar
                
                // Conversations list
                if conversationService.isLoading {
                    loadingView
                } else if filteredConversations.isEmpty {
                    emptyStateView
                } else {
                    conversationsList
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewMessage = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.teal)
                    }
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
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search conversations...", text: $searchText)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var filteredConversations: [Conversation] {
        if searchText.isEmpty {
            return conversationService.conversations
        } else {
            return conversationService.searchConversations(query: searchText)
        }
    }
    
    private var conversationsList: some View {
        List(filteredConversations) { conversation in
            ConversationRowView(conversation: conversation)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedConversation = conversation
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        conversationService.deleteConversation(conversation.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
        .listStyle(PlainListStyle())
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading conversations...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "message.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Messages Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Start a conversation with a service provider to get help with your needs.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                showingNewMessage = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Start New Conversation")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.teal)
                .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ConversationRowView: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            AsyncImage(url: URL(string: conversation.participantImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // Conversation details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.participantName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(conversation.lastMessageTime.timeAgoDisplay())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(conversation.lastMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.teal)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct NewMessageView: View {
    @ObservedObject var conversationService: ConversationService
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedProvider: Provider?
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search providers...", text: $searchText)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Providers list
                List(filteredProviders) { provider in
                    ProviderRowView(provider: provider)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedProvider = provider
                        }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
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
        }
    }
    
    private var filteredProviders: [Provider] {
        if searchText.isEmpty {
            return Provider.sampleData
        } else {
            return Provider.sampleData.filter { provider in
                provider.name.localizedCaseInsensitiveContains(searchText) ||
                provider.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct ProviderRowView: View {
    let provider: Provider
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            AsyncImage(url: URL(string: provider.profileImageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // Provider details
            VStack(alignment: .leading, spacing: 4) {
                Text(provider.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(provider.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", provider.rating))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Availability indicator
            Circle()
                .fill(provider.isAvailable ? Color.green : Color.red)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MessagesView()
} 