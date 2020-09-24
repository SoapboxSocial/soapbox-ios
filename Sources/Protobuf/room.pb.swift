// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: room.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

struct SignalRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var payload: SignalRequest.OneOf_Payload? = nil

  var join: JoinRequest {
    get {
      if case .join(let v)? = payload {return v}
      return JoinRequest()
    }
    set {payload = .join(newValue)}
  }

  var create: CreateRequest {
    get {
      if case .create(let v)? = payload {return v}
      return CreateRequest()
    }
    set {payload = .create(newValue)}
  }

  var negotiate: SessionDescription {
    get {
      if case .negotiate(let v)? = payload {return v}
      return SessionDescription()
    }
    set {payload = .negotiate(newValue)}
  }

  var trickle: Trickle {
    get {
      if case .trickle(let v)? = payload {return v}
      return Trickle()
    }
    set {payload = .trickle(newValue)}
  }

  var command: SignalRequest.Command {
    get {
      if case .command(let v)? = payload {return v}
      return SignalRequest.Command()
    }
    set {payload = .command(newValue)}
  }

  var invite: Invite {
    get {
      if case .invite(let v)? = payload {return v}
      return Invite()
    }
    set {payload = .invite(newValue)}
  }

  var unknownFields = SwiftProtobuf.UnknownStorage()

  enum OneOf_Payload: Equatable {
    case join(JoinRequest)
    case create(CreateRequest)
    case negotiate(SessionDescription)
    case trickle(Trickle)
    case command(SignalRequest.Command)
    case invite(Invite)

  #if !swift(>=4.1)
    static func ==(lhs: SignalRequest.OneOf_Payload, rhs: SignalRequest.OneOf_Payload) -> Bool {
      switch (lhs, rhs) {
      case (.join(let l), .join(let r)): return l == r
      case (.create(let l), .create(let r)): return l == r
      case (.negotiate(let l), .negotiate(let r)): return l == r
      case (.trickle(let l), .trickle(let r)): return l == r
      case (.command(let l), .command(let r)): return l == r
      case (.invite(let l), .invite(let r)): return l == r
      default: return false
      }
    }
  #endif
  }

  /// @TODO think about turning these into seperate things
  struct Command {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    var type: SignalRequest.Command.TypeEnum = .addSpeaker

    var data: Data = SwiftProtobuf.Internal.emptyData

    var unknownFields = SwiftProtobuf.UnknownStorage()

    enum TypeEnum: SwiftProtobuf.Enum {
      typealias RawValue = Int
      case addSpeaker // = 0
      case removeSpeaker // = 1
      case muteSpeaker // = 2
      case unmuteSpeaker // = 3
      case reaction // = 4
      case UNRECOGNIZED(Int)

      init() {
        self = .addSpeaker
      }

      init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .addSpeaker
        case 1: self = .removeSpeaker
        case 2: self = .muteSpeaker
        case 3: self = .unmuteSpeaker
        case 4: self = .reaction
        default: self = .UNRECOGNIZED(rawValue)
        }
      }

      var rawValue: Int {
        switch self {
        case .addSpeaker: return 0
        case .removeSpeaker: return 1
        case .muteSpeaker: return 2
        case .unmuteSpeaker: return 3
        case .reaction: return 4
        case .UNRECOGNIZED(let i): return i
        }
      }

    }

    init() {}
  }

  init() {}
}

#if swift(>=4.2)

extension SignalRequest.Command.TypeEnum: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [SignalRequest.Command.TypeEnum] = [
    .addSpeaker,
    .removeSpeaker,
    .muteSpeaker,
    .unmuteSpeaker,
    .reaction,
  ]
}

#endif  // swift(>=4.2)

struct SignalReply {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var payload: SignalReply.OneOf_Payload? = nil

  var join: JoinReply {
    get {
      if case .join(let v)? = payload {return v}
      return JoinReply()
    }
    set {payload = .join(newValue)}
  }

  var create: CreateReply {
    get {
      if case .create(let v)? = payload {return v}
      return CreateReply()
    }
    set {payload = .create(newValue)}
  }

  var negotiate: SessionDescription {
    get {
      if case .negotiate(let v)? = payload {return v}
      return SessionDescription()
    }
    set {payload = .negotiate(newValue)}
  }

