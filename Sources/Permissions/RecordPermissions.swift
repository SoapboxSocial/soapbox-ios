import AVFoundation
import UIKit

final class RecordPermissions {
    static func request(failure: @escaping (() -> Void), success: @escaping (() -> Void)) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            success()
        case .denied:
            failure()
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        success()
                    } else {
                        failure()
                    }
                }
            }
        }
    }
}
