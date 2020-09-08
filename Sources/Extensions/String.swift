import Foundation

extension String {
    func firstName() -> String {
        return components(separatedBy: " ")[0]
    }
}
