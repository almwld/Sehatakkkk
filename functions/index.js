const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {setGlobalOptions} = require('firebase-functions/v2/options');
const admin = require('firebase-admin');
const crypto = require('crypto');

admin.initializeApp();
setGlobalOptions({region: 'us-central1', maxInstances: 10});
const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

function requireAuth(request) {
  if (!request.auth || !request.auth.uid) throw new HttpsError('unauthenticated', 'يجب تسجيل الدخول أولاً');
  return request.auth.uid;
}
function amountOf(value) {
  const amount = Number(value);
  if (!Number.isFinite(amount) || amount <= 0 || amount > 100000000) throw new HttpsError('invalid-argument', 'المبلغ غير صالح');
  return Math.round(amount * 100) / 100;
}
function text(value, field, max = 500) {
  const result = String(value || '').trim();
  if (!result || result.length > max) throw new HttpsError('invalid-argument', `الحقل ${field} غير صالح`);
  return result;
}
function digest(value) { return crypto.createHash('sha256').update(value).digest('hex').slice(0, 40); }
async function isAdmin(uid) {
  const snap = await db.collection('users').doc(uid).get();
  return snap.exists && ['admin','superAdmin'].includes(snap.data().role);
}

exports.createWallet = onCall(async (request) => {
  const uid = requireAuth(request);
  const ref = db.collection('wallets').doc(uid);
  const snap = await ref.get();
  if (!snap.exists) {
    await ref.set({userId: uid, balance: 0, pendingBalance: 0, totalDeposited: 0, totalWithdrawn: 0, totalSpent: 0, currency: 'YER', isActive: true, createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp()});
  }
  return {userId: uid, created: !snap.exists};
});

exports.ensureVerificationNotice = onCall(async (request) => {
  const uid=requireAuth(request);
  const userSnap=await db.collection('users').doc(uid).get();
  if(!userSnap.exists) throw new HttpsError('not-found','حساب المستخدم غير موجود');
  const user=userSnap.data()||{}, role=String(user.role||'user');
  if(['user','patient','admin','superAdmin'].includes(role) || user.isVerified===true) return {shown:false};
  const existing=await db.collection('notifications').where('userId','==',uid).where('type','==','verification_required').limit(1).get();
  if(existing.empty) await db.collection('notifications').add({userId:uid,type:'verification_required',title:'يجب توثيق حسابك',body:'أكمل توثيق حسابك المهني ورفع مستنداتك حتى تتمكن من استخدام ميزات المنصة الخاصة بدورك.',role,isRead:false,action:'verification',createdAt:FieldValue.serverTimestamp()});
  return {shown:true};
});

