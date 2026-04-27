import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Signs in with email/password. Returns the [UserModel] if the Firestore
  /// user doc exists, or a fallback model derived from the Auth credential
  /// if the doc is missing or Firestore is unreachable.
  /// Never throws due to a missing/unreachable Firestore doc.
  Future<UserModel?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) return null;

    try {
      final model = await getUserModel(user.uid);
      if (model != null) return model;
    } catch (e) {
      debugPrint('AuthService: getUserModel failed — using fallback role: $e');
    }

    // Fallback: Auth succeeded but Firestore doc is missing or unreachable.
    // Derive role from email so the app still opens correctly.
    final role = email.contains('manager') ? 'manager' : 'developer';
    return UserModel(id: user.uid, name: email, email: email, role: role, createdAt: DateTime.now());
  }

  Future<void> signOut() => _auth.signOut();

  Future<UserModel?> getUserModel(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }
}
