import SwiftUI
import PhotosUI

struct ProviderProfileView: View {
    let provider: Provider
    var onMessage: (() -> Void)? = nil
    var onCall: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var showingFullBio = false

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero Section with Gradient Background
                        heroSection(geometry: geometry)
                        
                        // Content Section
                        contentSection
                    }
                }
                .ignoresSafeArea(edges: .top)
            }
            .navigationBarHidden(true)
            .overlay(alignment: .topTrailing) {
                // Modern close button
                IconButton(icon: "xmark", style: .ghost, size: .medium) {
                    dismiss()
                }
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .padding(AppConstants.Spacing.md)
            }
        }
    }
    
    private func heroSection(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            AppConstants.Colors.primaryGradient
                .frame(height: geometry.size.height * 0.4)
            
            // Content
            VStack(spacing: AppConstants.Spacing.lg) {
                Spacer()
                
                // Profile Image
                AvatarView(
                    imageURL: provider.profileImageURL,
                    name: provider.name,
                    size: .extraLarge,
                    status: provider.isAvailable ? .online : .offline
                )
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                // Basic Info
                VStack(spacing: AppConstants.Spacing.sm) {
                    Text(provider.name)
                        .font(AppConstants.Typography.headlineMedium)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: AppConstants.Spacing.sm) {
                        if !provider.categories.isEmpty {
                            ForEach(provider.categories.prefix(2), id: \.self) { category in
                                BadgeView(text: category, style: .secondary)
                            }
                        }
                    }
                    
                    // Rating
                    HStack(spacing: AppConstants.Spacing.xs) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(provider.rating) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.system(size: 16))
                        }
                        Text(String(format: "%.1f", provider.rating))
                            .font(AppConstants.Typography.titleMedium)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Text("(\(provider.reviewCount) reviews)")
                            .font(AppConstants.Typography.labelMedium)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
            }
            .padding(AppConstants.Spacing.screenPadding)
        }
    }
    
    private var contentSection: some View {
        VStack(spacing: AppConstants.Spacing.lg) {
            // Action Buttons
            actionButtonsSection
                .padding(.horizontal, AppConstants.Spacing.screenPadding)
                .padding(.top, AppConstants.Spacing.lg)
            
            // Quick Info Cards
            quickInfoSection
                .padding(.horizontal, AppConstants.Spacing.screenPadding)
            
            // Services Section
            if !provider.services.isEmpty {
                servicesSection
                    .padding(.horizontal, AppConstants.Spacing.screenPadding)
            }
            
            // Bio Section
            if !provider.bio.isEmpty {
                bioSection
                    .padding(.horizontal, AppConstants.Spacing.screenPadding)
            }
            
            // Contact Section
            contactSection
                .padding(.horizontal, AppConstants.Spacing.screenPadding)
                .padding(.bottom, AppConstants.Spacing.xxxl)
        }
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: AppConstants.Spacing.md) {
            ModernButton(
                title: "Call",
                icon: "phone.fill",
                style: .primary,
                size: .large
            ) {
                onCall?()
                dismiss()
            }
            
            ModernButton(
                title: "Message",
                icon: "message.fill",
                style: .secondary,
                size: .large
            ) {
                onMessage?()
                dismiss()
            }
        }
    }
    
    private var quickInfoSection: some View {
        HStack(spacing: AppConstants.Spacing.md) {
            // Rate Card
            CardView(style: .elevated) {
                VStack(spacing: AppConstants.Spacing.xs) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(AppConstants.Colors.success)
                            .font(.system(size: 20))
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.xxs) {
                        Text("$\(provider.hourlyRate)/hr")
                            .font(AppConstants.Typography.titleLarge)
                            .fontWeight(.bold)
                            .foregroundColor(AppConstants.Colors.text)
                        Text("Hourly Rate")
                            .font(AppConstants.Typography.labelMedium)
                            .foregroundColor(AppConstants.Colors.textSecondary)
                    }
                }
            }
            
            // Availability Card
            CardView(style: .elevated) {
                VStack(spacing: AppConstants.Spacing.xs) {
                    HStack {
                        StatusIndicator(status: provider.isAvailable ? .online : .offline)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.xxs) {
                        Text(provider.isAvailable ? "Available" : "Busy")
                            .font(AppConstants.Typography.titleLarge)
                            .fontWeight(.bold)
                            .foregroundColor(AppConstants.Colors.text)
                        Text("Status")
                            .font(AppConstants.Typography.labelMedium)
                            .foregroundColor(AppConstants.Colors.textSecondary)
                    }
                }
            }
        }
    }
    
    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
            SectionHeader(
                title: "Services",
                subtitle: "What \(provider.name) offers"
            )
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppConstants.Spacing.sm) {
                ForEach(provider.services) { service in
                    ServiceCard(service: service)
                }
            }
        }
    }
    
    private var bioSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
            SectionHeader(
                title: "About",
                subtitle: "Get to know \(provider.name)"
            )
            
            CardView(style: .elevated) {
                VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                    Text(showingFullBio ? provider.bio : String(provider.bio.prefix(150)) + (provider.bio.count > 150 ? "..." : ""))
                        .font(AppConstants.Typography.bodyMedium)
                        .foregroundColor(AppConstants.Colors.text)
                        .lineSpacing(2)
                    
                    if provider.bio.count > 150 {
                        Button(action: { showingFullBio.toggle() }) {
                            Text(showingFullBio ? "Show less" : "Read more")
                                .font(AppConstants.Typography.labelLarge)
                                .fontWeight(.medium)
                                .foregroundColor(AppConstants.Colors.primary)
                        }
                    }
                }
            }
        }
    }
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
            SectionHeader(
                title: "Contact Info",
                subtitle: "How to reach \(provider.name)"
            )
            
            CardView(style: .elevated) {
                VStack(spacing: AppConstants.Spacing.md) {
                    if let location = provider.location {
                        ContactInfoRow(
                            icon: "location.circle.fill",
                            iconColor: AppConstants.Colors.error,
                            title: "Location",
                            subtitle: "\(String(format: "%.4f", location.latitude)), \(String(format: "%.4f", location.longitude))"
                        )
                    }
                    
                    ContactInfoRow(
                        icon: "calendar.circle.fill",
                        iconColor: AppConstants.Colors.info,
                        title: "Member Since",
                        subtitle: formatDate(provider.joinDate)
                    )
                    
                    if provider.isVerified {
                        ContactInfoRow(
                            icon: "checkmark.seal.fill",
                            iconColor: AppConstants.Colors.success,
                            title: "Verified Provider",
                            subtitle: "Identity and skills verified"
                        )
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Service Card Component
struct ServiceCard: View {
    let service: Service
    
    var body: some View {
        CardView(style: .flat, padding: AppConstants.Spacing.md) {
            VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
                HStack {
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .foregroundColor(AppConstants.Colors.primary)
                        .font(.system(size: 16))
                    Spacer()
                }
                
                Text(service.name)
                    .font(AppConstants.Typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(AppConstants.Colors.text)
                    .lineLimit(2)
                
                if !service.description.isEmpty {
                    Text(service.description)
                        .font(AppConstants.Typography.bodySmall)
                        .foregroundColor(AppConstants.Colors.textSecondary)
                        .lineLimit(3)
                }
            }
        }
    }
}

// MARK: - Contact Info Row Component
struct ContactInfoRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: AppConstants.Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 20))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: AppConstants.Spacing.xxs) {
                Text(title)
                    .font(AppConstants.Typography.titleMedium)
                    .fontWeight(.medium)
                    .foregroundColor(AppConstants.Colors.text)
                
