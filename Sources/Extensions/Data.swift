import UIKit

extension Data {
    public var toInt: Int {
        return Int(UInt64(littleEndian: withUnsafeBytes { $0.pointee }))
    }
}
