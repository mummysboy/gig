import SwiftUI

// MARK: - Modern Card Component
struct CardView<Content: View>: View {
    let content: Content
    var style: CardStyle = .elevated
    var padding: CGFloat = AppConstants.Spacing.cardPadding
    
    enum CardStyle {
        case elevated
        case flat
        case glass
        case outline
    }
    
    init(style: CardStyle = .elevated, padding: CGFloat = AppConstants.Spacing.cardPadding, @ViewBuilder content: () -> Content) {
        self.style = style
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(cardBackground)
            .overlay(cardOverlay)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.CornerRadius.card))
            .shadow(color: shadowColor, radius: shadowRadius, x: shadowOffset.x, y: shadowOffset.y)
    }
    
    @ViewBuilder
    private var cardBackground: some View {
        switch style {
        case .elevated, .flat:
            AppConstants.Colors.cardBackground
        case .glass:
            AppConstants.Colors.glassGradient
                .background(.ultraThinMaterial)
        case .outline:
            Color.clear
        }
    }
    
    @ViewBuilder
    private var cardOverlay: some View {
        switch style {
        case .outline:
            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.card)
                .stroke(AppConstants.Colors.textSecondary.opacity(0.2), lineWidth: 1)
        case .glass:
            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.card)
                .stroke(AppConstants.Colors.glassStroke, lineWidth: 1)
        default:
            EmptyView()
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .elevated:
            return AppConstants.Shadow.md.color
        case .glass:
            return AppConstants.Shadow.lg.color
        default:
            return Color.clear
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .elevated:
            return AppConstants.Shadow.md.radius
        case .glass:
            return AppConstants.Shadow.lg.radius
        default:
            return 0
        }
    }
    
    private var shadowOffset: CGPoint {
        switch style {
        case .elevated:
            return CGPoint(x: AppConstants.Shadow.md.x, y: AppConstants.Shadow.md.y)
        case .glass:
            return CGPoint(x: AppConstants.Shadow.lg.x, y: AppConstants.Shadow.lg.y)
        default:
            return CGPoint(x: 0, y: 0)
        }
    }
}

// MARK: - Modern Button Components
struct ModernButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let size: ButtonSize
    let action: () -> Void
    
    @State private var isPressed = false
    
    enum ButtonStyle {
        case primary
        case secondary
        case tertiary
        case destructive
        case ghost
        case glass
    }
    
    enum ButtonSize {
        case small
        case medium
        case large
        
        var height: CGFloat {
            switch self {
            case .small: return 36
            case .medium: return AppConstants.Layout.buttonHeight
            case .large: return 56
            }
        }
        
        var fontSize: Font {
            switch self {
            case .small: return AppConstants.Typography.labelMedium
            case .medium: return AppConstants.Typography.titleMedium
            case .large: return AppConstants.Typography.titleLarge
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 16
            case .large: return 20
            }
        }
    }
    
    init(title: String, icon: String? = nil, style: ButtonStyle = .primary, size: ButtonSize = .medium, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            action()
        }) {
            HStack(spacing: AppConstants.Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .medium))
                }
                Text(title)
                    .font(size.fontSize)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
            .background(buttonBackground)
            .foregroundColor(textColor)
            .overlay(buttonOverlay)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.CornerRadius.button))
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowRadius / 2)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(AppConstants.Animation.buttonPress, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    @ViewBuilder
    private var buttonBackground: some View {
        switch style {
        case .primary:
            AppConstants.Colors.primaryGradient
        case .secondary:
            AppConstants.Colors.secondaryBackground
        case .tertiary:
            Color.clear
        case .destructive:
            AppConstants.Colors.error
        case .ghost:
            AppConstants.Colors.primary.opacity(0.1)
        case .glass:
            AppConstants.Colors.glassGradient
                .background(.ultraThinMaterial)
        }
    }
    
    @ViewBuilder
    private var buttonOverlay: some View {
        switch style {
        case .tertiary:
            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.button)
                .stroke(AppConstants.Colors.primary, lineWidth: 1.5)
        case .glass:
            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.button)
                .stroke(AppConstants.Colors.glassStroke, lineWidth: 1)
        default:
            EmptyView()
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary:
            return AppConstants.Colors.text
        case .tertiary, .ghost:
            return AppConstants.Colors.primary
        case .glass:
            return AppConstants.Colors.text
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return AppConstants.Shadow.primary.color
        case .destructive:
            return AppConstants.Shadow.error.color
        case .glass:
            return AppConstants.Shadow.lg.color
        default:
            return AppConstants.Shadow.sm.color
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .primary, .destructive:
            return 8
        case .glass:
            return AppConstants.Shadow.lg.radius
        case .tertiary, .ghost:
            return 0
        default:
            return AppConstants.Shadow.sm.radius
        }
    }
}

