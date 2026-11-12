/* Bundles the native BLE bridge into the synced web app. */
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { build } from 'esbuild';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..');

await build({
  entryPoints: [path.join(root, 'src', 'native-ble-entry.js')],
  bundle: true,
  format: 'esm',
  platform: 'browser',
  target: ['chrome90'],
  minify: true,
  legalComments: 'none',
  outfile: path.join(root, 'www', 'js', 'obd', 'native-ble.bundle.js'),
});

console.log('Bundled www/js/obd/native-ble.bundle.js');
