import SwiftUI

/// The full remote: device picker, status, navigation, system, media, volume,
/// channels, sources, apps and text input. Command clusters are disabled until
/// the TV is connected; Wake-on-LAN stays available so an off TV can be woken.
struct RemoteControlView: View {
    @ObservedObject var vm: TVControllerViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header

                Group {
                    DPadView { vm.send($0) }
                    systemRow
                    mediaRow
                    VolumeChannelView(onKey: { vm.send($0) },
                                      onChannel: { vm.enterChannel($0) })
                    sourcesSection
                    AppsGridView { vm.launch($0) }
                    TextInputBar { vm.sendText($0) }
                }
                .disabled(!vm.isConnected)
            }
            .padding()
        }
        .overlay(alignment: .bottom) { noticeBar }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 10) {
            HStack {
                Menu {
                    ForEach(vm.deviceStore.devices) { device in
                        Button(device.displayName) { vm.connect(to: device) }
                    }
                } label: {
                    Label(vm.deviceStore.selected?.displayName ?? "Sin dispositivo",
                          systemImage: "tv")
                }
                .disabled(vm.deviceStore.devices.isEmpty)

                Spacer()

                Button(vm.isConnected ? "Desconectar" : "Conectar") {
                    vm.toggleConnection()
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.deviceStore.selected == nil)
            }

            StatusBadge(state: vm.state)

            HStack(spacing: 8) {
                RemoteButton(symbol: "power", label: "Encender") { vm.powerOn() }
                RemoteButton(symbol: "poweroff", label: "Apagar") { vm.powerOff() }
                    .disabled(!vm.isConnected)
            }
        }
    }

    // MARK: - Rows

    private var systemRow: some View {
        HStack(spacing: 8) {
            RemoteButton(symbol: "house", label: "Home") { vm.send(.home) }
            RemoteButton(symbol: "arrow.uturn.backward", label: "Atrás") { vm.send(.back) }
            RemoteButton(symbol: "line.3.horizontal", label: "Menú") { vm.send(.menu) }
            RemoteButton(symbol: "escape", label: "Salir") { vm.send(.exit) }
        }
    }

    private var mediaRow: some View {
        HStack(spacing: 8) {
            RemoteButton(symbol: "backward.fill", label: "Rebobinar") { vm.send(.rewind) }
            RemoteButton(symbol: "playpause.fill", label: "Play") { vm.send(.playPause) }
            RemoteButton(symbol: "forward.fill", label: "Avanzar") { vm.send(.fastForward) }
            RemoteButton(symbol: "stop.fill", label: "Detener") { vm.send(.stop) }
        }
    }

    private var sourcesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Fuentes").font(.headline)
            HStack(spacing: 8) {
                RemoteButton(symbol: "list.bullet.rectangle", label: "Fuente") { vm.send(.source) }
                RemoteButton(symbol: "tv", label: "TV") { vm.send(.tv) }
                RemoteButton(symbol: "1.square", label: "HDMI1") { vm.send(.hdmi1) }
                RemoteButton(symbol: "2.square", label: "HDMI2") { vm.send(.hdmi2) }
                RemoteButton(symbol: "3.square", label: "HDMI3") { vm.send(.hdmi3) }
            }
            Text("Si el televisor no cambia de fuente, es posible que no admita el salto directo a HDMI. Usa «Fuente».")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Notice

    @ViewBuilder
    private var noticeBar: some View {
        if !vm.notice.isEmpty {
            Text(vm.notice)
                .font(.callout)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.thinMaterial, in: Capsule())
                .padding(.bottom, 10)
                .transition(.opacity)
        }
    }
}
