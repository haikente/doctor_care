import 'dart:io';
import 'dart:ui';
import 'package:doctor_care/core/images/images.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_bloc.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_event.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_state.dart';
import 'package:doctor_care/presentation/pages/screens/meal_analysis/meal_analysis_result_screen.dart';

class MealCaptureScreen extends StatefulWidget {
  const MealCaptureScreen({super.key});

  @override
  State<MealCaptureScreen> createState() => _MealCaptureScreenState();
}

class _MealCaptureScreenState extends State<MealCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
      _analyzeImage(image.path);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
      _analyzeImage(image.path);
    }
  }

  void _analyzeImage(String imagePath) {
    context.read<MealAnalysisBloc>().add(AnalyzeMealImageEvent(imagePath));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(Images.aifood, fit: BoxFit.cover),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.3, 0.6, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.75),
                  ],
                ),
              ),
            ),
          ),

          // ── Back button ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Main content ──
          BlocConsumer<MealAnalysisBloc, MealAnalysisState>(
            listener: (context, state) {
              if (state is MealAnalysisSuccess) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MealAnalysisResultScreen(
                      mealAnalysis: state.mealAnalysis,
                      imagePath: _imagePath!,
                    ),
                  ),
                );
              } else if (state is MealAnalysisError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.tr(
                        'error_with_message',
                        params: {'message': state.message},
                      ),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is MealAnalysisLoading) {
                return _buildLoadingState(context);
              }
              return _buildInitialState(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_imagePath != null) ...[
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      image: DecorationImage(
                        image: FileImage(File(_imagePath!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Gap(28),
                ],
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const Gap(20),
                Text(
                  context.tr('analyzing_meal'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Gap(8),
                Text(
                  context.tr('ai_analyzing'),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(flex: 3),

            // ── Icon illustration ──
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                size: 54,
                color: Colors.white,
              ),
            ),
            const Gap(28),

            // ── Title ──
            const Text(
              'Phân tích dinh dưỡng\nbằng AI',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.3,
                color: Colors.white,
                letterSpacing: -0.5,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 12,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(14),

            // ── Subtitle pill ──
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'Chụp ảnh bữa ăn, '),
                        TextSpan(
                          text: 'AI ',
                          style: TextStyle(
                            color: Colors.amber.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: 'sẽ phân tích '),
                        TextSpan(
                          text: 'dinh dưỡng chi tiết',
                          style: TextStyle(
                            color: Colors.lightBlue.shade800,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(flex: 1),

            // ── Feature chips ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFeatureChip(Icons.flash_on_rounded, 'Nhận diện nhanh'),
                const Gap(10),
                _buildFeatureChip(Icons.analytics_rounded, 'Chi tiết calo'),
              ],
            ),

            const Spacer(flex: 2),

            // ── Camera button ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _pickImageFromCamera,
                icon: const Icon(Icons.camera_alt_rounded, size: 22),
                label: const Text(
                  'Chụp ảnh bữa ăn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: Colors.blue.withOpacity(0.4),
                ),
              ),
            ),
            const Gap(12),

            // ── Gallery button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: OutlinedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(
                      Icons.photo_library_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Chọn từ thư viện',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.35),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Gap(40),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.amber.shade300),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
