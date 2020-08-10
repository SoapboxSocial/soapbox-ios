//
//  Data.swift
//  Voicely
//
//  Created by Dean Eigenmann on 03.08.20.
//

import UIKit

extension Data {
    public var toInt: Int {
        return Int(UInt64(littleEndian: withUnsafeBytes { $0.pointee }))
    }
}
