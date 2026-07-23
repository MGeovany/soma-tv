import SwiftUI

/// The full remote, laid out like a physical remote in a narrow column of
/// glass cards: header, power, D-pad, system, media, volume, channels,
/// sources, apps and text. Command clusters are disabled until connected;
/// Wake-on-LAN stays available so an off TV can still be woken.
struct RemoteControlView: View {
    @ObservedObject var vm: TVControllerViewModel

    private let columnWidth: CGFloat = 320

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                header

                Group {
                    SectionCard {
                        VStack(spacing: 10) {
                            DPadView { vm.send($0) }
                            systemRow
                        }
                    }
                    SectionCard("Media") { mediaRow; utilityRow }
                    SectionCard("Volume & Channels") {
                        VolumeChannelView(onKey: { vm.send($0) },
                                          onChannel: { vm.enterChannel($0) })
                    }
                    SectionCard("Sources") { sourcesRow; sourcesHint }
                    SectionCard("Apps") { AppsGridView { vm.launch($0) } }
                    SectionCard("Send text") { TextInputBar { vm.sendText($0) } }
                }
                .disabled(!vm.isConnected)
            }
            .frame(maxWidth: columnWidth)
            .frame(maxWidth: .infinity)
            .padding(16)
        }
        .overlay(alignment: .bottom) { noticeBar }
    }

    // MARK: - Header

    private var header: some View {
        SectionCard {
            VStack(spacing: 10) {
                HStack {
                    Menu {
                        ForEach(vm.deviceStore.devices) { device in
                            Button(device.displayName) { vm.connect(to: device) }
                        }
                    } label: {
                        Label(vm.deviceStore.selected?.displayName ?? "No device",
                              systemImage: "tv")
                            .font(Theme.heading(13, weight: .semibold))
                    }
                    .menuStyle(.borderlessButton)
                    .disabled(vm.deviceStore.devices.isEmpty)

                    Spacer()

                    if vm.isConnected {
                        Button("Disconnect") { vm.toggleConnection() }
                            .buttonStyle(GhostButtonStyle())
                            .disabled(vm.deviceStore.selected == nil)
                    } else {
                        Button("Connect") { vm.toggleConnection() }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(vm.deviceStore.selected == nil)
                    }
                }

                StatusBadge(state: vm.state)

                HStack(spacing: 8) {
                    RemoteButton(symbol: "power", label: "Power On") { vm.powerOn() }
                    RemoteButton(symbol: "poweroff", label: "Power Off") { vm.powerOff() }
                        .disabled(!vm.isConnected)
                }
            }
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
    private var sourcesRow: some View {
        HStack(spacing: 8) {
            RemoteButton(symbol: "1.square", label: "HDMI1") { vm.send(.hdmi1) }
            RemoteButton(symbol: "2.square", label: "HDMI2") { vm.send(.hdmi2) }
            RemoteButton(symbol: "3.square", label: "HDMI3") { vm.send(.hdmi3) }
            RemoteButton(symbol: "tv", label: "TV") { vm.send(.tv) }
            RemoteButton(symbol: "list.bullet.rectangle", label: "Source") { vm.send(.source) }
        }
    }

    private var sourcesHint: some View {
        Text("If the TV doesn't switch source, it may not support direct HDMI keys. Use “Source”.")
            .font(Theme.mono(9))
            .foregroundColor(Theme.textSubtle)
    }

    // MARK: - Notice

    @ViewBuilder
    private var noticeBar: some View {
        if !vm.notice.isEmpty {
            Text(vm.notice)
                .font(Theme.mono(11))
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .glassCard(cornerRadius: 999, highlighted: true)
                .padding(.bottom, 12)
                .transition(.opacity)
        }
    }
}
