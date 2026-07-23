import SwiftUI
import AppKit

/// Keeps the main window width matched to the active sidebar section.
struct WindowWidthSync: NSViewRepresentable {
    let width: CGFloat

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        view.isHidden = true
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            guard let window = nsView.window else { return }
            var frame = window.frame
            guard abs(frame.width - width) > 0.5 else { return }
            frame.size.width = width
            window.setFrame(frame, display: true, animate: false)
        }
    }
}
