const DEFAULT_ALLOWED_ORIGINS = ['https://sehatak.web.app'];

function getAllowedOrigins(env = process.env) {
  const configured = String(env.CORS_ALLOWED_ORIGINS || '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
  const origins = configured.length ? configured : [...DEFAULT_ALLOWED_ORIGINS];
  if (env.NODE_ENV !== 'production') {
    origins.push('http://localhost:3000', 'http://localhost:5173');
  }
  return new Set(origins);
}

function createCorsOptions(env = process.env) {
  const allowedOrigins = getAllowedOrigins(env);
  return {
    origin(origin, callback) {
      // Native mobile clients and server-to-server calls do not send Origin.
      if (!origin || allowedOrigins.has(origin)) return callback(null, true);
      const error = new Error('Origin is not allowed by CORS');
      error.status = 403;
      error.code = 'CORS_ORIGIN_DENIED';
      return callback(error);
    },
    credentials: false,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Authorization', 'Content-Type'],
    maxAge: 600,
    optionsSuccessStatus: 204,
  };
}

function securityHeaders(req, res, next) {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('Referrer-Policy', 'no-referrer');
  res.setHeader('X-Permitted-Cross-Domain-Policies', 'none');
  res.setHeader('Content-Security-Policy', "default-src 'none'; base-uri 'none'; frame-ancestors 'none'");
  if (req.path && req.path.startsWith('/api/')) {
    res.setHeader('Cache-Control', 'no-store');
  }
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

module.exports = {
  getAllowedOrigins,
  createCorsOptions,
  securityHeaders,
  createRateLimiter,
};
