import SwiftUI
import UIKit

@main
struct SomaApp: App {
    @StateObject private var vm = TVControllerViewModel()

    init() { Self.configureAppearance() }

    var body: some Scene {
        WindowGroup {
            RootView(vm: vm)
        }
    }

    /// Dark, translucent tab bar to match the glass UI.
    private static func configureAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = UIColor(white: 0.02, alpha: 0.6)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
