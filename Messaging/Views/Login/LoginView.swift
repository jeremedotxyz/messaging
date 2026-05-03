import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: ChatStore
    @Binding var isLoggedIn: Bool

    @State private var uin      = ""
    @State private var nickname = ""
    @State private var password = ""
    @State private var loading  = false

    var body: some View {
        ZStack {
            ICQTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ──────────────────────────────────────────────
                VStack(spacing: 12) {
                    ICQFlowerView(size: 88)
                        .padding(.top, 52)
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)

                    Text("ICQ")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("I Seek You")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(.white.opacity(0.75))
                        .padding(.bottom, 36)
                }
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(colors: [ICQTheme.teal, ICQTheme.tealDark],
                                   startPoint: .top, endPoint: .bottom)
                )

                // ── Form ─────────────────────────────────────────────────
                VStack(spacing: 14) {
                    field(label: "ICQ Number (UIN)", placeholder: "e.g. 12345678", text: $uin)
                        .keyboardType(.numberPad)

                    field(label: "Nickname", placeholder: "Your nickname", text: $nickname)

                    secureField(label: "Password", placeholder: "Password", text: $password)

                    Button(action: login) {
                        Group {
                            if loading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Connect")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(nickname.isEmpty ? ICQTheme.offlineGray : ICQTheme.teal)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(nickname.isEmpty || loading)
                    .padding(.top, 4)

                    Text("© 2024 ICQ Messaging")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(24)

                Spacer()
            }
        }
    }

    private func field(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(placeholder, text: text)
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .overlay(RoundedRectangle(cornerRadius: 9)
                    .stroke(ICQTheme.teal.opacity(0.25), lineWidth: 1))
        }
    }

    private func secureField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            SecureField(placeholder, text: text)
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .overlay(RoundedRectangle(cornerRadius: 9)
                    .stroke(ICQTheme.teal.opacity(0.25), lineWidth: 1))
        }
    }

    private func login() {
        loading = true
        store.currentUser = User(id: "me", uin: uin.isEmpty ? "12345678" : uin,
                                 nickname: nickname, statusMessage: "Hey there!",
                                 status: .online)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            loading     = false
            isLoggedIn  = true
        }
    }
}
