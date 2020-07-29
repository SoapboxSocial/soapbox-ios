//
//  RoomListInteractor.swift
//  Voicely
//
//  Created by Dean Eigenmann on 29.07.20.
//

import UIKit

protocol RoomListInteractorOutput {
    func presentRequestInProgress()
    func presentRooms(_ rooms: [APIClient.Room])
    func presentRoomRequestFailed()
}

class RoomListInteractor: RoomListViewControllerOutput {

    private var api: APIClient!

    private var output: RoomListInteractorOutput!

    var currentRoom: Int?

    init(output: RoomListInteractorOutput, api: APIClient) {
        self.api = api
        self.output = output
    }

    func loadRooms() {

        output.presentRequestInProgress()

        api.rooms { result in
            switch result {
            case .failure:
                self.output.presentRoomRequestFailed()
            case var .success(rooms):
                if let current = self.currentRoom {
                    rooms.sort {
                        ($0.id == current) && !($1.id == current)
                    }
                }

                self.output.presentRooms(rooms)
            }
        }
    }

    func didSelectRoom(id: Int) {
        // @todo
    }

}
