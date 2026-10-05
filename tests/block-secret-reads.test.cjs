const assert = require('node:assert/strict');
const { execFileSync } = require('node:child_process');
const { realpathSync } = require('node:fs');
const path = require('node:path');
const { createRequire } = require('node:module');
const test = require('node:test');

const piPackage = path.resolve(realpathSync(execFileSync('which', ['pi'], { encoding: 'utf8' }).trim()), '../../..');
const piRequire = createRequire(path.join(piPackage, 'package.json'));
const { createJiti } = piRequire('jiti');
const jiti = createJiti(__filename, {
  alias: { '@earendil-works/pi-coding-agent': path.join(piPackage, 'dist/index.js') },
});
let onToolCall;
jiti(path.join(__dirname, '../pi/extensions/block-secret-reads.ts')).default({
  on: (name, handler) => {
    assert.equal(name, 'tool_call');
    onToolCall = handler;
  },
});

function blocked(type, input) {
  return onToolCall({ toolName: type, input })?.block === true;
}

test('allows shareable environment templates via read and bash', () => {
  for (const name of ['.env.example', '.env.example.local', '.env.sample', '.env.template']) {
    assert.equal(blocked('read', { path: `/repo/${name}` }), false, name);
    assert.equal(blocked('bash', { command: `printf '%s\\n' /repo/${name}` }), false, name);
  }
});

test('still blocks real environment files via read and bash', () => {
  for (const name of ['.env', '.env.local', '.env.production']) {
    assert.equal(blocked('read', { path: `/repo/${name}` }), true, name);
    assert.equal(blocked('bash', { command: `head /repo/${name}` }), true, name);
  }
  assert.equal(blocked('read', { path: '/repo/.env.example/.env' }), true);
  assert.equal(blocked('bash', { command: 'head /repo/.env.example/.env' }), true);
});

test('continues blocking other secret paths', () => {
  assert.equal(blocked('read', { path: '/repo/credentials.json' }), true);
  assert.equal(blocked('bash', { command: 'head /repo/key.pem' }), true);
});
