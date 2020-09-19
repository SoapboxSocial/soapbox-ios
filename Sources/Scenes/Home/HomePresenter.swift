import Foundation

protocol HomePresenterOutput {
    func didFetchRooms(rooms: [RoomState])
    func displayError(title: String, description: String?)
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
}
