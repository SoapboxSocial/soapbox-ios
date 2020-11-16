import Foundation
import KeychainAccess
import SwiftProtobuf

protocol RoomController {
    func didSelect(room id: Int)
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
    func didFetchGroups(groups: [APIClient.Group])
    func didFetchMoreGroups(groups: [APIClient.Group])
}

class HomeInteractor: HomeViewControllerOutput {
    private let output: HomeInteractorOutput
    private let roomService: RoomServiceClient
    private let controller: RoomController
    private let api: APIClient

    private let groupLimit = 10
    private var groupOffset = 0

    init(output: HomeInteractorOutput, service: RoomServiceClient, controller: RoomController, api: APIClient) {
        self.output = output
        roomService = service
        self.controller = controller
        self.api = api
    }

    func fetchData() {
        // @TODO probably want to start refresh control.

        let call = roomService.listRooms(Google_Protobuf_Empty())

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

        // @TODO
        api.groups(id: UserDefaults.standard.integer(forKey: "id"), limit: groupLimit, offset: groupOffset, callback: { result in
            switch result {
            case .failure:
                self.output.didFetchGroups(groups: [])
            case let .success(groups):
                self.output.didFetchGroups(groups: groups)
            }
        })
    }

    func fetchMoreGroups() {
        let nextOffset = groupOffset + groupLimit

        api.groups(id: UserDefaults.standard.integer(forKey: "id"), limit: groupLimit, offset: nextOffset, callback: { result in
            switch result {
            case .failure: break
            case let .success(groups):
                self.output.didFetchMoreGroups(groups: groups)
                self.groupOffset = nextOffset
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
