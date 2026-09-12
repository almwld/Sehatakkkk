const {onDocumentCreated}=require('firebase-functions/v2/firestore');
const admin=require('firebase-admin');
const db=admin.firestore();

async function sendToUser(uid,payload){
  if(!uid)return;
  const snap=await db.collection('users').doc(uid).get();
  const token=snap.data()?.fcmToken;
  if(!token)return;
  try{
    const message={
      token:String(token).trim(),
      data:Object.fromEntries(Object.entries(payload.data||{}).map(([k,v])=>[k,String(v??'')])),
      android:{priority:'high'},
    };
    if(payload.notification){
      message.notification=payload.notification;
      message.android.notification={
        channelId:payload.channelId||'sehatak_messages_v2',
        sound:payload.sound||'notification',
        priority:'high',
      };
    }
    await admin.messaging().send(message);
  }catch(e){
    console.error(`FCM send failed for ${uid}:`,e.message);
    if(['messaging/registration-token-not-registered','messaging/invalid-registration-token'].includes(e.code)){
      await db.collection('users').doc(uid).set({fcmToken:null},{merge:true});
    }
  }
}

async function persistNotification({id,userId,type,title,body,data={}}){
  if(!userId)return;
  const ref=id?db.collection('notifications').doc(String(id)):db.collection('notifications').doc();
  await ref.set({
    userId:String(userId),
    type:String(type||'system'),
    title:String(title||'صحتك'),
    body:String(body||''),
    data,
    isRead:false,
    createdAt:admin.firestore.FieldValue.serverTimestamp(),
  },{merge:false});
}

exports.notifyNewChatMessage=onDocumentCreated('chats/{chatId}/messages/{messageId}',async event=>{
  const s=event.data;if(!s)return;
  const m=s.data()||{},chatId=event.params.chatId,senderId=String(m.senderId||'');
  if(!senderId)return;
  const chatSnap=await db.collection('chats').doc(chatId).get();
  if(!chatSnap.exists)return;
  const chat=chatSnap.data()||{};
  if(chat.isMuted===true)return;
  const ids=Array.isArray(chat.participants)?chat.participants.map(String):[];
  const receivers=ids.filter(id=>id&&id!==senderId);
  if(!receivers.length)return;
  const type=String(m.type||'text'),text=String(m.text||'').trim();
  const body={image:'📷 أرسل صورة',video:'🎬 أرسل فيديو',audio:'🎵 أرسل رسالة صوتية',file:'📎 أرسل ملف',location:'📍 شارك موقعاً'}[type]||text||'أرسل رسالة جديدة';
  const senderName=String(m.senderName||'مستخدم');

  // Delivery is distinct from sending: a message is delivered only when at
  // least one receiver is actually online. Opening the chat also marks it
  // delivered/read from the Flutter client.
  const receiverSnapshots=await Promise.all(receivers.map(uid=>db.collection('users').doc(uid).get()));
  const delivered=receiverSnapshots.some(snap=>snap.data()?.isOnline===true);
  await s.ref.update({
    isDelivered:delivered,
    deliveredAt:delivered?admin.firestore.FieldValue.serverTimestamp():null,
  });

  await Promise.all(receivers.map(async uid=>{
    const data={type:'new_message',chatId,messageId:event.params.messageId,senderId,senderName,body};
    // The Firestore notification record is the durable source for the in-app
    // Notification Center. The deterministic ID prevents duplicate records
    // if the Cloud Function is retried.
    await persistNotification({
      id:`chat_${chatId}_${event.params.messageId}_${uid}`,
      userId:uid,
      type:'new_message',
      title:senderName,
      body,
      data,
    });
    // FCM remains the device-delivery channel. It is not replaced by the
    // Notification Center record above.
    await sendToUser(uid,{channelId:'sehatak_messages_v2',sound:'notification',notification:{title:senderName,body},data});
  }));
});

exports.notifyIncomingCall=onDocumentCreated('calls/{callId}',async event=>{
  const s=event.data;if(!s)return;
  const c=s.data()||{},receiverId=String(c.receiverId||''),callerId=String(c.callerId||'');
  if(!receiverId||!callerId||receiverId===callerId)return;
  const isVideo=c.callType==='video'||c.isVideoCall===true;
  const callId=event.params.callId;
  const chatId=String(c.chatId||'');
  await sendToUser(receiverId,{
    channelId:'sehatak_calls_v2',
    sound:'call_ringtone',
    data:{type:'incoming_call',callId,chatId,callerId,callerName:String(c.callerName||'مستخدم'),callerPhotoUrl:String(c.callerPhotoUrl||''),isVideo:String(isVideo)},
  });
});
