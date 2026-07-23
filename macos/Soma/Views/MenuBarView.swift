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
            MinimalPanelBackground()

            ScrollView {
                VStack(spacing: 14) {
                    SectionCard("Connection") { headerBarContent }

                    Group {
                        SectionCard("Navigate") {
                            VStack(spacing: 8) {
                                DPadView { vm.send($0) }
                                HStack(spacing: 6) {
                                    RemoteButton(symbol: "arrow.uturn.backward", label: "Back") { vm.send(.back) }
                                    RemoteButton(symbol: "house.fill", label: "Home") { vm.send(.home) }
                                    RemoteButton(symbol: "line.3.horizontal", label: "Menu") { vm.send(.menu) }
                                }
                            }
                        }

                        SectionCard("Media") {
                            VStack(spacing: 6) {
                                HStack(spacing: 6) {
                                    RemoteButton(symbol: "backward.fill", label: "Rew") { vm.send(.rewind) }
                                    RemoteButton(symbol: "playpause.fill", label: "Play") { vm.send(.playPause) }
                                    RemoteButton(symbol: "forward.fill", label: "Fwd") { vm.send(.fastForward) }
                                }
                                HStack(spacing: 6) {
                                    RemoteButton(symbol: "stop.fill", label: "Stop") { vm.send(.stop) }
                                    RemoteButton(symbol: "escape", label: "Exit") { vm.send(.exit) }
                                }
                            }
                        }

                        SectionCard("Volume") {
                            VolumeControlsView { vm.send($0) }
                        }

                        SectionCard("Apps") {
                            AppsGridView(compact: true) { vm.launch($0) }
                        }

                        SectionCard("Input") {
                            Button {
                                showTextInput = true
                            } label: {
                                Label("Send text…", systemImage: "keyboard")
                                    .font(Theme.ui(11, weight: .medium))
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(GhostButtonStyle())
                        }
                    }
                    .disabled(!vm.isConnected)

                    if !vm.notice.isEmpty {
                        Text(vm.notice)
                            .font(Theme.caption(10))
                            .foregroundColor(Theme.textMuted)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 2)
                    }

                    footer
                }
                .padding(12)
            }
        }
        .foregroundColor(Theme.textPrimary)
        .tint(Theme.accentBright)
        .frame(width: Theme.contentPaneWidth, height: 620)
        .fixedSize()
        .sheet(isPresented: $showTextInput) {
            TextInputModal { vm.sendText($0) }
        }
    }

    private var headerBarContent: some View {
        HStack(spacing: 8) {
            LiveDot(color: vm.state.isConnected ? Theme.success : Theme.textSubtle)
            Text(vm.deviceStore.selected?.displayName ?? "No device")
                .font(Theme.ui(12, weight: .medium))
                .lineLimit(1)
            Spacer(minLength: 0)
            Text(vm.state.isConnected ? "Connected" : vm.state.title)
                .font(Theme.caption(10))
                .foregroundColor(vm.state.isConnected ? Theme.success : Theme.textMuted)
                .lineLimit(1)
        }
    }

    private var footer: some View {
        VStack(spacing: 10) {
            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)

            HStack {
                Button("Settings") {
                    openWindow(id: "main")
                    NSApp.activate(ignoringOtherApps: true)
                }
                .buttonStyle(.plain)
                .font(Theme.caption(11))
                .foregroundColor(Theme.textMuted)

                Spacer()

                Button("Quit") { NSApp.terminate(nil) }
                    .buttonStyle(.plain)
                    .font(Theme.caption(11))
                    .foregroundColor(Theme.textMuted)
            }
        }
    }
}

/// A small modal for typing text and sending it to the TV.
private struct TextInputModal: View {
    @Environment(\.dismiss) private var dismiss
    let onSend: (String) -> Void

    var body: some View {
        ZStack {
            MinimalPanelBackground()
            VStack(alignment: .leading, spacing: 14) {
                Text("Send text")
                    .font(Theme.ui(15, weight: .semibold))
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
        .frame(width: 320)
    }
}
