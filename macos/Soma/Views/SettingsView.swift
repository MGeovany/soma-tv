import SwiftUI

/// Settings: global keyboard shortcuts and the auto-off sleep timer.
struct SettingsView: View {
    @ObservedObject var vm: TVControllerViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Settings")
                    .font(Theme.heading(22, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                SectionCard("Global keyboard shortcuts") {
                    Toggle("Enable global shortcuts", isOn: Binding(
                        get: { vm.settings.globalHotKeysEnabled },
                        set: { vm.settings.globalHotKeysEnabled = $0; vm.refreshHotKeys() }
                    ))
                    .font(Theme.heading(12))
                    .tint(Theme.accentBright)

                    ForEach(HotKeyAction.allCases) { action in
                        HStack {
                            Text(action.title)
                                .font(Theme.heading(12))
                                .foregroundColor(Theme.textPrimary)
                            Spacer()
                            ShortcutRecorder(combo: Binding(
                                get: { vm.settings.hotKeys[action] },
                                set: { vm.settings.hotKeys[action] = $0; vm.refreshHotKeys() }
                            ))
                        }
                    }

                    Text("Shortcuts work even when Soma is in the background. They require at least one modifier key (⌘⌥⌃⇧).")
                        .font(Theme.mono(9))
                        .foregroundColor(Theme.textSubtle)
                }

                SectionCard("Sleep timer") {
                    SleepTimerSection(timer: vm.sleepTimer,
                                      isConnected: vm.isConnected,
                                      onStart: { vm.startSleepTimer(minutes: $0) },
                                      onCancel: { vm.cancelSleepTimer() })
                }

                SectionCard("About") {
                    Text("Soma uses Samsung's local WebSocket protocol. If a feature doesn't appear or respond, your TV model may not support it; in that case a notice is shown on the control screen.")
                        .font(Theme.mono(10))
                        .foregroundColor(Theme.textMuted)
                }
            }
            .padding(16)
        }
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
                Text("Turning off in")
                    .font(Theme.heading(12))
                    .foregroundColor(Theme.textMuted)
                Text(timer.displayText)
                    .font(Theme.mono(20, weight: .bold))
                    .foregroundColor(Theme.accentBright)
                Spacer()
                Button("Cancel", action: onCancel)
                    .buttonStyle(GhostButtonStyle())
            }
        } else {
            Stepper(value: $minutes, in: 1...240, step: 5) {
                Text("Minutes: \(minutes)")
                    .font(Theme.heading(12))
                    .foregroundColor(Theme.textPrimary)
            }
            Button("Start timer") { onStart(minutes) }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!isConnected)
            if !isConnected {
                Text("Connect to the TV to schedule power-off.")
                    .font(Theme.mono(9))
                    .foregroundColor(Theme.textSubtle)
            }
        }
    }
}
