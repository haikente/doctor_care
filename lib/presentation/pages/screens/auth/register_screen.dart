// import 'package:doctor_care/core/images/images.dart';
import 'package:doctor_care/core/localization/app_localizations.dart';
import 'package:doctor_care/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_onInputChanged);
    _emailController.addListener(_onInputChanged);
    _passwordController.addListener(_onInputChanged);
    _confirmPasswordController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    if (mounted) setState(() {});
  }

  bool get _isFormValid {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return fullName.isNotEmpty &&
      emailRegex.hasMatch(email) &&
        password.length >= 6 &&
        confirmPassword == password &&
        _agreeToTerms;
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_onInputChanged);
    _emailController.removeListener(_onInputChanged);
    _passwordController.removeListener(_onInputChanged);
    _confirmPasswordController.removeListener(_onInputChanged);
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      body: Stack(
        children: [
          // Positioned.fill(
          //   child: Image.asset(
          //     Images.login,
          //     fit: BoxFit.cover,
          //   ),
          // ),
        BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              setState(() {
                _errorMessage = null;
              });
              Navigator.pushReplacementNamed(context, '/navigation');
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
        
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.05),
                    theme.colorScheme.secondary.withOpacity(0.05),
                  ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Gap(10),
                          // Header
                          Column(
                            children: [
                              const Gap(10),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  l10n.translate('register_title'),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const Gap(4),
                              Text(
                                l10n.translate('register_subtitle'),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(
                                    0.6,
                                  ),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
        
                          const Gap(30),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Full Name Field
                                TextFormField(
                                  style: TextStyle(
                                      color: Color(0xFF333333),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14
                                    ),
                                  controller: _fullNameController,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    labelText: l10n.translate('full_name'),
                                    labelStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    // prefixIcon: Icon(
                                    //   Icons.person_outline,
                                    //   color: theme.colorScheme.primary,
                                    // ),
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
                                    if (value == null || value.trim().isEmpty) {
                                      return l10n.translate(
                                        'please_enter_full_name',
                                      );
                                    }
                                    return null;
                                  },
                                ),
        
                                const Gap(20),
        
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
                                    // prefixIcon: Icon(
                                    //   Icons.email_outlined,
                                    //   color: theme.colorScheme.primary,
                                    // ),
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
                                      return l10n.translate('please_enter_email');
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
                                          _obscurePassword = !_obscurePassword;
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
        
                                const Gap(20),
        
                                // Confirm Password Field
                                TextFormField(
                                  style: TextStyle(
                                      color: Color(0xFF333333),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14
                                    ),
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  decoration: InputDecoration(
                                    labelText: l10n.translate('confirm_password'),
                                    labelStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    // prefixIcon: Icon(
                                    //   Icons.lock_reset_outlined,
                                    //   color: theme.colorScheme.primary,
                                    // ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.5),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
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
                                        'please_enter_confirm_password',
                                      );
                                    }
                                    if (value != _passwordController.text) {
                                      return l10n.translate('password_not_match');
                                    }
                                    return null;
                                  },
                                ),
        
                                const Gap(24),
        
                                // Password Requirements
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer
                                        .withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.2),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: 18,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const Gap(8),
                                          Text(
                                            l10n.translate(
                                              'password_requirements',
                                            ),
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const Gap(8),
                                      _buildRequirementItem(
                                        theme,
                                        l10n.translate('req_valid_email'),
                                        _emailController.text.isNotEmpty &&
                                            RegExp(
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                            ).hasMatch(_emailController.text),
                                      ),
                                      const Gap(4),
                                      _buildRequirementItem(
                                        theme,
                                        l10n.translate('req_password_min'),
                                        _passwordController.text.length >= 6,
                                      ),
                                      const Gap(4),
                                      _buildRequirementItem(
                                        theme,
                                        l10n.translate('req_password_match'),
                                        _confirmPasswordController
                                                .text
                                                .isNotEmpty &&
                                            _confirmPasswordController.text ==
                                                _passwordController.text,
                                      ),
                                    ],
                                  ),
                                ),
        
                                const Gap(20),
        
                                // Terms Checkbox
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _agreeToTerms = !_agreeToTerms;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Checkbox(
                                            value: _agreeToTerms,
                                            onChanged: (value) {
                                              setState(() {
                                                _agreeToTerms = value ?? false;
                                              });
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                4,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Gap(12),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              text: l10n.translate('agree_to'),
                                              style: theme.textTheme.bodyMedium,
                                              children: [
                                                TextSpan(
                                                  text: l10n.translate(
                                                    'terms_of_use',
                                                  ),
                                                  style: TextStyle(
                                                    color:
                                                        theme.colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                    decoration:
                                                        TextDecoration.underline,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      ' ${l10n.translate('and')} ',
                                                ),
                                                TextSpan(
                                                  text: l10n.translate(
                                                    'privacy_policy',
                                                  ),
                                                  style: TextStyle(
                                                    color:
                                                        theme.colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                    decoration:
                                                        TextDecoration.underline,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                                l10n.translate('register_failed'),
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
        
                                const Gap(20),
        
                                // Register Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _isFormValid
                                        ? () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              context.read<AuthBloc>().add(
                                                SignUpEvent(
                                                  _fullNameController.text.trim(),
                                                  _emailController.text.trim(),
                                                  _passwordController.text.trim(),
                                                ),
                                              );
                                            }
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: theme
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      l10n.translate('register_btn'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
        
                          const Gap(10),
        
                          // Login Link
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: l10n.translate('have_account'),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: l10n.translate('login_title'),
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
        
                          const Gap(10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
       ]
      ),
    );
  }

  Widget _buildRequirementItem(ThemeData theme, String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isMet
              ? Colors.green
              : theme.colorScheme.onSurface.withOpacity(0.4),
        ),
        const Gap(8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isMet
                  ? Colors.green.shade700
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
