import Foundation
import KeychainAccess
import SwiftProtobuf

protocol RoomController {
    func didSelect(room id: String)
}

protocol RoomControllerDelegate {
    func didJoin(room: String)
    func didLeaveRoom()
    func reloadRooms()
}

protocol HomeInteractorOutput {
    func didFailToFetchRooms()
    func didFetchRooms(rooms: [RoomAPIClient.Room])
    func didJoin(room: String)
    func didLeaveRoom()
    func didFetchFeed(_ feed: [APIClient.StoryFeed])
    func didFetchOwnStories(_ stories: [APIClient.Story])
    func has(notifications: Bool)
}

class HomeInteractor: HomeViewControllerOutput {
    private let output: HomeInteractorOutput
    private let controller: RoomController
    private let api: APIClient
    private let roomApi: RoomAPIClient

    init(output: HomeInteractorOutput, controller: RoomController, api: APIClient, room: RoomAPIClient) {
        self.output = output
        self.controller = controller
        self.api = api
        roomApi = room
    }

    func fetchData() {
        // @TODO probably want to start refresh control.

        roomApi.rooms { result in
            switch result {
            case .failure:
                self.output.didFailToFetchRooms()
            case let .success(list):
                self.output.didFetchRooms(rooms: list)
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

    func didSelectRoom(room: String) {
        controller.didSelect(room: room)
    }
}

extension HomeInteractor: RoomControllerDelegate {
    func didJoin(room: String) {
        output.didJoin(room: room)
    }

    func didLeaveRoom() {
        output.didLeaveRoom()
    }

    func reloadRooms() {
        fetchData()
    }
}
