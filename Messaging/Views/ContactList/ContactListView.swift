import SwiftUI

struct ContactListView: View {
    @EnvironmentObject var store: ChatStore
    @State private var selectedContact: User?
    @State private var searchText = ""
    @State private var showStatusSheet = false
    @State private var showWSSheet = false
    @State private var wsURL = "ws://localhost:8080"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                searchBar
                contactList
                statusBar
            }
            .navigationBarHidden(true)
        }
        .sheet(item: $selectedContact) { contact in
            ChatView(contact: contact)
                .environmentObject(store)
        }
        .confirmationDialog("Set Status", isPresented: $showStatusSheet, titleVisibility: .visible) {
            ForEach(UserStatus.allCases, id: \.self) { s in
                Button(s.label) { store.setStatus(s) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showWSSheet) { wsConnectSheet }
    }

    // MARK: – Header

    private var header: some View {
        HStack(spacing: 10) {
            ICQFlowerView(size: 34)

            VStack(alignment: .leading, spacing: 0) {
                Text("ICQ")
                    .font(.system(size: 21, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("Messaging")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.65))
            }

            Spacer()

            // WS indicator
            Button { showWSSheet = true } label: {
                Image(systemName: store.ws.isConnected ? "wifi" : "wifi.slash")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(store.ws.isConnected ? ICQTheme.onlineGreen : .white.opacity(0.5))
                    .padding(6)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }

            // Current user / status picker
            Button { showStatusSheet = true } label: {
                HStack(spacing: 6) {
                    StatusDotView(status: store.currentUser.status, size: 9)
                    Text(store.currentUser.nickname)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.13))
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            LinearGradient(colors: [ICQTheme.teal, ICQTheme.tealDark],
                           startPoint: .top, endPoint: .bottom)
        )
    }

    // MARK: – Search

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.system(size: 14))
            TextField("Find a user…", text: $searchText)
                .font(.system(size: 14))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.systemGray4), lineWidth: 0.5))
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(ICQTheme.background)
    }

    // MARK: – Contact list

    private var contactList: some View {
        List {
            let online  = filtered(by: .online) + filtered(by: .away) + filtered(by: .busy)
            let offline = filtered(by: .offline)

            if !online.isEmpty {
                Section {
                    ForEach(online.sorted { $0.status.sortOrder < $1.status.sortOrder }) { c in
                        row(for: c)
                    }
                } header: {
                    sectionHeader("Online (\(online.count))", color: ICQTheme.onlineGreen)
                }
            }

            if !offline.isEmpty {
                Section {
                    ForEach(offline) { c in row(for: c) }
                } header: {
                    sectionHeader("Offline (\(offline.count))", color: ICQTheme.offlineGray)
                }
            }
        }
        .listStyle(.plain)
        .background(ICQTheme.background)
        .scrollContentBackground(.hidden)
    }

    private func row(for contact: User) -> some View {
        let unread = store.conversations.first { $0.contact.id == contact.id }?.unreadCount ?? 0
        return ContactRowView(user: contact, unreadCount: unread)
            .contentShape(Rectangle())
            .onTapGesture {
                store.startConversation(with: contact)
                selectedContact = contact
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 2, leading: 14, bottom: 2, trailing: 14))
    }

    // MARK: – Status bar

    private var statusBar: some View {
        HStack {
            StatusDotView(status: store.currentUser.status, size: 8)
            Text(store.currentUser.status.label)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            Spacer()
            Text("UIN: \(store.currentUser.uin)")
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .overlay(alignment: .top) {
            Rectangle().fill(Color(.systemGray5)).frame(height: 0.5)
        }
    }

    // MARK: – WS connect sheet

    private var wsConnectSheet: some View {
        NavigationStack {
            Form {
                Section("WebSocket Server URL") {
                    TextField("ws://localhost:8080", text: $wsURL)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                Section {
                    Button(store.ws.isConnected ? "Disconnect" : "Connect") {
                        if store.ws.isConnected { store.ws.disconnect() }
                        else { store.connectWS(serverURL: wsURL) }
                        showWSSheet = false
                    }
                    .foregroundStyle(store.ws.isConnected ? .red : ICQTheme.teal)
                }
            }
            .navigationTitle("Server Connection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showWSSheet = false }
                }
            }
        }
    }

    // MARK: – Helpers

    private func filtered(by status: UserStatus) -> [User] {
        store.contacts.filter {
            $0.status == status &&
            (searchText.isEmpty ||
             $0.nickname.localizedCaseInsensitiveContains(searchText) ||
             $0.uin.contains(searchText))
        }
    }

    private func sectionHeader(_ title: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Rectangle().fill(color.opacity(0.3)).frame(height: 1)
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(color)
                .fixedSize()
            Rectangle().fill(color.opacity(0.3)).frame(height: 1)
        }
        .textCase(nil)
    }
}
