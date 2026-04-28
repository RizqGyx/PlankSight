import AVFoundation
import Foundation

final class PlankVoiceCoach {
    struct Configuration {
        var languageCode: String = "id-ID"
        var minimumSpeakInterval: TimeInterval = 1.0
        var samePhraseCooldown: TimeInterval = 4.0
        var speechRate: Float = AVSpeechUtteranceDefaultSpeechRate * 0.9
        var speechPitch: Float = 1.0
    }

    private let synthesizer = AVSpeechSynthesizer()
    private let configuration: Configuration
    private var lastSpokenAt: TimeInterval = -1
    private var lastSpokenByPhrase: [String: TimeInterval] = [:]

    init(configuration: Configuration = .init()) {
        self.configuration = configuration
    }

    func speak(
        _ phrase: String,
        now: TimeInterval,
        force: Bool = false,
        samePhraseCooldown: TimeInterval? = nil
    ) {
        let normalized = phrase.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return }
        let effectiveCooldown = max(0, samePhraseCooldown ?? configuration.samePhraseCooldown)

        if !force {
            if lastSpokenAt >= 0, now - lastSpokenAt < configuration.minimumSpeakInterval { return }
            if let previous = lastSpokenByPhrase[normalized], now - previous < effectiveCooldown { return }
        }

        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }

        let utterance = AVSpeechUtterance(string: normalized)
        utterance.voice = AVSpeechSynthesisVoice(language: configuration.languageCode)
        utterance.rate = configuration.speechRate
        utterance.pitchMultiplier = configuration.speechPitch
        utterance.prefersAssistiveTechnologySettings = true

        synthesizer.speak(utterance)
        lastSpokenAt = now
        lastSpokenByPhrase[normalized] = now
    }

    func reset() {
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
        lastSpokenAt = -1
        lastSpokenByPhrase = [:]
    }
}
