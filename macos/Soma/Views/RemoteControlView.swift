import SwiftUI

/// The full remote, laid out like a physical remote in a narrow column of
/// glass cards: header, power, D-pad, system, media, volume, channels,
/// sources, apps and text. Command clusters are disabled until connected;
/// Wake-on-LAN stays available so an off TV can still be woken.
struct RemoteControlView: View {
    @ObservedObject var vm: TVControllerViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                connectionGroup

                Group {
                    SectionCard("Navigate") {
                        VStack(spacing: 8) {
                            DPadView { vm.send($0) }
                            systemRow
                        }
                    }

                    SectionCard("Media") {
                        VStack(spacing: 6) {
                            mediaRow
                            seekRow
                            utilityRow
                        }
                    }

                    SectionCard("Volume") {
                        VolumeControlsView { vm.send($0) }
                    }

                    SectionCard("Channels") {
                        ChannelControlsView(onKey: { vm.send($0) },
                                            onChannel: { vm.enterChannel($0) })
                    }

                    SectionCard("Sources") {
                        sourcesRow
                        sourcesHint
                    }

                    SectionCard("Apps") {
                        AppsGridView { vm.launch($0) }
                    }

                    SectionCard("Input") {
                        TextInputBar { vm.sendText($0) }
                    }
                }
                .disabled(!vm.isConnected)
            }
            .frame(maxWidth: Theme.columnWidth)
            .padding(.horizontal, Theme.contentPaddingH)
            .padding(.vertical, 14)
        }
        .overlay(alignment: .bottom) { noticeBar }
    }

    // MARK: - Connection

    private var connectionGroup: some View {
        SectionCard("Connection") {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Menu {
                        ForEach(vm.deviceStore.devices) { device in
                            Button(device.displayName) { vm.connect(to: device) }
                        }
                    } label: {
                        Label(vm.deviceStore.selected?.displayName ?? "No device",
                              systemImage: "tv")
                            .font(Theme.heading(12, weight: .semibold))
                            .lineLimit(1)
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

                HStack(spacing: 6) {
                    RemoteButton(symbol: "power", label: "On") { vm.powerOn() }
                    RemoteButton(symbol: "poweroff", label: "Off") { vm.powerOff() }
                        .disabled(!vm.isConnected)
                }
            }
        }
    }

    // MARK: - Rows

    private var systemRow: some View {
        HStack(spacing: 6) {
            RemoteButton(symbol: "arrow.uturn.backward", label: "Back") { vm.send(.back) }
            RemoteButton(symbol: "house.fill", label: "Home") { vm.send(.home) }
            RemoteButton(symbol: "line.3.horizontal", label: "Menu") { vm.send(.menu) }
        }
    }

    // Skip previous / play / skip next.
    private var mediaRow: some View {
        HStack(spacing: 6) {
            RemoteButton(symbol: "backward.end.fill", label: "Prev") { vm.send(.previous) }
            RemoteButton(symbol: "playpause.fill", label: "Play") { vm.send(.playPause) }
            RemoteButton(symbol: "forward.end.fill", label: "Next") { vm.send(.next) }
        }
    }

    // Seek within the current item (fast-forward / rewind).
    private var seekRow: some View {
        HStack(spacing: 6) {
            RemoteButton(symbol: "backward.fill", label: "Rewind") { vm.send(.rewind) }
            RemoteButton(symbol: "forward.fill", label: "Forward") { vm.send(.fastForward) }
        }
    }

    private var utilityRow: some View {
        HStack(spacing: 6) {
            RemoteButton(symbol: "stop.fill", label: "Stop") { vm.send(.stop) }
            RemoteButton(symbol: "escape", label: "Exit") { vm.send(.exit) }
        }
    }

    private var sourcesRow: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                RemoteButton(symbol: "1.square", label: "HDMI1") { vm.send(.hdmi1) }
                RemoteButton(symbol: "2.square", label: "HDMI2") { vm.send(.hdmi2) }
                RemoteButton(symbol: "3.square", label: "HDMI3") { vm.send(.hdmi3) }
            }
            HStack(spacing: 6) {
                RemoteButton(symbol: "tv", label: "TV") { vm.send(.tv) }
                RemoteButton(symbol: "list.bullet.rectangle", label: "Source") { vm.send(.source) }
            }
        }
    }

    private var sourcesHint: some View {
        Text("If the TV doesn't switch source, it may not support direct HDMI keys. Use “Source”.")
            .font(Theme.caption(9))
            .foregroundColor(Theme.textSubtle)
    }

    // MARK: - Notice

    @ViewBuilder
    private var noticeBar: some View {
        if !vm.notice.isEmpty {
            Text(vm.notice)
                .font(Theme.caption(11))
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .glassCard(cornerRadius: 999, highlighted: true)
                .padding(.bottom, 12)
        }
    }
}
