const WebSocket = require('ws');

const PORT = process.env.PORT || 8080;
const wss  = new WebSocket.Server({ port: PORT });

// clientId -> { ws, userId, nickname }
const clients = new Map();

wss.on('connection', (ws) => {
    const clientId = Math.random().toString(36).slice(2);
    clients.set(clientId, { ws, userId: null });

    console.log(`[+] Client connected (${clientId}) — total: ${clients.size}`);

    ws.on('message', (raw) => {
        let env;
        try { env = JSON.parse(raw); } catch { return; }

        // Tag the socket with its userId on first message
        if (env.senderId && !clients.get(clientId)?.userId) {
            clients.get(clientId).userId = env.senderId;
        }

        // Broadcast to all other clients
        for (const [id, client] of clients) {
            if (id !== clientId && client.ws.readyState === WebSocket.OPEN) {
                client.ws.send(raw.toString());
            }
        }
    });

    ws.on('close', () => {
        clients.delete(clientId);
        console.log(`[-] Client disconnected (${clientId}) — total: ${clients.size}`);
    });

    ws.on('error', (err) => console.error(`[!] ${clientId}:`, err.message));
});

console.log(`ICQ WebSocket server running on ws://localhost:${PORT}`);
