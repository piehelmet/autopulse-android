/* Copies the web app from ../autopulse-obd into ./www.
 * Run before scripts/build-ble.mjs so the BLE bundle lands in the fresh copy.
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..');
const source = path.resolve(root, '..', 'autopulse-obd');
const target = path.join(root, 'www');

const EXCLUDE = new Set(['.git', 'README.md', 'LICENSE', 'node_modules']);

if (!fs.existsSync(path.join(source, 'index.html'))) {
  console.error(`Cannot find the web app at ${source}`);
  process.exit(1);
}

fs.rmSync(target, { recursive: true, force: true });
fs.cpSync(source, target, {
  recursive: true,
  filter: (entry) => {
    const base = path.basename(entry);
    if (EXCLUDE.has(base)) return false;
    return true;
  },
});

const count = (dir) => fs.readdirSync(dir, { withFileTypes: true })
  .reduce((sum, e) => sum + (e.isDirectory() ? count(path.join(dir, e.name)) : 1), 0);

console.log(`Synced ${count(target)} files from ${source} to ${target}`);
