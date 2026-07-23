import SwiftUI

/// A wide field for typing text and sending it to the TV's focused input.
struct TextInputBar: View {
    let onSend: (String) -> Void

    @State private var text = ""

    private var isEmpty: Bool {
        text.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Type text and send it to the TV…", text: $text)
                .glassField()
                .submitLabel(.send)
                .onSubmit(send)
            Button("Send", action: send)
                .buttonStyle(PrimaryButtonStyle())
                .frame(maxWidth: .infinity)
                .disabled(isEmpty)
        }
    }

    private func send() {
        onSend(text)
        text = ""
    }
}
