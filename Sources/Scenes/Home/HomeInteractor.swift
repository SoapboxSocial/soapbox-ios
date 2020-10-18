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
    func didFetchImage()
    func didFetchActives(actives: [APIClient.ActiveUser])
}

class HomeInteractor: HomeViewControllerOutput {
    private let output: HomeInteractorOutput
    private let roomService: RoomServiceClient
    private let controller: RoomController
    private let api: APIClient

    private var token: String? {
        guard let identifier = Bundle.main.bundleIdentifier else {
            fatalError("no identifier")
        }

        let keychain = Keychain(service: identifier)
        return keychain[string: "token"]
    }

    init(output: HomeInteractorOutput, service: RoomServiceClient, controller: RoomController, api: APIClient) {
        self.output = output
        roomService = service
        self.controller = controller
        self.api = api
    }

    func fetchData() {
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

        api.actives(callback: { result in
            DispatchQueue.main.async {
                switch result {
                case .failure:
                    self.output.didFetchActives(actives: [])
                case let .success(users):
                    self.output.didFetchActives(actives: users)
                }
            }
        })
    }

    func fetchMe() {
        api.me(callback: { result in
            DispatchQueue.main.async {
                switch result {
                case .failure:
                    break // @TODO
                case let .success(user):
                    UserStore.store(user: user)
                    self.output.didFetchImage()
                }
            }
        })
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
        fetchData()
    }
}
