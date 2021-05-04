import UIKit

class SettingsPresenter: SettingsTable {
    func set(links: [Link]) {
        dataSource.append(Section(title: nil, data: links))
    }

    func set(appearance: [Selection]) {
        dataSource.append(Section(title: NSLocalizedString("appearance", comment: ""), data: appearance))
    }

    func set(deleteAccount: Destructive) {
        dataSource.append(Section(title: nil, data: [deleteAccount]))
    }

    func set(notifications: Plain) {
        dataSource.append(Section(title: nil, data: [notifications]))
    }
}
