const Reporter = require('./utils/test-reporter');
const { db, auth, createTempUser, deleteUser, getIdTokenForUser } = require('./utils/firebase-helper');
const { callNotify } = require('./utils/railway-client');

(async () => {
  const r = new Reporter('call-flow');
  let caller = null;
  const callId = `node-test-call-${Date.now()}-${Math.random().toString(36).slice(2,7)}`;
  try {
    const receiverUid = process.env.TEST_RECEIVER_UID;
    if (!receiverUid) throw new Error('Set TEST_RECEIVER_UID for the server-side call flow test');
    const receiver = await db().collection('users').doc(receiverUid).get();
    if (!receiver.exists) throw new Error('TEST_RECEIVER_UID does not exist');
    caller = await createTempUser('node-call-caller');
    await db().collection('users').doc(caller.uid).set({name:'Node Call Caller',isTestAccount:true},{merge:true});
    await db().collection('calls').doc(callId).set({callerId:caller.uid,receiverId:receiverUid,participants:[caller.uid,receiverUid],status:'ringing',callType:'audio',isVideoCall:false,createdAt:new Date()});
    const token = await getIdTokenForUser(caller.uid);
    const response = await callNotify(token, callId);
    if (response.status === 200 && response.body?.success) r.pass('Railway /call-notification', JSON.stringify({sent:response.body.sent,reason:response.body.reason,messageId:response.body.messageId ? 'present' : 'absent'}));
    else if (response.status === 200 && response.body?.reason === 'fcm_token_missing') r.skip('Railway /call-notification', 'Receiver has no FCM token');
    else throw new Error(`HTTP ${response.status}: ${JSON.stringify(response.body)}`);
  } catch (e) { r.fail('Railway /call-notification', e); }
  finally {
    try { await db().collection('calls').doc(callId).delete(); } catch (_) {}
    if (caller) { try { await deleteUser(caller.uid); } catch (_) {} }
  }
  r.writeReport(); process.exit(r.print() ? 0 : 1);
})().catch(e => { console.error(e); process.exit(1); });
