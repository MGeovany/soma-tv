import SwiftUI

/// Root tab bar: Remote, Devices and Settings — the mobile shell.
struct RootView: View {
    @ObservedObject var vm: TVControllerViewModel

    var body: some View {
        TabView {
            screen { RemoteControlView(vm: vm) }
                .tabItem { Label("Remote", systemImage: "av.remote.fill") }

            screen { DevicesView(vm: vm) }
                .tabItem { Label("Devices", systemImage: "tv") }

            screen { SettingsView(vm: vm) }
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(Theme.accentBright)
        .preferredColorScheme(.dark)
    }

    /// Wraps a screen with the ambient background behind a safe-area-aware body.
    private func screen<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        ZStack {
            AmbientBackground()
            content()
        }
    }
}
