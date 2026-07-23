import SwiftUI
import AppKit

/// Compact remote shown from the macOS menu bar. Keeps the essentials one click
/// away — navigation, volume, apps and a text-entry modal; the full window is
/// for setup and everything else.
struct MenuBarView: View {
    @ObservedObject var vm: TVControllerViewModel
    @Environment(\.openWindow) private var openWindow

    @State private var showTextInput = false

    var body: some View {
        VStack(spacing: 12) {
            Group {
                DPadView { vm.send($0) }

                HStack(spacing: 8) {
                    RemoteButton(symbol: "arrow.uturn.backward", label: "Back") { vm.send(.back) }
                    RemoteButton(symbol: "house.fill", label: "Home") { vm.send(.home) }
                    RemoteButton(symbol: "playpause.fill", label: "Play") { vm.send(.playPause) }
                }
                HStack(spacing: 8) {
                    RemoteButton(symbol: "speaker.wave.1.fill", label: "Vol −") { vm.send(.volumeDown) }
                    RemoteButton(symbol: "speaker.slash.fill", label: "Mute") { vm.send(.mute) }
                    RemoteButton(symbol: "speaker.wave.2.fill", label: "Vol +") { vm.send(.volumeUp) }
                }

                AppsGridView { vm.launch($0) }

                Button {
                    showTextInput = true
                } label: {
                    Label("Send text…", systemImage: "keyboard")
                        .frame(maxWidth: .infinity)
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
                Button("Settings…") {
                    openWindow(id: "main")
                    NSApp.activate(ignoringOtherApps: true)
                }
                Spacer()
                Button("Quit") { NSApp.terminate(nil) }
            }
        }
        .padding(12)
        .frame(width: 280)
        .sheet(isPresented: $showTextInput) {
            TextInputModal { vm.sendText($0) }
        }
    }
}

/// A small modal for typing text and sending it to the TV.
private struct TextInputModal: View {
    @Environment(\.dismiss) private var dismiss
    let onSend: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            TextInputBar { text in
                onSend(text)
                dismiss()
            }
            Button("Close") { dismiss() }
                .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(width: 320)
    }
}
