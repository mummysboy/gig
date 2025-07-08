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
    
    func startCall(with provider: Provider) {
        let handle = CXHandle(type: .generic, value: provider.id)
        let startCallAction = CXStartCallAction(call: UUID(), handle: handle)
        startCallAction.isVideo = false
        
        let transaction = CXTransaction(action: startCallAction)
        
        callController.request(transaction) { [weak self] error in
            if let error = error {
                print("Error starting call: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.isInCall = true
                    self?.currentCall = Call(
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
        guard let callUUID = currentCall?.id else { return }
        
        let endCallAction = CXEndCallAction(call: UUID(uuidString: callUUID) ?? UUID())
        let transaction = CXTransaction(action: endCallAction)
        
        callController.request(transaction) { [weak self] error in
            if let error = error {
                print("Error ending call: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.stopCallTimer()
                    self?.isInCall = false
                    self?.currentCall = nil
                }
            }
        }
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
            self.stopCallTimer()
            self.isInCall = false
            self.currentCall = nil
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