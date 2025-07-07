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
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.teal)
            }
               profileImage
       .frame(width: 120, height: 120)
       .clipShape(Circle())
       .overlay(
           Circle()
               .stroke(Color.teal, lineWidth: 3)
       )
            Spacer()
            Button(action: {}) {
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
            Rectangle().frame(height: 0.5).foregroundColor(Color(.systemGray4)),
            alignment: .bottom
        )
    }
    
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if conversationService.isLoading {
                        ProgressView().padding()
                    } else {
                        ForEach(conversationService.messages) { message in
                            ConversationMessageBubbleView(message: message)
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
                Button(action: {}) {
                    Image(systemName: "paperclip")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                if #available(iOS 16.0, *) {
                    TextField("Type a message...", text: $messageText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)
                        .focused($isTextFieldFocused)
                } else {
                    TextField("Type a message...", text: $messageText)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                }
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
        Provider.sampleData.first { $0.id == conversation.participantId }
    }
    
    private var profileImage: some View {
        if let provider = findProvider() {
            let urlString = provider.profileImageURL
            if !urlString.isEmpty, let url = URL(string: urlString) {
                return AnyView(
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                )
            }
        }
        return AnyView(
            Image(systemName: "person.circle.fill")
                .resizable()
                .foregroundColor(.gray)
        )
    }
}

struct ConversationMessageBubbleView: View {
    let message: ConversationMessage
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer()
                Text(message.content)
                    .padding()
                    .background(Color.teal)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            } else {
                Text(message.content)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(16)
                Spacer()
            }
        }
    }
}

struct MessageBubbleView: View {
    let message: Message
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                Text(message.content)
                    .padding()
                    .background(Color.teal)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            } else {
                Text(message.content)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(16)
                Spacer()
            }
        }
    }
} 