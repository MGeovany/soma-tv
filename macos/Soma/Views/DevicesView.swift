import SwiftUI

/// Manage several TVs: add, edit, select, connect and remove. The current
/// selection and each TV's IP / token / MAC are persisted by `DeviceStore`.
struct DevicesView: View {
    @ObservedObject var vm: TVControllerViewModel

    @State private var editing: TVDevice?
    @State private var isAdding = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("TVs")
                        .font(Theme.heading(22, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    Spacer()
                    Button { isAdding = true } label: {
                        Label("Add", systemImage: "plus")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }

                StatusBadge(state: vm.state)

                if vm.deviceStore.devices.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 8) {
                        ForEach(vm.deviceStore.devices) { device in
                            row(device)
                        }
                    }
                }
            }
            .padding(16)
        }
        .sheet(isPresented: $isAdding) {
            DeviceFormView(device: TVDevice()) { vm.deviceStore.add($0) }
        }
        .sheet(item: $editing) { device in
            DeviceFormView(device: device) { vm.deviceStore.update($0) }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tv.slash")
                .font(.largeTitle)
                .foregroundColor(Theme.textSubtle)
            Text("No saved TVs")
                .font(Theme.heading(15, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
            Text("Add one with its IP address to get started.")
                .font(Theme.mono(11))
                .foregroundColor(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .glassCard()
    }

    private func row(_ device: TVDevice) -> some View {
        let selected = vm.deviceStore.selectedID == device.id
        return HStack(spacing: 12) {
            Image(systemName: selected ? "checkmark.circle.fill" : "tv")
                .foregroundColor(selected ? Theme.accentBright : Theme.textMuted)
            VStack(alignment: .leading, spacing: 2) {
                Text(device.displayName)
                    .font(Theme.heading(14, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
                Text("\(device.ipAddress) · \(device.useSecure ? "wss" : "ws")")
                    .font(Theme.mono(10))
                    .foregroundColor(Theme.textMuted)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button("Connect") { vm.connect(to: device) }
                .buttonStyle(GhostButtonStyle())
                .fixedSize(horizontal: true, vertical: false)
            Button { editing = device } label: { Image(systemName: "pencil") }
                .buttonStyle(.borderless)
                .foregroundColor(Theme.textMuted)
            Button { vm.deviceStore.remove(device) } label: { Image(systemName: "trash") }
                .buttonStyle(.borderless)
                .foregroundColor(Theme.textMuted)
        }
        .padding(12)
        .glassCard(highlighted: selected)
    }
}

/// Add / edit form for a single TV.
struct DeviceFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State var device: TVDevice
    let onSave: (TVDevice) -> Void

    var body: some View {
        ZStack {
            AmbientBackground()
            VStack(alignment: .leading, spacing: 14) {
                Text("TV")
                    .font(Theme.heading(16, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                field("Name", text: $device.name)
                field("IP address", text: $device.ipAddress)
                field("MAC (for Wake-on-LAN)", text: $device.macAddress)

                Toggle("Secure connection (wss · 8002)", isOn: $device.useSecure)
                    .font(Theme.heading(12))
                    .tint(Theme.accentBright)

                HStack {
                    Spacer()
                    Button("Cancel") { dismiss() }
                        .buttonStyle(GhostButtonStyle())
                    Button("Save") { onSave(device); dismiss() }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(device.ipAddress.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .padding(18)
        }
        .foregroundColor(Theme.textPrimary)
        .frame(width: 400)
    }

    private func field(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(Theme.heading(10, weight: .semibold))
                .textCase(.uppercase).tracking(0.6)
                .foregroundColor(Theme.textMuted)
            TextField("", text: text)
                .accessibilityLabel(Text(title))
                .font(Theme.mono(12))
                .glassField()
                .accessibilityLabel(Text(title))
        }
    }
}
