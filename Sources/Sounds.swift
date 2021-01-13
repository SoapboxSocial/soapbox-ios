import AVFoundation

class Sounds {
    private static var blopPlayer: AVAudioPlayer?

    static func blop() {
        guard let url = Bundle.main.url(forResource: "blop", withExtension: "mp3") else {
            return
        }

        do {
            blopPlayer = try AVAudioPlayer(contentsOf: url)

            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)

            blopPlayer?.volume = 0.6
            blopPlayer?.play()
        } catch {
            debugPrint("\(error)")
        }
    }
}
