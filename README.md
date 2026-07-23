# Soma

A macOS app (iOS planned next) that controls Samsung Smart TVs over the local
network, using Samsung's WebSocket remote protocol — no cloud, no
third-party service, no account required. The TV shows an authorization
prompt on first connection, and from then on the app can send
remote-control commands to it.

Soma lives in the macOS menu bar (top-right) and has a main window for
configuration and device selection.

## Status

- **Mac** (`macos/`) — menu-bar remote with a full configuration window.
- **iOS** (`ios/`) — SwiftUI mobile remote (iPhone/iPad), same core and design.

> The device running Soma and the TV must be on the same local network.

## Features

- Navigation: up, down, left, right and OK.
- System: Home, Back, Menu, Play/Pause and Exit.
- Volume: up, down and mute.
- Channels: channel up/down, list, and direct number entry.
- Sources: TV, HDMI 1–4 and the source menu.
- Apps: YouTube, Netflix, Prime Video, Disney+, Hulu and Spotify.
- Text input sent to the TV's focused field.
- Automatic reconnection with backoff if the connection drops.
- Multiple TVs: stores IP, MAC, auth token and transport per device.
- Wake-on-LAN to power the TV on.
- Sleep timer with a countdown to power it off.
- Configurable global keyboard shortcuts (volume, mute, channel…).
- Arrow-key control while the window is focused.
- Clear connection, authorization and error states.

When a feature isn't supported by a given TV model, Soma shows a message
instead of failing silently.

## Architecture

```
Soma/
  Models/       TVDevice, RemoteKey, TVApp, ConnectionState, HotKeys
  Services/     SamsungTVClient (WebSocket + REST), DeviceStore, SettingsStore,
                WakeOnLAN, SleepTimer, GlobalHotKeyManager
  ViewModels/   TVControllerViewModel (state and logic)
  Views/        ContentView, RemoteControlView, DevicesView, SettingsView,
                MenuBarView and Components/ (D-pad, buttons, etc.)
```

Native macOS/Swift APIs only (SwiftUI, Network/POSIX, Carbon for global
hotkeys). No external dependencies.

The iOS app (`ios/Soma/`) mirrors this structure and reuses the same core
(models, `SamsungTVClient`, stores, view model) and the glass theme. It uses a
tab bar instead of the menu-bar rail and omits the macOS-only global keyboard
shortcuts. The core is currently duplicated per platform; a shared Swift
package is a natural follow-up to de-duplicate it.

## Build

macOS:

```
cd macos
xcodebuild -project Soma.xcodeproj -scheme Soma -configuration Debug build
```

iOS (simulator):

```
cd ios
xcodebuild -project Soma.xcodeproj -target Soma -sdk iphonesimulator build
```

Or open the respective `.xcodeproj` in Xcode and press ▶.
