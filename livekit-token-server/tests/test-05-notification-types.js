const Reporter = require('./utils/test-reporter');
const { getIdTokenForUser } = require('./utils/firebase-helper');
const { notify } = require('./utils/railway-client');

(async () => {
  const r = new Reporter('notification-types');
  const callerUid = process.env.TEST_CALLER_UID;
  const receiverId = process.env.TEST_RECEIVER_UID;
  if (!callerUid || !receiverId) r.skip('Supported notification types', 'Set TEST_CALLER_UID and TEST_RECEIVER_UID for live endpoint validation');
  else {
    try {
      const token = await getIdTokenForUser(callerUid);
      const types = ['new_message','appointment','medication','lab_result','payment','order','promotional','system','health','social'];
      for (const type of types) {
        const response = await notify(token,{receiverId,type,title:`Node ${type}`,body:'Backend validation'});
        if (response.status !== 200) throw new Error(`${type}: HTTP ${response.status} ${JSON.stringify(response.body)}`);
      }
      r.pass('All supported notification types', '10/10 accepted or safely skipped by recipient state');
    } catch (e) { r.fail('All supported notification types', e); }
  }
  r.writeReport(); process.exit(r.print() ? 0 : 1);
})().catch(e => { console.error(e); process.exit(1); });
