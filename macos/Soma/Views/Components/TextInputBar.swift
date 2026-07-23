import SwiftUI

/// A field for typing text and sending it to the TV's focused input.
struct TextInputBar: View {
    let onSend: (String) -> Void

    @State private var text = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Enviar texto").font(.headline)
            HStack {
                TextField("Escribe y envía al televisor…", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(send)
                Button("Enviar", action: send)
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func send() {
        onSend(text)
        text = ""
    }
}
