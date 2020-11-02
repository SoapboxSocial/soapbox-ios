import Foundation
import UIKit

protocol GroupCreationInteractorOutput {
    func present(error: GroupCreationInteractor.Error)
    func present(state: GroupCreationInteractor.State, id: Int?)
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
        debugPrint(users)
        if users.isEmpty {
            return output.present(state: .success, id: id)
        }
    }

    private func typeFor(visibility: Int) -> String {
        switch visibility {
        case 1:
            return "private"
        case 2:
            return "restricted"
        default:
            return "public"
        }
    }
}
