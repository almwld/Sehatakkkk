const test = require('node:test');
const assert = require('node:assert/strict');
const {
  getAllowedOrigins,
  createCorsOptions,
  securityHeaders,
  createRateLimiter,
} = require('../src/middleware/security.middleware');

test('production CORS defaults to the official Firebase Hosting origin only', () => {
  const origins = getAllowedOrigins({ NODE_ENV: 'production' });
  assert.deepEqual([...origins], ['https://sehatak.web.app']);
});

test('CORS allows configured web origins and non-browser clients, but rejects unknown origins', () => {
  const options = createCorsOptions({
    NODE_ENV: 'production',
    CORS_ALLOWED_ORIGINS: 'https://sehatak.web.app,https://portal.example.test',
  });
  options.origin('https://sehatak.web.app', (error, allowed) => {
    assert.equal(error, undefined);
    assert.equal(allowed, true);
  });
  options.origin(undefined, (error, allowed) => {
    assert.equal(error, undefined);
    assert.equal(allowed, true);
  });
  options.origin('https://attacker.example', (error) => {
    assert.equal(error.code, 'CORS_ORIGIN_DENIED');
    assert.equal(error.status, 403);
  });
  assert.equal(options.credentials, false);
});

test('security headers disable framing, sniffing, caching and active content on API responses', () => {
  const headers = {};
  let called = false;
  securityHeaders(
    { path: '/api/private', secure: true },
    { setHeader: (name, value) => { headers[name] = value; } },
    () => { called = true; },
  );
  assert.equal(called, true);
  assert.equal(headers['X-Content-Type-Options'], 'nosniff');
  assert.equal(headers['X-Frame-Options'], 'DENY');
  assert.equal(headers['Cache-Control'], 'no-store');
  assert.match(headers['Content-Security-Policy'], /default-src 'none'/);
});

test('rate limiter returns 429 after the configured request budget', () => {
  let timestamp = 1000;
  const limiter = createRateLimiter({
    windowMs: 1000,
    max: 2,
    now: () => timestamp,
    keyGenerator: (req) => req.ip,
  });
  const request = { ip: '198.51.100.10' };
  const makeResponse = () => ({
    headers: {},
    setHeader(name, value) { this.headers[name] = value; },
    status(code) { this.statusCode = code; return this; },
    json(body) { this.body = body; return this; },
  });
  let passed = 0;
  const next = () => { passed += 1; };
  limiter(request, makeResponse(), next);
  limiter(request, makeResponse(), next);
  const blocked = makeResponse();
  limiter(request, blocked, next);
  assert.equal(passed, 2);
  assert.equal(blocked.statusCode, 429);
  assert.equal(blocked.headers['Retry-After'], '1');
  timestamp += 1001;
  limiter(request, makeResponse(), next);
  assert.equal(passed, 3);
  limiter.close();
});
