import UIKit

class ActionSheetFactory {
    static func microphoneWarningActionSheet() -> ActionSheet {
        let sheet = ActionSheet(
            title: NSLocalizedString("microphone_permission_denied", comment: ""), // @TODO better text
            image: UIImage(systemName: "mic.circle")
        ) // @TODO

        sheet.add(action: ActionSheet.Action(title: NSLocalizedString("to_settings", comment: ""), style: .default, handler: { _ in
            DispatchQueue.main.async {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
        }))

        return sheet
    }
}
