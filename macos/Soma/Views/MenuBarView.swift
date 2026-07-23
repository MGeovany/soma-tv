import SwiftUI
import AppKit

/// Compact remote shown from the macOS menu bar. Keeps the essentials one click
/// away; the full window is for setup and everything else.
struct MenuBarView: View {
    @ObservedObject var vm: TVControllerViewModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                StatusBadge(state: vm.state)
                Button(vm.isConnected ? "Desconectar" : "Conectar") {
                    vm.toggleConnection()
                }
                .disabled(vm.deviceStore.selected == nil)
            }

            Divider()

            Group {
                DPadView { vm.send($0) }

                HStack(spacing: 8) {
                    RemoteButton(symbol: "house", label: "Home") { vm.send(.home) }
                    RemoteButton(symbol: "arrow.uturn.backward", label: "Atrás") { vm.send(.back) }
                    RemoteButton(symbol: "playpause.fill", label: "Play") { vm.send(.playPause) }
                }
                HStack(spacing: 8) {
                    RemoteButton(symbol: "speaker.wave.2.fill", label: "Vol +") { vm.send(.volumeUp) }
                    RemoteButton(symbol: "speaker.wave.1.fill", label: "Vol −") { vm.send(.volumeDown) }
                    RemoteButton(symbol: "speaker.slash.fill", label: "Silencio") { vm.send(.mute) }
                }
            }
            .disabled(!vm.isConnected)

            if !vm.notice.isEmpty {
                Text(vm.notice)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Divider()

            HStack {
                Button("Configuración…") {
                    openWindow(id: "main")
                    NSApp.activate(ignoringOtherApps: true)
                }
                Spacer()
                Button("Salir") { NSApp.terminate(nil) }
            }
        }
        .padding(12)
        .frame(width: 280)
    }
}
