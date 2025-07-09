import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var showingError = false
    @State private var logoScale: CGFloat = 0.8
    @State private var contentOpacity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Modern gradient background
                AppConstants.Colors.primaryGradient
                    .ignoresSafeArea()
                    .overlay(
                        // Subtle pattern overlay
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.clear
                            ]),
                            center: .topTrailing,
                            startRadius: 0,
                            endRadius: geometry.size.width
                        )
                    )
                
                // Content
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Hero Section
                    heroSection
                    
                    Spacer()
                    Spacer()
                    
                    // Authentication Section
                    authenticationSection
                    
                    Spacer()
                    
                    // Footer
                    footerSection
                }
                .padding(.horizontal, AppConstants.Spacing.screenPadding)
                .opacity(contentOpacity)
            }
        }
        .alert("Authentication Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(authService.authenticationError ?? "Unknown error")
        }
        .onChange(of: authService.authenticationError) { error in
            showingError = error != nil
        }
        .onAppear {
            animateEntry()
        }
    }
    
    private var heroSection: some View {
        VStack(spacing: AppConstants.Spacing.xl) {
            // App Logo with modern design
            ZStack {
                // Outer glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 60,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                
                // Main logo circle
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.9),
                                Color.white.opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.2)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                
                // Logo text
                Text("Gig")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppConstants.Colors.primary,
                                AppConstants.Colors.primaryDark
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .scaleEffect(logoScale)
            
            // Branding text
            VStack(spacing: AppConstants.Spacing.sm) {
                Text("Welcome to Gig")
                    .font(AppConstants.Typography.headlineLarge)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(AppConstants.appTagline)
                    .font(AppConstants.Typography.bodyLarge)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
    }
    
    private var authenticationSection: some View {
        VStack(spacing: AppConstants.Spacing.xl) {
            if authService.isFaceIDAvailable {
                availableFaceIDSection
            } else {
                unavailableFaceIDSection
            }
            
            // Demo login option
            demoLoginSection
        }
    }
    
    private var availableFaceIDSection: some View {
        VStack(spacing: AppConstants.Spacing.lg) {
            // Face ID Button
            Button(action: {
                authService.authenticateWithFaceID()
            }) {
                HStack(spacing: AppConstants.Spacing.md) {
                    Image(systemName: "faceid")
                        .font(.system(size: 24, weight: .medium))
                    
                    Text("Sign in with Face ID")
                        .font(AppConstants.Typography.titleLarge)
                        .fontWeight(.semibold)
                }
                .foregroundColor(AppConstants.Colors.primary)
                .frame(maxWidth: .infinity)
                .frame(height: AppConstants.Layout.buttonHeight + 8)
                .background(
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.large)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.large)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .disabled(authService.isAuthenticating)
            .scaleEffect(authService.isAuthenticating ? 0.98 : 1.0)
            .animation(AppConstants.Animation.smooth, value: authService.isAuthenticating)
            
            // Loading state
            if authService.isAuthenticating {
                HStack(spacing: AppConstants.Spacing.sm) {
                    LoadingView(style: .spinner)
                    Text("Authenticating...")
                        .font(AppConstants.Typography.bodyMedium)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
    
    private var unavailableFaceIDSection: some View {
        CardView(style: .glass, padding: AppConstants.Spacing.lg) {
            VStack(spacing: AppConstants.Spacing.md) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.orange)
                
                Text("Face ID Not Available")
                    .font(AppConstants.Typography.titleLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Please set up Face ID in Settings to use this app")
                    .font(AppConstants.Typography.bodyMedium)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var demoLoginSection: some View {
        VStack(spacing: AppConstants.Spacing.sm) {
            // Divider with text
            HStack {
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 1)
                
                Text("or")
                    .font(AppConstants.Typography.labelMedium)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, AppConstants.Spacing.md)
                
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 1)
            }
            
            // Demo button
            Button(action: {
                // Add haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                // For demo purposes, bypass Face ID
                authService.isAuthenticated = true
            }) {
                Text("Demo Login")
                    .font(AppConstants.Typography.titleMedium)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                    .underline()
            }
        }
    }
    
    private var footerSection: some View {
        VStack(spacing: AppConstants.Spacing.xs) {
            HStack(spacing: AppConstants.Spacing.sm) {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: 14))
                
                Text("Secure • Fast • Simple")
                    .font(AppConstants.Typography.labelMedium)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text("No passwords needed")
                .font(AppConstants.Typography.labelSmall)
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    private func animateEntry() {
        withAnimation(AppConstants.Animation.smooth.delay(0.2)) {
            logoScale = 1.0
        }
        
        withAnimation(AppConstants.Animation.fadeIn.delay(0.4)) {
            contentOpacity = 1.0
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationService())
} 