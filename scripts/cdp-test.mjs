// Minimal CDP driver for the AutoPulse WebView (test only).
const targets = await (await fetch('http://127.0.0.1:9222/json/list')).json();
const page = targets.find((t) => t.type === 'page');
if (!page) {
  console.error('no page target');
  process.exit(1);
}

const ws = new WebSocket(page.webSocketDebuggerUrl);
let nextId = 1;
const pending = new Map();

ws.addEventListener('message', (event) => {
  const msg = JSON.parse(event.data);
  if (msg.id && pending.has(msg.id)) {
    pending.get(msg.id)(msg);
    pending.delete(msg.id);
  }
});

await new Promise((resolve, reject) => {
  ws.addEventListener('open', resolve, { once: true });
  ws.addEventListener('error', reject, { once: true });
});

const send = (method, params) => new Promise((resolve) => {
  const id = nextId++;
  pending.set(id, resolve);
  ws.send(JSON.stringify({ id, method, params }));
});

const expression = `(async () => {
  const q = (s) => document.querySelector(s);
  const out = { started: true };
  q('#sideConnectBtn')?.click();
  await new Promise((r) => setTimeout(r, 700));
  out.modal = !!document.querySelector('#connBleBtn');
  const ble = q('#connBleBtn');
  if (ble) { ble.click(); out.clicked = true; } else { out.clicked = false; }
  return out;
})()`;

const res = await send('Runtime.evaluate', { expression, awaitPromise: true, returnByValue: true });
console.log(JSON.stringify(res.result?.result?.value ?? res, null, 2));

await new Promise((r) => setTimeout(r, 4000));

const after = await send('Runtime.evaluate', {
  expression: `({ title: document.title, modal: !!document.querySelector('.modal'), toast: document.querySelector('.toast')?.innerText || '', status: document.querySelector('#sideStatusText')?.innerText || '' })`,
  returnByValue: true,
});
console.log(JSON.stringify(after.result?.result?.value ?? after, null, 2));

ws.close();