exports.submitVerificationRequest = onCall(async (request) => {
  const uid=requireAuth(request);const userRef=db.collection('users').doc(uid);const requestRef=db.collection('verification_requests').doc(uid);let role='';
  const profile=(request.data?.profile&&typeof request.data.profile==='object')?request.data.profile:{};
  const documents=(request.data?.documents&&typeof request.data.documents==='object')?request.data.documents:{};
  await db.runTransaction(async(tx)=>{
    const [userSnap,existingSnap]=await Promise.all([tx.get(userRef),tx.get(requestRef)]);
    if(!userSnap.exists)throw new HttpsError('not-found','حساب المستخدم غير موجود');
    const user=userSnap.data();role=String(user.role||'user');
    if(['user','admin','superAdmin'].includes(role))throw new HttpsError('failed-precondition','هذا الحساب لا يحتاج إلى طلب توثيق مهني');
    if(user.isVerified===true)throw new HttpsError('failed-precondition','الحساب موثق بالفعل');
    if(existingSnap.exists&&existingSnap.data().status==='pending')throw new HttpsError('failed-precondition','طلب التوثيق قيد المراجعة');
    if(!String(profile.fullName||'').trim())throw new HttpsError('invalid-argument','الاسم الكامل مطلوب');
    if(!Number.isInteger(Number(profile.age))||Number(profile.age)<18||Number(profile.age)>100)throw new HttpsError('invalid-argument','العمر غير صالح');
    if(!String(profile.licenseNumber||'').trim())throw new HttpsError('invalid-argument','رقم الترخيص مطلوب');
    if(!String(profile.experience||'').trim())throw new HttpsError('invalid-argument','الخبرة مطلوبة');
    for(const key of ['academicRecord','certificates','professionalRecord']) if(!Array.isArray(documents[key])||documents[key].length<1) throw new HttpsError('invalid-argument','مستندات التوثيق المطلوبة غير مكتملة');
    const now=FieldValue.serverTimestamp();
    tx.set(requestRef,{requestId:uid,userId:uid,name:user.name||user.displayName||'',email:user.email||'',phone:user.phone||'',role,specialty:user.specialty||'',licenseNumber:String(profile.licenseNumber),experience:String(profile.experience),profile,documents,status:'pending',submittedAt:now,updatedAt:now},{merge:true});
    tx.update(userRef,{verificationStatus:'pending',isVerified:false,updatedAt:now});
  });
  const admins=await db.collection('users').where('role','in',['admin','superAdmin']).get();
  if(!admins.empty){const batch=db.batch();admins.docs.forEach(adminDoc=>batch.set(db.collection('notifications').doc(),{userId:adminDoc.id,type:'verification_request',title:'طلب توثيق حساب جديد',body:'طلب توثيق جديد لدور '+role+' يحتاج إلى المراجعة.',verificationRequestId:uid,role,isRead:false,createdAt:FieldValue.serverTimestamp()}));await batch.commit();}
  return {status:'pending',requestId:uid};
});
exports.reviewVerificationRequest = onCall(async (request) => {
  const adminUid=requireAuth(request);if(!(await isAdmin(adminUid)))throw new HttpsError('permission-denied','صلاحية المدير مطلوبة');const requestId=text(request.data.requestId,'requestId',128);const decision=text(request.data.decision,'decision',20);if(!['approve','reject'].includes(decision))throw new HttpsError('invalid-argument','قرار غير صالح');const requestRef=db.collection('verification_requests').doc(requestId);const userRef=db.collection('users').doc(requestId);let status='rejected';
  await db.runTransaction(async(tx)=>{const [reqSnap,userSnap]=await Promise.all([tx.get(requestRef),tx.get(userRef)]);if(!reqSnap.exists||!userSnap.exists)throw new HttpsError('not-found','طلب التوثيق أو الحساب غير موجود');const req=reqSnap.data(),user=userSnap.data();if(req.userId!==requestId)throw new HttpsError('failed-precondition','طلب التوثيق غير صالح');if(['user','admin','superAdmin'].includes(String(user.role||'')))throw new HttpsError('failed-precondition','هذا الدور لا يدعم التوثيق المهني');if(req.status!=='pending')throw new HttpsError('failed-precondition','تمت معالجة الطلب مسبقاً');const approved=decision==='approve';status=approved?'approved':'rejected';const now=FieldValue.serverTimestamp();tx.update(requestRef,{status,reviewedBy:adminUid,reviewedAt:now,updatedAt:now});tx.update(userRef,{isVerified:approved,verificationStatus:status,isAvailable:approved,updatedAt:now});if(String(user.role||'')==='doctor'){const doctorRef=db.collection('doctors').doc(requestId);const doctorSnap=await tx.get(doctorRef);if(doctorSnap.exists)tx.update(doctorRef,{isVerified:approved,verificationStatus:status,isAvailable:approved,isOnline:false,verifiedAt:approved?now:null,verifiedBy:adminUid,updatedAt:now});}const roleName=String(user.role||'');const facilityCollection=['lab'].includes(roleName)?'labs':['hospital'].includes(roleName)?'hospitals':['pharmacy','pharmacist','pharmacyOwner'].includes(roleName)?'pharmacies':['clinic','medical_center','dental','dentist','ophthalmology','eye_clinic','optometrist'].includes(roleName)?'health_facilities':null;if(facilityCollection){const ref=db.collection(facilityCollection).doc(requestId);const snap=await tx.get(ref);if(snap.exists)tx.update(ref,{isVerified:approved,verificationStatus:status,isPublished:approved,verifiedAt:approved?now:null,verifiedBy:adminUid,updatedAt:now});}});
  await db.collection('admin_audit_logs').add({actorId:adminUid,action:status==='approved'?'verification_approved':'verification_rejected',targetUserId:requestId,targetRole:String(user.role||''),requestId,createdAt:FieldValue.serverTimestamp()});
  await db.collection('notifications').add({userId:requestId,type:'verification_result',title:status==='approved'?'تم توثيق حسابك':'تم رفض طلب التوثيق',body:status==='approved'?'وافق مشرف المنصة على توثيق حسابك ويمكنك الآن استخدام ميزات دورك المهني.':'راجع متطلبات التوثيق وحدث بياناتك ثم أعد إرسال الطلب.',verificationStatus:status,isRead:false,createdAt:FieldValue.serverTimestamp()});return {requestId,status};
});
exports.submitDoctorVerification=exports.submitVerificationRequest;exports.reviewDoctorVerification=exports.reviewVerificationRequest;
exports.createAppointment = onCall(async (request) => {
  const uid = requireAuth(request);
  const doctorId = text(request.data.doctorId, 'doctorId', 128);
  const doctorRef = db.collection('doctors').doc(doctorId);
  const userRef = db.collection('users').doc(uid);
  const appointmentRef = db.collection('appointments').doc();
  const dateValue = request.data.date;
  const time = text(request.data.time, 'time', 20);
  const type = request.data.type ? String(request.data.type) : 'in_person';
  if (!['in_person', 'video', 'phone'].includes(type)) throw new HttpsError('invalid-argument', 'نوع الموعد غير صالح');
  let date;
  if (dateValue && typeof dateValue === 'string') date = new Date(dateValue);
  else if (dateValue && typeof dateValue._seconds === 'number') date = new Date(dateValue._seconds * 1000);
  else throw new HttpsError('invalid-argument', 'تاريخ الموعد غير صالح');
  if (Number.isNaN(date.getTime()) || date.getTime() < Date.now() - 60000) throw new HttpsError('invalid-argument', 'تاريخ الموعد يجب أن يكون مستقبلياً');
  await db.runTransaction(async (tx) => {
    const [doctorSnap, userSnap, existingSnap] = await Promise.all([
      tx.get(doctorRef), tx.get(userRef),
      tx.get(db.collection('appointments').where('doctorId', '==', doctorId).where('date', '==', admin.firestore.Timestamp.fromDate(date)).where('time', '==', time).where('status', 'in', ['pending', 'confirmed']).limit(1)),
    ]);
    if (!userSnap.exists) throw new HttpsError('failed-precondition', 'حساب المريض غير موجود');
    if (!doctorSnap.exists) throw new HttpsError('not-found', 'الطبيب غير موجود');
    const doctor = doctorSnap.data();
    if (doctor.userId !== doctorId || doctor.isVerified !== true) throw new HttpsError('failed-precondition', 'الطبيب غير موثق أو ارتباط الحساب غير صالح');
    if (existingSnap.docs.length) throw new HttpsError('already-exists', 'هذا الموعد محجوز مسبقاً');
    const now = FieldValue.serverTimestamp();
    tx.create(appointmentRef, {patientId: uid, patientName: userSnap.data().name || userSnap.data().displayName || 'مريض', doctorId, doctorName: doctor.name || '', doctorSpecialty: doctor.specialty || '', date: admin.firestore.Timestamp.fromDate(date), time, type, status: 'pending', notes: String(request.data.notes || '').trim().slice(0, 1000), clinicAddress: doctor.clinicAddress || null, clinicPhone: doctor.clinicPhone || null, createdAt: now, updatedAt: now, confirmedAt: null, cancelledAt: null, reminderSent: false});
  });
  return {appointmentId: appointmentRef.id, status: 'pending'};
});

