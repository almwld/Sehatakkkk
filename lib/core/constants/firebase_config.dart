import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static const String projectId = 'sehatak-platform';
  static const String appId = '1:123456789:android:abcdef123456';
  static const String apiKey = 'AIzaSy...';
  static const String messagingSenderId = '123456789';
  static const String storageBucket = 'sehatak-platform.appspot.com';
  static const String authDomain = 'sehatak-platform.firebaseapp.com';

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

  static FirebaseOptions get options => const FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
    authDomain: authDomain,
  );
}
