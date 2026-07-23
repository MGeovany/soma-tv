import SwiftUI

/// Connection / authorization / error state as a glass pill. Connected shows a
/// status dot; connecting shows a spinner; other states show an icon.
struct StatusBadge: View {
    let state: ConnectionState

    var body: some View {
        HStack(spacing: 8) {
            leading
            Text(state.title)
                .font(Theme.ui(12, weight: .semibold))
                .foregroundColor(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusInput, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusInput, style: .continuous)
                .strokeBorder(tint.opacity(0.28), lineWidth: 1)
        )
        .animation(.default, value: state)
    }

    @ViewBuilder
    private var leading: some View {
        if state.isConnected {
            LiveDot()
        } else if state.isBusy {
            ProgressView().controlSize(.small).tint(Theme.accentBright)
        } else {
            Image(systemName: state.symbolName).foregroundColor(tint)
        }
    }

    private var tint: Color {
        switch state {
        case .connected:                          return Theme.success
        case .connecting, .awaitingAuthorization: return Theme.accentBright
        case .unauthorized, .error:               return Theme.error
        case .disconnected:                        return Theme.textMuted
        }
    }
}
