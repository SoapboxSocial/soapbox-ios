import Foundation
import KeychainAccess

protocol WebSocketProviderDelegate: class {
    func webSocketDidConnect(_ webSocket: WebSocketProvider)
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider)
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data)
}

class WebSocketProvider: NSObject {
    private var token: String? {
        guard let identifier = Bundle.main.bundleIdentifier else {
            fatalError("no identifier")
        }

        let keychain = Keychain(service: identifier)
        return keychain[string: "token"]
    }

    var delegate: WebSocketProviderDelegate?
    private let url: URL
    private var socket: URLSessionWebSocketTask?
    private lazy var urlSession: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

    init(url: URL) {
        self.url = url
        super.init()
    }

    func connect() {
        let socket = urlSession.webSocketTask(with: try! URLRequest(url: url, method: .get, headers: ["Authorization": token!]))
        socket.resume()
        self.socket = socket
        readMessage()
    }

    func send(data: Data) {
        socket?.send(.data(data)) { _ in }
    }

    private func readMessage() {
        socket?.receive { [weak self] message in
            guard let self = self else { return }

            switch message {
            case let .success(.data(data)):
                self.delegate?.webSocket(self, didReceiveData: data)
                self.readMessage()

            case .success:
                debugPrint("Warning: Expected to receive data format but received a string. Check the websocket server config.")
                self.readMessage()

            case .failure:
                self.disconnect()
            }
        }
    }

    func disconnect() {
        socket?.cancel()
        socket = nil
        delegate?.webSocketDidDisconnect(self)
    }
}

extension WebSocketProvider: URLSessionWebSocketDelegate, URLSessionDelegate {
    func urlSession(_: URLSession, webSocketTask _: URLSessionWebSocketTask, didOpenWithProtocol _: String?) {
        delegate?.webSocketDidConnect(self)
    }

    func urlSession(_: URLSession, webSocketTask _: URLSessionWebSocketTask, didCloseWith _: URLSessionWebSocketTask.CloseCode, reason _: Data?) {
        disconnect()
    }
}
