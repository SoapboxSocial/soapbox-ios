import Foundation

protocol HomePresenterOutput {
    func didFetchFeed(_ feed: [APIClient.StoryFeed])
    func didFetchOwnStories(_ stories: [APIClient.Story])
    func didFetchRooms(_ rooms: [RoomAPIClient.Room])
    func displayError(title: String, description: String?)
    func displayCurrentRoom(_ id: String)
    func display(feed: Feed)
    func has(notifications: Bool)
    func removeCurrentRoom()
}

class HomePresenter: HomeInteractorOutput {
    var output: HomePresenterOutput!

    func didFailToFetchRooms() {
        output.displayError(
            title: NSLocalizedString("failed_to_load_rooms", comment: ""),
            description: NSLocalizedString("please_try_again_later", comment: "")
        )
    }

    func didFetchRooms(rooms: [RoomAPIClient.Room]) {
        output.didFetchRooms(rooms)
    }

    func didJoin(room: String) {
        output.displayCurrentRoom(room)
    }

    func didLeaveRoom() {
        output.removeCurrentRoom()
    }

    func didFetchFeed(_ feed: [APIClient.StoryFeed]) {
        output.didFetchFeed(feed)
    }

    func didFetchOwnStories(_ stories: [APIClient.Story]) {
        output.didFetchOwnStories(stories)
    }

    func didFetch(feed: Feed) {
        output.display(feed: feed)
    }

    func has(notifications: Bool) {
        output.has(notifications: notifications)
    }
}
