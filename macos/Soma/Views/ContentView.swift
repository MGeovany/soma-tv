import SwiftUI

/// Main window shell: a narrow glass navigation rail on the left and the
/// selected screen on the right, over the ambient background.
struct ContentView: View {
    @ObservedObject var vm: TVControllerViewModel
    @State private var section: Section = .control

    enum Section: String, CaseIterable, Identifiable {
        case control, devices, settings
        var id: String { rawValue }
        var symbol: String {
            switch self {
            case .control:  return "av.remote"
            case .devices:  return "tv"
            case .settings: return "gearshape"
            }
        }
        var title: String {
            switch self {
            case .control:  return "Control"
            case .devices:  return "Devices"
            case .settings: return "Settings"
            }
        }
    }

    var body: some View {
        ZStack {
            AmbientBackground()

            HStack(spacing: 0) {
                rail
                Divider().overlay(Theme.border)
                content
            }
        }
        .foregroundColor(Theme.textPrimary)
        .tint(Theme.accentBright)
        .frame(minWidth: 380, minHeight: 620)
    }

    // MARK: - Navigation rail

    private var rail: some View {
        VStack(spacing: 10) {
            ForEach(Section.allCases) { item in
                railButton(item)
            }
            Spacer()
            LiveDot(color: vm.state.isConnected ? Theme.success : Theme.textSubtle)
                .padding(.bottom, 10)
        }
        .padding(.vertical, 14)
        .frame(width: 56)
        .background(.ultraThinMaterial)
        .background(Theme.glassGradient)
        .overlay(alignment: .trailing) {
            Rectangle().fill(Theme.border).frame(width: 1)
        }
    }

    private func railButton(_ item: Section) -> some View {
        let selected = section == item
        return Button {
            section = item
        } label: {
            Image(systemName: item.symbol)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(selected ? Theme.accentBright : Theme.textMuted)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(selected ? Theme.accentSoft : Color.clear)
                )
                .overlay(alignment: .leading) {
                    if selected {
                        Capsule().fill(Theme.accentGradient)
                            .frame(width: 2, height: 22)
                            .offset(x: -9)
                    }
                }
        }
        .buttonStyle(.plain)
        .help(item.title)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch section {
        case .control:  RemoteControlView(vm: vm)
        case .devices:  DevicesView(vm: vm)
        case .settings: SettingsView(vm: vm)
        }
    }
}
