import 'package:doctor_care/core/images/images.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/core/services/auth_storage_service.dart';
import 'package:doctor_care/core/services/biometric_service.dart';
import 'package:doctor_care/presentation/bloc/auth/auth_bloc.dart';
import 'package:doctor_care/presentation/bloc/locale/locale_cubit.dart';
import 'package:doctor_care/presentation/bloc/locale/locale_state.dart';
import 'package:doctor_care/presentation/pages/screens/auth/register_screen.dart';
import 'package:doctor_care/presentation/pages/screens/auth/forgot_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final BiometricService _biometricService = BiometricService();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _canUseBiometrics = false;
  bool _isBiometricAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onInputChanged);
    _passwordController.addListener(_onInputChanged);
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final rememberMe = await AuthStorageService.getRememberMe();
    final savedEmail = await AuthStorageService.getSavedEmail();
    final canUseBiometrics = await _biometricService.canUseBiometric();

    if (mounted) {
      setState(() {
        _rememberMe = rememberMe;
        _canUseBiometrics = canUseBiometrics;
        if (savedEmail != null) {
          _emailController.text = savedEmail;
        }
      });
    }

    await AuthStorageService.debugPrint();
  }

  Future<void> _handleBiometricLogin() async {
    if (_isBiometricAuthenticating) return;

    setState(() {
      _isBiometricAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final typedEmail = _emailController.text.trim();
      final savedEmail = await AuthStorageService.getSavedEmail();
      final savedPassword = await AuthStorageService.getSavedPassword();
      final hasSavedSession = await AuthStorageService.hasValidSession();
      final currentUser = FirebaseAuth.instance.currentUser;

      if (savedEmail == null ||
          savedPassword == null ||
          savedPassword.isEmpty) {
        if (!mounted) return;
        setState(() {
          _errorMessage =
              'Không tìm thấy thông tin ghi nhớ. Vui lòng đăng nhập bằng email và mật khẩu.';
        });
        return;
      }

      if (typedEmail.isNotEmpty &&
          typedEmail.toLowerCase() != savedEmail.toLowerCase()) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Email không khớp với tài khoản đã ghi nhớ.';
        });
        return;
      }

      final authenticated = await _biometricService.authenticate();
      if (!mounted) return;

      if (authenticated) {
        if (currentUser != null && hasSavedSession) {
          context.read<AuthBloc>().add(CheckAuthStatusEvent());
        } else {
          _emailController.text = savedEmail;
          context.read<AuthBloc>().add(SignInEvent(savedEmail, savedPassword));
        }
      } else {
        setState(() {
          _errorMessage = 'Xác thực vân tay không thành công.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBiometricAuthenticating = false;
        });
      }
    }
  }

  void _onInputChanged() {
    setState(() {
      if (mounted) {}
    });
  }

  bool get _isFormValid {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email) && password.length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      body: Stack(
        children: [
          // Positioned.fill(
          //   child: Image.asset(Images.register, fit: BoxFit.cover),
          // ),
          BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) async {
              if (state is Authenticated) {
                final email = state.user.email.isNotEmpty
                    ? state.user.email
                    : _emailController.text.trim();
                await AuthStorageService.saveLoginSession(
                  odLoginUser: state.user.uid,
                  email: email,
                  role: state.role,
                  rememberMe: _rememberMe,
                  password: _passwordController.text.trim(),
                );

                if (!context.mounted) return;

                setState(() {
                  _errorMessage = null;
                });

                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              } else if (state is AuthError) {
                setState(() {
                  _errorMessage = state.message;
                });

                Future.delayed(const Duration(seconds: 8), () {
                  if (mounted && _errorMessage == state.message) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                });
              } else if (state is AuthLoading) {
                setState(() {
                  _errorMessage = null;
                });
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.1),
                        theme.colorScheme.secondary.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              return SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: Image.asset(
                                        'assets/images/logo_app.png',
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Gap(12),
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                            colors: [
                                              theme.colorScheme.primary,
                                              theme.colorScheme.secondary,
                                            ],
                                          ).createShader(bounds),
                                      child: const Text(
                                        "HealthCare+",
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 2,
                                          shadows: [
                                            Shadow(
                                              color: Colors.white10,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Gap(25),
                               Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.translate('login_title'),
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold,
                                         fontSize: 20,
                                         letterSpacing: 1
                                         ),
                                  ),
                                  const Gap(18),

                                  // Email Field
                                  TextFormField(
                                    style: TextStyle(
                                      color: Color(0xFF333333),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14
                                    ),
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: l10n.translate('email'),
                                      labelStyle: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: theme.colorScheme.outline
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: theme.colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: theme.colorScheme.surface,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return l10n.translate(
                                          'please_enter_email',
                                        );
                                      }
                                      final emailRegex = RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                      );
                                      if (!emailRegex.hasMatch(value)) {
                                        return l10n.translate(
                                          'invalid_email_format',
                                        );
                                      }
                                      return null;
                                    },
                                  ),

                                  const Gap(20),
                                  // Password Field
                                  TextFormField(
                                    style: TextStyle(
                                      color: Color(0xFF333333),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14
                                    ),
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: l10n.translate('password'),
                                      labelStyle: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                      // prefixIcon: Icon(
                                      //   Icons.lock_outline,
                                      //   color: theme.colorScheme.primary,
                                      // ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.5),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: theme.colorScheme.outline
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: theme.colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: theme.colorScheme.surface,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return l10n.translate(
                                          'please_enter_password',
                                        );
                                      }
                                      if (value.length < 6) {
                                        return l10n.translate('password_min_6');
                                      }
                                      return null;
                                    },
                                  ),

                                  const Gap(16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              onChanged: (value) async {
                                                final next = value ?? false;
                                                setState(() {
                                                  _rememberMe = next;
                                                });

                                                if (!next) {
                                                  await AuthStorageService.clearRememberMe();
                                                } else {
                                                  await AuthStorageService.saveRememberMe(
                                                    true,
                                                    _emailController.text.trim(),
                                                    _passwordController.text.trim(),    
                                                  );
                                                }
                                              },
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                          const Gap(8),
                                          Text(
                                            l10n.translate('remember_me'),
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ForgotPasswordScreen(),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              theme.colorScheme.primary,
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          l10n.translate('forgot_password'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const Gap(16),

                                  // Error Message Display
                                  if (_errorMessage != null)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        border: Border.all(
                                          color: Colors.red.shade200,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.red.shade700,
                                            size: 24,
                                          ),
                                          const Gap(12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  l10n.translate(
                                                    'login_failed',
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.red.shade900,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const Gap(4),
                                                Text(
                                                  _errorMessage!,
                                                  style: TextStyle(
                                                    color: Colors.red.shade800,
                                                    fontSize: 14,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.red.shade700,
                                              size: 20,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              setState(() {
                                                _errorMessage = null;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),

                                  const Gap(24),

                                  // Login actions
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 56,
                                          child: ElevatedButton(
                                            onPressed: _isFormValid
                                                ? () {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      context
                                                          .read<AuthBloc>()
                                                          .add(
                                                            SignInEvent(
                                                              _emailController
                                                                  .text
                                                                  .trim(),
                                                              _passwordController
                                                                  .text
                                                                  .trim(),
                                                            ),
                                                          );
                                                    }
                                                  }
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  theme.colorScheme.primary,
                                              foregroundColor: Colors.white,
                                              disabledBackgroundColor: theme
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.5),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              elevation: 0,
                                              shadowColor: theme
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.3),
                                            ),
                                            child: Text(
                                              l10n.translate('login_btn'),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (_canUseBiometrics) ...[
                                        const Gap(12),
                                        SizedBox(
                                          width: 56,
                                          height: 56,
                                          child: Tooltip(
                                            message: 'Đăng nhập bằng vân tay',
                                            child: OutlinedButton(
                                              onPressed:
                                                  _isBiometricAuthenticating
                                                  ? null
                                                  : _handleBiometricLogin,
                                              style: OutlinedButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                side: BorderSide(
                                                  color: theme
                                                      .colorScheme
                                                      .primary
                                                      .withOpacity(0.5),
                                                  width: 1.5,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                backgroundColor:
                                                    theme.cardColor,
                                              ),
                                              child: _isBiometricAuthenticating
                                                  ? SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: theme
                                                                .colorScheme
                                                                .primary,
                                                          ),
                                                    )
                                                  : Icon(
                                                      Icons.fingerprint_rounded,
                                                      color: theme
                                                          .colorScheme
                                                          .primary,
                                                      size: 28,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),

                                  const Gap(24),

                                  // Divider
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: theme.colorScheme.outline
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          l10n.translate('or'),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.5),
                                              ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: theme.colorScheme.outline
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const Gap(24),

                                  // Google Sign In Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: OutlinedButton(
                                      onPressed: state is AuthLoading
                                          ? null
                                          : () {
                                              context.read<AuthBloc>().add(
                                                SignInWithGoogleEvent(),
                                              );
                                            },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: theme.colorScheme.outline
                                              .withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        backgroundColor: theme.cardColor,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            Images.googleLogo,
                                            height: 24,
                                            width: 24,
                                          ),
                                          const Gap(12),
                                          Text(
                                            l10n.translate('login_with_google'),
                                            style: TextStyle(
                                              fontSize: 15,
                                              color:
                                                  theme.colorScheme.onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            

                            // Register Link
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    text: l10n.translate('no_account'),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: l10n.translate('register'),
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),    
              );
            },
          ),
          _buildLanguageSelector(context, theme),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, ThemeData theme) {
    final l10n = context.l10n;

    return Positioned(
      top: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 12, right: 16),
          child: BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              final localeCubit = context.read<LocaleCubit>();
              final languageCode = localeState.locale.languageCode
                  .toString()
                  .toUpperCase();

              return PopupMenuButton<String>(
                tooltip: l10n.translate('language'),
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: theme.colorScheme.surface,
                onSelected: (value) {
                  localeCubit.changeLocale(Locale(value));
                },
                itemBuilder: (context) => [
                  _buildLanguageMenuItem(
                    context: context,
                    value: 'vi',
                    label: l10n.translate('language_vi'),
                    isSelected: localeCubit.isVietnamese,
                  ),
                  _buildLanguageMenuItem(
                    context: context,
                    value: 'en',
                    label: l10n.translate('language_en'),
                    isSelected: localeCubit.isEnglish,
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.translate_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const Gap(6),
                      Text(
                        languageCode,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(2),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildLanguageMenuItem({
    required BuildContext context,
    required String value,
    required String label,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: isSelected
                ? Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  )
                : null,
          ),
          const Gap(8),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.removeListener(_onInputChanged);
    _passwordController.removeListener(_onInputChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
