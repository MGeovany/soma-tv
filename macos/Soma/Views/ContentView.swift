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
                content
            }
        }
        .foregroundColor(Theme.textPrimary)
        .tint(Theme.accentBright)
        .frame(width: activeWindowWidth)
        .frame(minHeight: 580, idealHeight: 620)
        .fixedSize(horizontal: true, vertical: false)
        .background(WindowWidthSync(width: activeWindowWidth))
    }

    private var activeContentWidth: CGFloat {
        switch section {
        case .control: Theme.contentPaneWidth
        case .devices, .settings: Theme.wideContentPaneWidth
        }
    }

    private var activeWindowWidth: CGFloat {
        Theme.railWidth + activeContentWidth
    }

    // MARK: - Navigation rail

    private var rail: some View {
        VStack(spacing: 6) {
            ForEach(Section.allCases) { item in
                railButton(item)
            }
            Spacer(minLength: 0)
            LiveDot(color: vm.state.isConnected ? Theme.success : Theme.textSubtle)
        }
        .padding(.horizontal, 8)
        .padding(.top, 32)
        .padding(.bottom, 14)
        .frame(width: Theme.railWidth)
        .background(GlassRailBackground())
    }

    private func railButton(_ item: Section) -> some View {
        let selected = section == item
        return Button {
            section = item
        } label: {
            Image(systemName: item.symbol)
                .font(.system(size: 16, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(selected ? .white : Theme.textMuted)
                .frame(width: 36, height: 36)
                .background {
                    if selected {
                        GlassButtonBackground(cornerRadius: 10, accent: true)
                    } else {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.white.opacity(0.04))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(Theme.border.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
        }
        .buttonStyle(.plain)
        .help(item.title)
        .accessibilityLabel(Text(item.title))
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        Group {
            switch section {
            case .control:  RemoteControlView(vm: vm)
            case .devices:  DevicesView(vm: vm)
            case .settings: SettingsView(vm: vm)
            }
        }
        .frame(width: activeContentWidth)
    }
}
