const {onDocumentCreated}=require('firebase-functions/v2/firestore');
const admin=require('firebase-admin');
const db=admin.firestore();

async function sendToUser(uid,payload){
  if(!uid)return;
  const snap=await db.collection('users').doc(uid).get();
  const userData=snap.data()||{};
  const tokens=[...(Array.isArray(userData.fcmTokens)?userData.fcmTokens:[]), userData.fcmToken].map(v=>String(v||'').trim()).filter(Boolean);
  if(!tokens.length)return;
  try{
    const type=String(payload.data?.type||'');
    const isCall=type==='incoming_call';
    const message={
      tokens,
      data:Object.fromEntries(Object.entries(payload.data||{}).map(([k,v])=>[k,String(v??'')])),
      android:{
        priority:'high',
        ttl:isCall?60*1000:60*60*1000,
      },
      apns:{
        headers:isCall
          ? {'apns-priority':'10','apns-push-type':'alert'}
          : {'apns-priority':'5','apns-push-type':'background'},
        payload:{
          aps:{
            'content-available':1,
            ...(isCall?{sound:'call_ringtone.caf'}:{}),
          },
        },
      },
    };
    const response=await admin.messaging().sendEachForMulticast(message);
    if(response.failureCount){ console.warn(`FCM multicast failures for ${uid}: ${response.failureCount}`); }
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

  // Delivery is distinct from sending: a message is delivered only when at
  // least one receiver is actually online. Opening the chat also marks it
  // delivered/read from the Flutter client.
  const receiverSnapshots=await Promise.all(receivers.map(uid=>db.collection('users').doc(uid).get()));
  const delivered=receiverSnapshots.some(snap=>snap.data()?.isOnline===true);
  await s.ref.update({
    isDelivered:delivered,
    deliveredAt:delivered?admin.firestore.FieldValue.serverTimestamp():null,
  });

  await Promise.all(receivers.map(uid=>sendToUser(uid,{data:{type:'new_message',chatId,messageId:event.params.messageId,senderId,senderName,body}})));
});

exports.notifyIncomingCall=onDocumentCreated('calls/{callId}',async event=>{
  const s=event.data;if(!s)return;
  const c=s.data()||{},receiverId=String(c.receiverId||''),callerId=String(c.callerId||'');
  if(!receiverId||!callerId||receiverId===callerId)return;
  const isVideo=c.callType==='video'||c.isVideoCall===true;
  const callId=event.params.callId;
  const chatId=String(c.chatId||'');
  await sendToUser(receiverId,{data:{type:'incoming_call',callId,chatId,callerId,callerName:String(c.callerName||'مستخدم'),callerPhotoUrl:String(c.callerPhotoUrl||''),isVideo:String(isVideo),callType:isVideo?'video':'audio'}});
});
