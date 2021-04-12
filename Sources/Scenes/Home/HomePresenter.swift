import Foundation

protocol HomePresenterOutput {
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

    func didJoin(room: String) {
        output.displayCurrentRoom(room)
    }

    func didLeaveRoom() {
        output.removeCurrentRoom()
    }

    func didFetch(feed: Feed) {
        output.display(feed: feed)
    }

    func has(notifications: Bool) {
        output.has(notifications: notifications)
    }
}
