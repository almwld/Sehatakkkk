const baseUrl = String(process.env.RAILWAY_URL || '').replace(/\/$/, '');

function requireBaseUrl() {
  if (!baseUrl) throw new Error('Set RAILWAY_URL to the deployed Railway service URL');
  return baseUrl;
}

async function request(path, options = {}) {
  const url = `${requireBaseUrl()}${path}`;
  const response = await fetch(url, {
    ...options,
    headers: {'content-type':'application/json', ...(options.headers || {})},
  });
  let body = null;
  try { body = await response.json(); } catch (_) {}
  return { status: response.status, ok: response.ok, body };
}

async function health() { return request('/health', {method:'GET'}); }
async function notificationHealth() { return request('/notification/health', {method:'GET'}); }
async function notify(idToken, payload) { return request('/notification', {method:'POST', headers:{authorization:`Bearer ${idToken}`}, body:JSON.stringify(payload)}); }
async function callNotify(idToken, callId) { return request('/call-notification', {method:'POST', headers:{authorization:`Bearer ${idToken}`}, body:JSON.stringify({callId})}); }

module.exports = { request, health, notificationHealth, notify, callNotify };
