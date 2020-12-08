import UIKit

class StoryReactionView: UIView {
    let reaction: String
    let count: Int

    init(reaction: String, count: Int) {
        self.reaction = reaction
        self.count = count

        super.init(frame: .zero)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
