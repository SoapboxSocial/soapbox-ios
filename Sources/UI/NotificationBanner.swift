import NotificationBannerSwift

private class NotificationBannerColors: BannerColorsProtocol {
    internal func color(for style: BannerStyle) -> UIColor {
        switch style {
        case .danger:
            return UIColor(red: 254 / 255, green: 88 / 255, blue: 88 / 255, alpha: 1.0)
        case .info:
            return .brandColor
        case .customView:
            return .clear
        case .success:
            return UIColor(red: 85 / 255, green: 232 / 255, blue: 88 / 144, alpha: 1.0)
        case .warning:
            return UIColor(red: 254 / 255, green: 88 / 255, blue: 88 / 255, alpha: 1.0)
        }
    }
}

class NotificationBanner {
    enum BannerType {
        case normal, floating
    }

    private var banner: NotificationBannerSwift.BaseNotificationBanner

    /// Closure that will be executed if the notification banner is tapped
    public var onTap: (() -> Void)? {
        didSet {
            banner.onTap = onTap
        }
    }

    init(title: String? = nil, subtitle: String? = nil, style: BannerStyle = .info, type: BannerType = .normal) {
        switch type {
        case .normal:
            banner = GrowingNotificationBanner(
                title: title,
                subtitle: subtitle,
                leftView: nil,
                rightView: nil,
                style: style,
                colors: NotificationBannerColors()
            )
        case .floating:
            banner = FloatingNotificationBanner(
                title: title,
                subtitle: subtitle,
                leftView: nil,
                rightView: nil,
                style: style,
                colors: NotificationBannerColors()
            )
        }
    }

    func show() {
        if let banner = banner as? FloatingNotificationBanner {
            return banner.show(cornerRadius: 10, shadowBlurRadius: 15)
        }

        banner.show()
    }
}
