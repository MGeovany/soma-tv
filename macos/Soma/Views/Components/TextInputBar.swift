import SwiftUI

/// A wide field for typing text and sending it to the TV's focused input.
struct TextInputBar: View {
    let onSend: (String) -> Void

    @State private var text = ""

    private var isEmpty: Bool {
        text.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Send text").font(.headline)
            TextField("Type text and send it to the TV…", text: $text)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity)
                .onSubmit(send)
            Button("Send", action: send)
                .frame(maxWidth: .infinity)
                .disabled(isEmpty)
        }
    }

    private func send() {
        onSend(text)
        text = ""
    }
}
