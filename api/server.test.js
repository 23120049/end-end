const { test } = require('node:test');
const assert = require('node:assert/strict');
const { EventEmitter } = require('node:events');
const { handler } = require('./server');

function request(method, url, body = '') {
  return new Promise(resolve => {
    const req = new EventEmitter();
    req.method = method;
    req.url = url;
    req.destroy = () => {};
    const res = {
      writeHead(status) { this.status = status; },
      end(payload) { resolve({ status: this.status, body: JSON.parse(payload) }); }
    };
    handler(req, res);
    if (method === 'POST') {
      req.emit('data', body);
      req.emit('end');
    }
  });
}

test('health, version, echo, and unknown routes', async () => {
  assert.deepEqual(await request('GET', '/api/health'), { status: 200, body: { status: 'ok' } });
  const version = await request('GET', '/api/version');
  assert.equal(version.status, 200);
  assert.ok(version.body.version);
  assert.deepEqual(await request('POST', '/api/echo', 'hello'), { status: 200, body: { echo: 'hello' } });
  assert.equal((await request('GET', '/api/echo')).status, 404);
  assert.equal((await request('GET', '/other')).status, 404);
});
