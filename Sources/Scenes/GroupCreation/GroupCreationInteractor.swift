import Foundation
import UIKit

protocol GroupCreationInteractorOutput {
    func present(error: GroupCreationInteractor.Error)
    func present(state: GroupCreationInteractor.State)
}

class GroupCreationInteractor: GroupCreationViewControllerOutput {
    enum Error {
        case invalidName
    }

    enum State: Int, CaseIterable {
        case name, describe, invite, success
    }

    private let output: GroupCreationInteractorOutput
    private let api: APIClient

    init(output: GroupCreationInteractorOutput, api: APIClient) {
        self.output = output
        self.api = api
    }

    func submit(name: String?) {
        guard let text = name, text != "", text.count <= 256 else {
            return output.present(error: .invalidName)
        }

        output.present(state: .describe)
    }

    func create(name: String, image: UIImage?, description: String?, visibility: Int) {
        api.createGroup(name: name, type: typeFor(visibility: visibility), description: description, image: image, callback: { _ in
            // @TODO
        })
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
