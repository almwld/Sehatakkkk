const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {setGlobalOptions} = require('firebase-functions/v2/options');
const admin = require('firebase-admin');
const crypto = require('crypto');

setGlobalOptions({region: 'us-central1', maxInstances: 10});
const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

const PLANS = {
  silver: {name: 'الباقة الفضية', monthly: 3000, annual: 30000, features: ['رعاية صحية منتظمة']},
  bronze: {name: 'الباقة البرونزية', monthly: 3900, annual: 39000, features: ['مزايا صحية متقدمة']},
  gold: {name: 'الباقة الذهبية', monthly: 4900, annual: 35000, features: ['الرعاية الصحية المتكاملة']},
  family: {name: 'باقة العائلة', monthly: 7500, annual: 75000, features: ['حتى 5 أفراد من العائلة']},
  crystal: {name: 'الباقة الكريستالية', monthly: 12000, annual: 120000, features: ['تجربة رعاية فائقة']},
};

function requireAuth(request) {
  if (!request.auth || !request.auth.uid) throw new HttpsError('unauthenticated', 'يجب تسجيل الدخول أولاً');
  return request.auth.uid;
}
function digest(value) { return crypto.createHash('sha256').update(value).digest('hex').slice(0, 40); }

exports.activateSubscription = onCall(async (request) => {
  const uid = requireAuth(request);
  const planCode = String(request.data.planCode || '').trim().toLowerCase();
  const billing = String(request.data.billing || 'monthly').trim().toLowerCase();
  const idempotencyKey = String(request.data.idempotencyKey || '').trim();
  const plan = PLANS[planCode];

  if (!plan) throw new HttpsError('not-found', 'الباقة المطلوبة غير موجودة');
  if (!['monthly', 'annual'].includes(billing)) throw new HttpsError('invalid-argument', 'دورة الفوترة غير صالحة');
  if (idempotencyKey.length < 8 || idempotencyKey.length > 200) throw new HttpsError('invalid-argument', 'مفتاح العملية غير صالح');

  const amount = billing === 'annual' ? plan.annual : plan.monthly;
  const requestHash = digest(`${uid}|${planCode}|${billing}|${idempotencyKey}`);
  const transactionId = `subpay_${uid}_${requestHash}`;
  const subscriptionId = `sub_${uid}_${requestHash}`;
  const invoiceId = `inv_${uid}_${requestHash}`;
  const walletRef = db.collection('wallets').doc(uid);
  const transactionRef = db.collection('transactions').doc(transactionId);
  const subscriptionRef = db.collection('subscriptions').doc(subscriptionId);
  const invoiceRef = db.collection('invoices').doc(invoiceId);

  await db.runTransaction(async (tx) => {
    const [walletSnap, txSnap, subscriptionSnap] = await Promise.all([
      tx.get(walletRef),
      tx.get(transactionRef),
      tx.get(subscriptionRef),
    ]);

    if (txSnap.exists && subscriptionSnap.exists) return;
    if (!walletSnap.exists || walletSnap.data().isActive === false) {
      throw new HttpsError('failed-precondition', 'المحفظة غير مفعلة لهذا الحساب');
    }

    const wallet = walletSnap.data();
    const balance = Number(wallet.balance || 0);
    if (balance < amount) throw new HttpsError('failed-precondition', 'رصيد المحفظة غير كافٍ');

    const activeSnap = await tx.get(
      db.collection('subscriptions')
        .where('userId', '==', uid)
        .where('status', 'in', ['active', 'trial'])
        .limit(1),
    );
    if (!activeSnap.empty) throw new HttpsError('already-exists', 'لديك اشتراك نشط بالفعل');

    const now = new Date();
    const end = new Date(now);
    if (billing === 'annual') end.setFullYear(end.getFullYear() + 1);
    else end.setMonth(end.getMonth() + 1);
    const timestamp = FieldValue.serverTimestamp();

    tx.update(walletRef, {
      balance: balance - amount,
      totalSpent: Number(wallet.totalSpent || 0) + amount,
      updatedAt: timestamp,
      lastTransactionAt: timestamp,
    });

    tx.set(transactionRef, {
      userId: uid,
      amount,
      fee: 0,
      netAmount: amount,
      type: 'payment',
      status: 'completed',
      title: `اشتراك ${plan.name}`,
      description: `اشتراك ${billing === 'annual' ? 'سنوي' : 'شهري'} في ${plan.name}`,
      serviceType: 'subscription',
      serviceId: planCode,
      idempotencyKey,
      metadata: {planCode, billing, subscriptionId, invoiceId},
      createdAt: timestamp,
      completedAt: timestamp,
    });

    tx.set(subscriptionRef, {
      userId: uid,
      plan: planCode,
      planName: plan.name,
      billing,
      status: 'active',
      startDate: now.toISOString(),
      endDate: end.toISOString(),
      price: amount,
      currency: 'YER',
      paymentProvider: 'wallet',
      transactionId,
      autoRenew: false,
      features: plan.features,
      idempotencyKey,
      createdAt: timestamp,
      updatedAt: timestamp,
    });

    tx.set(invoiceRef, {
      userId: uid,
      invoiceId,
      type: 'subscription',
      status: 'paid',
      amount,
      currency: 'YER',
      transactionId,
      subscriptionId,
      planCode,
      billing,
      issuedAt: timestamp,
      createdAt: timestamp,
    });
  });

  return {
    success: true,
    subscriptionId,
    transactionId,
    invoiceId,
    planCode,
    billing,
    amount,
    currency: 'YER',
    status: 'active',
  };
});
