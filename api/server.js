const http = require('node:http');

const port = Number(process.env.PORT || 3000);
const version = process.env.RELEASE_VERSION || 'local';
const sha = process.env.GIT_SHA || 'unknown';

function handler(req, res) {
  const path = new URL(req.url, 'http://localhost').pathname;
  const send = (status, body) => {
    res.writeHead(status, { 'content-type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify(body));
  };
  if (req.method === 'GET' && path === '/api/health') return send(200, { status: 'ok' });
  if (req.method === 'GET' && path === '/api/version') return send(200, { version, sha });
  if (req.method === 'POST' && path === '/api/echo') {
    let body = '';
    req.on('data', chunk => {
      body += chunk;
      if (body.length > 4096) req.destroy();
    });
    req.on('end', () => send(200, { echo: body }));
    return;
  }
  send(404, { error: 'not found' });
}

if (require.main === module) http.createServer(handler).listen(port, '0.0.0.0');
module.exports = { handler };
