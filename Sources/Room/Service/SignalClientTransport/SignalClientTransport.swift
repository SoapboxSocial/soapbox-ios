import Foundation

protocol SignalClientTransportDelegate: AnyObject {
    func signalClientTransportDidConnect(_ transport: SignalClientTransport)
    func signalClientTransportDidDisconnect(_ transport: SignalClientTransport)
    func signalClientTransport(_ transport: SignalClientTransport, didReceiveData data: Data)
}

protocol SignalClientTransport {
    var delegate: SignalClientTransportDelegate? { get set }

    func connect()
    func disconnect()
    func send(data: Data)
}
