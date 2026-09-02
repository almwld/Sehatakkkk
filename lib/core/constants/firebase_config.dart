// ============================================================
// 🔥 FirebaseConfig - تكوين Firebase
// ============================================================

class FirebaseConfig {
  // ✅ بيانات Firebase Project: sehatak-platform
  static const String projectId = 'sehatak-platform';
  static const String appId = '1:123456789:android:abcdef123456';
  static const String apiKey = 'AIzaSyDemoKey123456789';
  static const String messagingSenderId = '123456789';
  static const String storageBucket = 'sehatak-platform.appspot.com';
  static const String authDomain = 'sehatak-platform.firebaseapp.com';

  // ✅ مسارات Firestore
  static const String usersCollection = 'users';
  static const String doctorsCollection = 'doctors';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String callsCollection = 'calls';
  static const String notificationsCollection = 'notifications';
  static const String appointmentsCollection = 'appointments';
  static const String prescriptionsCollection = 'prescriptions';
  static const String articlesCollection = 'articles';
  static const String medicinesCollection = 'medicines';
  static const String ordersCollection = 'orders';

  // ✅ قواعد الأمان
  static const String securityRules = '''
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        function isAuthenticated() {
          return request.auth != null && request.auth.uid != null;
        }
        function isOwner(userId) {
          return isAuthenticated() && request.auth.uid == userId;
        }
        function isChatParticipant(chatId) {
          return isAuthenticated() &&
            get(/databases/$(database)/documents/chats/$(chatId)).data.participants
              .hasAny([request.auth.uid]);
        }
        match /users/{userId} {
          allow read: if isAuthenticated();
          allow write: if isOwner(userId);
        }
        match /doctors/{doctorId} {
          allow read: if true;
          allow write: if isAuthenticated() && request.auth.token.isDoctor == true;
        }
        match /chats/{chatId} {
          allow read: if isAuthenticated() && isChatParticipant(chatId);
          allow write: if isAuthenticated() && isChatParticipant(chatId);
          allow create: if isAuthenticated();
          allow delete: if isAuthenticated() && isChatParticipant(chatId);
        }
        match /chats/{chatId}/messages/{messageId} {
          allow read: if isAuthenticated() && isChatParticipant(chatId);
          allow write: if isAuthenticated() && isChatParticipant(chatId);
          allow create: if isAuthenticated() && isChatParticipant(chatId);
          allow delete: if isAuthenticated() &&
            isChatParticipant(chatId) &&
            request.auth.uid == resource.data.senderId;
        }
        match /calls/{callId} {
          allow read: if isAuthenticated() &&
            resource.data.participants.hasAny([request.auth.uid]);
          allow write: if isAuthenticated() &&
            resource.data.participants.hasAny([request.auth.uid]);
          allow create: if isAuthenticated();
        }
        match /notifications/{notificationId} {
          allow read: if isAuthenticated() &&
            resource.data.userId == request.auth.uid;
          allow write: if isAuthenticated() &&
            resource.data.userId == request.auth.uid;
        }
        match /appointments/{appointmentId} {
          allow read: if isAuthenticated() &&
            (resource.data.patientId == request.auth.uid ||
             resource.data.doctorId == request.auth.uid);
          allow write: if isAuthenticated() &&
            (resource.data.patientId == request.auth.uid ||
             resource.data.doctorId == request.auth.uid);
        }
        match /articles/{articleId} {
          allow read: if true;
          allow write: if isAuthenticated() && request.auth.token.isAdmin == true;
        }
        match /medicines/{medicineId} {
          allow read: if true;
          allow write: if isAuthenticated() && request.auth.token.isAdmin == true;
        }
        match /orders/{orderId} {
          allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
          allow write: if isAuthenticated() && resource.data.userId == request.auth.uid;
        }
      }
    }
  ''';
}
