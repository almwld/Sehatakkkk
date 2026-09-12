#!/usr/bin/env node
'use strict';
// Load test is opt-in. It will NOT send 100 real notifications unless STRESS_SEND=true.
const https=require('https'); const {URL}=require('url');
const url=process.env.NOTIFICATION_SERVER_URL; const token=process.env.FIREBASE_ID_TOKEN;
const total=Number(process.env.STRESS_COUNT||100); const concurrency=Number(process.env.STRESS_CONCURRENCY||10);
if(!url||!token){console.error('Set NOTIFICATION_SERVER_URL and FIREBASE_ID_TOKEN');process.exit(1)}
if(process.env.STRESS_SEND!=='true'){console.log(`DRY RUN: would issue ${total} requests with concurrency ${concurrency}. Set STRESS_SEND=true to execute.`);process.exit(0)}
const request=i=>new Promise(resolve=>{const u=new URL(url.replace(/\/$/,'')+'/notification');const body=JSON.stringify({receiverId:process.env.RECEIVER_UID,type:'system',subType:'stress_test',title:'Sehatak stress test',body:`stress ${i}`,data:{stressId:String(i)}});const r=https.request({hostname:u.hostname,path:u.pathname,method:'POST',headers:{Authorization:`Bearer ${token}`,'Content-Type':'application/json','Content-Length':Buffer.byteLength(body)}},res=>{res.resume();res.on('end',()=>resolve(res.statusCode||0))});r.on('error',()=>resolve(0));r.end(body)});
(async()=>{let next=0,done=0,ok=0;const started=Date.now();async function worker(){while(true){const i=next++;if(i>=total)return;const s=await request(i);done++;if(s>=200&&s<300)ok++;if(done%10===0)console.log(`${done}/${total}`)}}await Promise.all(Array.from({length:Math.min(concurrency,total)},worker));console.log(`RESULT ${ok}/${total} accepted in ${Date.now()-started}ms`);process.exitCode=ok===total?0:1})();
