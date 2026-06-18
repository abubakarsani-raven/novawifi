import SwiftUI
import NetworkExtension

// MARK: - Model

struct WifiCredentials {
    let ssid: String
    let password: String
    let label: String

    /// Decodes from the App Clip URL fragment.
    /// Expected format: https://appclip.novaheronix.com/wifi#d=<base64json>
    /// JSON payload: {"s":"SSID","p":"password","l":"Label"}
    init?(url: URL) {
        guard
            let fragment = url.fragment,
            fragment.hasPrefix("d="),
            let encoded = fragment.dropFirst(2).removingPercentEncoding,
            let data = Data(base64Encoded: encoded),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
            let s = json["s"], !s.isEmpty
        else { return nil }

        ssid = s
        password = json["p"] ?? ""
        label = json["l"] ?? ""
    }
}

// MARK: - Connection state

enum ConnectionState: Equatable {
    case idle
    case connecting
    case connected
    case alreadyConnected
    case failed(String)
}

// MARK: - View

struct WifiConnectView: View {
    @State private var credentials: WifiCredentials?
    @State private var connectionState: ConnectionState = .idle

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Spacer()
                contentCard
                Spacer()
                footer
            }
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
            guard let url = activity.webpageURL else { return }
            credentials = WifiCredentials(url: url)
            connectionState = .idle
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "wifi.circle.fill")
                .font(.system(size: 72))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.accentColor)
                .padding(.top, 48)

            Text("Nova Heronix")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .kerning(1.5)
        }
    }

    // MARK: Card

    private var contentCard: some View {
        VStack(spacing: 20) {
            if let creds = credentials {
                networkInfo(creds: creds)
                Divider()
                actionArea(creds: creds)
            } else {
                waitingPrompt
            }
        }
        .padding(24)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        .padding(.horizontal, 24)
    }

    private func networkInfo(creds: WifiCredentials) -> some View {
        VStack(spacing: 6) {
            Text(creds.label.isEmpty ? creds.ssid : creds.label)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            if !creds.label.isEmpty {
                Text(creds.ssid)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func actionArea(creds: WifiCredentials) -> some View {
        switch connectionState {
        case .idle:
            connectButton(creds: creds)

        case .connecting:
            HStack(spacing: 12) {
                ProgressView()
                Text("Connecting…")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)

        case .connected:
            statusLabel(
                icon: "checkmark.circle.fill",
                text: "Connected to \(creds.ssid)",
                color: .green
            )

        case .alreadyConnected:
            statusLabel(
                icon: "checkmark.circle.fill",
                text: "Already connected",
                color: .green
            )

        case .failed(let message):
            VStack(spacing: 14) {
                statusLabel(
                    icon: "exclamationmark.triangle.fill",
                    text: message,
                    color: .red
                )
                connectButton(creds: creds)
            }
        }
    }

    private var waitingPrompt: some View {
        VStack(spacing: 12) {
            Image(systemName: "wave.3.right.circle")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Hold your device near\nthe WiFi tag")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
    }

    private func connectButton(creds: WifiCredentials) -> some View {
        Button {
            connect(creds: creds)
        } label: {
            Label("Join \(creds.ssid)", systemImage: "wifi")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func statusLabel(icon: String, text: String, color: Color) -> some View {
        Label(text, systemImage: icon)
            .foregroundStyle(color)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }

    // MARK: Footer

    private var footer: some View {
        Text("Tap Join to connect this device to the network.")
            .font(.caption)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .padding(.bottom, 36)
    }

    // MARK: WiFi connection

    private func connect(creds: WifiCredentials) {
        connectionState = .connecting

        let config = NEHotspotConfiguration(
            ssid: creds.ssid,
            passphrase: creds.password,
            isWEP: false
        )
        config.joinOnce = false

        NEHotspotConfigurationManager.shared.apply(config) { error in
            DispatchQueue.main.async {
                if let nfcError = error as? NEHotspotConfigurationError {
                    switch nfcError {
                    case .alreadyAssociated:
                        connectionState = .alreadyConnected
                    case .userDenied:
                        connectionState = .failed("Connection cancelled.")
                    case .invalid:
                        connectionState = .failed("Invalid network credentials.")
                    default:
                        connectionState = .failed(nfcError.localizedDescription)
                    }
                } else if let error {
                    connectionState = .failed(error.localizedDescription)
                } else {
                    connectionState = .connected
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    WifiConnectView()
}
