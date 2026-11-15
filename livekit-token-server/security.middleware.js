const DEFAULT_ALLOWED_ORIGINS = ['https://sehatak.web.app'];

function createCorsMiddleware(env = process.env) {
  const configured = String(env.CORS_ALLOWED_ORIGINS || '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
  const allowed = new Set(configured.length ? configured : DEFAULT_ALLOWED_ORIGINS);
  if (env.NODE_ENV !== 'production') {
    allowed.add('http://localhost:3000');
    allowed.add('http://localhost:5173');
  }

  return (req, res, next) => {
    const origin = req.headers.origin;
    res.vary('Origin');
    if (origin && !allowed.has(origin)) {
      return res.status(403).json({ success: false, message: 'Origin is not allowed.' });
    }
    if (origin) {
      res.setHeader('Access-Control-Allow-Origin', origin);
      res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
      res.setHeader('Access-Control-Allow-Headers', 'Authorization, Content-Type');
      res.setHeader('Access-Control-Max-Age', '600');
    }
    if (req.method === 'OPTIONS') return res.status(204).end();
    return next();
  };
}

function securityHeaders(req, res, next) {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('Referrer-Policy', 'no-referrer');
  res.setHeader('X-Permitted-Cross-Domain-Policies', 'none');
  res.setHeader('Content-Security-Policy', "default-src 'none'; base-uri 'none'; frame-ancestors 'none'");
  res.setHeader('Cache-Control', 'no-store');
  if (process.env.NODE_ENV === 'production' && req.secure) {
    res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  }
  return next();
}

function createRateLimiter({
  windowMs = 60_000,
  max = 120,
  now = Date.now,
  keyGenerator = (req) => req.ip || req.socket?.remoteAddress || 'unknown',
} = {}) {
  const buckets = new Map();
  const cleanup = setInterval(() => {
    const timestamp = now();
    for (const [key, bucket] of buckets) {
      if (timestamp >= bucket.resetAt) buckets.delete(key);
    }
  }, Math.max(windowMs, 60_000));
  cleanup.unref?.();

  const middleware = (req, res, next) => {
    const key = String(keyGenerator(req));
    const timestamp = now();
    let bucket = buckets.get(key);
    if (!bucket || timestamp >= bucket.resetAt) {
      bucket = { count: 0, resetAt: timestamp + windowMs };
      buckets.set(key, bucket);
    }
    bucket.count += 1;
    if (bucket.count > max) {
      const retryAfter = Math.max(1, Math.ceil((bucket.resetAt - timestamp) / 1000));
      res.setHeader('Retry-After', String(retryAfter));
      console.warn('Security event: request rate limit exceeded', req.path);
      return res.status(429).json({
        success: false,
        message: 'عدد الطلبات كبير جداً. حاول مرة أخرى لاحقاً.',
      });
    }
    return next();
  };
  middleware.close = () => clearInterval(cleanup);
  return middleware;
}

module.exports = { createCorsMiddleware, securityHeaders, createRateLimiter };
