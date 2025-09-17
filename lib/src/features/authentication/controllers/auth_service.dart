import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 登录固定账号
  Future<User?> loginFixedAccount() async {
    try {
      // 固定账号
      const email = 'testuser@example.com';
      const password = '123456';

      // 尝试登录
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Login failed: ${e.message}');
      return null;
    }
  }

  /// 获取 Firebase ID Token
  Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }
}
