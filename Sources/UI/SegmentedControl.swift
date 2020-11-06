import BetterSegmentedControl
import UIKit

class SegmentedControl: BetterSegmentedControl {
    init(frame: CGRect, titles: [String]) {
        super.init(
            frame: frame,
            segments: LabelSegment.segments(
                withTitles: titles,
                normalFont: UIFont.rounded(forTextStyle: .title3, weight: .bold),
                normalTextColor: .white,
                selectedFont: UIFont.rounded(forTextStyle: .title3, weight: .bold),
                selectedTextColor: .black
            )
        )

        layer.cornerRadius = 15
        indicatorViewBackgroundColor = .white
        indicatorViewInset = 0
        backgroundColor = .lightBrandColor
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