exports.createPayment = onCall(async (request) => {
  const uid = requireAuth(request);
  const amount = amountOf(request.data.amount);
  const title = text(request.data.title, 'title');
  const description = text(request.data.description, 'description');
  const orderId = request.data.orderId ? String(request.data.orderId) : null;
  const serviceId = request.data.serviceId ? String(request.data.serviceId) : null;
  const serviceType = request.data.serviceType ? String(request.data.serviceType) : null;
  const idempotencyKey = request.data.idempotencyKey ? String(request.data.idempotencyKey) : digest(`${uid}|${orderId || ''}|${amount}|${serviceId || ''}|${Date.now()}`);
  const txId = `pay_${uid}_${digest(idempotencyKey)}`;
  const txRef = db.collection('transactions').doc(txId);
  const walletRef = db.collection('wallets').doc(uid);
  const orderRef = orderId ? db.collection('orders').doc(orderId) : null;
  await db.runTransaction(async (tx) => {
    const [walletSnap, existingSnap, orderSnap] = await Promise.all([tx.get(walletRef), tx.get(txRef), orderRef ? tx.get(orderRef) : Promise.resolve(null)]);
    if (existingSnap.exists) return;
    if (!walletSnap.exists) throw new HttpsError('failed-precondition', 'المحفظة غير مفعلة لهذا الحساب');
    const wallet = walletSnap.data();
    const balance = Number(wallet.balance || 0);
    if (wallet.isActive === false) throw new HttpsError('failed-precondition', 'المحفظة غير نشطة');
    if (balance < amount) throw new HttpsError('failed-precondition', 'رصيد المحفظة غير كافٍ');
    if (orderRef) {
      if (!orderSnap || !orderSnap.exists) throw new HttpsError('not-found', 'الطلب غير موجود');
      const order = orderSnap.data();
      if (order.userId !== uid) throw new HttpsError('permission-denied', 'لا تملك هذا الطلب');
      if (Math.abs(Number(order.total || 0) - amount) > 0.01) throw new HttpsError('failed-precondition', 'مبلغ الدفع لا يطابق إجمالي الطلب');
      if (order.transactionId) throw new HttpsError('already-exists', 'تم ربط الطلب بمعاملة دفع مسبقاً');
    }
    const now = FieldValue.serverTimestamp();
    tx.update(walletRef, {balance: balance - amount, totalSpent: Number(wallet.totalSpent || 0) + amount, updatedAt: now, lastTransactionAt: now});
    tx.set(txRef, {userId: uid, amount, fee: 0, netAmount: amount, type: 'payment', status: 'completed', title, description, orderId, serviceId, serviceType, metadata: request.data.metadata || null, idempotencyKey, createdAt: now, completedAt: now});
    if (orderRef) tx.update(orderRef, {paymentMethod: serviceType || 'wallet', transactionId: txId, updatedAt: new Date().toISOString()});
  });
  return {transactionId: txId, status: 'completed'};
});

