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
        ZStack {
            AmbientBackground()

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
                    .buttonStyle(GhostButtonStyle())
                }
                .disabled(!vm.isConnected)

                if !vm.notice.isEmpty {
                    Text(vm.notice)
                        .font(Theme.mono(10))
                        .foregroundColor(Theme.textMuted)
                        .lineLimit(2)
                }

                Divider().overlay(Theme.border)

                HStack {
                    Button("Settings…") {
                        openWindow(id: "main")
                        NSApp.activate(ignoringOtherApps: true)
                    }
                    .buttonStyle(GhostButtonStyle())
                    Spacer()
                    Button("Quit") { NSApp.terminate(nil) }
                        .buttonStyle(GhostButtonStyle())
                }
            }
            .padding(12)
        }
        .foregroundColor(Theme.textPrimary)
        .tint(Theme.accentBright)
        .frame(width: 288)
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
        ZStack {
            AmbientBackground()
            VStack(alignment: .leading, spacing: 14) {
                Text("Send text")
                    .font(Theme.heading(15, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                TextInputBar { text in
                    onSend(text)
                    dismiss()
                }
                Button("Close") { dismiss() }
                    .buttonStyle(GhostButtonStyle())
                    .frame(maxWidth: .infinity)
            }
            .padding(18)
        }
        .foregroundColor(Theme.textPrimary)
        .tint(Theme.accentBright)
        .frame(width: 340)
    }
}
