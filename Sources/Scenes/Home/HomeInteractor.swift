import Foundation
import KeychainAccess
import SwiftProtobuf

protocol RoomController {
    func didSelect(room id: Int)
    func didBeginSearching()
    func didEndSearching()
}

protocol RoomControllerDelegate {
    func didJoin(room: Int)
    func didLeaveRoom()
    func reloadRooms()
}

protocol HomeInteractorOutput {
    func didFailToFetchRooms()
    func didFetchRooms(rooms: RoomList)
    func didJoin(room: Int)
    func didLeaveRoom()
}

class HomeInteractor: HomeViewControllerOutput {
    private let output: HomeInteractorOutput
    private let roomService: RoomServiceClient
    private let controller: RoomController
    
    private var token: String? {
        guard let identifier = Bundle.main.bundleIdentifier else {
            fatalError("no identifier")
        }

        let keychain = Keychain(service: identifier)
        return keychain[string: "token"]
    }

    init(output: HomeInteractorOutput, service: RoomServiceClient, controller: RoomController) {
        self.output = output
        roomService = service
        self.controller = controller
    }

    func fetchRooms() {
        // @TODO probably want to start refresh control.

        let call = roomService.listRoomsV2(Auth.with {
            $0.session = token!
        })

        call.response.whenComplete { result in
            DispatchQueue.main.async {
                switch result {
                case .failure:
                    self.output.didFailToFetchRooms()
                case let .success(list):
                    self.output.didFetchRooms(rooms: list)
                }
            }
        }
    }

    func didSelectRoom(room: Int) {
        controller.didSelect(room: room)
    }

    func didEndSearching() {
        controller.didEndSearching()
    }

    func didBeginSearching() {
        controller.didBeginSearching()
    }
}

extension HomeInteractor: RoomControllerDelegate {
    func didJoin(room: Int) {
        output.didJoin(room: room)
    }

    func didLeaveRoom() {
        output.didLeaveRoom()
    }

    func reloadRooms() {
        fetchRooms()
    }
}
