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
                StatusBadge(state: vm.state)

                if vm.deviceStore.devices.isEmpty {
                    emptyState
                } else {
                    ForEach(vm.deviceStore.devices) { device in
                        row(device)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .top) { header }
        .sheet(isPresented: $isAdding) {
            DeviceFormView(device: TVDevice()) { vm.deviceStore.add($0) }
        }
        .sheet(item: $editing) { device in
            DeviceFormView(device: device) { vm.deviceStore.update($0) }
        }
    }

    private var header: some View {
        HStack {
            Text("TVs").font(Theme.ui(20, weight: .bold))
            Spacer()
            Button { isAdding = true } label: {
                Label("Add", systemImage: "plus")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tv.slash")
                .font(.largeTitle)
                .foregroundColor(Theme.textSubtle)
            Text("No saved TVs")
                .font(Theme.ui(15, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
            Text("Add one with its IP address to get started.")
                .font(Theme.caption(12))
                .foregroundColor(Theme.textMuted)
                .multilineTextAlignment(.center)
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
                    .font(Theme.ui(15, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                Text("\(device.ipAddress) · \(device.useSecure ? "wss" : "ws")")
                    .font(Theme.mono(11))
                    .foregroundColor(Theme.textMuted)
            }
            Spacer(minLength: 0)
            Button("Connect") { vm.connect(to: device) }
                .buttonStyle(GhostButtonStyle())
            Menu {
                Button("Edit") { editing = device }
                Button("Remove", role: .destructive) { vm.deviceStore.remove(device) }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(Theme.textMuted)
                    .frame(width: 32, height: 32)
            }
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
        NavigationStack {
            ZStack {
                AmbientBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        field("Name", text: $device.name)
                        field("IP address", text: $device.ipAddress, keyboard: .numbersAndPunctuation)
                        field("MAC (for Wake-on-LAN)", text: $device.macAddress)

                        Toggle("Secure connection (wss · 8002)", isOn: $device.useSecure)
                            .font(Theme.ui(13))
                            .tint(Theme.accentBright)
                            .padding(.top, 4)
                    }
                    .padding(18)
                }
            }
            .navigationTitle("TV")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave(device); dismiss() }
                        .disabled(device.ipAddress.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func field(_ title: String, text: Binding<String>,
                       keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(Theme.caption(10, weight: .semibold))
                .textCase(.uppercase)
                .foregroundColor(Theme.textMuted)
            TextField("", text: text)
                .font(Theme.mono(14))
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .glassField()
        }
    }
}
