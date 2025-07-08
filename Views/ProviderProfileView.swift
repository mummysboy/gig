import SwiftUI

struct ProviderProfileView: View {
    let provider: Provider
    var onMessage: (() -> Void)? = nil
    var onCall: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    
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
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            })
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

                // Show all categories as a comma-separated list
                if !provider.categories.isEmpty {
                    Text(provider.categories.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

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
        let urlString = provider.profileImageURL
        if !urlString.isEmpty, 
           let url = URL(string: urlString),
           url.scheme != nil {
            return AnyView(
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                }
                .onAppear {
                    print("[ProviderProfileView] Loading profile image for \(provider.name) from: \(url)")
                }
            )
        }
        return AnyView(
            Image(systemName: "person.circle.fill")
                .resizable()
                .foregroundColor(.gray)
                .onAppear {
                    print("[ProviderProfileView] Using fallback image for \(provider.name). URL was: \(urlString)")
                }
        )
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Call button
            Button(action: {
                onCall?()
                dismiss()
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
                onMessage?()
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

    // Mock reviews for display
    private var providerReviews: [ProviderReview]? {
        // Replace with real data source if available
        return [
            ProviderReview(reviewerName: "Sarah M.", rating: 5, text: "Excellent service! Very professional and completed the work on time. Highly recommend!", dateString: "July 4, 2025")
        ]
    }
}

struct ProviderReview: Identifiable {
    let id = UUID()
    let reviewerName: String
    let rating: Int
    let text: String
    let dateString: String
}

#Preview {
    ProviderProfileView(provider: Provider.sampleData.first!)
} 

// MARK: - Provider Profile Creation/Edit View
struct ProviderProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var profileImageURL: String = ""
    @State private var isAvailable: Bool = true
    @State private var selectedCategories: [String] = []
    @State private var services: [Service] = []
    @State private var hourlyRate: String = ""
    @State private var showCategoryPicker = false
    @State private var newServiceName: String = ""
    @State private var newServiceDescription: String = ""
    @State private var newServiceHourlyRate: String = ""
    @State private var newServiceFlatRate: String = ""
    @State private var showAddServiceSheet = false
    @State private var errorMessage: String?
    @StateObject private var aiService = AIService()

    var onSave: ((Provider) -> Void)? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppConstants.Spacing.lg) {
                    // Profile Header Card
                    CardView {
                        VStack(spacing: AppConstants.Spacing.md) {
                            // Profile image
                            if !profileImageURL.isEmpty, let url = URL(string: profileImageURL), url.scheme != nil {
                                AsyncImage(url: url) { image in
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "person.circle.fill").resizable().foregroundColor(.gray)
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(AppConstants.Colors.primary, lineWidth: 3))
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(AppConstants.Colors.primary, lineWidth: 3))
                            }
                            TextField("Name", text: $name)
                                .font(AppConstants.Fonts.title2.weight(.bold))
                                .multilineTextAlignment(.center)
                            TextField("Bio", text: $bio)
                                .font(AppConstants.Fonts.body)
                                .foregroundColor(AppConstants.Colors.secondaryText)
                                .multilineTextAlignment(.center)
                            Toggle("Available for work", isOn: $isAvailable)
                                .toggleStyle(SwitchToggleStyle(tint: AppConstants.Colors.primary))
                        }
                    }
                    // Categories Card
                    CardView {
                        VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
                            SectionHeader(title: "Categories")
                            Button(action: { showCategoryPicker = true }) {
                                HStack {
                                    Text(selectedCategories.isEmpty ? "Select Categories" : selectedCategories.joined(separator: ", "))
                                        .foregroundColor(selectedCategories.isEmpty ? .secondary : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    // Services Card
                    CardView {
                        VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
                            SectionHeader(title: "Services & Pricing")
                            ForEach(services.indices, id: \.self) { i in
                                CardView {
                                    VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                                        TextField("Service Name", text: $services[i].name)
                                            .font(AppConstants.Fonts.headline)
                                        ZStack(alignment: .trailing) {
                                            TextField("Description", text: $services[i].description)
                                                .font(AppConstants.Fonts.subheadline)
                                                .foregroundColor(AppConstants.Colors.secondaryText)
                                            if services[i].isEnhancing {
                                                ProgressView().padding(.trailing, 8)
                                            } else {
                                                ModernButton(title: "Enhance with AI", icon: "sparkles", color: AppConstants.Colors.primary) {
                                                    enhanceServiceWithAI(index: i)
                                                }
                                                .frame(maxWidth: 180)
                                                .padding(.trailing, 8)
                                            }
                                        }
                                        if let enhanced = services[i].enhancedDescription, services[i].isShowingEnhanced {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("AI Suggestion:")
                                                    .font(AppConstants.Fonts.caption)
                                                    .foregroundColor(.teal)
                                                Text(enhanced)
                                                    .font(AppConstants.Fonts.subheadline)
                                                    .foregroundColor(.primary)
                                                HStack(spacing: 12) {
                                                    ModernButton(title: "Keep", icon: "checkmark", color: .green) {
                                                        keepAISuggestion(index: i)
                                                    }
                                                    ModernButton(title: "Undo", icon: "arrow.uturn.backward", color: .gray) {
                                                        undoAISuggestion(index: i)
                                                    }
                                                }
                                            }
                                        }
                                        if let error = services[i].enhancementError {
                                            Text(error)
                                                .font(AppConstants.Fonts.caption)
                                                .foregroundColor(.red)
                                        }
                                        HStack(spacing: 16) {
                                            Text("$\(String(format: "%.2f", services[i].hourlyRate))/hr")
                                                .font(AppConstants.Fonts.caption)
                                                .foregroundColor(.teal)
                                            if let flat = services[i].flatRate {
                                                Text("$\(String(format: "%.2f", flat)) flat")
                                                    .font(AppConstants.Fonts.caption)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                }
                                .padding(.bottom, AppConstants.Spacing.sm)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        services.remove(at: i)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            ModernButton(title: "Add Service", icon: "plus", color: AppConstants.Colors.primary) {
                                showAddServiceSheet = true
                            }
                        }
                    }
                    if let error = errorMessage {
                        CardView {
                            Text(error)
                                .foregroundColor(.red)
                                .font(AppConstants.Fonts.body)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Edit Profile")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveProfile() }
                        .disabled(!canSave)
                }
            })
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(selected: $selectedCategories)
            }
            .sheet(isPresented: $showAddServiceSheet) {
                NavigationView {
                    Form {
                        Section(header: Text("Service Info")) {
                            TextField("Service Name", text: $newServiceName)
                            TextField("Description", text: $newServiceDescription)
                            TextField("Hourly Rate", text: $newServiceHourlyRate)
                                .keyboardType(.decimalPad)
                            TextField("Flat Rate (optional)", text: $newServiceFlatRate)
                                .keyboardType(.decimalPad)
                        }
                    }
                    .navigationTitle("Add Service")
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") { showAddServiceSheet = false }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Add") { addService() }
                                .disabled(newServiceName.isEmpty || newServiceHourlyRate.isEmpty)
                        }
                    })
                }
            }
        }
    }

    private var canSave: Bool {
        !name.isEmpty && !selectedCategories.isEmpty && !services.isEmpty
    }

    private func saveProfile() {
        guard let hourly = Double(hourlyRate.isEmpty ? "0" : hourlyRate) else {
            errorMessage = "Invalid hourly rate."
            return
        }
        let provider = Provider(
            name: name,
            categories: selectedCategories,
            bio: bio,
            profileImageURL: profileImageURL,
            hourlyRate: Int(hourly),
            rating: 0.0,
            reviewCount: 0,
            isAvailable: isAvailable,
            services: services
        )
        // Add to provider pool (in-memory for now)
        Provider.addToPool(provider)
        onSave?(provider)
        dismiss()
    }

    private func addService() {
        guard let hourly = Double(newServiceHourlyRate) else { return }
        let flat = Double(newServiceFlatRate)
        let service = Service(
            name: newServiceName,
            description: newServiceDescription,
            hourlyRate: hourly,
            flatRate: flat
        )
        services.append(service)
        newServiceName = ""
        newServiceDescription = ""
        newServiceHourlyRate = ""
        newServiceFlatRate = ""
        showAddServiceSheet = false
    }

    // --- AI Enhancement Logic ---
    private func enhanceServiceWithAI(index: Int) {
        guard services.indices.contains(index) else { return }
        services[index].isEnhancing = true
        services[index].enhancementError = nil
        let name = services[index].name
        let desc = services[index].description
        services[index].originalDescription = desc
        Task {
            struct CategoryPickerView: View {
                @Environment(\.dismiss) private var dismiss
                @Binding var selected: [String]
                var allCategories: [String] = Provider.availableCategories

                var body: some View {
                    NavigationView {
                        List {
                            ForEach(allCategories, id: \.self) { category in
                                HStack {
                                    Text(category)
                                    Spacer()
                                    if selected.contains(category) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.teal)
                                    }
                                }
                                .contentShape(Rectangle()) // makes the whole row tappable
                                .onTapGesture {
                                    toggle(category)
                                }
                            }
                        }
                        .navigationTitle("Select Categories")
                        .listStyle(.insetGrouped)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Cancel") { dismiss() }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") { dismiss() }
                            }
                        }
                    }
                }

                private func toggle(_ category: String) {
                    if let index = selected.firstIndex(of: category) {
                        selected.remove(at: index)
                    } else {
                        selected.append(category)
                    }
                }
            }
            do {
                let enhanced = try await aiService.enhanceServiceDescription(name: name, description: desc)
                services[index].enhancedDescription = enhanced
                services[index].isShowingEnhanced = true
            } catch {
                services[index].enhancementError = error.localizedDescription
            }
            services[index].isEnhancing = false
        }
    }
    private func keepAISuggestion(index: Int) {
        guard services.indices.contains(index), let enhanced = services[index].enhancedDescription else { return }
        services[index].description = enhanced
        services[index].isShowingEnhanced = false
        services[index].enhancedDescription = nil
        services[index].originalDescription = nil
        services[index].enhancementError = nil
    }
    private func undoAISuggestion(index: Int) {
        guard services.indices.contains(index), let original = services[index].originalDescription else { return }
        services[index].description = original
        services[index].isShowingEnhanced = false
        services[index].enhancedDescription = nil
        services[index].originalDescription = nil
        services[index].enhancementError = nil
    }
}

// MARK: - Category Picker
struct CategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selected: [String]
    var allCategories: [String] = Provider.availableCategories

    var body: some View {
        NavigationView {
            List {
                ForEach(allCategories, id: \.self) { category in
                    HStack {
                        Text(category)
                        Spacer()
                        if selected.contains(category) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.teal)
                        }
                    }
                    .contentShape(Rectangle()) // makes the whole row tappable
                    .onTapGesture {
                        toggle(category)
                    }
                }
            }
            .navigationTitle("Select Categories")
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func toggle(_ category: String) {
        if let index = selected.firstIndex(of: category) {
            selected.remove(at: index)
        } else {
            selected.append(category)
        }
    }
}




// MARK: - Provider Pool Add Helper
extension Provider {
    static func addToPool(_ provider: Provider) {
        // In a real app, this would save to a backend or persistent store
        // For demo, append to sampleData (if not already present)
        if !sampleData.contains(where: { $0.id == provider.id }) {
            sampleData.append(provider)
        }
    }
} 
