# Skorbord App: Hybrid Local & Real-Time Plan

## 1. Connection Detection & Mode Selection

- On app startup, attempt to connect to the WebSocket backend.
- If the connection succeeds, operate in **Online/Multiplayer** mode (real-time sync).
- If the connection fails (e.g., `net::ERR_CONNECTION_REFUSED`), fall back to **Offline/Local** mode (single-device play).

## 2. Local Mode (Single-Device)

- All game state, player data, and scores are stored in local storage (`shared_preferences` or IndexedDB).
- All features (scoring, undo, player management, winner animation, etc.) work as normal, but only on the current device.
- UI clearly indicates **Offline/Local Mode** (e.g., a banner or icon).
- Optionally, allow the user to retry connecting to the backend from a settings menu.

## 3. Online/Multiplayer Mode

- If the WebSocket connection is available, use real-time sync for all game state.
- All actions (score changes, player updates, etc.) are sent to the backend and broadcast to all connected clients.
- UI indicates **Online/Multiplayer Mode** (e.g., a green connection icon).

## 4. Seamless Transition

- If the connection drops during play, automatically switch to Local Mode and notify the user.
- If the connection is restored, offer to sync local changes or rejoin the online game.

## 5. Implementation Steps

- Refactor `SocketService` to expose connection status and allow for a "disconnected" state.
- In `AppState` or main app logic, branch all game state logic based on connection status:
  - If connected: use WebSocket/REST for all actions.
  - If not connected: use local storage and in-memory state.
- Ensure all UI components (GameBoard, ScoreControls, etc.) work identically in both modes.
- Add clear UI feedback for mode (e.g., connection status icon, offline banner).
- Add tests for both modes to ensure full feature parity.

## 6. Optional Enhancements

- Allow exporting/importing local games for sharing or backup.
- If a game is started offline and later goes online, offer to upload/sync the local game.
- Provide user settings to force offline or online mode for debugging.

---

This plan ensures the Skorbord app is always usable, even without a backend, and provides a seamless upgrade to real-time multiplayer when a connection is available.
