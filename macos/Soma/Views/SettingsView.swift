import SwiftUI

/// Settings: global keyboard shortcuts and the auto-off sleep timer.
struct SettingsView: View {
    @ObservedObject var vm: TVControllerViewModel

    var body: some View {
        Form {
            Section("Atajos globales de teclado") {
                Toggle("Activar atajos globales", isOn: Binding(
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
                Text("Los atajos funcionan aunque Soma esté en segundo plano. Requieren al menos una tecla modificadora (⌘⌥⌃⇧).")
                    .font(.caption2).foregroundStyle(.secondary)
            }

            Section("Temporizador de apagado") {
                SleepTimerSection(timer: vm.sleepTimer,
                                  isConnected: vm.isConnected,
                                  onStart: { vm.startSleepTimer(minutes: $0) },
                                  onCancel: { vm.cancelSleepTimer() })
            }

            Section("Información") {
                Text("Soma usa el protocolo WebSocket local de Samsung. Si una función no aparece o no responde, es posible que tu modelo de televisor no la admita; en ese caso se mostrará un aviso en la pantalla de control.")
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
                Text("Se apagará en \(timer.displayText)")
                Spacer()
                Button("Cancelar", action: onCancel)
            }
        } else {
            Stepper("Minutos: \(minutes)", value: $minutes, in: 1...240, step: 5)
            Button("Iniciar temporizador") { onStart(minutes) }
                .disabled(!isConnected)
            if !isConnected {
                Text("Conéctate al televisor para programar el apagado.")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
    }
}
