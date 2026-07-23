import SwiftUI
import AppKit

/// Records a global keyboard shortcut. While recording, a local event monitor
/// captures the next key press and turns it into a `KeyCombo`.
struct ShortcutRecorder: View {
    @Binding var combo: KeyCombo?

    @State private var isRecording = false
    @State private var monitor: Any?

    var body: some View {
        HStack(spacing: 6) {
            Button(action: toggle) {
                Text(label)
                    .font(Theme.mono(11))
                    .foregroundColor(isRecording ? Theme.accentBright : Theme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .frame(minWidth: 112, maxWidth: 140)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .background(
                GlassButtonBackground(
                    cornerRadius: 8,
                    accent: isRecording,
                    pressed: isRecording
                )
            )

            if combo != nil {
                Button {
                    combo = nil
                    stop()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textMuted)
                }
                .buttonStyle(.plain)
                .help("Remove shortcut")
            }
        }
        .onDisappear(perform: stop)
    }

    private var label: String {
        if isRecording { return "Press keys…" }
        return combo?.displayString ?? "Not set"
    }

    private func toggle() {
        isRecording ? stop() : start()
    }

    private func start() {
        isRecording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let combo = KeyCombo(event: event)
            if combo.modifiers != 0 {
                self.combo = combo
                self.stop()
                return nil
            }
            return event
        }
    }

    private func stop() {
        isRecording = false
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}