  var trickle: Trickle {
    get {
      if case .trickle(let v)? = payload {return v}
      return Trickle()
    }
    set {payload = .trickle(newValue)}
  }

  var event: SignalReply.Event {
    get {
      if case .event(let v)? = payload {return v}
      return SignalReply.Event()
    }
    set {payload = .event(newValue)}
  }

  var unknownFields = SwiftProtobuf.UnknownStorage()

  enum OneOf_Payload: Equatable {
    case join(JoinReply)
    case create(CreateReply)
    case negotiate(SessionDescription)
    case trickle(Trickle)
    case event(SignalReply.Event)

  #if !swift(>=4.1)
    static func ==(lhs: SignalReply.OneOf_Payload, rhs: SignalReply.OneOf_Payload) -> Bool {
      switch (lhs, rhs) {
      case (.join(let l), .join(let r)): return l == r
      case (.create(let l), .create(let r)): return l == r
      case (.negotiate(let l), .negotiate(let r)): return l == r
      case (.trickle(let l), .trickle(let r)): return l == r
      case (.event(let l), .event(let r)): return l == r
      default: return false
      }
    }
  #endif
  }

  struct Event {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    var type: SignalReply.Event.TypeEnum = .joined

    var from: Int64 = 0

    var data: Data = SwiftProtobuf.Internal.emptyData

    var unknownFields = SwiftProtobuf.UnknownStorage()

    enum TypeEnum: SwiftProtobuf.Enum {
      typealias RawValue = Int
      case joined // = 0
      case left // = 1
      case addedSpeaker // = 2
      case removedSpeaker // = 3
      case changedOwner // = 4
      case mutedSpeaker // = 5
      case unmutedSpeaker // = 6
      case reacted // = 7
      case UNRECOGNIZED(Int)

      init() {
        self = .joined
      }

      init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .joined
        case 1: self = .left
        case 2: self = .addedSpeaker
        case 3: self = .removedSpeaker
        case 4: self = .changedOwner
        case 5: self = .mutedSpeaker
        case 6: self = .unmutedSpeaker
        case 7: self = .reacted
        default: self = .UNRECOGNIZED(rawValue)
        }
      }

      var rawValue: Int {
        switch self {
        case .joined: return 0
        case .left: return 1
        case .addedSpeaker: return 2
        case .removedSpeaker: return 3
        case .changedOwner: return 4
        case .mutedSpeaker: return 5
        case .unmutedSpeaker: return 6
        case .reacted: return 7
        case .UNRECOGNIZED(let i): return i
        }
      }

    }

    init() {}
  }

  init() {}
}

#if swift(>=4.2)

extension SignalReply.Event.TypeEnum: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [SignalReply.Event.TypeEnum] = [
    .joined,
    .left,
    .addedSpeaker,
    .removedSpeaker,
    .changedOwner,
    .mutedSpeaker,
    .unmutedSpeaker,
    .reacted,
  ]
}

#endif  // swift(>=4.2)

struct JoinRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var room: Int64 = 0

  var session: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct JoinReply {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var answer: SessionDescription {
    get {return _answer ?? SessionDescription()}
    set {_answer = newValue}
  }
  /// Returns true if `answer` has been explicitly set.
  var hasAnswer: Bool {return self._answer != nil}
  /// Clears the value of `answer`. Subsequent reads from it will return its default value.
  mutating func clearAnswer() {self._answer = nil}

  var room: RoomState {
    get {return _room ?? RoomState()}
    set {_room = newValue}
  }
  /// Returns true if `room` has been explicitly set.
  var hasRoom: Bool {return self._room != nil}
  /// Clears the value of `room`. Subsequent reads from it will return its default value.
  mutating func clearRoom() {self._room = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _answer: SessionDescription? = nil
  fileprivate var _room: RoomState? = nil
}

struct RoomList {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var rooms: [RoomState] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct RoomState {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var id: Int64 = 0

  var name: String = String()

  var members: [RoomState.RoomMember] = []

  /// @TODO THINK ABOUT ENUM
  var role: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  struct RoomMember {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    var id: Int64 = 0

    var displayName: String = String()

    var image: String = String()

    var role: String = String()

    var muted: Bool = false

    var ssrc: UInt32 = 0

    var unknownFields = SwiftProtobuf.UnknownStorage()

    init() {}
  }

  init() {}
}

struct CreateRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var name: String = String()

  var session: String = String()

  var visibility: CreateRequest.Visibility = .public

  var unknownFields = SwiftProtobuf.UnknownStorage()

  enum Visibility: SwiftProtobuf.Enum {
    typealias RawValue = Int
    case `public` // = 0
    case `private` // = 1
    case UNRECOGNIZED(Int)

    init() {
      self = .public
    }

    init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .public
      case 1: self = .private
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    var rawValue: Int {
      switch self {
      case .public: return 0
      case .private: return 1
      case .UNRECOGNIZED(let i): return i
      }
    }

  }

  init() {}
}

#if swift(>=4.2)

extension CreateRequest.Visibility: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [CreateRequest.Visibility] = [
    .public,
    .private,
  ]
}