// MARK: - Icon Button Component
struct IconButton: View {
    let icon: String
    let style: IconButtonStyle
    let size: IconButtonSize
    let action: () -> Void
    
    @State private var isPressed = false
    
    enum IconButtonStyle {
        case primary
        case secondary
        case ghost
        case danger
    }
    
    enum IconButtonSize {
        case small
        case medium
        case large
        
        var dimension: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 44
            case .large: return 56
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 18
            case .large: return 22
            }
        }
    }
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: size.dimension, height: size.dimension)
                .background(backgroundColor)
                .clipShape(Circle())
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowRadius / 2)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(AppConstants.Animation.buttonPress, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return AppConstants.Colors.primary
        case .secondary:
            return AppConstants.Colors.secondaryBackground
        case .ghost:
            return Color.clear
        case .danger:
            return AppConstants.Colors.error
        }
    }
    
    private var iconColor: Color {
        switch style {
        case .primary, .danger:
            return .white
        case .secondary:
            return AppConstants.Colors.text
        case .ghost:
            return AppConstants.Colors.primary
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return AppConstants.Shadow.primary.color
        case .danger:
            return AppConstants.Shadow.error.color
        case .ghost:
            return Color.clear
        default:
            return AppConstants.Shadow.sm.color
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .ghost:
            return 0
        default:
            return 4
        }
    }
}

// MARK: - Modern Badge Component
struct BadgeView: View {
    let text: String
    let style: BadgeStyle
    
    enum BadgeStyle {
        case primary
        case secondary
        case success
        case warning
        case error
        case info
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return AppConstants.Colors.primary
            case .secondary:
                return AppConstants.Colors.textSecondary
            case .success:
                return AppConstants.Colors.success
            case .warning:
                return AppConstants.Colors.warning
            case .error:
                return AppConstants.Colors.error
            case .info:
                return AppConstants.Colors.info
            }
        }
        
        var textColor: Color {
            switch self {
            case .secondary:
                return .white
            default:
                return .white
            }
        }
    }
    
    var body: some View {
        Text(text)
            .font(AppConstants.Typography.labelSmall)
            .fontWeight(.semibold)
            .foregroundColor(style.textColor)
            .padding(.horizontal, AppConstants.Spacing.xs)
            .padding(.vertical, AppConstants.Spacing.xxs)
            .background(style.backgroundColor)
            .clipShape(Capsule())
    }
}

// MARK: - Status Indicator Component
struct StatusIndicator: View {
    let status: Status
    let showLabel: Bool
    
    enum Status {
        case online
        case offline
        case busy
        case away
        
        var color: Color {
            switch self {
            case .online:
                return AppConstants.Colors.online
            case .offline:
                return AppConstants.Colors.offline
            case .busy:
                return AppConstants.Colors.busy
            case .away:
                return AppConstants.Colors.away
            }
        }
        
        var label: String {
            switch self {
            case .online:
                return "Available"
            case .offline:
                return "Offline"
            case .busy:
                return "Busy"
            case .away:
                return "Away"
            }
        }
    }
    
    init(status: Status, showLabel: Bool = false) {
        self.status = status
        self.showLabel = showLabel
    }
    
    var body: some View {
        HStack(spacing: AppConstants.Spacing.xs) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                )
            
            if showLabel {
                Text(status.label)
                    .font(AppConstants.Typography.labelMedium)
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }
        }
    }
}

// MARK: - Modern Avatar Component
struct AvatarView: View {
    let imageURL: String?
    let name: String
    let size: AvatarSize
    let status: StatusIndicator.Status?
    
    enum AvatarSize {
        case small
        case medium
        case large
        case extraLarge
        
