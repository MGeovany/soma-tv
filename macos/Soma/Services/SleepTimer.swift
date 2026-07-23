import Foundation
import Combine

/// Fires a single action after a delay and publishes the remaining time so the
/// UI can show a countdown. Used to power the TV off automatically.
@MainActor
final class SleepTimer: ObservableObject {
    @Published private(set) var remaining: TimeInterval = 0
    @Published private(set) var isRunning = false

    private var timer: Timer?
    private var deadline: Date?
    private var onFire: (() -> Void)?

    func start(minutes: Int, onFire: @escaping () -> Void) {
        cancel()
        guard minutes > 0 else { return }
        self.onFire = onFire

        let interval = TimeInterval(minutes * 60)
        deadline = Date().addingTimeInterval(interval)
        remaining = interval
        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
        deadline = nil
        isRunning = false
        remaining = 0
    }

    private func tick() {
        guard let deadline else { return }
        remaining = max(0, deadline.timeIntervalSinceNow)
        if remaining <= 0 {
            let fire = onFire
            cancel()
            fire?()
        }
    }

    /// mm:ss for display.
    var displayText: String {
        let total = Int(remaining.rounded())
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
