import AVFoundation

class Sounds {
    private static var blopPlayer: AVAudioPlayer?

    static func blop() {
        guard let url = Bundle.main.url(forResource: "blop", withExtension: "mp3") else {
            return
        }

        do {
            blopPlayer = try AVAudioPlayer(contentsOf: url)

            blopPlayer?.volume = 0.6

            DispatchQueue.global(qos: .background).async {
                self.blopPlayer?.play()
            }
        } catch {
            debugPrint("\(error)")
        }
    }
}