exports.submitTopUp = onCall(async (request) => {
  const uid = requireAuth(request);
  const amount = amountOf(request.data.amount);
  const walletName = text(request.data.walletName, 'walletName', 100);
  const referenceNumber = text(request.data.referenceNumber, 'referenceNumber', 120);
  const key = digest(`${uid}|deposit|${walletName}|${referenceNumber}`);
  const txId = `dep_${uid}_${key}`;
  const txRef = db.collection('transactions').doc(txId);
  const walletRef = db.collection('wallets').doc(uid);
  await db.runTransaction(async (tx) => {
    const [existing, wallet] = await Promise.all([tx.get(txRef), tx.get(walletRef)]);
    if (existing.exists) return;
    if (!wallet.exists || wallet.data().isActive === false) throw new HttpsError('failed-precondition', 'المحفظة غير مفعلة');
    tx.set(txRef, {userId: uid, amount, fee: 0, netAmount: amount, type: 'deposit', status: 'pending', title: `طلب تغذية حساب عبر ${walletName}`, description: `رقم الإشعار: ${referenceNumber}`, referenceNumber, walletName, idempotencyKey: key, metadata: request.data.metadata || null, createdAt: FieldValue.serverTimestamp(), completedAt: null});
  });
  return {transactionId: txId, status: 'pending'};
});

exports.requestRefund = onCall(async (request) => {
  const uid = requireAuth(request);
  const originalId = text(request.data.transactionId, 'transactionId', 150);
  const reason = text(request.data.reason, 'reason', 500);
  const originalRef = db.collection('transactions').doc(originalId);
  const refundId = `ref_${uid}_${digest(originalId)}`;
  const refundRef = db.collection('transactions').doc(refundId);
  await db.runTransaction(async (tx) => {
    const [original, existing] = await Promise.all([tx.get(originalRef), tx.get(refundRef)]);
    if (existing.exists) return;
    if (!original.exists) throw new HttpsError('not-found', 'المعاملة غير موجودة');
    const data = original.data();
    if (data.userId !== uid) throw new HttpsError('permission-denied', 'لا تملك هذه المعاملة');
    if (data.type !== 'payment' || data.status !== 'completed') throw new HttpsError('failed-precondition', 'لا يمكن استرداد هذه المعاملة');
    tx.set(refundRef, {userId: uid, amount: Number(data.amount), fee: 0, netAmount: Number(data.amount), type: 'refund', status: 'pending', title: `طلب استرداد: ${data.title || 'عملية دفع'}`, description: `سبب الاسترداد: ${reason}`, orderId: data.orderId || null, serviceId: data.serviceId || null, serviceType: data.serviceType || null, metadata: {originalTransactionId: originalId, reason}, createdAt: FieldValue.serverTimestamp(), completedAt: null});
  });
  return {transactionId: refundId, status: 'pending'};
});

