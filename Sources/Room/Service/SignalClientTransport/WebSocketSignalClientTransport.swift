import Foundation
import KeychainAccess

class WebSocketSignalClientTransport: NSObject, SignalClientTransport {
    weak var delegate: SignalClientTransportDelegate?

    private let url: URL
    private var socket: URLSessionWebSocketTask?
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

    private var token: String? {
        guard let identifier = Bundle.main.bundleIdentifier else {
            fatalError("no identifier")
        }

        let keychain = Keychain(service: identifier)
        return keychain[string: "token"]
    }

    init(url: URL) {
        self.url = url.appendingPathComponent("/v1/signal")
        super.init()
    }

    func connect() {
        var request = URLRequest(url: url)
        request.addValue(token!, forHTTPHeaderField: "Authorization")

        let socket = session.webSocketTask(with: request)
        socket.resume()
        self.socket = socket
        readLoop()
    }

    func disconnect() {
        socket?.cancel()
        socket = nil
        delegate?.signalClientTransportDidDisconnect(self)
    }

    func send(data: Data) {
        socket?.send(.data(data), completionHandler: { err in
            if let error = err {
                debugPrint("\(error)")
            }
        })
    }

    private func readLoop() {
        socket?.receive { [weak self] message in
            guard let self = self else { return }

            switch message {
            case let .success(.data(data)):
                self.delegate?.signalClientTransport(self, didReceiveData: data)
                self.readLoop()

            case .success:
                debugPrint("Warning: Expected to receive data format but received a string. Check the websocket server config.")
                self.readLoop()

            case .failure:
                self.disconnect()
            }
        }
    }

    private func ping() {
        socket?.sendPing { error in
            if let error = error {
                debugPrint("err sending PING \(error)")
                return
            }

            DispatchQueue.global().asyncAfter(deadline: .now() + 30) {
                self.ping()
            }
        }
    }
}

extension WebSocketSignalClientTransport: URLSessionWebSocketDelegate, URLSessionDelegate {
    func urlSession(_: URLSession, webSocketTask _: URLSessionWebSocketTask, didOpenWithProtocol _: String?) {
        ping()
        delegate?.signalClientTransportDidConnect(self)
    }

    func urlSession(_: URLSession, webSocketTask _: URLSessionWebSocketTask, didCloseWith _: URLSessionWebSocketTask.CloseCode, reason _: Data?) {
        disconnect()
    }
}