        var dimension: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 44
            case .large: return 64
            case .extraLarge: return 96
            }
        }
        
        var fontSize: Font {
            switch self {
            case .small: return AppConstants.Typography.labelMedium
            case .medium: return AppConstants.Typography.titleMedium
            case .large: return AppConstants.Typography.titleLarge
            case .extraLarge: return AppConstants.Typography.headlineSmall
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let imageURL = imageURL,
                   !imageURL.isEmpty,
                   let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        fallbackAvatar
                    }
                } else {
                    fallbackAvatar
                }
            }
            .frame(width: size.dimension, height: size.dimension)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(AppConstants.Colors.primary.opacity(0.2), lineWidth: 2)
            )
            
            if let status = status {
                StatusIndicator(status: status)
                    .offset(x: 4, y: 4)
            }
        }
    }
    
    private var fallbackAvatar: some View {
        ZStack {
            Circle()
                .fill(AppConstants.Colors.primaryGradient)
            
            Text(initials)
                .font(size.fontSize)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
    
    private var initials: String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map { String($0) }
        return initials.prefix(2).joined().uppercased()
    }
}

// MARK: - Section Header Component
struct SectionHeader: View {
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(title: String, subtitle: String? = nil, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.xxs) {
            HStack {
                VStack(alignment: .leading, spacing: AppConstants.Spacing.xxs) {
                    Text(title)
                        .font(AppConstants.Typography.titleLarge)
                        .fontWeight(.bold)
                        .foregroundColor(AppConstants.Colors.text)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(AppConstants.Typography.bodyMedium)
                            .foregroundColor(AppConstants.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                if let action = action, let actionTitle = actionTitle {
                    Button(action: action) {
                        Text(actionTitle)
                            .font(AppConstants.Typography.titleMedium)
                            .fontWeight(.medium)
                            .foregroundColor(AppConstants.Colors.primary)
                    }
                }
            }
        }
        .padding(.bottom, AppConstants.Spacing.sm)
    }
}

// MARK: - Loading Components
struct LoadingView: View {
    let style: LoadingStyle
    
    enum LoadingStyle {
        case dots
        case spinner
        case pulse
    }
    
    var body: some View {
        Group {
            switch style {
            case .dots:
                DotsLoadingView()
            case .spinner:
                SpinnerLoadingView()
            case .pulse:
                PulseLoadingView()
            }
        }
    }
}

struct DotsLoadingView: View {
    @State private var animateOffset = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(AppConstants.Colors.primary)
                    .frame(width: 8, height: 8)
                    .offset(y: animateOffset ? -8 : 0)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animateOffset
                    )
            }
        }
        .onAppear {
            animateOffset = true
        }
    }
}

struct SpinnerLoadingView: View {
    @State private var rotation = 0.0
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(AppConstants.Colors.primary, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .frame(width: 24, height: 24)
            .rotationEffect(.degrees(rotation))
            .animation(
                Animation.linear(duration: 1)
                    .repeatForever(autoreverses: false),
                value: rotation
            )
            .onAppear {
                rotation = 360
            }
    }
}

struct PulseLoadingView: View {
    @State private var scale = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        Circle()
            .fill(AppConstants.Colors.primary)
            .frame(width: 20, height: 20)
            .scaleEffect(scale)
            .opacity(opacity)
            .animation(
                Animation.easeInOut(duration: 1)
                    .repeatForever(autoreverses: true),
                value: scale
            )
            .onAppear {
                scale = 1.2
                opacity = 0.1
            }
    }
}

// MARK: - Empty State Component
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(icon: String, title: String, description: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.xl) {
            VStack(spacing: AppConstants.Spacing.lg) {
                Image(systemName: icon)
                    .font(.system(size: 64, weight: .light))
                    .foregroundColor(AppConstants.Colors.textSecondary)
                
                VStack(spacing: AppConstants.Spacing.sm) {
                    Text(title)
                        .font(AppConstants.Typography.titleLarge)
                        .fontWeight(.semibold)
                        .foregroundColor(AppConstants.Colors.text)
                        .multilineTextAlignment(.center)
                    
                    Text(description)
                        .font(AppConstants.Typography.bodyMedium)
                        .foregroundColor(AppConstants.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppConstants.Spacing.xl)
                }
            }
            
            if let actionTitle = actionTitle, let action = action {
                ModernButton(title: actionTitle, style: .primary, action: action)
                    .frame(maxWidth: 200)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppConstants.Spacing.xl)
    }
} 