exports.requestWithdrawal = onCall(async (request) => {
  const uid = requireAuth(request);
  const amount = amountOf(request.data.amount);
  const walletName = text(request.data.walletName, 'walletName', 100);
  const destination = text(request.data.destination, 'destination', 150);
  const key = digest(`${uid}|withdrawal|${walletName}|${destination}|${amount}`);
  const txId = `wd_${uid}_${key}`;
  const txRef = db.collection('transactions').doc(txId);
  const walletRef = db.collection('wallets').doc(uid);
  await db.runTransaction(async (tx) => {
    const [wallet, existing] = await Promise.all([tx.get(walletRef), tx.get(txRef)]);
    if (existing.exists) return;
    if (!wallet.exists || wallet.data().isActive === false) throw new HttpsError('failed-precondition', 'المحفظة غير مفعلة');
    const data = wallet.data();
    if (Number(data.balance || 0) < amount) throw new HttpsError('failed-precondition', 'الرصيد غير كافٍ');
    tx.update(walletRef, {balance: Number(data.balance || 0) - amount, pendingBalance: Number(data.pendingBalance || 0) + amount, updatedAt: FieldValue.serverTimestamp()});
    tx.set(txRef, {userId: uid, amount, fee: 0, netAmount: amount, type: 'withdrawal', status: 'pending', title: `طلب سحب عبر ${walletName}`, description: `وجهة السحب: ${destination}`, walletName, referenceNumber: destination, idempotencyKey: key, createdAt: FieldValue.serverTimestamp(), completedAt: null});
  });
  return {transactionId: txId, status: 'pending'};
});

exports.reviewTransaction = onCall(async (request) => {
  const uid = requireAuth(request);
  if (!(await isAdmin(uid))) throw new HttpsError('permission-denied', 'صلاحية المدير مطلوبة');
  const transactionId = text(request.data.transactionId, 'transactionId', 150);
  const decision = text(request.data.decision, 'decision', 20);
  if (!['approve', 'reject'].includes(decision)) throw new HttpsError('invalid-argument', 'قرار غير صالح');
  const txRef = db.collection('transactions').doc(transactionId);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(txRef);
    if (!snap.exists) throw new HttpsError('not-found', 'المعاملة غير موجودة');
    const data = snap.data();
    if (data.status !== 'pending') throw new HttpsError('failed-precondition', 'المعاملة تمت معالجتها مسبقاً');
    const amount = Number(data.amount || 0);
    if (!Number.isFinite(amount) || amount <= 0) throw new HttpsError('failed-precondition', 'مبلغ المعاملة غير صالح');
    const walletRef = db.collection('wallets').doc(data.userId);
    const walletSnap = await tx.get(walletRef);
    if (!walletSnap.exists) throw new HttpsError('failed-precondition', 'محفظة المستخدم غير موجودة');
    const wallet = walletSnap.data();
    const now = FieldValue.serverTimestamp();
    if (decision === 'reject') {
      if (data.type === 'withdrawal') tx.update(walletRef, {balance: Number(wallet.balance || 0) + amount, pendingBalance: Math.max(0, Number(wallet.pendingBalance || 0) - amount), updatedAt: now});
      tx.update(txRef, {status: 'failed', completedAt: now, updatedAt: now, reviewedBy: uid});
      return;
    }
    if (data.type === 'deposit') tx.update(walletRef, {balance: Number(wallet.balance || 0) + amount, totalDeposited: Number(wallet.totalDeposited || 0) + amount, updatedAt: now, lastTransactionAt: now});
    else if (data.type === 'refund') tx.update(walletRef, {balance: Number(wallet.balance || 0) + amount, totalSpent: Math.max(0, Number(wallet.totalSpent || 0) - amount), updatedAt: now, lastTransactionAt: now});
    else if (data.type === 'withdrawal') tx.update(walletRef, {pendingBalance: Math.max(0, Number(wallet.pendingBalance || 0) - amount), totalWithdrawn: Number(wallet.totalWithdrawn || 0) + amount, updatedAt: now, lastTransactionAt: now});
    else throw new HttpsError('failed-precondition', 'نوع المعاملة لا يدعم المراجعة');
    tx.update(txRef, {status: 'completed', completedAt: now, reviewedBy: uid, updatedAt: now});
  });
  return {transactionId, status: 'completed'};
});

// Triggers are kept separate from the core callable functions to keep this file maintainable.
Object.assign(exports, require('./notification_triggers'));

exports.getSuperAdminDailyReport = onCall(async (request) => {
  const uid=requireAuth(request);const me=await db.collection('users').doc(uid).get();
  if(!me.exists || me.data().role!=='superAdmin') throw new HttpsError('permission-denied','صلاحية المدير الأعلى مطلوبة');
  const since=new Date();since.setHours(0,0,0,0);
  const snap=await db.collection('admin_audit_logs').where('createdAt','>=',since).get();
  const counts={};snap.docs.forEach(d=>{const a=String(d.data().action||'unknown');counts[a]=(counts[a]||0)+1;});
  await db.collection('admin_daily_reports').doc(since.toISOString().slice(0,10)).set({date:since.toISOString().slice(0,10),totalActions:snap.size,actions:counts,generatedBy:uid,generatedAt:FieldValue.serverTimestamp()},{merge:true});
  return {date:since.toISOString().slice(0,10),totalActions:snap.size,actions:counts};
});
