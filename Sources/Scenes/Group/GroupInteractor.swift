import Foundation

protocol GroupInteractorOutput {
    func present(group: APIClient.Group)
    func present(inviter: APIClient.User)
    func presentInviteAccepted()
    func presentInviteDeclined()
    func presentJoined()
    func presentError()
}

class GroupInteractor: GroupViewControllerOutput {
    private let output: GroupInteractorOutput
    private let api: APIClient
    private let group: Int

    init(output: GroupInteractorOutput, api: APIClient, group: Int) {
        self.output = output
        self.api = api
        self.group = group
    }

    func loadData() {
        api.group(id: group, callback: { result in
            switch result {
            case .failure:
                self.output.presentError()
            case let .success(group):

                if group.isInvited ?? false {
                    self.loadInvite()
                }

                self.output.present(group: group)
            }
        })
    }

    func acceptInvite() {
        api.acceptInvite(id: group, callback: { result in
            switch result {
            case .failure:
                self.output.presentError()
            case .success:
                self.output.presentInviteAccepted()
            }
        })
    }

    func declineInvite() {
        api.declineInvite(id: group, callback: { result in
            switch result {
            case .failure:
                self.output.presentError()
            case .success:
                self.output.presentInviteDeclined()
            }
        })
    }

    func join() {
        api.join(group: group, callback: { result in
            switch result {
            case .failure:
                self.output.presentError()
            case .success:
                self.output.presentJoined()
            }
        })
    }

    private func loadInvite() {
        api.getInvite(id: group, callback: { result in
            switch result {
            case .failure: break
            case let .success(inviter):
                self.output.present(inviter: inviter)
            }
        })
    }
}
