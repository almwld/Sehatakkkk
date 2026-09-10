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
    // Incoming calls MUST be data-only so the Flutter background handler can
    // create the local full-screen call notification. A normal FCM notification
    // would bypass that handler while the app is backgrounded/terminated.
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
  await Promise.all(receivers.map(uid=>sendToUser(uid,{channelId:'sehatak_messages_v2',sound:'notification',notification:{title:senderName,body},data:{type:'chat_message',chatId,messageId:event.params.messageId,senderId,senderName,body}})));
});

exports.notifyIncomingCall=onDocumentCreated('calls/{callId}',async event=>{
  const s=event.data;if(!s)return;
  const c=s.data()||{},receiverId=String(c.receiverId||''),callerId=String(c.callerId||'');
  if(!receiverId||!callerId||receiverId===callerId)return;
  const isVideo=c.callType==='video'||c.isVideoCall===true;
  const callId=event.params.callId;
  const chatId=String(c.chatId||'');
  // Do not include a notification payload here. Flutter's background FCM
  // handler turns this high-priority data message into a full-screen local
  // incoming-call notification, including when the app process is dead.
  await sendToUser(receiverId,{
    channelId:'sehatak_calls_v2',
    sound:'call_ringtone',
    data:{type:'incoming_call',callId,chatId,callerId,callerName:String(c.callerName||'مستخدم'),callerPhotoUrl:String(c.callerPhotoUrl||''),isVideo:String(isVideo)},
  });
});
