import Foundation
import SwiftProtobuf

protocol HomeInteractorOutput {
    func didFailToFetchRooms()
    func didFetchRooms(rooms: RoomList)
}

class HomeInteractor: HomeViewControllerOutput {
    private let output: HomeInteractorOutput
    private let roomService: RoomServiceClient

    init(output: HomeInteractorOutput, service: RoomServiceClient) {
        self.output = output
        roomService = service
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
