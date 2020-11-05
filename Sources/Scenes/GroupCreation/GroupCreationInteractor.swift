import Foundation
import UIKit

protocol GroupCreationInteractorOutput {
    func present(error: GroupCreationInteractor.Error)
    func present(state: GroupCreationInteractor.State, id: Int?)
    func present(friends: [APIClient.User])
}

class GroupCreationInteractor: GroupCreationViewControllerOutput {
    enum Error {
        case invalidName, failedToCreate
    }

    enum State: Int, CaseIterable {
        case name, describe, invite, success
    }

    private let output: GroupCreationInteractorOutput
    private let api: APIClient

    private var id: Int!

    init(output: GroupCreationInteractorOutput, api: APIClient) {
        self.output = output
        self.api = api
    }

    func submit(name: String?) {
        guard let text = name, text != "", text.count <= 256 else {
            return output.present(error: .invalidName)
        }

        output.present(state: .describe, id: nil)
    }

    func create(name: String, image: UIImage?, description: String?, visibility: Int) {
        api.createGroup(name: name, type: typeFor(visibility: visibility), description: description, image: image, callback: { result in
            switch result {
            case .failure:
                self.output.present(error: .failedToCreate)
            case let .success(id):
                self.id = id
                self.output.present(state: .invite, id: nil)
            }
        })
    }

    func invite(users: [Int]) {
        if users.isEmpty {
            return output.present(state: .success, id: id)
        }

        api.inviteGroupMembers(id: id, users: users, callback: { _ in
            // @TODO
            self.output.present(state: .success, id: self.id)
        })
    }

    func fetchFriends() {
        api.friends { result in
            switch result {
            case .failure: break
            case let .success(users):
                self.output.present(friends: users)
            }
        }
    }

    private func typeFor(visibility: Int) -> APIClient.GroupType {
        switch visibility {
        case 1:
            return APIClient.GroupType.private
        case 2:
            return APIClient.GroupType.restricted
        default:
            return APIClient.GroupType.public
        }
    }
}
