import SwiftUI

/// Volume, mute and channel controls, plus direct channel entry.
struct VolumeChannelView: View {
    let onKey: (RemoteKey) -> Void
    let onChannel: (String) -> Void

    @State private var channel = ""

    var body: some View {
        VStack(spacing: 8) {
            // Mute in the middle.
            HStack(spacing: 8) {
                RemoteButton(symbol: "speaker.wave.1.fill", label: "Vol −") { onKey(.volumeDown) }
                RemoteButton(symbol: "speaker.slash.fill", label: "Mute") { onKey(.mute) }
                RemoteButton(symbol: "speaker.wave.2.fill", label: "Vol +") { onKey(.volumeUp) }
            }
            HStack(spacing: 8) {
                RemoteButton(symbol: "chevron.down.circle", label: "Ch −") { onKey(.channelDown) }
                RemoteButton(symbol: "list.bullet", label: "List") { onKey(.channelList) }
                RemoteButton(symbol: "chevron.up.circle", label: "Ch +") { onKey(.channelUp) }
            }
            HStack(spacing: 8) {
                TextField("Channel no.", text: $channel)
                    .font(Theme.mono(15))
                    .keyboardType(.numberPad)
                    .glassField()
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
