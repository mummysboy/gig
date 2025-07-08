import Foundation
import LocalAuthentication
import SwiftUI

class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isAuthenticating = false
    @Published var authenticationError: String?
    
    private let context = LAContext()
    
    init() {
        // Check if user was previously authenticated
        checkAuthenticationStatus()
    }
    
    func authenticateWithFaceID() {
        isAuthenticating = true
        authenticationError = nil
        
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Log in to Gig securely with Face ID"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
                DispatchQueue.main.async {
                    self?.isAuthenticating = false
                    
                    if success {
                        self?.isAuthenticated = true
                        self?.saveAuthenticationState()
                    } else {
                        if let error = error {
                            self?.authenticationError = self?.getAuthenticationErrorMessage(error)
                        } else {
                            self?.authenticationError = "Authentication failed"
                        }
                    }
                }
            }
        } else {
            isAuthenticating = false
            authenticationError = getAuthenticationErrorMessage(error)
        }
    }
    
    func signOut() {
        isAuthenticated = false
        clearAuthenticationState()
    }
    
    private func checkAuthenticationStatus() {
        // In a real app, you would check for a valid session token
        // For demo purposes, we'll start with not authenticated
        isAuthenticated = false
    }
    
    private func saveAuthenticationState() {
        // Save authentication state to UserDefaults or Keychain
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
    }
    
    private func clearAuthenticationState() {
        // Clear authentication state
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
    }
    
    private func getAuthenticationErrorMessage(_ error: Error?) -> String {
        guard let error = error as? LAError else {
            return "Authentication failed"
        }
        
        switch error.code {
        case .userCancel:
            return "Authentication was cancelled"
        case .userFallback:
            return "Authentication method not available"
        case .biometryNotAvailable:
            return "Face ID is not available on this device"
        case .biometryNotEnrolled:
            return "Face ID is not set up on this device"
        case .biometryLockout:
            return "Face ID is locked. Please try again later"
        default:
            return "Authentication failed: \(error.localizedDescription)"
        }
    }
    
    var isFaceIDAvailable: Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
} 