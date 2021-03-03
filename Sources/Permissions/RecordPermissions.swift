import AVFoundation
import UIKit

final class RecordPermissions {
    static func request(context: UIViewController, callback: @escaping (() -> Void)) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            callback()
        case .denied:
            return showMicrophoneWarning(context)
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        callback()
                    } else {
                        self.showMicrophoneWarning(context)
                    }
                }
            }
        }
    }

    private static func showMicrophoneWarning(_ context: UIViewController) {
        let alert = UIAlertController(
            title: NSLocalizedString("microphone_permission_denied", comment: ""),
            message: nil, preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("to_settings", comment: ""), style: .default, handler: { _ in
            DispatchQueue.main.async {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
        }))

        context.present(alert, animated: true)
    }
}
