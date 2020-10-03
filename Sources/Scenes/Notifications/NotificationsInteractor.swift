import Foundation

protocol NotificationsInteractorOutput {
    func presentError()
    func present(notifications: [APIClient.Notification])
}

class NotificationsInteractor: NotificationsViewControllerOutput {
    private let output: NotificationsInteractorOutput

    private let api: APIClient

    init(output: NotificationsInteractorOutput, api: APIClient) {
        self.output = output
        self.api = api
    }

    func loadNotifications() {
        api.notifications(callback: { result in
            switch result {
            case .failure:
                self.output.presentError()
            case let .success(notifications):
                self.output.present(notifications: notifications)
            }
        })
    }
}
