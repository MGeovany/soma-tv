import SwiftUI

/// Main window: control, devices and settings in tabs.
struct ContentView: View {
    @ObservedObject var vm: TVControllerViewModel

    var body: some View {
        TabView {
            RemoteControlView(vm: vm)
                .tabItem { Label("Control", systemImage: "av.remote") }
            DevicesView(vm: vm)
                .tabItem { Label("Devices", systemImage: "tv") }
            SettingsView(vm: vm)
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .frame(minWidth: 360, minHeight: 600)
    }
}
