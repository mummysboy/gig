import SwiftUI
import PhotosUI

struct ProviderProfileView: View {
    let provider: Provider
    var onMessage: (() -> Void)? = nil
    var onCall: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    Divider().padding(.horizontal)
                    actionButtonsSection
                    Divider().padding(.horizontal)
                    servicesSection
                    Divider().padding(.horizontal)
                    detailsSection
                    Divider().padding(.horizontal)
                    contactSection
                }
                .padding(.vertical)
            }
            .navigationTitle(provider.name)
            .navigationBarTitleDisplayMode(.large)
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
        VStack(spacing: 16) {
            profileImage
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.teal, lineWidth: 3))
                .shadow(radius: 4)

            Text(provider.name)
                .font(.title2).fontWeight(.bold)

            if !provider.categories.isEmpty {
                Text(provider.categories.joined(separator: ", "))
                    .font(.subheadline).foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if !provider.services.isEmpty {
                Text(provider.services.map { $0.name }.joined(separator: ", "))
                    .font(.subheadline).foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 4) {
                Image(systemName: "star.fill").foregroundColor(.yellow)
                Text(String(format: "%.2f", provider.rating)).fontWeight(.semibold)
                Text("(\(provider.reviewCount) reviews)").foregroundColor(.secondary)
            }.font(.subheadline)

            Label(provider.isAvailable ? "Available" : "Busy",
                  systemImage: provider.isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.caption)
                .foregroundColor(provider.isAvailable ? .green : .red)
        }
        .padding()
    }

    private var profileImage: some View {
        let urlString = provider.profileImageURL
        if !urlString.isEmpty, let url = URL(string: urlString), url.scheme != nil {
            return AnyView(
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.crop.circle.badge.exclam")
                        .resizable().foregroundColor(.gray)
                }
            )
        }
        return AnyView(
            Image(systemName: "person.crop.circle.badge.exclam")
                .resizable().foregroundColor(.gray)
        )
    }

    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                onCall?()
                dismiss()
            }) {
                Label("Call \(provider.name)", systemImage: "phone.fill")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.teal)
                    .cornerRadius(12)
            }

            Button(action: {
                onMessage?()
                dismiss()
            }) {
                Label("Send Message", systemImage: "message.fill")
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
            Text("Services").font(.headline).fontWeight(.semibold)
                .padding(.horizontal)

            ForEach(provider.services) { service in
                VStack(alignment: .leading, spacing: 8) {
                    Text(service.name).font(.subheadline).fontWeight(.medium)
                    if !service.description.isEmpty {
                        Text(service.description).font(.caption).foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "dollarsign.circle.fill").foregroundColor(.teal)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hourly Rate").font(.caption).foregroundColor(.secondary)
                    Text("$\(String(format: "%.2f", provider.hourlyRate))/hour")
                        .font(.headline).fontWeight(.semibold)
                }
                Spacer()
            }

            if !provider.bio.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("About").font(.headline).fontWeight(.semibold)
                    Text(provider.bio).font(.body).foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var contactSection: some View {
        HStack {
            Image(systemName: "location.circle.fill").foregroundColor(.teal)
            VStack(alignment: .leading, spacing: 2) {
                Text("Current Location").font(.caption).foregroundColor(.secondary)
                if let location = provider.location {
                    Text("\(String(format: "%.4f", location.latitude)), \(String(format: "%.4f", location.longitude))")
                        .font(.subheadline)
                } else {
                    Text("No location").font(.subheadline).foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var providerReviews: [ProviderReview]? {
        return [
            ProviderReview(reviewerName: "Sarah M.", rating: 5, text: "Excellent service! Very professional and completed the work on time. Highly recommend!", dateString: "July 4, 2025")
        ]
    }
}

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
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Image
                    VStack(spacing: 8) {
                        ZStack(alignment: .bottomTrailing) {
                            Group {
                                if let image = profileImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.teal, lineWidth: 3))
                            .shadow(radius: 4)
                            Button(action: { showImagePicker = true }) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 20))
                                    .padding(8)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            .offset(x: 8, y: 8)
                        }
                        Text("Edit Photo")
                            .font(.caption)
                            .foregroundColor(.teal)
                    }
                    .padding(.top, 16)

                    // Editable Fields
                    Group {
                        ProfileEditField(title: "Name", text: $name, icon: "person.fill")
                        ProfileEditField(title: "Email", text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
                        ProfileEditField(title: "Bio", text: $bio, icon: "quote.bubble.fill", isMultiline: true)
                        ProfileEditField(title: "Skills (comma separated)", text: $skills, icon: "star.fill")
                        ProfileEditField(title: "Categories (comma separated)", text: $categories, icon: "tag.fill")
                        ProfileEditField(title: "Hourly Rate", text: $hourlyRate, icon: "dollarsign.circle.fill", keyboardType: .decimalPad)
                        Toggle(isOn: $isAvailable) {
                            Label("Available for work", systemImage: "checkmark.circle.fill")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    // Save Button
                    Button(action: saveProfile) {
                        Text("Save Profile")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.teal)
                            .cornerRadius(14)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            })
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $profileImage)
            }
        }
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
        onSave?(provider)
        dismiss()
    }
}

struct ProfileEditField: View {
    let title: String
    @Binding var text: String
    var icon: String? = nil
    var isMultiline: Bool = false
    var keyboardType: UIKeyboardType = .default
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let icon = icon {
                Label(title, systemImage: icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if isMultiline {
                TextEditor(text: $text)
                    .frame(minHeight: 60, maxHeight: 120)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            } else {
                TextField(title, text: $text)
                    .keyboardType(keyboardType)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
        }
        .padding(.vertical, 4)
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
