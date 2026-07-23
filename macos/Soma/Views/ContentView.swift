import SwiftUI

/// Main window: control, devices and settings in tabs.
struct ContentView: View {
    @ObservedObject var vm: TVControllerViewModel

    var body: some View {
        TabView {
            RemoteControlView(vm: vm)
                .tabItem { Label("Control", systemImage: "av.remote") }
            DevicesView(vm: vm)
                .tabItem { Label("Dispositivos", systemImage: "tv") }
            SettingsView(vm: vm)
                .tabItem { Label("Ajustes", systemImage: "gearshape") }
        }
        .frame(minWidth: 420, minHeight: 600)
    }
}
