import SwiftUI

@main
struct SomaApp: App {
    // Single source of truth shared by the menu-bar remote and the main window.
    @StateObject private var vm = TVControllerViewModel()

    var body: some Scene {
        // Compact remote that lives in the macOS menu bar (top-right).
        MenuBarExtra {
            MenuBarView(vm: vm)
        } label: {
            Image(systemName: vm.state.isConnected ? "av.remote.fill" : "av.remote")
        }
        .menuBarExtraStyle(.window)

        // Main window for configuration and device selection.
        Window("Soma", id: "main") {
            ContentView(vm: vm)
        }
        .defaultSize(width: Theme.wideWindowWidth, height: 620)
        .windowResizability(.contentMinSize)
    }
}
