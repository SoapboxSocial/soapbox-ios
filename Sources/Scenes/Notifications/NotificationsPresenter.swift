import Foundation

protocol NotificationsPresenterOutput {
    func display(notifications: [APIClient.Notification])
    func displayError()
}

class NotificationsPresenter: NotificationsInteractorOutput {
    private var output: NotificationsPresenterOutput

    init(output: NotificationsPresenterOutput) {
        self.output = output
    }
    
    func presentError() {
        output.displayError()
    }

    func present(notifications: [APIClient.Notification]) {
        output.display(notifications: notifications)
    }
}
