import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Quản lý phiên đăng nhập - đảm bảo chỉ 1 thiết bị hoạt động
class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  static const _localTokenKey = 'active_session_token';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<DocumentSnapshot>? _sessionListener;
  String? _currentToken;

  /// Tạo session token mới, lưu lên Firestore + local.
  /// Gọi sau khi signIn / signInWithGoogle thành công.
  Future<void> generateAndStoreSession() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final token = _generateToken();
    _currentToken = token;

    // Lưu lên Firestore
    await _firestore.collection('users').doc(uid).set({
      'activeSessionToken': token,
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Lưu local
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localTokenKey, token);
  }

  /// Bắt đầu lắng nghe thay đổi session trên Firestore.
  /// Khi phát hiện token khác → gọi [onConflict].
  void listenForSessionConflict({
    required VoidCallback onConflict,
  }) {
    stopListening();

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _sessionListener = _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      final remoteToken = data['activeSessionToken'] as String?;
      if (remoteToken == null) return;

      // So sánh với token local
      if (_currentToken != null && remoteToken != _currentToken) {
        debugPrint('[SessionService] Session conflict detected – logging out');
        stopListening();
        onConflict();
      }
    });
  }

  /// Dừng lắng nghe.
  void stopListening() {
    _sessionListener?.cancel();
    _sessionListener = null;
  }

  /// Xóa session local khi sign out.
  Future<void> clearSession() async {
    stopListening();
    _currentToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localTokenKey);
  }

  /// Khôi phục token đã lưu local (dùng khi app cold-start, user vẫn
  /// đang authenticated).
  Future<void> restoreLocalToken() async {
    final prefs = await SharedPreferences.getInstance();
    _currentToken = prefs.getString(_localTokenKey);
  }

  // ── helpers ──────────────────────────────────────────────

  String _generateToken() {
    final random = Random.secure();
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
