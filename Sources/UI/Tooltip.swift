import EasyTipView

class Tooltip: EasyTipView {
    private static var preferences: Preferences = {
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = .rounded(forTextStyle: .callout, weight: .regular)
        preferences.drawing.foregroundColor = .white
        preferences.drawing.backgroundColor = .brandColor
        preferences.drawing.arrowPosition = .bottom
        return preferences
    }()

    static func create(text: String) -> EasyTipView {
        return EasyTipView(text: text, preferences: preferences)
    }
}
