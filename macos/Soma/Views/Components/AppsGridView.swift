import SwiftUI

/// A grid of launchable Smart TV apps (YouTube, Netflix, Prime Video, …).
struct AppsGridView: View {
    var compact: Bool = false
    let onLaunch: (TVApp) -> Void

    private var columns: [GridItem] {
        compact
            ? Array(repeating: GridItem(.flexible(), spacing: 6), count: 3)
            : [GridItem(.adaptive(minimum: 72), spacing: 6)]
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(TVApp.presets) { app in
                if compact {
                    compactTile(app)
                } else {
                    RemoteButton(symbol: app.symbolName, label: app.name) { onLaunch(app) }
                }
            }
        }
    }

    private func compactTile(_ app: TVApp) -> some View {
        Button { onLaunch(app) } label: {
            VStack(spacing: 4) {
                Image(systemName: app.symbolName)
                    .font(.system(size: 14, weight: .medium))
                Text(app.shortName)
                    .font(Theme.caption(8, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 38)
        }
        .buttonStyle(RemoteTileStyle())
        .help(app.name)
    }
}

private extension TVApp {
    var shortName: String {
        switch name {
        case "Prime Video": return "Prime"
        case "HBO Max":     return "HBO"
        default:            return name
        }
    }
}
