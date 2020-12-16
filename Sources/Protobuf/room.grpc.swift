//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: room.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import GRPC
import NIO
import SwiftProtobuf


/// Usage: instantiate `RoomServiceClient`, then call methods of this protocol to make API calls.
internal protocol RoomServiceClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: RoomServiceClientInterceptorFactoryProtocol? { get }

  func signal(
    callOptions: CallOptions?,
    handler: @escaping (SignalReply) -> Void
  ) -> BidirectionalStreamingCall<SignalRequest, SignalReply>

  func listRooms(
    _ request: SwiftProtobuf.Google_Protobuf_Empty,
    callOptions: CallOptions?
  ) -> UnaryCall<SwiftProtobuf.Google_Protobuf_Empty, RoomList>
}

extension RoomServiceClientProtocol {
  internal var serviceName: String {
    return "RoomService"
  }

  /// Bidirectional streaming call to Signal
  ///
  /// Callers should use the `send` method on the returned object to send messages
  /// to the server. The caller should send an `.end` after the final message has been sent.
  ///
  /// - Parameters:
  ///   - callOptions: Call options.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ClientStreamingCall` with futures for the metadata and status.
  internal func signal(
    callOptions: CallOptions? = nil,
    handler: @escaping (SignalReply) -> Void
  ) -> BidirectionalStreamingCall<SignalRequest, SignalReply> {
    return self.makeBidirectionalStreamingCall(
      path: "/RoomService/Signal",
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeSignalInterceptors() ?? [],
      handler: handler
    )
  }

  /// Unary call to ListRooms
  ///
  /// - Parameters:
  ///   - request: Request to send to ListRooms.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func listRooms(
    _ request: SwiftProtobuf.Google_Protobuf_Empty,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<SwiftProtobuf.Google_Protobuf_Empty, RoomList> {
    return self.makeUnaryCall(
      path: "/RoomService/ListRooms",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeListRoomsInterceptors() ?? []
    )
  }
}

internal protocol RoomServiceClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'signal'.
  func makeSignalInterceptors() -> [ClientInterceptor<SignalRequest, SignalReply>]

  /// - Returns: Interceptors to use when invoking 'listRooms'.
  func makeListRoomsInterceptors() -> [ClientInterceptor<SwiftProtobuf.Google_Protobuf_Empty, RoomList>]
}

internal final class RoomServiceClient: RoomServiceClientProtocol {
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: RoomServiceClientInterceptorFactoryProtocol?

  /// Creates a client for the RoomService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: RoomServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

