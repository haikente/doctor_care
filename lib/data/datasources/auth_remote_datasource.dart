import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/core/services/session_service.dart';
import 'package:doctor_care/domain/failures/failures.dart';
import 'package:doctor_care/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signUp(String fullName, String email, String password);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> resetPassword(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    GoogleSignIn? googleSignIn,
  }) : googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user == null) {
        throw ServerFailure("Tài khoản không tồn tại");
      }

      // Đăng ký session token cho thiết bị này
      await SessionService.instance.generateAndStoreSession();

      // Fetch User Data from Firestore
      final docSnapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return UserModel.fromMap(
          docSnapshot.data()!,
          user.uid,
          user.email ?? "",
        );
      }

      return UserModel(uid: user.uid, email: user.email ?? "", role: 'patient');
    } on FirebaseAuthException catch (e) {
      // Xử lý chi tiết các mã lỗi Firebase
      switch (e.code) {
        case 'user-not-found':
          throw ServerFailure('Không tìm thấy tài khoản với email này');
        case 'wrong-password':
          throw ServerFailure('Mật khẩu không chính xác');
        case 'invalid-email':
          throw ServerFailure('Email không hợp lệ');
        case 'user-disabled':
          throw ServerFailure('Tài khoản đã bị vô hiệu hóa');
        case 'too-many-requests':
          throw ServerFailure('Quá nhiều lần thử. Vui lòng thử lại sau');
        case 'network-request-failed':
          throw ServerFailure('Lỗi kết nối mạng. Kiểm tra internet của bạn');
        case 'invalid-credential':
          throw ServerFailure('Email hoặc mật khẩu không đúng');
        case 'operation-not-allowed':
          throw ServerFailure('Đăng nhập email/password chưa được kích hoạt');
        default:
          throw ServerFailure(e.message ?? "Đăng nhập thất bại");
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Lỗi không xác định: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    await SessionService.instance.clearSession();
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      try {
        final docSnapshot = await firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (docSnapshot.exists && docSnapshot.data() != null) {
          return UserModel.fromMap(
            docSnapshot.data()!,
            user.uid,
            user.email ?? "",
          );
        } else {
          // Fallback if data doesn't exist
          return UserModel(
            uid: user.uid,
            email: user.email ?? "",
            role: 'patient',
          );
        }
      } catch (e) {
        // Fallback on error
        return UserModel(
          uid: user.uid,
          email: user.email ?? "",
          role: 'patient',
        );
      }
    }
    return null;
  }

  Future<String> _getUserRole(String uid) async {
    try {
      final docSnapshot = await firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return docSnapshot.data()!['role'] ?? 'patient';
      } else {
        // Nếu tài khoản không tồn tại
        return 'patient';
      }
    } catch (e) {
      // Nếu có lỗi xảy ra
      return 'patient';
    }
  }

  @override
  Future<UserModel> signUp(
    String fullName,
    String email,
    String password,
  ) async {
    try {
      final normalizedFullName = fullName.trim();
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) {
        throw ServerFailure("Tài khoản không tồn tại");
      }

      // Khởi tạo user
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? "",
        role: 'patient',
        fullName: normalizedFullName.isEmpty ? null : normalizedFullName,
      );

      await firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      // Xử lý chi tiết các mã lỗi Firebase
      switch (e.code) {
        case 'email-already-in-use':
          throw ServerFailure('Email này đã được đăng ký');
        case 'invalid-email':
          throw ServerFailure('Email không hợp lệ');
        case 'operation-not-allowed':
          throw ServerFailure('Đăng ký chưa được kích hoạt');
        case 'weak-password':
          throw ServerFailure(
            'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn',
          );
        case 'network-request-failed':
          throw ServerFailure('Lỗi kết nối mạng. Kiểm tra internet của bạn');
        default:
          throw ServerFailure(e.message ?? "Đăng ký thất bại");
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Lỗi không xác định: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw ServerFailure("Hủy đăng nhập Google");
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user == null) {
        throw ServerFailure("Đăng nhập Google thất bại");
      }

      // Kiểm tra vai trò người dùng trong Firestore, nếu không tồn tại thì tạo mới với vai trò 'patient'
      String role = 'patient';
      try {
        role = await _getUserRole(user.uid);
      } catch (e) {
        // Nếu việc lấy vai trò thất bại (tài liệu có thể không tồn tại), tạo nó
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? "",
          role: 'patient',
        );
        await firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
        role = 'patient';
      }

      final docSnapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (!docSnapshot.exists) {
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? "",
          role: 'patient', // Default role for Google Sign-In
        );
        await firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
      }

      // Đăng ký session token cho thiết bị này
      await SessionService.instance.generateAndStoreSession();

      final userDoc = await firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        return UserModel.fromMap(userDoc.data()!, user.uid, user.email ?? "");
      }

      return UserModel(uid: user.uid, email: user.email ?? "", role: role);
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(e.message ?? "Lỗi xác thực Google");
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw ServerFailure('Không tìm thấy tài khoản với email này');
      } else if (e.code == 'invalid-email') {
        throw ServerFailure('Email không hợp lệ');
      } else {
        throw ServerFailure(e.message ?? 'Không thể gửi email khôi phục');
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
