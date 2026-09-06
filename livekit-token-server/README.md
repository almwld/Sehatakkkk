# Sehatak LiveKit Token Server

خادم Node.js صغير مستقل لإصدار LiveKit JWT لتطبيق «صحتك».

- Firebase Auth هو مصدر الهوية.
- Firebase/Firestore يبقى الـBackend الرئيسي للتطبيق.
- هذا الخادم لا يخزن بيانات المستخدمين.
- `LIVEKIT_API_KEY` و`LIVEKIT_API_SECRET` متغيرات بيئية سرية ولا توضع في Git.

## التشغيل المحلي

```bash
cd livekit-token-server
npm install
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/firebase-service-account.json
export LIVEKIT_API_KEY='...'
export LIVEKIT_API_SECRET='...'
npm start
```

## متغيرات البيئة

- `PORT` (اختياري، الافتراضي 8080)
- `LIVEKIT_API_KEY` (سري)
- `LIVEKIT_API_SECRET` (سري)
- `LIVEKIT_URL` (اختياري، الافتراضي رابط LiveKit الخاص بصحتك)
- اعتماد Firebase Admin عبر بيئة الاستضافة؛ لا ترفع ملف service-account إلى المستودع.

## API

`GET /health` للتحقق من أن الخادم يعمل.

`POST /token` يتطلب:

`Authorization: Bearer <Firebase ID token>`

وجسم JSON:

```json
{"roomName":"call_<callId>","participantName":"اسم المستخدم"}
```

الخادم يتحقق من Firebase ID token ثم يصدر توكن LiveKit بهوية Firebase UID فقط.

> GitHub Repository هو مصدر الكود. تشغيل الخادم نفسه يحتاج بيئة استضافة Node.js مستمرة؛ GitHub Actions ليس خادمًا دائمًا.
