import 'package:doctor_care/core/images/images.dart';
import 'package:doctor_care/core/services/auth_storage_service.dart';
import 'package:doctor_care/presentation/bloc/auth/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

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
    
    final hasSession = await AuthStorageService.hasValidSession();
    final currentUser = FirebaseAuth.instance.currentUser;
    
    // Debug
    await AuthStorageService.debugPrint();
    
    if (!hasSession) {
      if (currentUser != null) {
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    if (mounted) {
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
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
              child: Image.asset(Images.splashBackground, fit: BoxFit.cover,))),
              Gap(20),
            Text(
              "Doctor Care",
              style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
