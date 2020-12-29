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
    func didFetchFeed(_ feed: [APIClient.StoryFeed])
    func didFetchOwnStories(_ stories: [APIClient.Story])
    func has(notifications: Bool)
}

class HomeInteractor: HomeViewControllerOutput {
    private let output: HomeInteractorOutput
    private let roomService: RoomServiceClient
    private let controller: RoomController
    private let api: APIClient

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

        let user = UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId)

        api.stories(user: user, callback: { result in
            switch result {
            case .failure:
                self.output.didFetchOwnStories([])
            case let .success(stories):
                self.output.didFetchOwnStories(stories)
            }
        })

        api.feed(callback: { result in
            switch result {
            case .failure:
                self.output.didFetchFeed([])
            case let .success(stories):
                self.output.didFetchFeed(
                    stories.sorted(by: {
                        ($0.stories.map { $0.deviceTimestamp }.max() ?? 0) > ($1.stories.map { $0.deviceTimestamp }.max() ?? 0)
                    })
                )
            }
        })
    }

    func fetchMe() {
        api.me(callback: { result in
            DispatchQueue.main.async {
                switch result {
                case let .failure(error):
                    switch error {
                    case let .endpoint(value):
                        if value.code == .unauthorized {
                            (UIApplication.shared.delegate as! AppDelegate).transitionToLoginView()
                        }
                    default:
                        break
                    }
                case let .success(me):
                    self.output.has(notifications: me.hasNotifications)
                    UserStore.store(user: me.user)
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
