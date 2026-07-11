import AVFoundation
import UIKit

final class SoundManager {
    static let shared = SoundManager()
    private init() {}

    func playCorrect() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func playWrong() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    func playResult() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
