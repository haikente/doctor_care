import 'package:doctor_care/core/images/images.dart';
import 'package:doctor_care/core/services/auth_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      redirect();
    });
  }

  Future<void> redirect() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // Kiểm tra xem có phiên đăng nhập đã lưu không (Remember Me)
    final hasSession = await AuthStorageService.hasValidSession();
    final currentUser = FirebaseAuth.instance.currentUser;
    
    // Debug
    await AuthStorageService.debugPrint();
    
    if (hasSession && currentUser != null) {
      // Có phiên đã lưu VÀ Firebase còn authenticated -> Auto login
      final session = await AuthStorageService.getSavedSession();
      final role = session?['role'] ?? 'patient';
      
      if (mounted) {
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin-panel');
        } else {
          Navigator.pushReplacementNamed(context, '/navigation');
        }
      }
    } else if (currentUser != null) {

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/navigation');
      }
    } else {

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              height: 130,
              width: 130,
              child: Image.asset(Images.logo, fit: BoxFit.cover,))),
            const Text(
              "Doctor Care",
              style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
