function resolveLabBookingPricing(lab, booking) {
  const catalog = Array.isArray(lab?.tests) ? lab.tests : [];
  const rawIds = Array.isArray(booking?.testIds)
    ? booking.testIds
    : Array.isArray(booking?.tests)
      ? booking.tests.map((item) => item && typeof item === 'object' ? item.id : null)
      : booking?.testId
        ? [booking.testId]
        : [];
  const testIds = [...new Set(rawIds.map((value) => String(value || '').trim()).filter(Boolean))];
  if (!testIds.length || testIds.length > 20) {
    throw new Error('Booking must contain between 1 and 20 valid test IDs.');
  }

  const selected = testIds.map((id) => catalog.find((item) =>
    item && typeof item === 'object' && String(item.id || '') === id
  ));
  if (selected.some((item) => !item)) {
    throw new Error('One or more requested tests are not in the trusted lab catalog.');
  }

  const tests = selected.map((item, index) => {
    const price = Number(item.price);
    if (!Number.isFinite(price) || price < 0 || price > 100000000) {
      throw new Error('The lab catalog contains an invalid test price.');
    }
    return {
      id: testIds[index],
      name: String(item.name || '').trim().slice(0, 200),
      price: Math.round(price * 100) / 100,
    };
  });
  const total = Math.round(tests.reduce((sum, item) => sum + item.price, 0) * 100) / 100;
  if (!Number.isFinite(total) || total <= 0) {
    throw new Error('The trusted lab catalog total is invalid.');
  }
  return { testIds, tests, total };
}

module.exports = { resolveLabBookingPricing };