#endif  // swift(>=4.2)

struct CreateReply {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var id: Int64 = 0

  var answer: SessionDescription {
    get {return _answer ?? SessionDescription()}
    set {_answer = newValue}
  }
  /// Returns true if `answer` has been explicitly set.
  var hasAnswer: Bool {return self._answer != nil}
  /// Clears the value of `answer`. Subsequent reads from it will return its default value.
  mutating func clearAnswer() {self._answer = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _answer: SessionDescription? = nil
}

struct Trickle {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var init_p: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct SessionDescription {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// "answer" | "offer" | "pranswer" | "rollback"
  var type: String = String()

  var sdp: Data = SwiftProtobuf.Internal.emptyData

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Invite {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var id: Int64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension SignalRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "SignalRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "join"),
    2: .same(proto: "create"),
    3: .same(proto: "negotiate"),
    4: .same(proto: "trickle"),
    5: .same(proto: "command"),
    6: .same(proto: "invite"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1:
        var v: JoinRequest?
        if let current = self.payload {
          try decoder.handleConflictingOneOf()
          if case .join(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {self.payload = .join(v)}
      case 2:
        var v: CreateRequest?
        if let current = self.payload {
          try decoder.handleConflictingOneOf()
          if case .create(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {self.payload = .create(v)}
      case 3:
        var v: SessionDescription?
        if let current = self.payload {
          try decoder.handleConflictingOneOf()
          if case .negotiate(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {self.payload = .negotiate(v)}
      case 4:
        var v: Trickle?
        if let current = self.payload {
          try decoder.handleConflictingOneOf()
          if case .trickle(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {self.payload = .trickle(v)}
      case 5:
        var v: SignalRequest.Command?
        if let current = self.payload {
          try decoder.handleConflictingOneOf()
          if case .command(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {self.payload = .command(v)}
      case 6:
        var v: Invite?
        if let current = self.payload {
          try decoder.handleConflictingOneOf()
          if case .invite(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {self.payload = .invite(v)}
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    switch self.payload {
    case .join(let v)?:
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    case .create(let v)?:
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    case .negotiate(let v)?:
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    case .trickle(let v)?:
      try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
    case .command(let v)?:
      try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
    case .invite(let v)?:
      try visitor.visitSingularMessageField(value: v, fieldNumber: 6)
    case nil: break
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SignalRequest, rhs: SignalRequest) -> Bool {
    if lhs.payload != rhs.payload {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension SignalRequest.Command: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = SignalRequest.protoMessageName + ".Command"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "type"),
    2: .same(proto: "data"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularEnumField(value: &self.type)
      case 2: try decoder.decodeSingularBytesField(value: &self.data)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.type != .addSpeaker {
      try visitor.visitSingularEnumField(value: self.type, fieldNumber: 1)
    }
    if !self.data.isEmpty {
      try visitor.visitSingularBytesField(value: self.data, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SignalRequest.Command, rhs: SignalRequest.Command) -> Bool {
    if lhs.type != rhs.type {return false}
    if lhs.data != rhs.data {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension SignalRequest.Command.TypeEnum: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "ADD_SPEAKER"),
    1: .same(proto: "REMOVE_SPEAKER"),
    2: .same(proto: "MUTE_SPEAKER"),
    3: .same(proto: "UNMUTE_SPEAKER"),
    4: .same(proto: "REACTION"),
  ]
}

extension SignalReply: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "SignalReply"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "join"),
    2: .same(proto: "create"),
    3: .same(proto: "negotiate"),
    4: .same(proto: "trickle"),
    5: .same(proto: "event"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1:
        var v: JoinReply?
        if let current = self.payload {
          try decoder.handleConflictingOneOf()
          if case .join(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {self.payload = .join(v)}
      case 2:
        var v: CreateReply?
        if let current = self.payload {
          try decoder.handleConflictingOneOf()
          if case .create(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {self.payload = .create(v)}
      case 3:
        var v: SessionDescription?
        if let current = self.payload {
          try decoder.handleConflictingOneOf()
          if case .negotiate(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {self.payload = .negotiate(v)}
      case 4:
        var v: Trickle?
        if let current = self.payload {
          try decoder.handleConflictingOneOf()
          if case .trickle(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {self.payload = .trickle(v)}
      case 5:
        var v: SignalReply.Event?
        if let current = self.payload {
          try decoder.handleConflictingOneOf()
          if case .event(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {self.payload = .event(v)}
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    switch self.payload {
    case .join(let v)?:
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    case .create(let v)?:
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    case .negotiate(let v)?:
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    case .trickle(let v)?:
      try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
    case .event(let v)?:
      try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
    case nil: break
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SignalReply, rhs: SignalReply) -> Bool {
    if lhs.payload != rhs.payload {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension SignalReply.Event: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = SignalReply.protoMessageName + ".Event"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "type"),
    2: .same(proto: "from"),
    3: .same(proto: "data"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularEnumField(value: &self.type)
      case 2: try decoder.decodeSingularInt64Field(value: &self.from)
      case 3: try decoder.decodeSingularBytesField(value: &self.data)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.type != .joined {
      try visitor.visitSingularEnumField(value: self.type, fieldNumber: 1)
    }
    if self.from != 0 {
      try visitor.visitSingularInt64Field(value: self.from, fieldNumber: 2)
    }
    if !self.data.isEmpty {
      try visitor.visitSingularBytesField(value: self.data, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SignalReply.Event, rhs: SignalReply.Event) -> Bool {
    if lhs.type != rhs.type {return false}
    if lhs.from != rhs.from {return false}
    if lhs.data != rhs.data {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension SignalReply.Event.TypeEnum: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "JOINED"),
    1: .same(proto: "LEFT"),
    2: .same(proto: "ADDED_SPEAKER"),
    3: .same(proto: "REMOVED_SPEAKER"),
    4: .same(proto: "CHANGED_OWNER"),
    5: .same(proto: "MUTED_SPEAKER"),
    6: .same(proto: "UNMUTED_SPEAKER"),
    7: .same(proto: "REACTED"),
  ]
}

extension JoinRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "JoinRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "room"),
    2: .same(proto: "session"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularInt64Field(value: &self.room)
      case 2: try decoder.decodeSingularStringField(value: &self.session)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.room != 0 {
      try visitor.visitSingularInt64Field(value: self.room, fieldNumber: 1)
    }
    if !self.session.isEmpty {
      try visitor.visitSingularStringField(value: self.session, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: JoinRequest, rhs: JoinRequest) -> Bool {
    if lhs.room != rhs.room {return false}
    if lhs.session != rhs.session {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension JoinReply: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "JoinReply"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "answer"),
    2: .same(proto: "room"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularMessageField(value: &self._answer)
      case 2: try decoder.decodeSingularMessageField(value: &self._room)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if let v = self._answer {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    }
    if let v = self._room {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: JoinReply, rhs: JoinReply) -> Bool {
    if lhs._answer != rhs._answer {return false}
    if lhs._room != rhs._room {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension RoomList: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "RoomList"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "rooms"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeRepeatedMessageField(value: &self.rooms)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.rooms.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.rooms, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: RoomList, rhs: RoomList) -> Bool {
    if lhs.rooms != rhs.rooms {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension RoomState: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "RoomState"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "name"),
    3: .same(proto: "members"),
    4: .same(proto: "role"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularInt64Field(value: &self.id)
      case 2: try decoder.decodeSingularStringField(value: &self.name)
      case 3: try decoder.decodeRepeatedMessageField(value: &self.members)
      case 4: try decoder.decodeSingularStringField(value: &self.role)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.id != 0 {
      try visitor.visitSingularInt64Field(value: self.id, fieldNumber: 1)
    }
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 2)
    }
    if !self.members.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.members, fieldNumber: 3)
    }
    if !self.role.isEmpty {
      try visitor.visitSingularStringField(value: self.role, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: RoomState, rhs: RoomState) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.name != rhs.name {return false}
    if lhs.members != rhs.members {return false}
    if lhs.role != rhs.role {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension RoomState.RoomMember: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = RoomState.protoMessageName + ".RoomMember"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "displayName"),
    3: .same(proto: "image"),
    4: .same(proto: "role"),
    5: .same(proto: "muted"),
    6: .same(proto: "ssrc"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularInt64Field(value: &self.id)
      case 2: try decoder.decodeSingularStringField(value: &self.displayName)
      case 3: try decoder.decodeSingularStringField(value: &self.image)
      case 4: try decoder.decodeSingularStringField(value: &self.role)
      case 5: try decoder.decodeSingularBoolField(value: &self.muted)
      case 6: try decoder.decodeSingularUInt32Field(value: &self.ssrc)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.id != 0 {
      try visitor.visitSingularInt64Field(value: self.id, fieldNumber: 1)
    }
    if !self.displayName.isEmpty {
      try visitor.visitSingularStringField(value: self.displayName, fieldNumber: 2)
    }
    if !self.image.isEmpty {
      try visitor.visitSingularStringField(value: self.image, fieldNumber: 3)
    }
    if !self.role.isEmpty {
      try visitor.visitSingularStringField(value: self.role, fieldNumber: 4)
    }
    if self.muted != false {
      try visitor.visitSingularBoolField(value: self.muted, fieldNumber: 5)
    }
    if self.ssrc != 0 {
      try visitor.visitSingularUInt32Field(value: self.ssrc, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: RoomState.RoomMember, rhs: RoomState.RoomMember) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.displayName != rhs.displayName {return false}
    if lhs.image != rhs.image {return false}
    if lhs.role != rhs.role {return false}
    if lhs.muted != rhs.muted {return false}
    if lhs.ssrc != rhs.ssrc {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension CreateRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "CreateRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "name"),
    2: .same(proto: "session"),
    3: .same(proto: "visibility"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.name)
      case 2: try decoder.decodeSingularStringField(value: &self.session)
      case 3: try decoder.decodeSingularEnumField(value: &self.visibility)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 1)
    }
    if !self.session.isEmpty {
      try visitor.visitSingularStringField(value: self.session, fieldNumber: 2)
    }
    if self.visibility != .public {
      try visitor.visitSingularEnumField(value: self.visibility, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: CreateRequest, rhs: CreateRequest) -> Bool {
    if lhs.name != rhs.name {return false}
    if lhs.session != rhs.session {return false}
    if lhs.visibility != rhs.visibility {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension CreateRequest.Visibility: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "PUBLIC"),
    1: .same(proto: "PRIVATE"),
  ]
}

extension CreateReply: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "CreateReply"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "answer"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularInt64Field(value: &self.id)
      case 2: try decoder.decodeSingularMessageField(value: &self._answer)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.id != 0 {
      try visitor.visitSingularInt64Field(value: self.id, fieldNumber: 1)
    }
    if let v = self._answer {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: CreateReply, rhs: CreateReply) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs._answer != rhs._answer {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Trickle: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "Trickle"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "init"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.init_p)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.init_p.isEmpty {
      try visitor.visitSingularStringField(value: self.init_p, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Trickle, rhs: Trickle) -> Bool {
    if lhs.init_p != rhs.init_p {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension SessionDescription: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "SessionDescription"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "type"),
    2: .same(proto: "sdp"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.type)
      case 2: try decoder.decodeSingularBytesField(value: &self.sdp)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.type.isEmpty {
      try visitor.visitSingularStringField(value: self.type, fieldNumber: 1)
    }
    if !self.sdp.isEmpty {
      try visitor.visitSingularBytesField(value: self.sdp, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SessionDescription, rhs: SessionDescription) -> Bool {
    if lhs.type != rhs.type {return false}
    if lhs.sdp != rhs.sdp {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Invite: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "Invite"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularInt64Field(value: &self.id)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.id != 0 {
      try visitor.visitSingularInt64Field(value: self.id, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Invite, rhs: Invite) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
