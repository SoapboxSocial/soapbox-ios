// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: room.proto
//
// For information on using the generated types, please see the documenation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that your are building against the same version of the API
// that was used to generate this file.
private struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
    struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
    typealias Version = _2
}

struct RoomEvent {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    var type: RoomEvent.TypeEnum = .joined

    var from: String = String()

    var unknownFields = SwiftProtobuf.UnknownStorage()

    enum TypeEnum: SwiftProtobuf.Enum {
        typealias RawValue = Int
        case joined // = 0
        case left // = 1
        case UNRECOGNIZED(Int)

        init() {
            self = .joined
        }

        init?(rawValue: Int) {
            switch rawValue {
            case 0: self = .joined
            case 1: self = .left
            default: self = .UNRECOGNIZED(rawValue)
            }
        }

        var rawValue: Int {
            switch self {
            case .joined: return 0
            case .left: return 1
            case let .UNRECOGNIZED(i): return i
            }
        }
    }

    init() {}
}

#if swift(>=4.2)

    extension RoomEvent.TypeEnum: CaseIterable {
        // The compiler won't synthesize support with the UNRECOGNIZED case.
        static var allCases: [RoomEvent.TypeEnum] = [
            .joined,
            .left,
        ]
    }

#endif // swift(>=4.2)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension RoomEvent: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
    static let protoMessageName: String = "RoomEvent"
    static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "type"),
        2: .same(proto: "from"),
    ]

    mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            switch fieldNumber {
            case 1: try decoder.decodeSingularEnumField(value: &type)
            case 2: try decoder.decodeSingularStringField(value: &from)
            default: break
            }
        }
    }

    func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
        if type != .joined {
            try visitor.visitSingularEnumField(value: type, fieldNumber: 1)
        }
        if !from.isEmpty {
            try visitor.visitSingularStringField(value: from, fieldNumber: 2)
        }
        try unknownFields.traverse(visitor: &visitor)
    }

    static func == (lhs: RoomEvent, rhs: RoomEvent) -> Bool {
        if lhs.type != rhs.type { return false }
        if lhs.from != rhs.from { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}

extension RoomEvent.TypeEnum: SwiftProtobuf._ProtoNameProviding {
    static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        0: .same(proto: "JOINED"),
        1: .same(proto: "LEFT"),
    ]
}
