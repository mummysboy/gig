import SwiftUI

struct FeedbackView: View {
    let provider: Provider
    @Environment(\.dismiss) private var dismiss
    @State private var rating: Int = 0
    @State private var reviewText = ""
    @State private var selectedCategories: Set<String> = []
    @State private var isSubmitting = false
    
    let feedbackCategories = [
        "Professionalism",
        "Quality of Work",
        "Communication",
        "Punctuality",
        "Value for Money",
        "Overall Experience"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Provider info
                    providerInfoSection
                    
                    // Rating section
                    ratingSection
                    
                    // Categories section
                    categoriesSection
                    
                    // Review text section
                    reviewTextSection
                    
                    // Submit button
                    submitButton
                }
                .padding()
            }
            .navigationTitle("Rate Your Experience")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var providerInfoSection: some View {
        HStack(spacing: 16) {
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
                        .foregroundColor(.gray)
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .onAppear {
                    print("[FeedbackView] Loading provider image from: \(url)")
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .onAppear {
                        print("[FeedbackView] Using fallback image. URL was: \(provider.profileImageURL)")
                    }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(provider.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(provider.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var ratingSection: some View {
        VStack(spacing: 16) {
            Text("How would you rate your experience?")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Button(action: {
                        rating = star
                    }) {
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(.title)
                            .foregroundColor(star <= rating ? .yellow : .gray)
                    }
                }
            }
            
            if rating > 0 {
                Text(ratingText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What went well? (Select all that apply)")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(feedbackCategories, id: \.self) { category in
                    Button(action: {
                        if selectedCategories.contains(category) {
                            selectedCategories.remove(category)
                        } else {
                            selectedCategories.insert(category)
                        }
                    }) {
                        Text(category)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedCategories.contains(category) ? Color.teal : Color(.systemGray5))
                            .foregroundColor(selectedCategories.contains(category) ? .white : .primary)
                            .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var reviewTextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Additional comments (optional)")
                .font(.headline)
            if #available(iOS 16.0, *) {
                TextField("Share your experience...", text: $reviewText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
            } else {
                TextField("Share your experience...", text: $reviewText)
                    .textFieldStyle(.roundedBorder)
                // No axis or ranged lineLimit support before iOS 16
            }
        }
    }
    
    private var submitButton: some View {
        Button(action: submitFeedback) {
            HStack {
                if isSubmitting {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                }
                
                Text(isSubmitting ? "Submitting..." : "Submit Review")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(rating > 0 ? Color.teal : Color.gray)
            .cornerRadius(12)
        }
        .disabled(rating == 0 || isSubmitting)
    }
    
    private var ratingText: String {
        switch rating {
        case 1:
            return "Poor - We're sorry to hear that"
        case 2:
            return "Fair - We'll work to improve"
        case 3:
            return "Good - Thanks for your feedback"
        case 4:
            return "Very Good - We're glad you had a good experience"
        case 5:
            return "Excellent - We're thrilled you loved it!"
        default:
            return ""
        }
    }
    
    private func submitFeedback() {
        isSubmitting = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isSubmitting = false
            dismiss()
            
            // Show success message
            // In a real app, you'd show a toast or alert
        }
    }
}

// MARK: - Quick Rating View
struct QuickRatingView: View {
    let provider: Provider
    @Environment(\.dismiss) private var dismiss
    @State private var rating: Int = 0
    
    var body: some View {
        VStack(spacing: 24) {
            // Provider info
            HStack(spacing: 16) {
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
                            .foregroundColor(.gray)
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .onAppear {
                        print("[QuickRatingView] Loading provider image from: \(url)")
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.gray)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .onAppear {
                            print("[QuickRatingView] Using fallback image. URL was: \(provider.profileImageURL)")
                        }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(provider.name)
                        .font(.headline)
                    
                    Text("How was your experience?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Quick rating
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { star in
                    Button(action: {
                        rating = star
                        submitQuickRating()
                    }) {
                        Image(systemName: "star")
                            .font(.title2)
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private func submitQuickRating() {
        // Submit quick rating
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}

#Preview {
    FeedbackView(provider: Provider.sampleData[0])
} 