                Text(subtitle)
                    .font(AppConstants.Typography.bodyMedium)
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Modern Profile Edit View
struct ProviderProfileEditView: View {
    @State private var profileImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var bio: String = ""
    @State private var skills: String = ""
    @State private var categories: String = ""
    @State private var hourlyRate: String = ""
    @State private var isAvailable: Bool = true
    @Environment(\.dismiss) private var dismiss
    var onSave: ((Provider) -> Void)? = nil

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppConstants.Spacing.xl) {
                    // Profile Image Section
                    profileImageSection
                    
                    // Form Fields
                    formFieldsSection
                    
                    // Settings Section
                    settingsSection
                    
                    // Save Button
                    saveButtonSection
                }
                .padding(.horizontal, AppConstants.Spacing.screenPadding)
                .padding(.vertical, AppConstants.Spacing.lg)
            }
            .background(AppConstants.Colors.background)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    IconButton(icon: "xmark", style: .ghost, size: .medium) {
                        dismiss()
                    }
                }
            })
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $profileImage)
            }
        }
    }
    
    private var profileImageSection: some View {
        VStack(spacing: AppConstants.Spacing.md) {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        ZStack {
                            Circle()
                                .fill(AppConstants.Colors.primaryGradient)
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(AppConstants.Colors.primary.opacity(0.2), lineWidth: 3)
                )
                .shadow(color: AppConstants.Shadow.lg.color, radius: AppConstants.Shadow.lg.radius, x: 0, y: 4)
                
                IconButton(icon: "camera.fill", style: .primary, size: .small) {
                    showImagePicker = true
                }
                .offset(x: 8, y: 8)
            }
            
            Text("Profile Photo")
                .font(AppConstants.Typography.labelMedium)
                .foregroundColor(AppConstants.Colors.textSecondary)
        }
        .padding(.top, AppConstants.Spacing.lg)
    }
    
    private var formFieldsSection: some View {
        VStack(spacing: AppConstants.Spacing.lg) {
            SectionHeader(title: "Basic Information")
            
            VStack(spacing: AppConstants.Spacing.md) {
                ModernTextField(title: "Name", text: $name, icon: "person.fill")
                ModernTextField(title: "Email", text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
                ModernTextField(title: "Bio", text: $bio, icon: "quote.bubble.fill", isMultiline: true)
                ModernTextField(title: "Skills (comma separated)", text: $skills, icon: "star.fill")
                ModernTextField(title: "Categories (comma separated)", text: $categories, icon: "tag.fill")
                ModernTextField(title: "Hourly Rate", text: $hourlyRate, icon: "dollarsign.circle.fill", keyboardType: .decimalPad)
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(spacing: AppConstants.Spacing.lg) {
            SectionHeader(title: "Settings")
            
            CardView(style: .elevated) {
                Toggle(isOn: $isAvailable) {
                    HStack(spacing: AppConstants.Spacing.md) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(isAvailable ? AppConstants.Colors.success : AppConstants.Colors.textSecondary)
                            .font(.system(size: 20))
                        
                        VStack(alignment: .leading, spacing: AppConstants.Spacing.xxs) {
                            Text("Available for work")
                                .font(AppConstants.Typography.titleMedium)
                                .fontWeight(.medium)
                                .foregroundColor(AppConstants.Colors.text)
                            
                            Text("Show as available to clients")
                                .font(AppConstants.Typography.bodySmall)
                                .foregroundColor(AppConstants.Colors.textSecondary)
                        }
                        
                        Spacer()
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: AppConstants.Colors.primary))
            }
        }
    }
    
    private var saveButtonSection: some View {
        ModernButton(
            title: "Save Profile",
            icon: "checkmark.circle.fill",
            style: .primary,
            size: .large
        ) {
            saveProfile()
        }
        .padding(.top, AppConstants.Spacing.md)
    }

    private func saveProfile() {
        // Convert skills and categories to arrays
        let skillsArray = skills.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let categoriesArray = categories.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let rate = Double(hourlyRate) ?? 0.0
        
        let provider = Provider(
            id: UUID().uuidString,
            name: name,
            categories: categoriesArray,
            bio: bio,
            profileImageURL: "",
            hourlyRate: Int(rate),
            rating: 5.0,
            reviewCount: 0,
            isAvailable: isAvailable,
            location: nil,
            skills: skillsArray,
            services: [],
            isVerified: false,
            joinDate: Date()
        )
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        onSave?(provider)
        dismiss()
    }
}

// MARK: - Modern Text Field Component
struct ModernTextField: View {
    let title: String
    @Binding var text: String
    var icon: String? = nil
    var isMultiline: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
            HStack(spacing: AppConstants.Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(AppConstants.Colors.primary)
                        .font(.system(size: 14))
                }
                Text(title)
                    .font(AppConstants.Typography.labelMedium)
                    .fontWeight(.medium)
                    .foregroundColor(AppConstants.Colors.text)
            }
            
            if isMultiline {
                TextEditor(text: $text)
                    .frame(minHeight: 80, maxHeight: 120)
                    .padding(AppConstants.Spacing.sm)
                    .background(AppConstants.Colors.secondaryBackground)
                    .cornerRadius(AppConstants.CornerRadius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.md)
                            .stroke(AppConstants.Colors.primary.opacity(0.2), lineWidth: 1)
                    )
            } else {
                TextField(title, text: $text)
                    .keyboardType(keyboardType)
                    .font(AppConstants.Typography.bodyMedium)
                    .padding(AppConstants.Spacing.md)
                    .background(AppConstants.Colors.secondaryBackground)
                    .cornerRadius(AppConstants.CornerRadius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.md)
                            .stroke(AppConstants.Colors.primary.opacity(0.2), lineWidth: 1)
                    )
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
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
