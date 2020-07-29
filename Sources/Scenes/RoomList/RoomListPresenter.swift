//
//  RoomListPresenter.swift
//  Voicely
//
//  Created by Dean Eigenmann on 29.07.20.
//

import UIKit

protocol RoomListPresenterOutput {
    func changedCurrentRoom(_ currentRoom: Int)
    func fetchedRoomList(_ rooms: [APIClient.Room])
    func didBeginRefreshing()
    func didEndRefreshing()
}

class RoomListPresenter: RoomListInteractorOutput {

    var output: RoomListPresenterOutput

    init(output: RoomListPresenterOutput) {
        self.output = output
    }

    func presentRequestInProgress() {
        output.didBeginRefreshing()
    }

    func presentRoomRequestFailed() {
        output.fetchedRoomList([])
        output.didEndRefreshing()
    }

    func presentRooms(_ rooms: [APIClient.Room]) {
        output.fetchedRoomList(rooms)
        output.didEndRefreshing()
    }
}
