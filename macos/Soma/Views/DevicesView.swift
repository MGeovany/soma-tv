import SwiftUI

/// Manage several TVs: add, edit, select, connect and remove. The current
/// selection and each TV's IP / token / MAC are persisted by `DeviceStore`.
struct DevicesView: View {
    @ObservedObject var vm: TVControllerViewModel

    @State private var editing: TVDevice?
    @State private var isAdding = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TVs").font(.title2.bold())
                Spacer()
                Button { isAdding = true } label: {
                    Label("Add", systemImage: "plus")
                }
            }

            StatusBadge(state: vm.state)

            if vm.deviceStore.devices.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(vm.deviceStore.devices) { device in
                        row(device)
                    }
                }
                .listStyle(.inset)
            }
        }
        .padding()
        .sheet(isPresented: $isAdding) {
            DeviceFormView(device: TVDevice()) { vm.deviceStore.add($0) }
        }
        .sheet(item: $editing) { device in
            DeviceFormView(device: device) { vm.deviceStore.update($0) }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tv.slash").font(.largeTitle).foregroundStyle(.secondary)
            Text("No saved TVs").font(.headline)
            Text("Add one with its IP address to get started.")
                .font(.callout).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func row(_ device: TVDevice) -> some View {
        HStack {
            Image(systemName: vm.deviceStore.selectedID == device.id ? "checkmark.circle.fill" : "tv")
                .foregroundStyle(vm.deviceStore.selectedID == device.id ? Color.accentColor : .secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(device.displayName).font(.body.weight(.medium))
                Text("\(device.ipAddress) · \(device.useSecure ? "wss" : "ws")")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button("Connect") { vm.connect(to: device) }
            Button { editing = device } label: { Image(systemName: "pencil") }
                .buttonStyle(.borderless)
            Button { vm.deviceStore.remove(device) } label: { Image(systemName: "trash") }
                .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
}

/// Add / edit form for a single TV.
struct DeviceFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State var device: TVDevice
    let onSave: (TVDevice) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("TV").font(.headline)
            Form {
                TextField("Name", text: $device.name)
                TextField("IP address", text: $device.ipAddress)
                TextField("MAC (for Wake-on-LAN)", text: $device.macAddress)
                Toggle("Secure connection (wss · 8002)", isOn: $device.useSecure)
            }
            .textFieldStyle(.roundedBorder)

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save") { onSave(device); dismiss() }
                    .buttonStyle(.borderedProminent)
                    .disabled(device.ipAddress.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding()
        .frame(width: 380)
    }
}
