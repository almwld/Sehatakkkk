#!/usr/bin/env node
'use strict';
const admin = require('firebase-admin');
const https = require('https');
const { URL } = require('url');
require('dotenv').config();

const request = (url, method, headers, body) => new Promise((resolve, reject) => {
  const u = new URL(url);
  const r = https.request({hostname:u.hostname,port:u.port||443,path:u.pathname+u.search,method,headers:{'Content-Type':'application/json',...headers}}, res => {
    let s=''; res.on('data',c=>s+=c); res.on('end',()=>{let data={};try{data=JSON.parse(s||'{}')}catch(_){} resolve({status:res.statusCode,data});});
  });
  r.on('error',reject); r.setTimeout(20000,()=>r.destroy(new Error('timeout')));
  if(body) r.write(JSON.stringify(body)); r.end();
});

async function main(){
  const account=process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if(!account) throw new Error('FIREBASE_SERVICE_ACCOUNT_JSON is required');
  if(!process.env.NOTIFICATION_SERVER_URL || !process.env.FIREBASE_WEB_API_KEY || !process.env.RECEIVER_UID) throw new Error('NOTIFICATION_SERVER_URL, FIREBASE_WEB_API_KEY and RECEIVER_UID are required');
  admin.initializeApp({credential:admin.credential.cert(JSON.parse(account))});
  const db=admin.firestore();
  const receiver=await db.collection('users').doc(process.env.RECEIVER_UID).get();
  if(!receiver.exists) throw new Error('Receiver user not found');
  if(typeof receiver.data().fcmToken!=='string' || !receiver.data().fcmToken.trim()) throw new Error('Receiver has no real FCM token');
  const caller=await admin.auth().createUser({email:`notify-test-${Date.now()}@example.invalid`,password:`T${Date.now()}!test`,displayName:'Notification Integration Test'});
  try{
    const custom=await admin.auth().createCustomToken(caller.uid);
    const auth=await request(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=${encodeURIComponent(process.env.FIREBASE_WEB_API_KEY)}`,'POST',{}, {token:custom,returnSecureToken:true});
    if(auth.status!==200 || !auth.data.idToken) throw new Error(`ID token exchange failed: HTTP ${auth.status}`);
    const response=await request(`${process.env.NOTIFICATION_SERVER_URL.replace(/\/$/,'')}/notification`,'POST',{Authorization:`Bearer ${auth.data.idToken}`},{receiverId:process.env.RECEIVER_UID,type:'system',subType:'integration_test',title:'Sehatak integration test',body:'FCM server acceptance test',data:{testId:String(Date.now())}});
    console.log(`HTTP ${response.status}`);
    console.log(JSON.stringify(response.data));
    if(response.status<200||response.status>=300||response.data.success!==true||response.data.sent!==true) process.exitCode=1;
    console.log('DEVICE DELIVERY IS NOT CLAIMED: verify the real Android device separately.');
  }finally{await admin.auth().deleteUser(caller.uid).catch(()=>{});}
}
main().catch(e=>{console.error(`FAIL: ${e.message}`);process.exitCode=1;});
