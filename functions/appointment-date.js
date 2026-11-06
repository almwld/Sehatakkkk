function appointmentInstantFromDateMarker(dateMarker, time, timeZone = 'Asia/Aden') {
  const marker = dateMarker instanceof Date ? dateMarker : new Date(dateMarker);
  if (Number.isNaN(marker.getTime())) throw new TypeError('Invalid appointment date marker.');
  const normalizedTime = String(time).trim();
  if (!/^(?:[01]?\d|2[0-3]):[0-5]\d$/.test(normalizedTime)) {
    throw new TypeError('Invalid appointment time.');
  }
  const [hour, minute] = normalizedTime.split(':').map(Number);
  const utcGuess = Date.UTC(
    marker.getUTCFullYear(),
    marker.getUTCMonth(),
    marker.getUTCDate(),
    hour,
    minute,
  );
  const parts = new Intl.DateTimeFormat('en-US', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    hourCycle: 'h23',
  }).formatToParts(new Date(utcGuess));
  const values = Object.fromEntries(parts.map((part) => [part.type, part.value]));
  const representedAsUtc = Date.UTC(
    Number(values.year),
    Number(values.month) - 1,
    Number(values.day),
    Number(values.hour),
    Number(values.minute),
  );
  return new Date(utcGuess - (representedAsUtc - utcGuess));
}

module.exports = {appointmentInstantFromDateMarker};
