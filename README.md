# AutoPulse OBD2 — Android build

This folder produces the standalone Android app for AutoPulse OBD2. It bundles the
entire web app inside the APK and runs it in a native WebView shell — **no Chrome,
no GitHub Pages and no internet connection required**, not even on first launch.

Unlike a Trusted Web Activity, nothing here depends on the Chrome app being
installed, and there is no URL bar or browser chrome at any point.

## How it works

| Piece | Role |
| --- | --- |
| `../autopulse-obd` | The web app (single source of truth). |
| `scripts/sync-web.mjs` | Copies the web app into `www/`. |
| `scripts/build-ble.mjs` | Bundles `src/native-ble-entry.js` (the BLE plugin) into `www/js/obd/native-ble.bundle.js`. |
| `android/` | Capacitor Android project. |
| `@capacitor-community/bluetooth-le` | Talks to the Android BLE stack directly. |

The web app's transport layer (`js/obd/transport.js`) detects the native shell via
`window.Capacitor` and routes Bluetooth through the native bridge. On the hosted
PWA the same file keeps using Web Bluetooth.

USB serial remains a desktop browser feature; Web Serial is not available to
Android WebViews.

## Build

Requirements: JDK 21, Android SDK (platform 36, build-tools 36.1.0), Node 20+.

```powershell
npm install
node scripts/sync-web.mjs
node scripts/build-ble.mjs
npx cap sync android
cd android
./gradlew assembleRelease
```

Output: `android/app/build/outputs/apk/release/app-release.apk`

Signing uses `../autopulse-twa/autopulse.keystore` by default. Override with
`AUTOPULSE_KEYSTORE`, `AUTOPULSE_KEYSTORE_PASSWORD`, `AUTOPULSE_KEY_ALIAS` and
`AUTOPULSE_KEY_PASSWORD`.

Icons and splash screens are regenerated from `../autopulse-obd/assets/icon-512.png`:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/make-android-assets.ps1
```

## Notes

- Package ID `io.github.piehelmet.autopulse` matches the earlier TWA release, so this
  version installs as an upgrade over it when signed with the same key.
- Bluetooth permissions are merged from the plugin manifest. Android 12+ asks for
  `BLUETOOTH_SCAN` / `BLUETOOTH_CONNECT`; older versions ask for location, which the
  Android BLE stack requires for scanning.
