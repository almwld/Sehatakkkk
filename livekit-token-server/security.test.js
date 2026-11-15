const test = require('node:test');
const assert = require('node:assert/strict');
const { createCorsMiddleware, securityHeaders, createRateLimiter } = require('./security.middleware');

function response() {
  return {
    headers: {},
    statusCode: 200,
    setHeader(name, value) { this.headers[name] = value; },
    vary(value) { this.headers.Vary = value; },
    status(code) { this.statusCode = code; return this; },
    json(body) { this.body = body; return this; },
    end() { this.ended = true; return this; },
  };
}

test('CORS rejects untrusted browser origins and allows the configured site', () => {
  const cors = createCorsMiddleware({ NODE_ENV: 'production', CORS_ALLOWED_ORIGINS: 'https://sehatak.web.app' });
  const denied = response();
  cors({ headers: { origin: 'https://evil.example' }, method: 'GET' }, denied, () => assert.fail('must reject'));
  assert.equal(denied.statusCode, 403);

  const allowed = response();
  let passed = false;
  cors({ headers: { origin: 'https://sehatak.web.app' }, method: 'GET' }, allowed, () => { passed = true; });
  assert.equal(passed, true);
  assert.equal(allowed.headers['Access-Control-Allow-Origin'], 'https://sehatak.web.app');
  assert.equal(allowed.headers['Access-Control-Allow-Credentials'], undefined);
});

test('CORS supports preflight and native clients without Origin', () => {
  const cors = createCorsMiddleware({ NODE_ENV: 'production' });
  const preflight = response();
  cors({ headers: { origin: 'https://sehatak.web.app' }, method: 'OPTIONS' }, preflight, () => assert.fail('preflight must end'));
  assert.equal(preflight.statusCode, 204);
  assert.equal(preflight.ended, true);

  let passed = false;
  cors({ headers: {}, method: 'POST' }, response(), () => { passed = true; });
  assert.equal(passed, true);
});

test('security headers disable sniffing, framing and caching', () => {
  const res = response();
  let passed = false;
  securityHeaders({ secure: true }, res, () => { passed = true; });
  assert.equal(passed, true);
  assert.equal(res.headers['X-Content-Type-Options'], 'nosniff');
  assert.equal(res.headers['X-Frame-Options'], 'DENY');
  assert.equal(res.headers['Cache-Control'], 'no-store');
});

test('rate limiter blocks requests beyond its budget and resets the window', () => {
  let timestamp = 1000;
  const limiter = createRateLimiter({ windowMs: 1000, max: 1, now: () => timestamp, keyGenerator: (req) => req.ip });
  const req = { ip: 'test-ip', path: '/token' };
  let passed = 0;
  const next = () => { passed += 1; };
  limiter(req, response(), next);
  const blocked = response();
  limiter(req, blocked, next);
  assert.equal(blocked.statusCode, 429);
  assert.equal(blocked.headers['Retry-After'], '1');
  timestamp += 1001;
  limiter(req, response(), next);
  assert.equal(passed, 2);
  limiter.close();
});
