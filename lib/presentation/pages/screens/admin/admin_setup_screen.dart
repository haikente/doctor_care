import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AdminSetupScreen extends StatefulWidget {
  const AdminSetupScreen({super.key});

  @override
  State<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _secretKeyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final String _adminSecretKey = "DOCTORCARE_ADMIN_2026";

  Future<void> _createAdminAccount() async {
    if (!_formKey.currentState!.validate()) return;

    // Kiểm tra secret key
    if (_secretKeyController.text != _adminSecretKey) {
      _showError("Secret Key không đúng!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firebaseAuth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      // 1. Tạo user trong Firebase Auth
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("Không thể tạo user");
      }

      // 2. Lưu vào Firestore với role admin
      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'role': 'admin', // ⭐ ROLE ADMIN
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSuccess("Tạo Admin thành công!");

      // Sign out để user phải đăng nhập lại
      await firebaseAuth.signOut();

      // Quay về login
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showError('Email đã được sử dụng');
      } else if (e.code == 'weak-password') {
        _showError('Mật khẩu quá yếu');
      } else {
        _showError(e.message ?? 'Lỗi tạo tài khoản');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _promoteExistingUser() async {
    if (_emailController.text.isEmpty) {
      _showError("Vui lòng nhập email");
      return;
    }

    if (_secretKeyController.text != _adminSecretKey) {
      _showError("Secret Key không đúng!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final email = _emailController.text.trim();

      // Tìm user theo email
      final querySnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _showError("Không tìm thấy user với email này");
        return;
      }

      // Update role
      final docId = querySnapshot.docs.first.id;
      await firestore.collection('users').doc(docId).update({
        'role': 'admin',
        'promotedAt': FieldValue.serverTimestamp(),
      });

      _showSuccess("Đã nâng cấp user thành Admin!");
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const Gap(12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const Gap(12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 Admin Setup'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade700, Colors.red.shade900],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Warning Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 60,
                          color: Colors.red.shade700,
                        ),
                        const Gap(16),
                        Text(
                          '⚠️ CẢ NHẮC BẢO MẬT',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const Gap(12),
                        Text(
                          'Màn hình này chỉ dùng 1 lần để tạo Admin đầu tiên.\n\n'
                          '⚠️ SAU KHI TẠO XONG:\n'
                          '1. XÓA file admin_setup_screen.dart\n'
                          '2. XÓA route trong main.dart\n'
                          '3. Rebuild app\n\n'
                          'Nếu không, bất kỳ ai cũng có thể tạo admin!',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const Gap(32),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tạo Admin Account',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Gap(24),

                        // Secret Key
                        TextFormField(
                          controller: _secretKeyController,
                          decoration: InputDecoration(
                            labelText: '🔑 Secret Key',
                            prefixIcon: const Icon(Icons.key),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value != _adminSecretKey) {
                              return 'Secret key không đúng';
                            }
                            return null;
                          },
                        ),

                        const Gap(16),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email Admin',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập email';
                            }
                            return null;
                          },
                        ),

                        const Gap(16),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                            }
                            return null;
                          },
                        ),

                        const Gap(24),

                        // Create Admin Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _createAdminAccount,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.person_add),
                            label: const Text('Tạo Admin Mới'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        const Gap(16),

                        // Promote Existing User Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _promoteExistingUser,
                            icon: const Icon(Icons.upgrade),
                            label: const Text('Nâng cấp User hiện có'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red.shade700),
                              foregroundColor: Colors.red.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Gap(24),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue.shade700),
                            const Gap(8),
                            Text(
                              'Hướng dẫn:',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Gap(12),
                        Text(
                          '1. Nhập Secret Key: $_adminSecretKey\n'
                          '2. Nhập email và password cho admin\n'
                          '3. Bấm "Tạo Admin Mới"\n\n'
                          'HOẶC\n\n'
                          '1. Nhập email của user đã tồn tại\n'
                          '2. Bấm "Nâng cấp User hiện có"',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }
}
