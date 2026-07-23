import SwiftUI

/// Shows the current connection / authorization / error state clearly, with a
/// spinner while a connection attempt is in progress. Rendered as a colored
/// card so the state is always obvious ("connecting…", "connected", errors).
struct StatusBadge: View {
    let state: ConnectionState

    var body: some View {
        HStack(spacing: 8) {
            if state.isBusy {
                ProgressView()
                    .controlSize(.small)
            } else {
                Image(systemName: state.symbolName)
            }
            Text(state.title)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
        .font(.callout.weight(.medium))
        .foregroundStyle(state.tint)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(state.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
        .animation(.default, value: state)
    }
}
