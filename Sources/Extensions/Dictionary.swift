import Foundation

extension Dictionary where Key == String, Value == String {
    func value<T: LosslessStringConvertible>(_: T.Type, key: String) -> T? {
        guard let str = self[key], let value = T(str) else {
            return nil
        }

        return value
    }
}
