import SwiftUI

struct ProviderProfileView: View {
    let provider: Provider
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with profile image and basic info
                    headerSection
                    
                    // Action buttons
                    actionButtonsSection
                    
                    // Services
                    servicesSection
                    
                    // Bio and details
                    detailsSection
                    
                    // Contact and location
                    contactSection
                }
            }
            .navigationTitle(provider.name)
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Profile image
            profileImage
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.teal, lineWidth: 3)
                )

            // Name and services
            VStack(spacing: 8) {
                Text(provider.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(provider.services.map { $0.name }.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.2f", provider.rating))
                        .fontWeight(.semibold)
                    Text("(\(provider.reviewCount) reviews)")
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
            }

            // Availability status
            HStack {
                Circle()
                    .fill(provider.isAvailable ? Color.green : Color.red)
                    .frame(width: 8, height: 8)

                Text(provider.isAvailable ? "Available" : "Busy")
                    .font(.caption)
                    .foregroundColor(provider.isAvailable ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private var profileImage: some View {
        if let urlString = provider.profileImageURL, !urlString.isEmpty {
            if let url = URL(string: urlString) {
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
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Call button
            Button(action: {
                // Handle call action
            }) {
                HStack {
                    Image(systemName: "phone.fill")
                    Text("Call \(provider.name)")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.teal)
                .cornerRadius(12)
            }
            
            // Message button
            Button(action: {
                navigationCoordinator.startConversation(with: provider)
                dismiss()
            }) {
                HStack {
                    Image(systemName: "message.fill")
                    Text("Send Message")
                        .fontWeight(.medium)
                }
                .foregroundColor(.teal)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.teal.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
    
    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Services")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            ForEach(provider.services) { service in
                VStack(alignment: .leading, spacing: 8) {
                    Text(service.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    if !service.description.isEmpty {
                        Text(service.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(nil)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Hourly rate
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.teal)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hourly Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(String(format: "%.2f", provider.hourlyRate))/hour")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                Spacer()
            }
            
            // Bio
            if !provider.bio.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(provider.bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var contactSection: some View {
        HStack {
            Image(systemName: "location.circle.fill")
                .foregroundColor(.teal)
            VStack(alignment: .leading, spacing: 2) {
                Text("Current Location")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if let location = provider.location {
                    Text("\(String(format: "%.4f", location.latitude)), \(String(format: "%.4f", location.longitude))")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                } else {
                    Text("No location")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    ProviderProfileView(provider: Provider.sampleData.first!)
} 
