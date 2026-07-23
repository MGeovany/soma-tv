import SwiftUI

/// Settings: global keyboard shortcuts and the auto-off sleep timer.
struct SettingsView: View {
    @ObservedObject var vm: TVControllerViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                SectionCard("Shortcuts") {
                    VStack(spacing: 12) {
                        SettingsToggleRow(
                            title: "Enable global shortcuts",
                            isOn: Binding(
                                get: { vm.settings.globalHotKeysEnabled },
                                set: { vm.settings.globalHotKeysEnabled = $0; vm.refreshHotKeys() }
                            )
                        )

                        VStack(spacing: 0) {
                            ForEach(Array(HotKeyAction.allCases.enumerated()), id: \.element.id) { index, action in
                                if index > 0 {
                                    SettingsDivider()
                                }
                                SettingsShortcutRow(
                                    title: action.title,
                                    combo: Binding(
                                        get: { vm.settings.hotKeys[action] },
                                        set: { vm.settings.hotKeys[action] = $0; vm.refreshHotKeys() }
                                    )
                                )
                            }
                        }
                        .opacity(vm.settings.globalHotKeysEnabled ? 1 : 0.45)
                        .disabled(!vm.settings.globalHotKeysEnabled)

                        Text("Shortcuts work in the background. Use at least one modifier: ⌘ ⌥ ⌃ ⇧.")
                            .font(Theme.caption(10))
                            .foregroundColor(Theme.textSubtle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                SectionCard("Sleep timer") {
                    SleepTimerSection(
                        timer: vm.sleepTimer,
                        isConnected: vm.isConnected,
                        onStart: { vm.startSleepTimer(minutes: $0) },
                        onCancel: { vm.cancelSleepTimer() }
                    )
                }

                SectionCard("About") {
                    Text("Soma uses Samsung's local WebSocket protocol. Unsupported features show a notice on the control screen.")
                        .font(Theme.caption(11))
                        .foregroundColor(Theme.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineSpacing(2)
                }
            }
            .frame(maxWidth: Theme.wideColumnWidth)
            .padding(.horizontal, Theme.contentPaddingH)
            .padding(.vertical, 14)
        }
    }
}

// MARK: - Rows

private struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(Theme.ui(12, weight: .medium))
                .foregroundColor(Theme.textPrimary)
        }
        .toggleStyle(.switch)
        .tint(Theme.accentBright)
    }
}

private struct SettingsShortcutRow: View {
    let title: String
    @Binding var combo: KeyCombo?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(title)
                .font(Theme.ui(12, weight: .medium))
                .foregroundColor(Theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ShortcutRecorder(combo: $combo)
        }
        .padding(.vertical, 4)
    }
}

private struct SettingsDivider: View {
    var body: some View {
        Rectangle()
            .fill(Theme.border)
            .frame(height: 1)
            .padding(.vertical, 6)
    }
}

// MARK: - Sleep timer

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
                        .font(Theme.ui(22, weight: .semibold))
                        .foregroundColor(Theme.accentBright)
                }

                Spacer(minLength: 0)

                Button("Cancel", action: onCancel)
                    .buttonStyle(GhostButtonStyle())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusInput, style: .continuous)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusInput, style: .continuous)
                    .strokeBorder(Theme.border, lineWidth: 1)
            )
        } else {
            VStack(spacing: 10) {
                Stepper(value: $minutes, in: 1...240, step: 5) {
                    Text("\(minutes) min")
                        .font(Theme.ui(12, weight: .medium))
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
