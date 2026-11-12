/* Native BLE bridge entry point.
 *
 * Bundled by scripts/build-ble.mjs into www/js/obd/native-ble.bundle.js.
 * Inside the Capacitor WebView, @capacitor/core finds the BleClient entry in
 * window.Capacitor.PluginHeaders and routes every call to the Android BLE
 * stack. The web implementation that ships with the plugin is never used.
 */

import { BleClient } from '@capacitor-community/bluetooth-le';

export const initialize = () => BleClient.initialize({ androidNeverForLocation: false });
export const isEnabled = () => BleClient.isEnabled();
export const requestEnable = () => BleClient.requestEnable();
export const requestDevice = (options) => BleClient.requestDevice(options);
export const connect = (deviceId, onDisconnect) => BleClient.connect(deviceId, onDisconnect);
export const disconnect = (deviceId) => BleClient.disconnect(deviceId);
export const getServices = (deviceId) => BleClient.getServices(deviceId);

export const startNotifications = (deviceId, service, characteristic, callback) => (
  BleClient.startNotifications(deviceId, service, characteristic, callback)
);

export const write = (deviceId, service, characteristic, value) => (
  BleClient.write(deviceId, service, characteristic, value)
);

export const writeWithoutResponse = (deviceId, service, characteristic, value) => (
  BleClient.writeWithoutResponse(deviceId, service, characteristic, value)
);
