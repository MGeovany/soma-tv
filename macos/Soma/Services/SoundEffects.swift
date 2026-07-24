import AVFoundation

/// Synthesized UI sound effects: a satisfying mechanical-keyboard "click" when
/// a control is pressed and a soft "tick" when the pointer hovers it (macOS).
///
/// The waveforms are rendered once into PCM buffers at first use and played
/// through a shared, always-running `AVAudioEngine` for low-latency feedback,
/// so there are no audio assets to bundle.
final class SoundEffects {
    static let shared = SoundEffects()

    /// Master switch for all UI sounds.
    var isEnabled = true

    enum Effect { case click, hover }

    private let engine = AVAudioEngine()
    private let clickNode = AVAudioPlayerNode()
    private let hoverNode = AVAudioPlayerNode()
    private var clickBuffer: AVAudioPCMBuffer?
    private var hoverBuffer: AVAudioPCMBuffer?
    private var configured = false
    private let queue = DispatchQueue(label: "com.soma.soundeffects", qos: .userInitiated)

    private init() {}

    /// Plays the given effect. Safe to call from any thread; no-op when disabled
    /// or if the audio engine could not start.
    func play(_ effect: Effect) {
        guard isEnabled else { return }
        queue.async { [weak self] in
            guard let self else { return }
            self.configureIfNeeded()
            guard self.engine.isRunning else { return }
            switch effect {
            case .click:
                if let buffer = self.clickBuffer {
                    self.clickNode.scheduleBuffer(buffer, at: nil, options: .interrupts)
                }
            case .hover:
                if let buffer = self.hoverBuffer {
                    self.hoverNode.scheduleBuffer(buffer, at: nil, options: .interrupts)
                }
            }
        }
    }

    private func configureIfNeeded() {
        guard !configured else { return }
        configured = true

        let sampleRate = 44_100.0
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else {
            configured = false
            return
        }

        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        // Ambient: mixes with other audio and respects the ring/silent switch.
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
        #endif

        engine.attach(clickNode)
        engine.attach(hoverNode)
        engine.connect(clickNode, to: engine.mainMixerNode, format: format)
        engine.connect(hoverNode, to: engine.mainMixerNode, format: format)

        clickBuffer = SoundEffects.renderClick(format: format, sampleRate: sampleRate)
        hoverBuffer = SoundEffects.renderHover(format: format, sampleRate: sampleRate)

        do {
            try engine.start()
            clickNode.play()
            hoverNode.play()
        } catch {
            configured = false
        }
    }

    // MARK: - Synthesis

    /// A short mechanical key press: a noisy attack transient, a low resonant
    /// "thock" body and a crisp mid tap.
    private static func renderClick(format: AVAudioFormat, sampleRate: Double) -> AVAudioPCMBuffer? {
        let duration = 0.06
        let frames = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames),
              let channel = buffer.floatChannelData else { return nil }
        buffer.frameLength = frames

        var seed: UInt64 = 0x9E3779B97F4A7C15
        for i in 0..<Int(frames) {
            let t = Double(i) / sampleRate

            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            let noise = Double(Int64(bitPattern: seed) >> 40) / Double(1 << 23)
            let transient = noise * exp(-t / 0.0018) * 0.5

            let thock = sin(2 * .pi * 165 * t) * exp(-t / 0.022) * 0.5
            let tap = sin(2 * .pi * 1200 * t) * exp(-t / 0.005) * 0.22

            let sample = max(-1, min(1, (transient + thock + tap) * 0.7))
            channel[0][i] = Float(sample)
        }
        return buffer
    }

    /// A quiet, soft high-frequency tick for pointer hover.
    private static func renderHover(format: AVAudioFormat, sampleRate: Double) -> AVAudioPCMBuffer? {
        let duration = 0.03
        let frames = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames),
              let channel = buffer.floatChannelData else { return nil }
        buffer.frameLength = frames

        for i in 0..<Int(frames) {
            let t = Double(i) / sampleRate
            let env = exp(-t / 0.006)
            let tone = sin(2 * .pi * 2200 * t) * 0.6 + sin(2 * .pi * 3300 * t) * 0.2
            let sample = max(-1, min(1, tone * env * 0.09))
            channel[0][i] = Float(sample)
        }
        return buffer
    }
}
