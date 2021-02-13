import LinkPresentation
import UIKit

class MetadataItemSource: NSObject, UIActivityItemSource {
    private let metadata: LPLinkMetadata

    init(metadata: LPLinkMetadata) {
        self.metadata = metadata
    }

    func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        return metadata.title
    }

    func activityViewController(_: UIActivityViewController, itemForActivityType _: UIActivity.ActivityType?) -> Any? {
        // @TODO
        return nil
    }

    func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        return metadata
    }
}
