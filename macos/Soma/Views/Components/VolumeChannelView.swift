import SwiftUI

/// Volume, mute and channel controls, plus direct channel entry.
struct VolumeChannelView: View {
    let onKey: (RemoteKey) -> Void
    let onChannel: (String) -> Void

    @State private var channel = ""

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                RemoteButton(symbol: "speaker.wave.2.fill", label: "Vol +") { onKey(.volumeUp) }
                RemoteButton(symbol: "speaker.wave.1.fill", label: "Vol −") { onKey(.volumeDown) }
                RemoteButton(symbol: "speaker.slash.fill", label: "Silencio") { onKey(.mute) }
            }
            HStack(spacing: 8) {
                RemoteButton(symbol: "chevron.up.circle", label: "Canal +") { onKey(.channelUp) }
                RemoteButton(symbol: "chevron.down.circle", label: "Canal −") { onKey(.channelDown) }
                RemoteButton(symbol: "list.bullet", label: "Lista") { onKey(.channelList) }
            }
            HStack {
                TextField("N.º de canal", text: $channel)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)
                    .onSubmit(go)
                Button("Ir", action: go)
                    .disabled(channel.isEmpty)
            }
        }
    }

    private func go() {
        onChannel(channel)
        channel = ""
    }
}
