import Foundation
import CallKit
import PushKit
import AVFoundation

class CallService: NSObject, ObservableObject {
    @Published var isInCall = false
    @Published var currentCall: Call?
    @Published var callDuration: TimeInterval = 0
    
    private var callController = CXCallController()
    private var callProvider: CXProvider
    private var callUpdate = CXCallUpdate()
    private var timer: Timer?
    private var activeCallUUID: UUID?
    
    override init() {
        let providerConfiguration = CXProviderConfiguration(localizedName: "Gig")
        providerConfiguration.supportsVideo = false
        providerConfiguration.maximumCallGroups = 1
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportedHandleTypes = [.generic]
        
        callProvider = CXProvider(configuration: providerConfiguration)
        
        super.init()
        callProvider.setDelegate(self, queue: nil)
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func startCall(with provider: Provider) {
        let callUUID = UUID()
        activeCallUUID = callUUID
        
        let handle = CXHandle(type: .generic, value: provider.id)
        let startCallAction = CXStartCallAction(call: callUUID, handle: handle)
        startCallAction.isVideo = false
        
        let transaction = CXTransaction(action: startCallAction)
        
        callController.request(transaction) { [weak self] error in
            if let error = error {
                print("Error starting call: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.activeCallUUID = nil
                }
            } else {
                DispatchQueue.main.async {
                    self?.isInCall = true
                    self?.currentCall = Call(
                        id: callUUID.uuidString,
                        providerName: provider.name,
                        providerId: provider.id,
                        status: .ongoing
                    )
                    self?.startCallTimer()
                }
            }
        }
    }
    
    func endCall() {
        guard let callUUID = activeCallUUID else { 
            // Fallback: try to clean up local state even if no UUID
            cleanupCallState()
            return 
        }
        
        let endCallAction = CXEndCallAction(call: callUUID)
        let transaction = CXTransaction(action: endCallAction)
        
        callController.request(transaction) { [weak self] error in
            if let error = error {
                print("Error ending call: \(error.localizedDescription)")
            }
            // Always clean up state regardless of CallKit result
            DispatchQueue.main.async {
                self?.cleanupCallState()
            }
        }
    }
    
    private func cleanupCallState() {
        stopCallTimer()
        isInCall = false
        currentCall = nil
        activeCallUUID = nil
    }
    
    private func startCallTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.callDuration += 1
            }
        }
    }
    
    private func stopCallTimer() {
        timer?.invalidate()
        timer = nil
        callDuration = 0
    }
    
    func formatCallDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - CXProviderDelegate
extension CallService: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        // Handle provider reset
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // Handle start call action
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // Handle end call action
        DispatchQueue.main.async {
            self.cleanupCallState()
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        // Handle hold call action
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        // Handle mute call action
        action.fulfill()
    }
} 