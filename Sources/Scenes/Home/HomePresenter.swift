import Foundation

protocol HomePresenterOutput {
    func didFetchRooms(rooms: [RoomState])
    func didFetchFeed(_ feed: [APIClient.StoryFeed])
    func didFetchOwnStories(_ stories: [APIClient.Story])
    func displayError(title: String, description: String?)
    func displayCurrentRoom(_ id: Int)
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

    func didFetchRooms(rooms: RoomList) {
        output.didFetchRooms(rooms: rooms.rooms)
    }

    func didJoin(room: Int) {
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
}
