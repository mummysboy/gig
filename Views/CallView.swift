import SwiftUI
import AVFoundation

struct CallView: View {
    let provider: Provider
    @ObservedObject var callService: CallService
    @Environment(\.dismiss) private var dismiss
    @State private var isMuted = false
    @State private var isSpeakerOn = false
    @State private var showingFeedback = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.teal.opacity(0.3), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Provider info
                VStack(spacing: 20) {
                    // Defensive image handling
                    if !provider.profileImageURL.isEmpty,
                       let url = URL(string: provider.profileImageURL),
                       url.scheme != nil {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.white)
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .onAppear {
                            print("[CallView] Loading provider image from: \(url)")
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.white)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                            )
                            .onAppear {
                                print("[CallView] Using fallback image. URL was: \(provider.profileImageURL)")
                            }
                    }
                    
                    VStack(spacing: 8) {
                        Text(provider.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(provider.primaryCategory ?? "")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(callService.formatCallDuration(callService.callDuration))
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                
                Spacer()
                
                // Call controls
                VStack(spacing: 30) {
                    // Mute and speaker controls
                    HStack(spacing: 60) {
                        CallControlButton(
                            icon: isMuted ? "mic.slash.fill" : "mic.fill",
                            isActive: isMuted,
                            action: { isMuted.toggle() }
                        )
                        
                        CallControlButton(
                            icon: isSpeakerOn ? "speaker.wave.3.fill" : "speaker.fill",
                            isActive: isSpeakerOn,
                            action: { isSpeakerOn.toggle() }
                        )
                    }
                    
                    // End call button
                    Button(action: {
                        callService.endCall()
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "phone.down.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Spacer()
                
                // Call status
                Text("Connected")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Start the call
            callService.startCall(with: provider)
        }
        .onDisappear {
            // End call if still active
            if callService.isInCall {
                callService.endCall()
            }
        }
        .sheet(isPresented: $showingFeedback) {
            FeedbackView(provider: provider)
        }
    }
}

struct CallControlButton: View {
    let icon: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isActive ? Color.white : Color.white.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isActive ? .teal : .white)
            }
        }
    }
}

// MARK: - Call Incoming View
struct IncomingCallView: View {
    let provider: Provider
    @ObservedObject var callService: CallService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.teal.opacity(0.3), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Provider info
                VStack(spacing: 20) {
                    // Defensive image handling
                    if !provider.profileImageURL.isEmpty,
                       let url = URL(string: provider.profileImageURL),
                       url.scheme != nil {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.white)
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .onAppear {
                            print("[IncomingCallView] Loading provider image from: \(url)")
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.white)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                            )
                            .onAppear {
                                print("[IncomingCallView] Using fallback image. URL was: \(provider.profileImageURL)")
                            }
                    }
                    
                    VStack(spacing: 8) {
                        Text(provider.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Incoming call...")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Call controls
                HStack(spacing: 60) {
                    // Decline button
                    Button(action: {
                        callService.endCall()
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "phone.down.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Accept button
                    Button(action: {
                        // Accept call logic
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "phone.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    CallView(
        provider: Provider.sampleData[0],
        callService: CallService()
    )
} 