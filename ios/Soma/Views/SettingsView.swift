import SwiftUI

/// Settings: the auto-off sleep timer and app info. (Global keyboard shortcuts
/// are macOS-only and omitted on iOS.)
struct SettingsView: View {
    @ObservedObject var vm: TVControllerViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Settings")
                    .font(Theme.ui(20, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                SectionCard("Sleep timer") {
                    SleepTimerSection(
                        timer: vm.sleepTimer,
                        isConnected: vm.isConnected,
                        onStart: { vm.startSleepTimer(minutes: $0) },
                        onCancel: { vm.cancelSleepTimer() }
                    )
                }

                SectionCard("About") {
                    Text("Soma uses Samsung's local WebSocket protocol. Unsupported features show a notice on the control screen. Your iPhone and the TV must be on the same Wi-Fi network.")
                        .font(Theme.caption(12))
                        .foregroundColor(Theme.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineSpacing(2)
                }
            }
            .padding(16)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct SleepTimerSection: View {
    @ObservedObject var timer: SleepTimer
    let isConnected: Bool
    let onStart: (Int) -> Void
    let onCancel: () -> Void

    @State private var minutes = 30

    var body: some View {
        if timer.isRunning {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Turning off in")
                        .font(Theme.caption(10))
                        .foregroundColor(Theme.textMuted)
                    Text(timer.displayText)
                        .font(Theme.mono(24, weight: .semibold))
                        .foregroundColor(Theme.accentBright)
                }
                Spacer(minLength: 0)
                Button("Cancel", action: onCancel)
                    .buttonStyle(GhostButtonStyle())
            }
        } else {
            VStack(spacing: 10) {
                Stepper(value: $minutes, in: 1...240, step: 5) {
                    Text("\(minutes) min")
                        .font(Theme.ui(13, weight: .medium))
                        .foregroundColor(Theme.textPrimary)
                }
                Button("Start timer") { onStart(minutes) }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: .infinity)
                if !isConnected {
                    Text("Connect to the TV to schedule power-off.")
                        .font(Theme.caption(10))
                        .foregroundColor(Theme.textSubtle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}
