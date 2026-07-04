import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/data/models/user_models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  Future<void> loadUser() async {
    if (_currentUser != null) return;
    
    _setLoading(true);
    _error = null;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _currentUser = null;
        _setLoading(false);
        return;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(user.uid, doc.data()!);
      } else {
        _currentUser = UserModel(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          phone: user.phoneNumber ?? '',
          photoUrl: user.photoURL,
          role: 'user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(_currentUser!.toMap());
      }
    } catch (e) {
      _error = e.toString();
      print('⚠️ UserProvider error: $e');
    }

    _setLoading(false);
  }

  Future<bool> updateUser(UserModel user) async {
    _setLoading(true);
    _error = null;

    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
      final currentUser = _auth.currentUser;
      if (currentUser != null && user.name.isNotEmpty) {
        await currentUser.updateDisplayName(user.name);
        await currentUser.reload();
      }
      _currentUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateField(String field, dynamic value) async {
    if (_currentUser == null) return false;

    try {
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        field: value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      final updatedMap = _currentUser!.toMap();
      updatedMap[field] = value;
      updatedMap['updatedAt'] = DateTime.now();
      
      _currentUser = UserModel.fromMap(_currentUser!.uid, updatedMap);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    _currentUser = null;
    await loadUser();
  }

  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
