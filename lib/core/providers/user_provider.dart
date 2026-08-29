import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  
  User? get user => _user;
  
  void loadUserSafely() {
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }
  
  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }
}
