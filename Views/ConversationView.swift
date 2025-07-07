import SwiftUI

struct ConversationView: View {
    let conversation: Conversation
    @ObservedObject var conversationService: ConversationService
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var showingProviderProfile = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            conversationHeader
            
            // Messages
            messagesList
            
            // Input area
            messageInputArea
        }
        .navigationBarHidden(true)
        .onAppear {
            conversationService.loadMessages(for: conversation.id)
            conversationService.markConversationAsRead(conversation.id)
        }
        .sheet(isPresented: $showingProviderProfile) {
            if let provider = findProvider() {
                ProviderProfileView(provider: provider)
            }
        }
    }
    
    private var conversationHeader: some View {
        HStack(spacing: 12) {
            // Back button
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.teal)
            }
            
            // Profile image
            AsyncImage(url: URL(string: conversation.participantImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .onTapGesture {
                showingProviderProfile = true
            }
            
            // Participant info
            VStack(alignment: .leading, spacing: 2) {
                Text(conversation.participantName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Online")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Call button
            Button(action: {
                // Handle call action
            }) {
                Image(systemName: "phone.fill")
                    .font(.title3)
                    .foregroundColor(.teal)
                    .frame(width: 40, height: 40)
                    .background(Color.teal.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.systemGray4)),
            alignment: .bottom
        )
    }
    
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if conversationService.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        ForEach(conversationService.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                }
                .padding()
            }
            .onChange(of: conversationService.messages.count) { _ in
                if let lastMessage = conversationService.messages.last {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var messageInputArea: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                // Attachment button
                Button(action: {
                    // Handle attachment
                }) {
                    Image(systemName: "paperclip")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                
                // Text field
                if #available(iOS 16.0, *) {
                    TextField("Type a message...", text: $messageText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)
                        .focused($isTextFieldFocused)
                } else {
                    TextField("Type a message...", text: $messageText)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                    // No axis or ranged lineLimit support before iOS 16
                }
                
                // Send button
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .teal)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
    
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        conversationService.sendMessage(trimmedText, to: conversation.id)
        messageText = ""
        isTextFieldFocused = false
    }
    
    private func findProvider() -> Provider? {
        return Provider.sampleData.first { $0.id == conversation.participantId }
    }
}

// MARK: - Quick Actions View
struct QuickActionsView: View {
    let onActionSelected: (String) -> Void
    
    let quickActions = [
        "What's your availability?",
        "What are your rates?",
        "Can you help with this?",
        "When can you start?",
        "Do you have references?"
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(quickActions, id: \.self) { action in
                    Button(action: {
                        onActionSelected(action)
                    }) {
                        Text(action)
                            .font(.caption)
                            .foregroundColor(.teal)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.teal.opacity(0.1))
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Message Status View
struct MessageStatusView: View {
    let status: MessageStatus
    
    var body: some View {
        HStack(spacing: 4) {
            switch status {
            case .sending:
                ProgressView()
                    .scaleEffect(0.7)
            case .sent:
                Image(systemName: "checkmark")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            case .delivered:
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            case .read:
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.teal)
            }
        }
    }
}

enum MessageStatus {
    case sending
    case sent
    case delivered
    case read
}

#Preview {
    ConversationView(
        conversation: Conversation.sampleData.first!,
        conversationService: ConversationService()
    )
} 