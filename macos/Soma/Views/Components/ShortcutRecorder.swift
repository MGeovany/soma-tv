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
                    .frame(minWidth: 150)
            }
            if combo != nil {
                Button {
                    combo = nil
                    stop()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(.borderless)
                .help("Quitar atajo")
            }
        }
        .onDisappear(perform: stop)
    }

    private var label: String {
        if isRecording { return "Pulsa una combinación…" }
        return combo?.displayString ?? "Sin asignar"
    }

    private func toggle() {
        isRecording ? stop() : start()
    }

    private func start() {
        isRecording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Ignore lone modifier presses; require at least one modifier so
            // the shortcut is safe to register globally.
            let combo = KeyCombo(event: event)
            if combo.modifiers != 0 {
                self.combo = combo
                self.stop()
                return nil // swallow the event
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
