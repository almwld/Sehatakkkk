class ApiConfig {
  static const String baseUrl = 'http://localhost:3000';
  static const String chatsEndpoint = '/api/chats';
  static const String messagesEndpoint = '/api/messages';
  static const String callsEndpoint = '/api/calls';
  static const String filesEndpoint = '/api/files';
  static const String livekitEndpoint = '/api/livekit';
  static const String authEndpoint = '/api/auth';
  static const String firebaseEndpoint = '/api/firebase';
  static const String notificationsEndpoint = '/api/notifications';
  static const String usersEndpoint = '/api/users';
  
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;
  static const int maxRetries = 3;
}
