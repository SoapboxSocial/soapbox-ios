import Foundation

protocol HomePresenterOutput {
    func didFetchRooms(rooms: [RoomState])
    func didFetchGroups(groups: [APIClient.Group])
    func didFetchMoreGroups(groups: [APIClient.Group])
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

    func didFetchGroups(groups: [APIClient.Group]) {
        output.didFetchGroups(groups: groups)
    }

    func didFetchMoreGroups(groups: [APIClient.Group]) {
        output.didFetchMoreGroups(groups: groups)
    }

    func didFetchOwnStories(_ stories: [APIClient.Story]) {
        output.didFetchOwnStories(stories)
    }
}
