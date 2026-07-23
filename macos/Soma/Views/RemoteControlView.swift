import SwiftUI

/// The full remote, laid out like a physical remote in a narrow column:
/// power, D-pad, system, media, volume, channels, sources, apps and text.
/// Command clusters are disabled until the TV is connected; Wake-on-LAN stays
/// available so an off TV can still be woken.
struct RemoteControlView: View {
    @ObservedObject var vm: TVControllerViewModel

    /// Keeps the control column narrow, like a real remote.
    private let columnWidth: CGFloat = 300

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                header
                powerRow

                Group {
                    DPadView { vm.send($0) }
                    systemRow
                    mediaRow
                    utilityRow
                    VolumeChannelView(onKey: { vm.send($0) },
                                      onChannel: { vm.enterChannel($0) })
                    sourcesSection
                    AppsGridView { vm.launch($0) }
                    TextInputBar { vm.sendText($0) }
                }
                .disabled(!vm.isConnected)
            }
            .frame(maxWidth: columnWidth)
            .frame(maxWidth: .infinity) // center the column
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
                    Label(vm.deviceStore.selected?.displayName ?? "No device",
                          systemImage: "tv")
                }
                .disabled(vm.deviceStore.devices.isEmpty)

                Spacer()

                Button(vm.isConnected ? "Disconnect" : "Connect") {
                    vm.toggleConnection()
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.deviceStore.selected == nil)
            }

            StatusBadge(state: vm.state)
        }
    }

    private var powerRow: some View {
        HStack(spacing: 8) {
            RemoteButton(symbol: "power", label: "Power On") { vm.powerOn() }
            RemoteButton(symbol: "poweroff", label: "Power Off") { vm.powerOff() }
                .disabled(!vm.isConnected)
        }
    }

    // MARK: - Rows

    // Home in the middle.
    private var systemRow: some View {
        HStack(spacing: 8) {
            RemoteButton(symbol: "arrow.uturn.backward", label: "Back") { vm.send(.back) }
            RemoteButton(symbol: "house.fill", label: "Home") { vm.send(.home) }
            RemoteButton(symbol: "line.3.horizontal", label: "Menu") { vm.send(.menu) }
        }
    }

    // Play/Pause in the middle.
    private var mediaRow: some View {
        HStack(spacing: 8) {
            RemoteButton(symbol: "backward.fill", label: "Rewind") { vm.send(.rewind) }
            RemoteButton(symbol: "playpause.fill", label: "Play") { vm.send(.playPause) }
            RemoteButton(symbol: "forward.fill", label: "Forward") { vm.send(.fastForward) }
        }
    }

    private var utilityRow: some View {
        HStack(spacing: 8) {
            RemoteButton(symbol: "stop.fill", label: "Stop") { vm.send(.stop) }
            RemoteButton(symbol: "escape", label: "Exit") { vm.send(.exit) }
        }
    }

    // HDMI 1–3, then TV, then Source.
    private var sourcesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Sources").font(.headline)
            HStack(spacing: 8) {
                RemoteButton(symbol: "1.square", label: "HDMI1") { vm.send(.hdmi1) }
                RemoteButton(symbol: "2.square", label: "HDMI2") { vm.send(.hdmi2) }
                RemoteButton(symbol: "3.square", label: "HDMI3") { vm.send(.hdmi3) }
                RemoteButton(symbol: "tv", label: "TV") { vm.send(.tv) }
                RemoteButton(symbol: "list.bullet.rectangle", label: "Source") { vm.send(.source) }
            }
            Text("If the TV doesn't switch source, it may not support direct HDMI keys. Use “Source”.")
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
