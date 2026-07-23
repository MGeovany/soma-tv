import SwiftUI

/// A grid of launchable Smart TV apps (YouTube, Netflix, Prime Video, …).
struct AppsGridView: View {
    let onLaunch: (TVApp) -> Void

    private let columns = [GridItem(.adaptive(minimum: 88), spacing: 8)]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Aplicaciones").font(.headline)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(TVApp.presets) { app in
                    Button { onLaunch(app) } label: {
                        VStack(spacing: 4) {
                            Image(systemName: app.symbolName).font(.title2)
                            Text(app.name).font(.caption).lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, minHeight: 54)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
}
