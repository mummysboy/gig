import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var showingError = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.teal.opacity(0.1), Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo and branding
                VStack(spacing: 20) {
                    // App icon placeholder
                    ZStack {
                        Circle()
                            .fill(Color.teal)
                            .frame(width: 120, height: 120)
                            .shadow(color: .teal.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        Text("Gig")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Gig")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("The smart phonebook for the gig economy")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
                
                // Authentication section
                VStack(spacing: 24) {
                    if authService.isFaceIDAvailable {
                        VStack(spacing: 16) {
                            Button(action: {
                                authService.authenticateWithFaceID()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "faceid")
                                        .font(.title2)
                                    
                                    Text("Sign in with Face ID")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.teal)
                                .cornerRadius(16)
                                .shadow(color: .teal.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .disabled(authService.isAuthenticating)
                            
                            if authService.isAuthenticating {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Authenticating...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title)
                                .foregroundColor(.orange)
                            
                            Text("Face ID Not Available")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Please set up Face ID in Settings to use this app")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Demo login button for testing
                    Button(action: {
                        // For demo purposes, bypass Face ID
                        authService.isAuthenticated = true
                    }) {
                        Text("Demo Login (Skip Face ID)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .underline()
                    }
                }
                
                Spacer()
                
                // Footer
                VStack(spacing: 8) {
                    Text("Secure • Fast • Simple")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("No passwords needed")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 40)
        }
        .alert("Authentication Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(authService.authenticationError ?? "Unknown error")
        }
        .onChange(of: authService.authenticationError) { error in
            showingError = error != nil
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationService())
} 