import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service để quản lý và kiểm tra role của user
class RoleService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy role của user hiện tại
  static Future<String> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return 'guest';

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        return 'patient'; // Mặc định là patient
      }
      
      final data = doc.data();
      return data?['role'] ?? 'patient';
    } catch (e) {
      return 'patient';
    }
  }

  /// Kiểm tra user hiện tại có phải admin không
  static Future<bool> isAdmin() async {
    final role = await getCurrentUserRole();
    return role == 'admin';
  }

  /// Kiểm tra user hiện tại có phải doctor không
  static Future<bool> isDoctor() async {
    final role = await getCurrentUserRole();
    return role == 'doctor';
  }

  /// Kiểm tra user hiện tại có phải patient không
  static Future<bool> isPatient() async {
    final role = await getCurrentUserRole();
    return role == 'patient';
  }

  /// Stream để theo dõi role thay đổi real-time
  static Stream<String> roleStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value('guest');

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return 'patient';
          return doc.data()?['role'] ?? 'patient';
        });
  }

  /// Update role của user (chỉ admin mới được gọi)
  static Future<bool> updateUserRole(String uid, String newRole) async {
    try {
      // Kiểm tra user hiện tại có phải admin không
      final isCurrentUserAdmin = await isAdmin();
      if (!isCurrentUserAdmin) {
        return false;
      }

      // Không cho phép tự thay đổi role của chính mình
      final currentUser = _auth.currentUser;
      if (currentUser?.uid == uid) {
        return false;
      }

      // Validate role
      if (!['admin', 'doctor', 'patient'].contains(newRole)) {
        return false;
      }

      // Update role
      await _firestore.collection('users').doc(uid).update({
        'role': newRole,
        'roleUpdatedAt': FieldValue.serverTimestamp(),
        'roleUpdatedBy': currentUser?.uid,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Lấy tất cả users theo role
  static Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'docId': doc.id,
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Đếm số lượng users theo role
  static Future<Map<String, int>> countUsersByRole() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      
      int adminCount = 0;
      int doctorCount = 0;
      int patientCount = 0;

      for (var doc in snapshot.docs) {
        final role = doc.data()['role'] ?? 'patient';
        switch (role) {
          case 'admin':
            adminCount++;
            break;
          case 'doctor':
            doctorCount++;
            break;
          case 'patient':
          default:
            patientCount++;
            break;
        }
      }

      return {
        'admin': adminCount,
        'doctor': doctorCount,
        'patient': patientCount,
        'total': snapshot.docs.length,
      };
    } catch (e) {
      return {
        'admin': 0,
        'doctor': 0,
        'patient': 0,
        'total': 0,
      };
    }
  }

  /// Debug: In thông tin user hiện tại
  static Future<void> debugCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    final role = await getCurrentUserRole();
    print('🔐 === USER INFO ===');
    print('   Email: ${user.email}');
    print('   UID: ${user.uid}');
    print('   Role: $role');
    print('   Is Admin: ${role == 'admin' ? '' : ''}');
    print('   Is Doctor: ${role == 'doctor' ? '' : ''}');
    print('   Is Patient: ${role == 'patient' ? '' : ''}');
    print('==================');
  }
}
