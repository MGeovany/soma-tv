import SwiftUI

/// Volume and mute controls.
struct VolumeControlsView: View {
    let onKey: (RemoteKey) -> Void

    var body: some View {
        HStack(spacing: 6) {
            RemoteButton(symbol: "speaker.wave.1.fill", label: "Vol −") { onKey(.volumeDown) }
            RemoteButton(symbol: "speaker.slash.fill", label: "Mute") { onKey(.mute) }
            RemoteButton(symbol: "speaker.wave.2.fill", label: "Vol +") { onKey(.volumeUp) }
        }
    }
}

/// Channel up/down, list and direct entry.
struct ChannelControlsView: View {
    let onKey: (RemoteKey) -> Void
    let onChannel: (String) -> Void

    @State private var channel = ""

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                RemoteButton(symbol: "chevron.down.circle", label: "Ch −") { onKey(.channelDown) }
                RemoteButton(symbol: "list.bullet", label: "List") { onKey(.channelList) }
                RemoteButton(symbol: "chevron.up.circle", label: "Ch +") { onKey(.channelUp) }
            }
            HStack(spacing: 6) {
                TextField("Channel no.", text: $channel)
                    .font(Theme.mono(13))
                    .glassField()
                    .frame(maxWidth: .infinity)
                    .onSubmit(go)
                Button("Go", action: go)
                    .buttonStyle(GhostButtonStyle())
                    .disabled(channel.isEmpty)
            }
        }
    }

    private func go() {
        onChannel(channel)
        channel = ""
    }
}

/// Volume, mute and channel controls — kept for callers that want both together.
struct VolumeChannelView: View {
    let onKey: (RemoteKey) -> Void
    let onChannel: (String) -> Void

    var body: some View {
        VStack(spacing: 6) {
            VolumeControlsView(onKey: onKey)
            ChannelControlsView(onKey: onKey, onChannel: onChannel)
        }
    }
}
