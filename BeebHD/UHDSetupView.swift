// SPDX-License-Identifier: GPL-3.0-or-later
import SwiftUI

@MainActor final class UHDSetupState: ObservableObject {
    @Published var link = ""
    @Published var message: String?
    @Published var busy = false
    @Published var configured = UHDIdentityVault.isConfigured
    func connect() {
        busy = true; message = nil
        let value = link
        Task {
            defer { busy = false }
            do {
                let client = try UHDProvisioningClient(link: value)
                let payload = try await client.retrieve()
                try UHDIdentityVault.install(payload)
                link = ""; configured = UHDIdentityVault.isConfigured
                message = "Connected. 4K playback now runs directly on Apple TV. You can close the Mac helper."
            } catch { message = error.localizedDescription }
        }
    }
}
struct UHDSetupView: View {
    @StateObject private var state = UHDSetupState()
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("4K HLG · TwinVine").font(.title2).bold()
            Text(state.configured ? "UHD identity connected" : "One-time setup required").foregroundStyle(state.configured ? .green : .secondary)
            Text("Run setup-uhd.command on your Mac. Paste its setup URL here using the iPhone Remote keyboard. After connecting once, the Mac is no longer needed for playback.")
                .font(.callout).foregroundStyle(.secondary)
            TextField("One-time setup URL", text: $state.link)
            HStack(spacing: 24) {
                Button(state.busy ? "Connecting…" : "Connect TwinVine") { state.connect() }.disabled(state.busy || state.link.isEmpty)
                if state.configured {
                    Button("Forget UHD identity") { UHDIdentityVault.remove(); state.configured = false; state.message = "UHD identity removed from this Apple TV." }
                }
            }
            if let message = state.message { Text(message).font(.callout) }
        }.onAppear { state.configured = UHDIdentityVault.isConfigured }
    }
}
