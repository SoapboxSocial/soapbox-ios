import Foundation
import KeychainAccess
import SwiftProtobuf

class Feed {
    var rooms = [RoomAPIClient.Room]()
    var stories = [APIClient.StoryFeed]()
    var ownStory = [APIClient.Story]()
    var actives = [APIClient.ActiveUser]()
}

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
    func didJoin(room: String)
    func didLeaveRoom()
    func didFetch(feed: Feed)
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
        let feed = Feed()

        let group = DispatchGroup()

        group.enter()
        roomApi.rooms(callback: { result in
            group.leave()
            switch result {
            case .failure:
                self.output.didFailToFetchRooms() // @TODO
            case let .success(list):
                feed.rooms = list
            }
        })

        let user = UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId)

        group.enter()
        api.stories(user: user, callback: { result in
            group.leave()
            switch result {
            case .failure:
                break
            case let .success(stories):
                feed.ownStory = stories
            }
        })

        group.enter()
        api.feed(callback: { result in
            group.leave()
            switch result {
            case .failure:
                break
            case let .success(stories):
                feed.stories = stories.sorted(by: {
                    ($0.stories.map { $0.deviceTimestamp }.max() ?? 0) > ($1.stories.map { $0.deviceTimestamp }.max() ?? 0)
                })
            }
        })

        group.enter()
        api.actives(callback: { result in
            group.leave()
            switch result {
            case .failure:
                break
            case let .success(actives):
                feed.actives = actives
            }
        })

        group.notify(queue: .main) {
            self.output.didFetch(feed: feed)
        }
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

    // @TODO seems like this is called too early
    func reloadRooms() {
        fetchData()
    }
}
