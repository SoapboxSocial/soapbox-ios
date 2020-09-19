import Foundation
import SwiftProtobuf

protocol RoomController {}

protocol HomeInteractorOutput {
    func didFailToFetchRooms()
    func didFetchRooms(rooms: RoomList)
}

class HomeInteractor: HomeViewControllerOutput {
    private let output: HomeInteractorOutput
    private let roomService: RoomServiceClient
    private let controller: RoomController

    init(output: HomeInteractorOutput, service: RoomServiceClient, controller: RoomController) {
        self.output = output
        roomService = service
        self.controller = controller
    }

    func fetchRooms() {
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
    }
}
