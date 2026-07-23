import SwiftUI

struct ContentView: View {
    @StateObject private var tv = SamsungTVController()
    @State private var ipAddress: String = ""
    @State private var useSecure: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Soma")
                .font(.largeTitle.bold())

            // IP + connect
            HStack {
                TextField("TV IP address (e.g. 192.168.1.50)", text: $ipAddress)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { tv.connect(ip: ipAddress, secure: useSecure) }

                Button("Connect") {
                    tv.connect(ip: ipAddress, secure: useSecure)
                }
            }

            // Transport selector
            Picker("Transport", selection: $useSecure) {
                Text("ws:// (8001)").tag(false)
                Text("wss:// (8002)").tag(true)
            }
            .pickerStyle(.segmented)

            // Status
            Text(tv.status)
                .font(.callout)
                .foregroundStyle(tv.isConnected ? .green : .secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 60, alignment: .top)

            Divider()

            // Controls
            HStack(spacing: 16) {
                Button("Vol +") { tv.sendKey("KEY_VOLUP") }
                Button("Vol −") { tv.sendKey("KEY_VOLDOWN") }
                Button("Mute")  { tv.sendKey("KEY_MUTE") }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!tv.isConnected)

            Spacer()
        }
        .padding(24)
    }
}

#Preview {
    ContentView()
}
