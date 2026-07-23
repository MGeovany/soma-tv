import SwiftUI

/// A grid of launchable Smart TV apps (YouTube, Netflix, Prime Video, …).
struct AppsGridView: View {
    let onLaunch: (TVApp) -> Void

    private let columns = [GridItem(.adaptive(minimum: 96), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(TVApp.presets) { app in
                RemoteButton(symbol: app.symbolName, label: app.name) { onLaunch(app) }
            }
        }
    }
}
