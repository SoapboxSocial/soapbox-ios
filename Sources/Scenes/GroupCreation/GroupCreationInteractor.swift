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
        case name, describe, invite
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

    func create(name _: String, image _: UIImage?, description _: String?, visibility _: Int) {}
}
