import 'dart:io';
import 'dart:ui';
import 'package:doctor_care/core/images/images.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_bloc.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_event.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_state.dart';
import 'package:doctor_care/presentation/pages/screens/meal_analysis/meal_analysis_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class MealCaptureScreen extends StatefulWidget {
  const MealCaptureScreen({super.key});

  @override
  State<MealCaptureScreen> createState() => _MealCaptureScreenState();
}

class _MealCaptureScreenState extends State<MealCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;

  Future<void> _pickImageFromCamera() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  void _analyzeImage(String imagePath) {
    context.read<MealAnalysisBloc>().add(AnalyzeMealImageEvent(imagePath));
  }

  void _continueWithSelectedImage() {
    final imagePath = _imagePath;
    if (imagePath == null) return;
    _analyzeImage(imagePath);
  }

  void _showInvalidImageDialog(String reason) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _InvalidImageDialog(
          reason: reason,
          onRetakeCamera: () {
            Navigator.pop(dialogContext);
            setState(() {
              _imagePath = null;
            });
            _pickImageFromCamera();
          },
          onPickGallery: () {
            Navigator.pop(dialogContext);
            setState(() {
              _imagePath = null;
            });
            _pickImageFromGallery();
          },
          onCancel: () {
            Navigator.pop(dialogContext);
            setState(() {
              _imagePath = null;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset(Images.aifood, fit: BoxFit.cover)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.08),
                    Colors.black.withOpacity(0.72),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _TopBar(onBack: () => Navigator.pop(context)),
            ),
          ),
          BlocConsumer<MealAnalysisBloc, MealAnalysisState>(
            listener: (context, state) {
              if (state is MealAnalysisSuccess) {
                final imagePath = _imagePath;
                if (imagePath == null) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MealAnalysisResultScreen(
                      mealAnalysis: state.mealAnalysis,
                      imagePath: imagePath,
                    ),
                  ),
                );
              } else if (state is MealAnalysisInvalidImage) {
                _showInvalidImageDialog(state.reason);
              } else if (state is MealAnalysisError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.tr(
                        'error_with_message',
                        params: {'message': state.message},
                      ),
                    ),
                    backgroundColor: Colors.red.shade700,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is MealAnalysisLoading) {
                return _LoadingView(imagePath: _imagePath);
              }

              if (_imagePath != null) {
                return _PreviewView(
                  imagePath: _imagePath!,
                  onContinue: _continueWithSelectedImage,
                  onRetake: _pickImageFromCamera,
                );
              }

              return _CaptureView(
                onCamera: _pickImageFromCamera,
                onGallery: _pickImageFromGallery,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _GlassIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: onBack,
        ),
        const Spacer(),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.22),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: Colors.amber.shade300,
                  ),
                  const Gap(6),
                  const Text(
                    'AI Nutrition',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewView extends StatelessWidget {
  const _PreviewView({
    required this.imagePath,
    required this.onContinue,
    required this.onRetake,
  });

  final String imagePath;
  final VoidCallback onContinue;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 76, 20, 20),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.30),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(imagePath),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Gap(18),
            _PreviewActionPanel(onContinue: onContinue, onRetake: onRetake),
          ],
        ),
      ),
    );
  }
}

class _PreviewActionPanel extends StatelessWidget {
  const _PreviewActionPanel({required this.onContinue, required this.onRetake});

  final VoidCallback onContinue;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.20)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: onRetake,
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Chụp lại'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.5)),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(10),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: onContinue,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Tiếp tục'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF145C9E),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaptureView extends StatelessWidget {
  const _CaptureView({required this.onCamera, required this.onGallery});

  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 76, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            const Text(
              'Phân tích bữa ăn',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
            const Gap(10),
            Text(
              'Chụp hoặc chọn ảnh món ăn để AI ước tính calo, macro và chỉ số dinh dưỡng.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.82),
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Gap(18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _FeaturePill(icon: Icons.bolt_rounded, label: 'Nhanh'),
                _FeaturePill(
                  icon: Icons.pie_chart_rounded,
                  label: 'Calo & macro',
                ),
                _FeaturePill(
                  icon: Icons.health_and_safety_rounded,
                  label: 'Gợi ý sức khỏe',
                ),
              ],
            ),
            const Gap(28),
            _ActionPanel(onCamera: onCamera, onGallery: onGallery),
          ],
        ),
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({required this.onCamera, required this.onGallery});

  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.20)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: onCamera,
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Chụp ảnh'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF145C9E),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(10),
              SizedBox(
                width: 56,
                height: 56,
                child: Tooltip(
                  message: 'Chọn từ thư viện',
                  child: OutlinedButton(
                    onPressed: onGallery,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Icon(Icons.photo_library_rounded, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.32),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (imagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(
                          File(imagePath!),
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Gap(22),
                    ],
                    const SizedBox(
                      width: 42,
                      height: 42,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.5,
                        color: Colors.white,
                      ),
                    ),
                    const Gap(18),
                    const Text(
                      'Đang phân tích bữa ăn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'AI đang nhận diện món ăn và tính dinh dưỡng',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.13),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const Gap(6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Tooltip(
          message: tooltip,
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon),
            color: Colors.white,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.white.withOpacity(0.18)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InvalidImageDialog extends StatelessWidget {
  const _InvalidImageDialog({
    required this.reason,
    required this.onRetakeCamera,
    required this.onPickGallery,
    required this.onCancel,
  });

  final String reason;
  final VoidCallback onRetakeCamera;
  final VoidCallback onPickGallery;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notification_important_outlined,
              color: Colors.blue,
              size: 70,
            ),
          ),
          const Gap(25),
          Text(
            context.tr('invalid_image_title'),
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const Gap(12),
          Text(
            reason,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
          const Gap(8),
          Text(
            context.tr('invalid_image_hint'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          const Gap(20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: context.tr('invalid_image_retake'),
                  onPressed: onRetakeCamera,
                  gradient: [Colors.blue.shade50, Colors.blue.shade50],
                  textColor: Colors.blue,
                ),
              ),
              const Gap(10),
              Expanded(
                child: CustomButton(
                  text: context.tr('invalid_image_pick_gallery'),
                  onPressed: onPickGallery,
                ),
              ),
            ],
          ),
          const Gap(8),
          TextButton(
            onPressed: onCancel,
            child: Text(
              context.tr('cancel'),
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
