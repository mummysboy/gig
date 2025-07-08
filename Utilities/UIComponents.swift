import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        content
            .padding(AppConstants.Spacing.md)
            .background(AppConstants.Colors.secondaryBackground)
            .cornerRadius(AppConstants.CornerRadius.large)
            .shadow(color: AppConstants.Colors.primary.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(AppConstants.Fonts.title3.weight(.bold))
            .foregroundColor(AppConstants.Colors.text)
            .padding(.bottom, AppConstants.Spacing.sm)
    }
}

struct ModernButton: View {
    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(AppConstants.CornerRadius.medium)
        }
        .buttonStyle(PlainButtonStyle())
    }
} 