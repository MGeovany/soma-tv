import SwiftUI

/// Settings: global keyboard shortcuts and the auto-off sleep timer.
struct SettingsView: View {
    @ObservedObject var vm: TVControllerViewModel

    var body: some View {
        Form {
            Section("Global keyboard shortcuts") {
                Toggle("Enable global shortcuts", isOn: Binding(
                    get: { vm.settings.globalHotKeysEnabled },
                    set: { vm.settings.globalHotKeysEnabled = $0; vm.refreshHotKeys() }
                ))
                ForEach(HotKeyAction.allCases) { action in
                    HStack {
                        Text(action.title)
                        Spacer()
                        ShortcutRecorder(combo: Binding(
                            get: { vm.settings.hotKeys[action] },
                            set: { vm.settings.hotKeys[action] = $0; vm.refreshHotKeys() }
                        ))
                    }
                }
                Text("Shortcuts work even when Soma is in the background. They require at least one modifier key (⌘⌥⌃⇧).")
                    .font(.caption2).foregroundStyle(.secondary)
            }

            Section("Sleep timer") {
                SleepTimerSection(timer: vm.sleepTimer,
                                  isConnected: vm.isConnected,
                                  onStart: { vm.startSleepTimer(minutes: $0) },
                                  onCancel: { vm.cancelSleepTimer() })
            }

            Section("About") {
                Text("Soma uses Samsung's local WebSocket protocol. If a feature doesn't appear or respond, your TV model may not support it; in that case a notice is shown on the control screen.")
                    .font(.callout).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}

/// Sleep-timer controls. Observes the timer directly so the countdown updates.
private struct SleepTimerSection: View {
    @ObservedObject var timer: SleepTimer
    let isConnected: Bool
    let onStart: (Int) -> Void
    let onCancel: () -> Void

    @State private var minutes = 30

    var body: some View {
        if timer.isRunning {
            HStack {
                Text("Turning off in \(timer.displayText)")
                Spacer()
                Button("Cancel", action: onCancel)
            }
        } else {
            Stepper("Minutes: \(minutes)", value: $minutes, in: 1...240, step: 5)
            Button("Start timer") { onStart(minutes) }
                .disabled(!isConnected)
            if !isConnected {
                Text("Connect to the TV to schedule power-off.")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
    }
}
