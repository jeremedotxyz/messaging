# ICQ Messaging

A real-time iOS chat app built with SwiftUI, styled after the classic ICQ messenger.

![iOS 16+](https://img.shields.io/badge/iOS-16%2B-teal) ![Swift](https://img.shields.io/badge/Swift-5.9-orange)

## Features

- ICQ-inspired UI — teal gradient headers, daisy flower logo, yellow petals
- Contact list grouped by Online / Away / Busy / Offline with pulsing status dots
- Real-time messaging over WebSocket
- Simulated replies in demo mode (no server needed)
- Read receipts with checkmarks
- Set your own status (Online, Away, DND, Offline)
- Search contacts by nickname or UIN

## Screenshots

| Login | Contacts | Chat |
|-------|----------|------|
| Teal header + flower logo + UIN form | Online/Offline sections + unread badges | Bubble chat + read receipts |

## Getting Started

### 1. Generate the Xcode project

Install [XcodeGen](https://github.com/yonaskolb/XcodeGen) if you haven't:

```bash
brew install xcodegen
```

Then from the repo root:

```bash
xcodegen generate
open Messaging.xcodeproj
```

### 2. Run the WebSocket server (optional)

For real-time multi-device messaging:

```bash
cd server
npm install
npm start
```

Server runs on `ws://localhost:8080`.

In the app, tap the **wifi icon** in the contact list header to connect.

Without a server the app runs in demo mode — contacts send automatic replies.

## Project Structure

```
Messaging/
├── MessagingApp.swift          # App entry point
├── ContentView.swift           # Login / contact list router
├── Theme/
│   └── ICQTheme.swift          # Color palette
├── Models/
│   ├── User.swift              # UIN, nickname, status
│   ├── Message.swift           # Chat message
│   └── Conversation.swift      # Contact + message thread
├── Services/
│   ├── WebSocketService.swift  # URLSession WebSocket client
│   └── ChatStore.swift         # App state + demo data
└── Views/
    ├── Login/                  # Login screen
    ├── ContactList/            # Contact list + rows
    ├── Chat/                   # Chat view + bubbles
    └── Components/             # Flower logo, status dot

server/
├── index.js                    # Node.js WebSocket broadcast server
└── package.json
```

## Requirements

- Xcode 15+
- iOS 16+
- Node.js 18+ (server only)
