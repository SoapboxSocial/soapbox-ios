import Foundation

extension NSMutableAttributedString {
    func addAttributes(toText text: String, _ attrs: [NSAttributedString.Key: Any] = [:]) {
        addAttributes(attrs, range: mutableString.range(of: text))
    }
}
